const { pool } = require("../config")

// Helper function to convert snake_case database columns to camelCase
const toCamelCase = (dbObj) => {
    if (!dbObj) return null

    const newObj = {}
    for (const key in dbObj) {
        if (Object.prototype.hasOwnProperty.call(dbObj, key)) {
            const newKey = key.replace(/_([a-z])/g, (_, letter) =>
                letter.toUpperCase()
            )
            newObj[newKey] = dbObj[key]
        }
    }
    return newObj
}

// Record a new price for a product at a store location
const recordPrice = async (priceData) => {
    const {
        productId,
        storeLocationId,
        price,
        salePrice,
        saleEnds,
        currency,
        userId,
    } = priceData

    try {
        const result = await pool.query(
            `INSERT INTO product_prices 
       (product_id, store_location_id, price, sale_price, sale_ends, currency, reported_by, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW()) 
       RETURNING *`,
            [
                productId,
                storeLocationId,
                price,
                salePrice,
                saleEnds,
                currency || "USD",
                userId,
            ]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error recording price:", error)
        throw error
    }
}

// Get price history for a product at a specific store location
const getPriceHistory = async (productId, storeLocationId) => {
    try {
        const result = await pool.query(
            `SELECT * FROM product_prices 
       WHERE product_id = $1 AND store_location_id = $2 
       ORDER BY created_at DESC`,
            [productId, storeLocationId]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting price history:", error)
        throw error
    }
}

// Get latest prices for a product across all store locations
const getLatestPricesForProduct = async (productId) => {
    try {
        const result = await pool.query(
            `SELECT pp.*, sl.address, sl.city, sl.state, s.name as store_name, s.logo_url as store_logo
       FROM (
         SELECT DISTINCT ON (store_location_id) id, product_id, store_location_id, price, sale_price, sale_ends, currency, reported_by, created_at
         FROM product_prices
         WHERE product_id = $1
         ORDER BY store_location_id, created_at DESC
       ) pp
       JOIN store_locations sl ON pp.store_location_id = sl.id
       JOIN stores s ON sl.store_id = s.id
       ORDER BY COALESCE(pp.sale_price, pp.price) ASC`,
            [productId]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting latest prices for product:", error)
        throw error
    }
}

// Get best price for a product within a geographic area
const getBestPriceForProduct = async (
    productId,
    latitude,
    longitude,
    radiusInKm = 10
) => {
    try {
        const result = await pool.query(
            `SELECT pp.*, sl.address, sl.city, sl.state, s.name as store_name, s.logo_url as store_logo,
        (6371 * acos(cos(radians($2)) * cos(radians(sl.latitude)) * cos(radians(sl.longitude) - radians($3)) + sin(radians($2)) * sin(radians(sl.latitude)))) AS distance
       FROM (
         SELECT DISTINCT ON (store_location_id) id, product_id, store_location_id, price, sale_price, sale_ends, currency, reported_by, created_at
         FROM product_prices
         WHERE product_id = $1
         ORDER BY store_location_id, created_at DESC
       ) pp
       JOIN store_locations sl ON pp.store_location_id = sl.id
       JOIN stores s ON sl.store_id = s.id
       WHERE (6371 * acos(cos(radians($2)) * cos(radians(sl.latitude)) * cos(radians(sl.longitude) - radians($3)) + sin(radians($2)) * sin(radians(sl.latitude)))) < $4
       ORDER BY COALESCE(pp.sale_price, pp.price) ASC
       LIMIT 1`,
            [productId, latitude, longitude, radiusInKm]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error getting best price for product:", error)
        throw error
    }
}

// Get prices for a shopping list optimized for best overall price
const getPricesForShoppingList = async (
    listId,
    latitude,
    longitude,
    radiusInKm = 10
) => {
    try {
        // First, get all items in the shopping list
        const listItemsResult = await pool.query(
            "SELECT * FROM shopping_list_items WHERE list_id = $1",
            [listId]
        )

        if (listItemsResult.rows.length === 0) {
            return {
                items: [],
                stores: [],
                totalPrice: 0,
            }
        }

        const listItems = listItemsResult.rows.map(toCamelCase)
        const productIds = listItems.map((item) => item.productId)

        // Get the latest prices for all products in the list at nearby stores
        const pricesResult = await pool.query(
            `WITH latest_prices AS (
         SELECT DISTINCT ON (product_id, store_location_id) 
           pp.id, pp.product_id, pp.store_location_id, pp.price, pp.sale_price, pp.currency,
           COALESCE(pp.sale_price, pp.price) as effective_price
         FROM product_prices pp
         WHERE pp.product_id = ANY($1::uuid[])
         ORDER BY pp.product_id, pp.store_location_id, pp.created_at DESC
       ),
       nearby_stores AS (
         SELECT sl.id, sl.store_id, sl.address, sl.city, sl.state,
           s.name as store_name, s.logo_url as store_logo,
           (6371 * acos(cos(radians($2)) * cos(radians(sl.latitude)) * cos(radians(sl.longitude) - radians($3)) + sin(radians($2)) * sin(radians(sl.latitude)))) AS distance
         FROM store_locations sl
         JOIN stores s ON sl.store_id = s.id
         WHERE (6371 * acos(cos(radians($2)) * cos(radians(sl.latitude)) * cos(radians(sl.longitude) - radians($3)) + sin(radians($2)) * sin(radians(sl.latitude)))) < $4
       )
       SELECT lp.*, p.name as product_name, ns.store_name, ns.store_logo, ns.address, ns.city, ns.state, ns.distance
       FROM latest_prices lp
       JOIN products p ON lp.product_id = p.id
       JOIN nearby_stores ns ON lp.store_location_id = ns.id
       ORDER BY lp.product_id, lp.effective_price ASC`,
            [productIds, latitude, longitude, radiusInKm]
        )

        // Group prices by store to calculate total costs
        const pricesByStore = {}
        const productPrices = {}

        pricesResult.rows.forEach((row) => {
            const price = toCamelCase(row)
            const storeId = price.storeLocationId
            const productId = price.productId

            if (!pricesByStore[storeId]) {
                pricesByStore[storeId] = {
                    storeLocationId: storeId,
                    storeName: price.storeName,
                    storeLogo: price.storeLogo,
                    address: price.address,
                    city: price.city,
                    state: price.state,
                    distance: price.distance,
                    items: [],
                    totalPrice: 0,
                    missingItems: [],
                }
            }

            // Find the quantity from the shopping list
            const listItem = listItems.find(
                (item) => item.productId === productId
            )
            const quantity = listItem ? listItem.quantity : 1

            const effectivePrice = price.salePrice || price.price
            const totalItemPrice = effectivePrice * quantity

            pricesByStore[storeId].items.push({
                productId,
                productName: price.productName,
                price: effectivePrice,
                salePrice: price.salePrice,
                quantity,
                totalPrice: totalItemPrice,
            })

            pricesByStore[storeId].totalPrice += totalItemPrice

            // Track best price for each product
            if (
                !productPrices[productId] ||
                effectivePrice < productPrices[productId].price
            ) {
                productPrices[productId] = {
                    price: effectivePrice,
                    storeLocationId: storeId,
                }
            }
        })

        // Calculate missing items for each store
        Object.keys(pricesByStore).forEach((storeId) => {
            const store = pricesByStore[storeId]
            productIds.forEach((productId) => {
                if (!store.items.find((item) => item.productId === productId)) {
                    const listItem = listItems.find(
                        (item) => item.productId === productId
                    )
                    store.missingItems.push({
                        productId,
                        quantity: listItem ? listItem.quantity : 1,
                    })
                }
            })
        })

        // Convert to array and sort by total price
        const storesArray = Object.values(pricesByStore).sort(
            (a, b) => a.totalPrice - b.totalPrice
        )

        // Calculate best store distribution (lowest total price)
        const bestDistribution = {
            items: [],
            stores: [],
            totalPrice: 0,
        }

        // Add all items with their best price store
        productIds.forEach((productId) => {
            if (productPrices[productId]) {
                const bestPrice = productPrices[productId]
                const storeInfo = pricesByStore[bestPrice.storeLocationId]
                const item = storeInfo.items.find(
                    (item) => item.productId === productId
                )

                bestDistribution.items.push({
                    productId,
                    productName: item.productName,
                    price: bestPrice.price,
                    quantity: item.quantity,
                    totalPrice: bestPrice.price * item.quantity,
                    storeLocationId: bestPrice.storeLocationId,
                    storeName: storeInfo.storeName,
                })

                // Add store if not already in the list
                if (
                    !bestDistribution.stores.find(
                        (s) => s.storeLocationId === bestPrice.storeLocationId
                    )
                ) {
                    bestDistribution.stores.push({
                        storeLocationId: bestPrice.storeLocationId,
                        storeName: storeInfo.storeName,
                        storeLogo: storeInfo.storeLogo,
                        address: storeInfo.address,
                        city: storeInfo.city,
                        state: storeInfo.state,
                        distance: storeInfo.distance,
                    })
                }

                bestDistribution.totalPrice += bestPrice.price * item.quantity
            }
        })

        return {
            byStore: storesArray,
            bestPrice: bestDistribution,
        }
    } catch (error) {
        console.error("Error getting prices for shopping list:", error)
        throw error
    }
}

// Update a price record
const updatePrice = async (priceId, priceData) => {
    const { price, salePrice, saleEnds } = priceData

    try {
        const result = await pool.query(
            `UPDATE product_prices 
       SET price = $1, 
           sale_price = $2, 
           sale_ends = $3, 
           updated_at = NOW() 
       WHERE id = $4 
       RETURNING *`,
            [price, salePrice, saleEnds, priceId]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error updating price:", error)
        throw error
    }
}

// Delete a price record
const deletePrice = async (priceId) => {
    try {
        const result = await pool.query(
            "DELETE FROM product_prices WHERE id = $1 RETURNING *",
            [priceId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error deleting price:", error)
        throw error
    }
}

module.exports = {
    recordPrice,
    getPriceHistory,
    getLatestPricesForProduct,
    getBestPriceForProduct,
    getPricesForShoppingList,
    updatePrice,
    deletePrice,
}

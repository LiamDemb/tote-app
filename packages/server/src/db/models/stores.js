const { pool } = require("../config")
const { transaction } = require("../index")

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

// Create a new store
const createStore = async (storeData) => {
    const { name, description, logoUrl, website } = storeData

    try {
        const result = await pool.query(
            `INSERT INTO stores 
       (name, description, logo_url, website, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, NOW(), NOW()) 
       RETURNING *`,
            [name, description, logoUrl, website]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error creating store:", error)
        throw error
    }
}

// Get a store by ID
const getStoreById = async (storeId) => {
    try {
        const result = await pool.query("SELECT * FROM stores WHERE id = $1", [
            storeId,
        ])

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error getting store by ID:", error)
        throw error
    }
}

// Get all stores
const getAllStores = async () => {
    try {
        const result = await pool.query("SELECT * FROM stores ORDER BY name")

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting all stores:", error)
        throw error
    }
}

// Update a store
const updateStore = async (storeId, storeData) => {
    const { name, description, logoUrl, website } = storeData

    try {
        const result = await pool.query(
            `UPDATE stores 
       SET name = $1, 
           description = $2, 
           logo_url = $3, 
           website = $4, 
           updated_at = NOW() 
       WHERE id = $5 
       RETURNING *`,
            [name, description, logoUrl, website, storeId]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error updating store:", error)
        throw error
    }
}

// Delete a store
const deleteStore = async (storeId) => {
    try {
        const result = await pool.query(
            "DELETE FROM stores WHERE id = $1 RETURNING *",
            [storeId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error deleting store:", error)
        throw error
    }
}

// Add a store location
const addStoreLocation = async (locationData) => {
    const {
        storeId,
        address,
        city,
        state,
        zipCode,
        country,
        latitude,
        longitude,
        phone,
        hours,
    } = locationData

    try {
        const result = await pool.query(
            `INSERT INTO store_locations 
       (store_id, address, city, state, zip_code, country, latitude, longitude, phone, hours, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, NOW(), NOW()) 
       RETURNING *`,
            [
                storeId,
                address,
                city,
                state,
                zipCode,
                country,
                latitude,
                longitude,
                phone,
                hours,
            ]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error adding store location:", error)
        throw error
    }
}

// Get store locations by store ID
const getStoreLocations = async (storeId) => {
    try {
        const result = await pool.query(
            "SELECT * FROM store_locations WHERE store_id = $1",
            [storeId]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting store locations:", error)
        throw error
    }
}

// Get store locations near coordinates (within a certain radius)
const getStoreLocationsNearby = async (
    latitude,
    longitude,
    radiusInKm = 10
) => {
    try {
        // Using the Haversine formula to calculate distance between coordinates
        const result = await pool.query(
            `SELECT sl.*, s.name as store_name, s.logo_url as store_logo,
        (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) AS distance
       FROM store_locations sl
       JOIN stores s ON sl.store_id = s.id
       WHERE (6371 * acos(cos(radians($1)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($1)) * sin(radians(latitude)))) < $3
       ORDER BY distance`,
            [latitude, longitude, radiusInKm]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting nearby store locations:", error)
        throw error
    }
}

// Update a store location
const updateStoreLocation = async (locationId, locationData) => {
    const {
        address,
        city,
        state,
        zipCode,
        country,
        latitude,
        longitude,
        phone,
        hours,
    } = locationData

    try {
        const result = await pool.query(
            `UPDATE store_locations 
       SET address = $1, 
           city = $2, 
           state = $3, 
           zip_code = $4, 
           country = $5, 
           latitude = $6, 
           longitude = $7, 
           phone = $8, 
           hours = $9, 
           updated_at = NOW() 
       WHERE id = $10 
       RETURNING *`,
            [
                address,
                city,
                state,
                zipCode,
                country,
                latitude,
                longitude,
                phone,
                hours,
                locationId,
            ]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error updating store location:", error)
        throw error
    }
}

// Delete a store location
const deleteStoreLocation = async (locationId) => {
    try {
        const result = await pool.query(
            "DELETE FROM store_locations WHERE id = $1 RETURNING *",
            [locationId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error deleting store location:", error)
        throw error
    }
}

// Get a store with all its locations
const getStoreWithLocations = async (storeId) => {
    return transaction(async (client) => {
        try {
            // Get store details
            const storeResult = await client.query(
                "SELECT * FROM stores WHERE id = $1",
                [storeId]
            )

            if (storeResult.rows.length === 0) {
                return null
            }

            const store = toCamelCase(storeResult.rows[0])

            // Get all locations for this store
            const locationsResult = await client.query(
                "SELECT * FROM store_locations WHERE store_id = $1",
                [storeId]
            )

            store.locations = locationsResult.rows.map(toCamelCase)

            return store
        } catch (error) {
            console.error("Error getting store with locations:", error)
            throw error
        }
    })
}

module.exports = {
    createStore,
    getStoreById,
    getAllStores,
    updateStore,
    deleteStore,
    addStoreLocation,
    getStoreLocations,
    getStoreLocationsNearby,
    updateStoreLocation,
    deleteStoreLocation,
    getStoreWithLocations,
}

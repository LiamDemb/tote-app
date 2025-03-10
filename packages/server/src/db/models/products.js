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

// Create a new product
const createProduct = async (productData) => {
    const { name, description, category, barcode, imageUrl, brand } =
        productData

    try {
        const result = await pool.query(
            `INSERT INTO products 
       (name, description, category, barcode, image_url, brand, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW()) 
       RETURNING *`,
            [name, description, category, barcode, imageUrl, brand]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error creating product:", error)
        throw error
    }
}

// Get a product by ID
const getProductById = async (productId) => {
    try {
        const result = await pool.query(
            "SELECT * FROM products WHERE id = $1",
            [productId]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error getting product by ID:", error)
        throw error
    }
}

// Get products by category
const getProductsByCategory = async (category) => {
    try {
        const result = await pool.query(
            "SELECT * FROM products WHERE category = $1 ORDER BY name",
            [category]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting products by category:", error)
        throw error
    }
}

// Search products by name or description
const searchProducts = async (searchTerm) => {
    try {
        console.log(`Executing product search for term: "${searchTerm}"`)

        // Trim and validate search term
        const trimmedTerm = searchTerm.trim()
        if (!trimmedTerm) {
            console.log("Empty search term, returning empty result")
            return []
        }

        const searchPattern = `%${trimmedTerm}%`
        console.log(`Using search pattern: "${searchPattern}"`)

        const result = await pool.query(
            `SELECT * FROM products 
            WHERE name ILIKE $1 
               OR description ILIKE $1 
               OR brand ILIKE $1
            ORDER BY name`,
            [searchPattern]
        )

        console.log(`Search found ${result.rows.length} results`)

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error searching products:", error)
        throw error
    }
}

// Update a product
const updateProduct = async (productId, productData) => {
    // Get the existing product first
    const existingProduct = await getProductById(productId)
    if (!existingProduct) {
        throw new Error("Product not found")
    }

    // Prepare updated data, using existing values for any missing fields
    const updatedData = {
        name: productData.name || existingProduct.name,
        description: productData.description || existingProduct.description,
        category: productData.category || existingProduct.category,
        barcode: productData.barcode || existingProduct.barcode,
        imageUrl: productData.imageUrl || existingProduct.imageUrl,
        brand: productData.brand || existingProduct.brand,
    }

    try {
        const result = await pool.query(
            `UPDATE products 
       SET name = $1, 
           description = $2, 
           category = $3, 
           barcode = $4, 
           image_url = $5, 
           brand = $6, 
           updated_at = NOW() 
       WHERE id = $7 
       RETURNING *`,
            [
                updatedData.name,
                updatedData.description,
                updatedData.category,
                updatedData.barcode,
                updatedData.imageUrl,
                updatedData.brand,
                productId,
            ]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error updating product:", error)
        throw error
    }
}

// Delete a product
const deleteProduct = async (productId) => {
    try {
        const result = await pool.query(
            "DELETE FROM products WHERE id = $1 RETURNING *",
            [productId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error deleting product:", error)
        throw error
    }
}

// Get product by barcode
const getProductByBarcode = async (barcode) => {
    try {
        const result = await pool.query(
            "SELECT * FROM products WHERE barcode = $1",
            [barcode]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error getting product by barcode:", error)
        throw error
    }
}

module.exports = {
    createProduct,
    getProductById,
    getProductsByCategory,
    searchProducts,
    updateProduct,
    deleteProduct,
    getProductByBarcode,
}

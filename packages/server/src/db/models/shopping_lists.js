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

// Create a new shopping list
const createShoppingList = async (listData) => {
    const { userId, name, description } = listData

    try {
        const result = await pool.query(
            `INSERT INTO shopping_lists 
       (user_id, name, description, created_at, updated_at) 
       VALUES ($1, $2, $3, NOW(), NOW()) 
       RETURNING *`,
            [userId, name, description]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error creating shopping list:", error)
        throw error
    }
}

// Get a shopping list by ID
const getShoppingListById = async (listId) => {
    try {
        const result = await pool.query(
            "SELECT * FROM shopping_lists WHERE id = $1",
            [listId]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error getting shopping list by ID:", error)
        throw error
    }
}

// Get all shopping lists for a user
const getShoppingListsByUserId = async (userId) => {
    try {
        const result = await pool.query(
            "SELECT * FROM shopping_lists WHERE user_id = $1 ORDER BY created_at DESC",
            [userId]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting shopping lists by user ID:", error)
        throw error
    }
}

// Update a shopping list
const updateShoppingList = async (listId, listData) => {
    const { name, description } = listData

    try {
        const result = await pool.query(
            `UPDATE shopping_lists 
       SET name = $1, 
           description = $2, 
           updated_at = NOW() 
       WHERE id = $3 
       RETURNING *`,
            [name, description, listId]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error updating shopping list:", error)
        throw error
    }
}

// Delete a shopping list
const deleteShoppingList = async (listId) => {
    // Use transaction to delete list and all its items
    return transaction(async (client) => {
        try {
            // First delete all items in the list
            await client.query(
                "DELETE FROM shopping_list_items WHERE list_id = $1",
                [listId]
            )

            // Then delete the list itself
            const result = await client.query(
                "DELETE FROM shopping_lists WHERE id = $1 RETURNING *",
                [listId]
            )

            return result.rowCount > 0
        } catch (error) {
            console.error("Error deleting shopping list:", error)
            throw error
        }
    })
}

// Add an item to a shopping list
const addItemToList = async (itemData) => {
    const { listId, productId, quantity, notes, isChecked } = itemData

    try {
        const result = await pool.query(
            `INSERT INTO shopping_list_items 
       (list_id, product_id, quantity, notes, is_checked, created_at, updated_at) 
       VALUES ($1, $2, $3, $4, $5, NOW(), NOW()) 
       RETURNING *`,
            [listId, productId, quantity || 1, notes || "", isChecked || false]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error adding item to shopping list:", error)
        throw error
    }
}

// Get all items in a shopping list
const getListItems = async (listId) => {
    try {
        const result = await pool.query(
            `SELECT i.*, p.name as product_name, p.image_url as product_image 
       FROM shopping_list_items i
       JOIN products p ON i.product_id = p.id
       WHERE i.list_id = $1
       ORDER BY i.created_at ASC`,
            [listId]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting shopping list items:", error)
        throw error
    }
}

// Update a shopping list item
const updateListItem = async (itemId, itemData) => {
    const { quantity, notes, isChecked } = itemData

    try {
        const result = await pool.query(
            `UPDATE shopping_list_items 
       SET quantity = $1, 
           notes = $2, 
           is_checked = $3, 
           updated_at = NOW() 
       WHERE id = $4 
       RETURNING *`,
            [quantity, notes, isChecked, itemId]
        )

        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error updating shopping list item:", error)
        throw error
    }
}

// Remove an item from a shopping list
const removeListItem = async (itemId) => {
    try {
        const result = await pool.query(
            "DELETE FROM shopping_list_items WHERE id = $1 RETURNING *",
            [itemId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error removing item from shopping list:", error)
        throw error
    }
}

// Get shopping list with all its items (including product details)
const getShoppingListWithItems = async (listId) => {
    return transaction(async (client) => {
        try {
            // Get list details
            const listResult = await client.query(
                "SELECT * FROM shopping_lists WHERE id = $1",
                [listId]
            )

            if (listResult.rows.length === 0) {
                return null
            }

            const list = toCamelCase(listResult.rows[0])

            // Get all items with product details
            const itemsResult = await client.query(
                `SELECT i.*, p.name as product_name, p.image_url as product_image, p.brand as product_brand 
         FROM shopping_list_items i
         JOIN products p ON i.product_id = p.id
         WHERE i.list_id = $1
         ORDER BY i.created_at ASC`,
                [listId]
            )

            list.items = itemsResult.rows.map(toCamelCase)

            return list
        } catch (error) {
            console.error("Error getting shopping list with items:", error)
            throw error
        }
    })
}

module.exports = {
    createShoppingList,
    getShoppingListById,
    getShoppingListsByUserId,
    updateShoppingList,
    deleteShoppingList,
    addItemToList,
    getListItems,
    updateListItem,
    removeListItem,
    getShoppingListWithItems,
}

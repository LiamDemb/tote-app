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

// Record a new search query
const recordSearch = async (searchData) => {
    const {
        userId,
        query,
        category,
        filters,
        latitude,
        longitude,
        resultCount,
    } = searchData

    try {
        const result = await pool.query(
            `INSERT INTO search_history 
       (user_id, query, category, filters, latitude, longitude, result_count, created_at) 
       VALUES ($1, $2, $3, $4, $5, $6, $7, NOW()) 
       RETURNING *`,
            [userId, query, category, filters, latitude, longitude, resultCount]
        )

        return toCamelCase(result.rows[0])
    } catch (error) {
        console.error("Error recording search:", error)
        throw error
    }
}

// Get search history for a user
const getUserSearchHistory = async (userId, limit = 20) => {
    try {
        const result = await pool.query(
            `SELECT * FROM search_history 
       WHERE user_id = $1 
       ORDER BY created_at DESC 
       LIMIT $2`,
            [userId, limit]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting user search history:", error)
        throw error
    }
}

// Get popular searches
const getPopularSearches = async (days = 7, limit = 10) => {
    try {
        const result = await pool.query(
            `SELECT query, COUNT(*) as search_count
       FROM search_history
       WHERE created_at > NOW() - INTERVAL '${days} days'
       GROUP BY query
       ORDER BY search_count DESC
       LIMIT $1`,
            [limit]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting popular searches:", error)
        throw error
    }
}

// Get popular categories
const getPopularCategories = async (days = 7, limit = 10) => {
    try {
        const result = await pool.query(
            `SELECT category, COUNT(*) as search_count
       FROM search_history
       WHERE created_at > NOW() - INTERVAL '${days} days' AND category IS NOT NULL
       GROUP BY category
       ORDER BY search_count DESC
       LIMIT $1`,
            [limit]
        )

        return result.rows.map(toCamelCase)
    } catch (error) {
        console.error("Error getting popular categories:", error)
        throw error
    }
}

// Delete search history for a user
const deleteUserSearchHistory = async (userId) => {
    try {
        const result = await pool.query(
            "DELETE FROM search_history WHERE user_id = $1 RETURNING *",
            [userId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error deleting user search history:", error)
        throw error
    }
}

// Delete a specific search record
const deleteSearch = async (searchId) => {
    try {
        const result = await pool.query(
            "DELETE FROM search_history WHERE id = $1 RETURNING *",
            [searchId]
        )

        return result.rowCount > 0
    } catch (error) {
        console.error("Error deleting search record:", error)
        throw error
    }
}

// Get search insights for a user (common searches, categories, etc.)
const getUserSearchInsights = async (userId) => {
    try {
        const topQueriesResult = await pool.query(
            `SELECT query, COUNT(*) as search_count
       FROM search_history
       WHERE user_id = $1
       GROUP BY query
       ORDER BY search_count DESC
       LIMIT 5`,
            [userId]
        )

        const topCategoriesResult = await pool.query(
            `SELECT category, COUNT(*) as search_count
       FROM search_history
       WHERE user_id = $1 AND category IS NOT NULL
       GROUP BY category
       ORDER BY search_count DESC
       LIMIT 5`,
            [userId]
        )

        const searchPatternResult = await pool.query(
            `SELECT EXTRACT(DOW FROM created_at) as day_of_week, 
              EXTRACT(HOUR FROM created_at) as hour_of_day,
              COUNT(*) as search_count
       FROM search_history
       WHERE user_id = $1
       GROUP BY day_of_week, hour_of_day
       ORDER BY search_count DESC
       LIMIT 5`,
            [userId]
        )

        return {
            topQueries: topQueriesResult.rows.map(toCamelCase),
            topCategories: topCategoriesResult.rows.map(toCamelCase),
            searchPatterns: searchPatternResult.rows.map(toCamelCase),
        }
    } catch (error) {
        console.error("Error getting user search insights:", error)
        throw error
    }
}

module.exports = {
    recordSearch,
    getUserSearchHistory,
    getPopularSearches,
    getPopularCategories,
    deleteUserSearchHistory,
    deleteSearch,
    getUserSearchInsights,
}

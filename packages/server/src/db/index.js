const { pool, query, testConnection } = require("./config")
const { runMigrations } = require("./migrate")

// Database initialization function
const initDatabase = async () => {
    try {
        // Test connection
        const connected = await testConnection()
        if (!connected) {
            throw new Error("Database connection failed")
        }

        // Run migrations
        await runMigrations()

        return true
    } catch (error) {
        console.error("Database initialization failed:", error)
        return false
    }
}

// Helper function for transactions
const transaction = async (callback) => {
    const client = await pool.connect()
    try {
        await client.query("BEGIN")
        const result = await callback(client)
        await client.query("COMMIT")
        return result
    } catch (e) {
        await client.query("ROLLBACK")
        throw e
    } finally {
        client.release()
    }
}

// Export basic database utilities first (these don't depend on models)
const dbUtils = {
    query,
    pool,
    testConnection,
    initDatabase,
    transaction,
}

// Export the module
module.exports = {
    ...dbUtils,

    // Models are loaded lazily to avoid circular dependencies
    get models() {
        return {
            users: require("./models/users"),
            products: require("./models/products"),
            shoppingLists: require("./models/shopping_lists"),
            stores: require("./models/stores"),
            prices: require("./models/prices"),
            searchHistory: require("./models/search_history"),
        }
    },
}

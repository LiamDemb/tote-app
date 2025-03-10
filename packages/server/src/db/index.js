const { pool, query, transaction, testConnection } = require("./config")
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

        console.log("Database initialization completed successfully")
        return true
    } catch (error) {
        console.error("Database initialization failed:", error)
        // Important: We don't close the pool here - we want to keep it open
        // even if initialization fails, allowing for reconnection attempts
        return false
    }
}

// Graceful shutdown function - should be called when the server is shutting down
const closeDatabase = async () => {
    console.log("Closing database connections...")
    try {
        await pool.end()
        console.log("Database connections closed successfully")
        return true
    } catch (error) {
        console.error("Error closing database connections:", error)
        return false
    }
}

// Export the database module
module.exports = {
    // Expose the pool for direct access when needed
    pool,
    query,
    transaction,
    testConnection,
    initDatabase,
    closeDatabase,
    // Models are still accessible via the models getter
    get models() {
        return {
            users: require("./models/users"),
            products: require("./models/products"),
            stores: require("./models/stores"),
            shoppingLists: require("./models/shopping_lists"),
            // Add other models as needed
        }
    },
}

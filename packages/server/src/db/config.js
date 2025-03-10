const { Pool } = require("pg")
require("dotenv").config()

// Use DATABASE_URL if provided (Render sets this automatically)
// Otherwise, build the connection from individual parameters
let poolConfig = {}

if (process.env.DATABASE_URL) {
    // Use the provided connection string
    poolConfig = {
        connectionString: process.env.DATABASE_URL,
        ssl:
            process.env.NODE_ENV === "production"
                ? { rejectUnauthorized: false }
                : false,
    }
} else {
    // Build from individual parameters
    poolConfig = {
        user: process.env.DB_USER,
        host: process.env.DB_HOST,
        database: process.env.DB_NAME,
        port: process.env.DB_PORT,
    }

    // Only add password if it's provided
    if (process.env.DB_PASSWORD) {
        poolConfig.password = process.env.DB_PASSWORD
    }
}

// Create the pool
const pool = new Pool(poolConfig)

// Generic query function
const query = async (text, params) => {
    try {
        return await pool.query(text, params)
    } catch (err) {
        console.error("Database query error:", err)
        throw err
    }
}

// Transaction helper function
const transaction = async (callback) => {
    const client = await pool.connect()
    try {
        await client.query("BEGIN")
        const result = await callback(client)
        await client.query("COMMIT")
        return result
    } catch (error) {
        await client.query("ROLLBACK")
        throw error
    } finally {
        client.release()
    }
}

// Simple function to test database connection
const testConnection = async () => {
    try {
        const res = await query("SELECT NOW()")
        console.log("Database connection successful:", res.rows[0])
        return true
    } catch (err) {
        console.error("Database connection error:", err)
        return false
    }
}

module.exports = {
    pool,
    query,
    transaction,
    testConnection,
}

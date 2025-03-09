require("dotenv").config()
const express = require("express")
const cors = require("cors")
const morgan = require("morgan")
const { Pool } = require("pg")
const db = require("./db")

// Database connection configuration
const dbConfig = {
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
}

// Only add password if it's provided (to handle empty password case)
if (process.env.DB_PASSWORD) {
    dbConfig.password = process.env.DB_PASSWORD
}

// Create Express app
const app = express()
const port = process.env.PORT || 5000

// Middleware
app.use(
    cors({
        origin: "*", // Allow all origins for development
        methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"],
        allowedHeaders: [
            "Content-Type",
            "Authorization",
            "Accept",
            "Origin",
            "X-Requested-With",
        ],
        credentials: true,
        maxAge: 86400, // Cache preflight requests for 24 hours
    })
)
app.use(express.json())
app.use(express.urlencoded({ extended: true }))
app.use(morgan("dev"))

// Import routes
const dbRoutes = require("./routes/db")
const userRoutes = require("./routes/users")

// Basic route
app.get("/", (req, res) => {
    res.json({ message: "Tote API Server" })
})

// Health check endpoint
app.get("/health", (req, res) => {
    res.status(200).json({ status: "ok", timestamp: new Date().toISOString() })
})

// API routes
app.use("/api/db", dbRoutes)
app.use("/api/users", userRoutes)

// Start server
const startServer = async () => {
    try {
        // Initialize database if needed
        const dbInitialized = await db.initDatabase()
        if (!dbInitialized) {
            console.warn(
                "Database initialization failed. Some features may not work correctly."
            )
        } else {
            console.log("Database connected successfully")
        }

        // Start server
        app.listen(port, () => {
            console.log(`Server running on port ${port}`)
        })
    } catch (error) {
        console.error("Failed to start server:", error)
        process.exit(1)
    }
}

// Handle graceful shutdown
process.on("SIGINT", async () => {
    console.log("Shutting down gracefully")
    try {
        await db.pool.end()
        console.log("Database pool closed")
        process.exit(0)
    } catch (error) {
        console.error("Error during shutdown:", error)
        process.exit(1)
    }
})

// Start the server
startServer()

module.exports = app

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

// Handle preflight requests globally for all routes
app.options("*", cors())

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
        // Initialize database
        const dbInitialized = await db.initDatabase()
        if (!dbInitialized) {
            console.warn(
                "WARNING: Database initialization failed. Server starting anyway."
            )
        }

        // Start the server
        const port = process.env.PORT || 5000
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
        // Use the db module's closeDatabase function instead of directly ending the pool
        await db.closeDatabase()
        console.log("Server shutdown complete")
        process.exit(0)
    } catch (error) {
        console.error("Error during shutdown:", error)
        process.exit(1)
    }
})

// Handle SIGTERM (sent by hosting platforms like Render)
process.on("SIGTERM", async () => {
    console.log("Received SIGTERM signal - shutting down gracefully")
    try {
        await db.closeDatabase()
        console.log("Server shutdown complete")
        process.exit(0)
    } catch (error) {
        console.error("Error during shutdown:", error)
        process.exit(1)
    }
})

// Start the server
startServer()

module.exports = app

const express = require("express")
const cors = require("cors")
const bodyParser = require("body-parser")
const dotenv = require("dotenv")
// Add https and fs modules
const https = require("https")
const http = require("http")
const fs = require("fs")
const path = require("path")
// Use the db module instead of creating a separate pool
const db = require("./src/db")
const { verifyToken } = require("./src/middleware/auth")

// Load environment variables
dotenv.config()

// Initialize Express app
const app = express()
const PORT = process.env.PORT || 5000
const NODE_ENV = process.env.NODE_ENV || "development"
const USE_HTTPS = process.env.USE_HTTPS === "true" || false

// Handle preflight requests globally for all routes
app.options("*", cors())

// CORS Configuration - Properly enable CORS for all requests
app.use(
    cors({
        origin: "*", // Allow all origins
        methods: ["GET", "POST", "PATCH", "PUT", "DELETE", "OPTIONS"],
        allowedHeaders: ["Content-Type", "Authorization", "Accept"],
        credentials: true,
        maxAge: 86400, // Cache preflight requests for 24 hours
    })
)

// Other middleware
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Initialize the database
db.initDatabase()
    .then(() => {
        console.log("Database initialized successfully")
    })
    .catch((err) => {
        console.error("Failed to initialize database:", err)
        // Don't exit the process here - let the server run even if DB init fails
        // This allows you to fix DB issues without restarting the server
    })

// Get the database pool from the db module
const pool = db.pool

// Routes
app.get("/", (req, res) => {
    res.send("Tote API is running")
})

// Protected route example
app.get("/api/user/profile", verifyToken, async (req, res) => {
    try {
        const { rows } = await pool.query("SELECT * FROM users WHERE id = $1", [
            req.user.uid,
        ])

        if (rows.length === 0) {
            return res.status(404).json({ error: "User not found" })
        }

        res.json(rows[0])
    } catch (error) {
        console.error("Error fetching user profile:", error)
        res.status(500).json({ error: "Internal server error" })
    }
})

// Create or update user after authentication
app.post("/api/user/sync", verifyToken, async (req, res) => {
    try {
        const { uid, email, name } = req.user

        const result = await pool.query(
            `
      INSERT INTO users (id, email, display_name)
      VALUES ($1, $2, $3)
      ON CONFLICT (id) DO UPDATE
      SET email = $2, display_name = $3
      RETURNING *
      `,
            [uid, email, name]
        )

        res.json(result.rows[0])
    } catch (error) {
        console.error("Error syncing user:", error)
        res.status(500).json({ error: "Internal server error" })
    }
})

// Auth routes placeholder
app.post("/api/auth/login", (req, res) => {
    // Placeholder for login authentication
    res.json({
        success: true,
        message: "Login successful",
        user: {
            id: "1",
            email: req.body.email,
            name: "Test User",
        },
        token: "placeholder-token",
    })
})

// Setup HTTPS server
const startServer = async () => {
    try {
        // Configuration for HTTPS based on environment
        if (USE_HTTPS) {
            try {
                // Paths to SSL certificate files
                const certPath =
                    process.env.SSL_CERT_PATH ||
                    path.join(__dirname, "ssl", "server.cert")
                const keyPath =
                    process.env.SSL_KEY_PATH ||
                    path.join(__dirname, "ssl", "server.key")

                // Check if certificate files exist
                if (!fs.existsSync(certPath) || !fs.existsSync(keyPath)) {
                    console.error(
                        "SSL certificate or key file not found at specified path"
                    )
                    console.error(`  Certificate path: ${certPath}`)
                    console.error(`  Key path: ${keyPath}`)
                    console.error("Falling back to HTTP server")

                    // Fall back to HTTP if cert files not found
                    startHttpServer()
                    return
                }

                // SSL options
                const httpsOptions = {
                    key: fs.readFileSync(keyPath),
                    cert: fs.readFileSync(certPath),
                    // Modern, secure defaults
                    minVersion: "TLSv1.2",
                    ciphers: [
                        "ECDHE-ECDSA-AES128-GCM-SHA256",
                        "ECDHE-RSA-AES128-GCM-SHA256",
                        "ECDHE-ECDSA-AES256-GCM-SHA384",
                        "ECDHE-RSA-AES256-GCM-SHA384",
                        "ECDHE-ECDSA-CHACHA20-POLY1305",
                        "ECDHE-RSA-CHACHA20-POLY1305",
                    ].join(":"),
                }

                // Create HTTPS server
                https.createServer(httpsOptions, app).listen(PORT, () => {
                    console.log(
                        `🔒 HTTPS Server running on port ${PORT} in ${NODE_ENV} mode`
                    )
                })

                // Optional: Also start HTTP server on a different port that redirects to HTTPS
                if (process.env.REDIRECT_HTTP === "true") {
                    const HTTP_PORT = process.env.HTTP_PORT || 8080
                    const redirectApp = express()

                    // Redirect all HTTP requests to HTTPS
                    redirectApp.use((req, res) => {
                        const httpsUrl = `https://${req.hostname}:${PORT}${req.url}`
                        res.redirect(301, httpsUrl)
                    })

                    http.createServer(redirectApp).listen(HTTP_PORT, () => {
                        console.log(
                            `HTTP Server running on port ${HTTP_PORT} (redirecting to HTTPS)`
                        )
                    })
                }
            } catch (error) {
                console.error("Error setting up HTTPS server:", error)
                // Fall back to HTTP if HTTPS setup fails
                startHttpServer()
            }
        } else {
            // Use HTTP if HTTPS is not explicitly enabled
            startHttpServer()
        }
    } catch (error) {
        console.error("Failed to start server:", error)
        process.exit(1)
    }
}

// Helper function to start HTTP server
const startHttpServer = () => {
    http.createServer(app).listen(PORT, () => {
        console.log(`HTTP Server running on port ${PORT} in ${NODE_ENV} mode`)
        console.log(
            "⚠️ WARNING: Running without HTTPS. This is not secure for production use."
        )
    })
}

// Handle graceful shutdown
process.on("SIGINT", async () => {
    console.log("Received SIGINT signal. Shutting down gracefully...")
    try {
        await db.closeDatabase()
        console.log("Database connections closed")
        process.exit(0)
    } catch (error) {
        console.error("Error during shutdown:", error)
        process.exit(1)
    }
})

// Handle SIGTERM (sent by hosting platforms)
process.on("SIGTERM", async () => {
    console.log("Received SIGTERM signal. Shutting down gracefully...")
    try {
        await db.closeDatabase()
        console.log("Database connections closed")
        process.exit(0)
    } catch (error) {
        console.error("Error during shutdown:", error)
        process.exit(1)
    }
})

// Start the server
startServer()

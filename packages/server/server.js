const express = require("express")
const cors = require("cors")
const bodyParser = require("body-parser")
const dotenv = require("dotenv")
// Use the db module instead of creating a separate pool
const db = require("./src/db")
const { verifyToken } = require("./src/middleware/auth")

// Load environment variables
dotenv.config()

// Initialize Express app
const app = express()
const PORT = process.env.PORT || 5000

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

// Start server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`)
})

const express = require("express")
const cors = require("cors")
const bodyParser = require("body-parser")
const dotenv = require("dotenv")
const { Pool } = require("pg")
const { verifyToken } = require("./src/middleware/auth")

// Load environment variables
dotenv.config()

// Database connection configuration
const dbConfig = {
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT,
}

// Only add password if it's provided
if (process.env.DB_PASSWORD) {
    dbConfig.password = process.env.DB_PASSWORD
}

// Initialize Express app
const app = express()
const PORT = process.env.PORT || 5000

// Middleware
app.use(cors())
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Database connection
const pool = new Pool(dbConfig)

// Test database connection
pool.query("SELECT NOW()", (err, res) => {
    if (err) {
        console.error("Error connecting to the database:", err)
    } else {
        console.log("Database connected successfully")
    }
})

// Create users table if it doesn't exist
pool.query(
    `
  CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  )
`,
    (err, res) => {
        if (err) {
            console.error("Error creating users table:", err)
        } else {
            console.log("Users table ready")
        }
    }
)

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

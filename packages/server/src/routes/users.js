const express = require("express")
const router = express.Router()
const db = require("../db")

/**
 * @route   POST /api/users
 * @desc    Create a new user
 * @access  Public
 */
router.post("/", async (req, res) => {
    try {
        const {
            email,
            firebaseUid,
            firstName,
            lastName,
            authProvider = "email",
        } = req.body

        console.log("POST /api/users - Request received:", {
            email,
            firebaseUid,
            firstName,
            lastName,
            authProvider,
        })

        // Validate required fields
        if (!email || !firebaseUid) {
            console.log(
                "POST /api/users - Validation failed: Missing email or firebaseUid"
            )
            return res
                .status(400)
                .json({ error: "Email and firebaseUid are required" })
        }

        // Check if user already exists with this Firebase UID
        const existingUser = await db.models.users.getUserByFirebaseUid(
            firebaseUid
        )
        if (existingUser) {
            console.log(
                "POST /api/users - User already exists with Firebase UID:",
                firebaseUid
            )
            return res
                .status(409)
                .json({ error: "User already exists with this Firebase UID" })
        }

        // Create user
        const userData = {
            email,
            firebaseUid,
            firstName,
            lastName,
            authProvider,
        }

        console.log("POST /api/users - Creating user with data:", userData)

        const user = await db.models.users.createUser(userData)
        console.log("POST /api/users - User created successfully:", user)

        res.status(201).json(user)
    } catch (error) {
        console.error("POST /api/users - Error creating user:", error)
        res.status(500).json({ error: "Server error", details: error.message })
    }
})

/**
 * @route   GET /api/users/firebase/:firebaseUid
 * @desc    Get user by Firebase UID
 * @access  Public
 */
router.get("/firebase/:firebaseUid", async (req, res) => {
    try {
        const { firebaseUid } = req.params
        console.log(
            "GET /api/users/firebase/:firebaseUid - Request received:",
            { firebaseUid }
        )

        const user = await db.models.users.getUserByFirebaseUid(firebaseUid)

        if (!user) {
            console.log(
                "GET /api/users/firebase/:firebaseUid - User not found:",
                { firebaseUid }
            )
            return res.status(404).json({ error: "User not found" })
        }

        console.log("GET /api/users/firebase/:firebaseUid - User found:", user)
        res.json(user)
    } catch (error) {
        console.error("GET /api/users/firebase/:firebaseUid - Error:", error)
        res.status(500).json({ error: "Server error", details: error.message })
    }
})

/**
 * @route   GET /api/users/:id
 * @desc    Get user by ID
 * @access  Public
 */
router.get("/:id", async (req, res) => {
    try {
        const { id } = req.params

        const user = await db.models.users.getUserById(id)

        if (!user) {
            return res.status(404).json({ error: "User not found" })
        }

        res.json(user)
    } catch (error) {
        console.error("Error getting user by ID:", error)
        res.status(500).json({ error: "Server error" })
    }
})

/**
 * @route   PATCH /api/users/:id
 * @desc    Update user profile
 * @access  Public
 */
router.patch("/:id", async (req, res) => {
    try {
        const { id } = req.params
        const { firstName, lastName, preferences } = req.body

        // Check if user exists
        const existingUser = await db.models.users.getUserById(id)
        if (!existingUser) {
            return res.status(404).json({ error: "User not found" })
        }

        // Update user profile
        const profileData = {
            firstName,
            lastName,
            preferences,
        }

        const updatedUser = await db.models.users.updateUserProfile(
            id,
            profileData
        )

        res.json(updatedUser)
    } catch (error) {
        console.error("Error updating user profile:", error)
        res.status(500).json({ error: "Server error" })
    }
})

/**
 * @route   GET /api/users/test-db
 * @desc    Test database connectivity
 * @access  Public
 */
router.get("/test-db", async (req, res) => {
    try {
        console.log("GET /api/users/test-db - Testing database connectivity")

        // Test database connection
        const testResult = await db.query("SELECT NOW() as time")
        console.log("Database connection test result:", testResult.rows[0])

        // Try to count users
        const userCount = await db.query("SELECT COUNT(*) as count FROM users")
        console.log("User count:", userCount.rows[0])

        // Return success
        res.json({
            success: true,
            message: "Database connection successful",
            time: testResult.rows[0].time,
            userCount: userCount.rows[0].count,
        })
    } catch (error) {
        console.error("GET /api/users/test-db - Error:", error)
        res.status(500).json({
            success: false,
            error: "Database connection failed",
            details: error.message,
        })
    }
})

module.exports = router

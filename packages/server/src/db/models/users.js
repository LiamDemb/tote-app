const { query, transaction } = require("../config")

// Helper to convert snake_case database fields to camelCase for JavaScript
const toCamelCase = (dbObj) => {
    if (!dbObj) return null

    const newObj = {}
    for (const key in dbObj) {
        if (Object.prototype.hasOwnProperty.call(dbObj, key)) {
            const camelKey = key.replace(/_([a-z])/g, (_, letter) =>
                letter.toUpperCase()
            )
            newObj[camelKey] = dbObj[key]
        }
    }
    return newObj
}

/**
 * Create a new user
 * @param {Object} userData User data
 * @returns {Promise<Object>} Created user object
 */
const createUser = async (userData) => {
    const {
        email,
        authProvider = "email",
        firebaseUid,
        firstName,
        lastName,
    } = userData

    console.log("Creating user in database:", {
        email,
        firebaseUid,
        firstName,
        lastName,
    })

    return transaction(async (client) => {
        try {
            // Insert the user
            const userResult = await client.query(
                `INSERT INTO users (email, firebase_uid, first_name, last_name) 
                VALUES ($1, $2, $3, $4) 
                RETURNING id, email, firebase_uid, first_name, last_name, created_at, updated_at`,
                [email, firebaseUid, firstName, lastName]
            )

            console.log("User inserted, result:", userResult.rows[0])
            const user = toCamelCase(userResult.rows[0])
            return user
        } catch (error) {
            console.error("Error in createUser transaction:", error)
            throw error
        }
    })
}

/**
 * Get user by ID
 * @param {string} userId User ID
 * @returns {Promise<Object>} User object with profile data
 */
const getUserById = async (userId) => {
    console.log("Getting user by ID:", userId)

    try {
        const result = await query(
            `SELECT id, email, firebase_uid, first_name, last_name, created_at, updated_at
             FROM users
             WHERE id = $1`,
            [userId]
        )

        console.log("Query result:", result.rows)
        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error in getUserById:", error)
        throw error
    }
}

/**
 * Get user by Firebase UID
 * @param {string} firebaseUid Firebase UID
 * @returns {Promise<Object>} User object with profile data
 */
const getUserByFirebaseUid = async (firebaseUid) => {
    console.log("Getting user by Firebase UID:", firebaseUid)

    try {
        const result = await query(
            `SELECT id, email, firebase_uid, first_name, last_name, created_at, updated_at
             FROM users
             WHERE firebase_uid = $1`,
            [firebaseUid]
        )

        console.log("Query result:", result.rows)
        return result.rows.length ? toCamelCase(result.rows[0]) : null
    } catch (error) {
        console.error("Error in getUserByFirebaseUid:", error)
        throw error
    }
}

/**
 * Update user profile
 * @param {string} userId User ID
 * @param {Object} profileData Profile data to update
 * @returns {Promise<Object>} Updated user object
 */
const updateUserProfile = async (userId, profileData) => {
    const { firstName, lastName } = profileData
    console.log("Updating user profile:", { userId, firstName, lastName })

    return transaction(async (client) => {
        try {
            // Update user
            await client.query(
                `UPDATE users 
                 SET first_name = COALESCE($1, first_name),
                     last_name = COALESCE($2, last_name),
                     updated_at = NOW()
                 WHERE id = $3`,
                [firstName, lastName, userId]
            )

            // Return updated user data
            const result = await client.query(
                `SELECT id, email, firebase_uid, first_name, last_name, created_at, updated_at
                 FROM users
                 WHERE id = $1`,
                [userId]
            )

            console.log("User updated, result:", result.rows[0])
            return result.rows.length ? toCamelCase(result.rows[0]) : null
        } catch (error) {
            console.error("Error in updateUserProfile transaction:", error)
            throw error
        }
    })
}

module.exports = {
    createUser,
    getUserById,
    getUserByFirebaseUid,
    updateUserProfile,
}

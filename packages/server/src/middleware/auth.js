const admin = require("firebase-admin")
const { models } = require("../db")

// Initialize Firebase Admin SDK if not already initialized
if (!admin.apps.length) {
    try {
        // If FIREBASE_SERVICE_ACCOUNT environment variable is a JSON string, parse it
        let credential
        try {
            const serviceAccount = JSON.parse(
                process.env.FIREBASE_SERVICE_ACCOUNT
            )
            credential = admin.credential.cert(serviceAccount)
        } catch (e) {
            // If parsing fails, assume it's a path to a service account file
            credential = admin.credential.applicationDefault()
        }

        admin.initializeApp({
            credential,
        })

        console.log("Firebase Admin SDK initialized")
    } catch (error) {
        console.error("Error initializing Firebase Admin SDK:", error)
    }
}

/**
 * Middleware to authenticate requests using Firebase Auth token
 */
const authenticateFirebaseToken = async (req, res, next) => {
    const authHeader = req.headers.authorization

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return res
            .status(401)
            .json({ error: "Unauthorized: Missing or invalid token format" })
    }

    const idToken = authHeader.split("Bearer ")[1]

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken)
        req.user = {
            uid: decodedToken.uid,
            email: decodedToken.email,
            emailVerified: decodedToken.email_verified,
        }

        // Try to find user in database
        try {
            const user = await models.users.getUserByFirebaseUid(
                decodedToken.uid
            )
            if (user) {
                req.user.id = user.id
                req.user.profile = user
            }
        } catch (dbError) {
            // Log error but continue since Firebase authentication succeeded
            console.error("Error fetching user from database:", dbError)
        }

        next()
    } catch (error) {
        console.error("Error verifying Firebase token:", error)
        res.status(401).json({ error: "Unauthorized: Invalid token" })
    }
}

/**
 * Optional authentication - proceeds even if token is invalid
 */
const optionalAuthentication = async (req, res, next) => {
    const authHeader = req.headers.authorization

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
        return next()
    }

    const idToken = authHeader.split("Bearer ")[1]

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken)
        req.user = {
            uid: decodedToken.uid,
            email: decodedToken.email,
            emailVerified: decodedToken.email_verified,
        }

        // Try to find user in database
        try {
            const user = await models.users.getUserByFirebaseUid(
                decodedToken.uid
            )
            if (user) {
                req.user.id = user.id
                req.user.profile = user
            }
        } catch (dbError) {
            console.error("Error fetching user from database:", dbError)
        }
    } catch (error) {
        // Continue without authenticated user
        console.warn(
            "Invalid token provided but continuing as unauthenticated:",
            error.message
        )
    }

    next()
}

module.exports = {
    authenticateFirebaseToken,
    optionalAuthentication,
}

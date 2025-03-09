const admin = require("firebase-admin")
const dotenv = require("dotenv")
const path = require("path")

dotenv.config()

let serviceAccount
try {
    // First, try to get from environment variable
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)
    }
    // If not found in env, try to load from local file
    else {
        serviceAccount = require(path.join(
            __dirname,
            "../../../firebase-service-account.json"
        ))
    }
} catch (error) {
    console.error("Error loading Firebase credentials:", error.message)
    console.error("Please ensure you have either:")
    console.error("1. Set FIREBASE_SERVICE_ACCOUNT environment variable, or")
    console.error(
        "2. Placed firebase-service-account.json in the server root directory"
    )
    process.exit(1)
}

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL:
        process.env.FIREBASE_DATABASE_URL ||
        `https://${serviceAccount.project_id}.firebaseio.com`,
})

module.exports = admin

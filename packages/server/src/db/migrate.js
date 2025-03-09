require("dotenv").config()
const fs = require("fs")
const path = require("path")
const { pool } = require("./config")

// Function to run a migration file
const runMigration = async (filePath) => {
    const sql = fs.readFileSync(filePath, "utf8")
    console.log(`Running migration: ${path.basename(filePath)}`)

    try {
        // Using a transaction for each migration file
        const client = await pool.connect()
        try {
            await client.query("BEGIN")
            await client.query(sql)
            await client.query("COMMIT")
            console.log(`Migration successful: ${path.basename(filePath)}`)
            return true
        } catch (err) {
            await client.query("ROLLBACK")
            console.error(`Migration failed: ${path.basename(filePath)}`)
            console.error(err)
            return false
        } finally {
            client.release()
        }
    } catch (err) {
        console.error(
            `Failed to connect to database for migration: ${path.basename(
                filePath
            )}`
        )
        console.error(err)
        return false
    }
}

// Function to run all migrations
const runMigrations = async () => {
    try {
        // Create migrations table if it doesn't exist
        const createMigrationsTable = `
            CREATE TABLE IF NOT EXISTS migrations (
                id SERIAL PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                applied_at TIMESTAMP DEFAULT current_timestamp
            )
        `

        await pool.query(createMigrationsTable)

        // Get list of applied migrations
        const { rows: appliedMigrations } = await pool.query(
            "SELECT name FROM migrations"
        )
        const appliedMigrationNames = appliedMigrations.map((row) => row.name)

        // Get all migration files
        const migrationsDir = path.join(__dirname, "migrations")
        const migrationFiles = fs
            .readdirSync(migrationsDir)
            .filter((file) => file.endsWith(".sql"))
            .sort() // Ensure files are processed in alphabetical order

        // Apply migrations that haven't been applied yet
        for (const file of migrationFiles) {
            if (!appliedMigrationNames.includes(file)) {
                const filePath = path.join(migrationsDir, file)
                const success = await runMigration(filePath)

                if (success) {
                    // Record successful migration
                    await pool.query(
                        "INSERT INTO migrations (name) VALUES ($1)",
                        [file]
                    )
                } else {
                    console.error(`Failed to apply migration: ${file}`)
                    throw new Error(`Migration failed: ${file}`)
                }
            }
        }

        console.log("All migrations completed successfully!")
    } catch (err) {
        console.error("Error during migration process:", err)
        throw err
    }
    // IMPORTANT: Removed the pool.end() call that was here
    // This allows the pool to remain open for other operations
}

// Run migrations when script is executed directly
if (require.main === module) {
    runMigrations()
        .then(() => {
            console.log("Migration process completed.")
            // Only end the pool when running as a standalone script
            pool.end()
            process.exit(0)
        })
        .catch((err) => {
            console.error("Migration failed:", err)
            pool.end()
            process.exit(1)
        })
}

module.exports = {
    runMigrations,
    runMigration,
}

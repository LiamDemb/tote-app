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
    // Create migrations table if it doesn't exist
    const createMigrationsTable = `
    CREATE TABLE IF NOT EXISTS migrations (
      id SERIAL PRIMARY KEY,
      name VARCHAR(255) NOT NULL,
      applied_at TIMESTAMP NOT NULL DEFAULT NOW()
    );
  `

    try {
        await pool.query(createMigrationsTable)

        // Get list of migrations that have already been applied
        const { rows: appliedMigrations } = await pool.query(
            "SELECT name FROM migrations"
        )
        const appliedMigrationNames = appliedMigrations.map((row) => row.name)

        // Get all migration files from the migrations directory
        const migrationsDir = path.join(__dirname, "migrations")
        const migrationFiles = fs
            .readdirSync(migrationsDir)
            .filter((file) => file.endsWith(".sql"))
            .sort() // Sort to run in numerical order

        // Run the migrations that haven't been applied yet
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
                    // Exit on first failure
                    console.error("Migration failed. Exiting.")
                    process.exit(1)
                }
            } else {
                console.log(`Skipping already applied migration: ${file}`)
            }
        }

        console.log("All migrations completed successfully!")
    } catch (err) {
        console.error("Error during migration process:", err)
        process.exit(1)
    } finally {
        await pool.end()
    }
}

// Run migrations when script is executed directly
if (require.main === module) {
    runMigrations()
        .then(() => console.log("Migration process completed."))
        .catch((err) => {
            console.error("Migration process failed:", err)
            process.exit(1)
        })
}

module.exports = {
    runMigrations,
    runMigration,
}

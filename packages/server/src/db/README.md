# Tote App Database

This directory contains all the database-related code for the Tote shopping app.

## Directory Structure

```
db/
├── config.js          # Database connection configuration
├── index.js           # Main database interface
├── migrate.js         # Migration utility
├── migrations/        # SQL migration files
│   └── 001_initial_schema.sql  # Initial database schema
├── models/            # Database models
│   └── users.js       # User-related database operations
└── README.md          # This file
```

## Database Schema

The database schema follows a relational model and includes tables for:

-   Users and profiles
-   Products (both generic types and specific products)
-   Shopping lists and items
-   Stores and prices
-   Search history and route optimization

## Getting Started

1. Make sure PostgreSQL is installed and running on your system
2. Create a `.env` file in the server root directory (see `.env.example`)
3. Create a database in PostgreSQL:
    ```
    createdb tote_db
    ```
4. Initialize the database:
    ```
    npm run db:init
    ```

## API Usage

The database can be accessed through the models in the `db/models` directory:

```javascript
const { models } = require("../db")

// Create a new user
const user = await models.users.createUser({
    email: "user@example.com",
    firebaseUid: "some-firebase-uid",
    firstName: "John",
    lastName: "Doe",
})

// Get user by ID
const user = await models.users.getUserById("user-id")
```

## Adding Models

To create a new model:

1. Create a file in the `models` directory (e.g. `products.js`)
2. Implement database operations for that entity
3. Export them as methods
4. Import and add to the models object in `index.js`

## Migrations

To add a new migration:

1. Create a new SQL file in the `migrations` directory with a numeric prefix (e.g. `002_add_new_table.sql`)
2. The migration system will automatically detect and run new migrations in order

Run migrations manually:

```
npm run migrate
```

## Database Connection

The database connection is managed through a connection pool for better performance. The connection parameters are read from environment variables.

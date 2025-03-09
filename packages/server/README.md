# Tote Backend Server

The Node.js backend server for the Tote smart shopping application.

## Setup

1. Install dependencies:

    ```bash
    npm install
    ```

2. Configure environment:

    ```bash
    cp .env.example .env
    ```

    Update the `.env` file with your configuration.

3. Start development server:
    ```bash
    npm run dev
    ```

## API Endpoints

### Authentication

-   `POST /api/auth/login` - User login (placeholder)
    ```json
    {
        "email": "user@example.com",
        "password": "password"
    }
    ```

## Database

PostgreSQL database connection is prepared but commented out in the initial setup. To enable:

1. Ensure PostgreSQL is running
2. Update `.env` with your database credentials
3. Uncomment the database connection code in `server.js`

## Scripts

-   `npm run dev` - Start development server with nodemon
-   `npm start` - Start production server
-   `npm test` - Run tests (to be implemented)

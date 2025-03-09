# Tote Shopping App

A modern shopping list application built with Flutter and Node.js.

## Features

-   User authentication with Firebase
-   Shopping list management
-   Product search and categorization
-   Store preferences
-   Cross-platform support (iOS, Android)

## Project Structure

This is a monorepo containing:

-   `packages/tote_app`: Flutter mobile application
-   `packages/server`: Node.js backend API

## Getting Started

### Prerequisites

-   Flutter SDK
-   Node.js and npm
-   PostgreSQL database

### Setup

1. Clone the repository
2. Set up the server:

    ```
    cd packages/server
    npm install
    cp .env.sample .env  # Configure your environment variables
    npm run db:init      # Initialize the database
    npm run dev          # Start the development server
    ```

3. Set up the Flutter app:
    ```
    cd packages/tote_app
    flutter pub get
    flutter run
    ```

## Deployment

The backend is configured for deployment on Render with a PostgreSQL database.

## Development

### Backend (Node.js + Express)

-   Server runs on port 5000 by default
-   Uses Express for API endpoints
-   PostgreSQL for database (not configured in initial setup)
-   Nodemon for hot reloading during development

### Frontend (Flutter)

-   Cross-platform mobile and web application
-   Material 3 design
-   State management with Riverpod
-   HTTP package for API communication

## Available Scripts

### Backend

-   `npm run dev`: Start development server with hot reload
-   `npm start`: Start production server
-   `npm test`: Run tests (to be implemented)

### Frontend

-   `flutter run`: Run the app in development mode
-   `flutter build`: Build the app for production
-   `flutter test`: Run tests (to be implemented)

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details

## Acknowledgments

-   Flutter and Dart team for the amazing cross-platform framework
-   Express.js team for the robust backend framework
-   All contributors and maintainers

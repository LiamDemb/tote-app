# Tote Mobile App

The Flutter frontend for the Tote smart shopping application.

## Features

-   Cross-platform (iOS, Android, Web)
-   Material 3 Design
-   State management with Riverpod
-   Clean architecture

## Getting Started

1. Ensure Flutter is installed and configured:

    ```bash
    flutter doctor
    ```

2. Install dependencies:

    ```bash
    flutter pub get
    ```

3. Run the app:
    ```bash
    flutter run
    ```

## Development

### Project Structure

```
lib/
├── constants/    # App constants and configuration
├── models/       # Data models
├── providers/    # Riverpod providers
├── screens/      # UI screens
├── services/     # API and business logic services
├── utils/        # Utility functions
└── widgets/      # Reusable widgets
```

### State Management

-   Using Riverpod for state management
-   Providers are organized in the `providers` directory

### Styling

-   Material 3 design system
-   Custom theme configuration in `main.dart`
-   Google Fonts for typography

## Building

### Android

```bash
flutter build apk
```

### iOS

```bash
flutter build ios
```

### Web

```bash
flutter build web
```

## Testing

```bash
flutter test
```

## Dependencies

-   `flutter_riverpod`: ^2.4.10
-   `http`: ^1.2.0
-   `shared_preferences`: ^2.2.2
-   `flutter_svg`: ^2.0.10+1
-   `google_fonts`: ^6.1.0

/// Environment configuration for the Tote App
/// 
/// This handles environment-specific values like API URLs to allow
/// the app to work in development, staging, and production environments.

enum Environment { dev, staging, prod }

class EnvironmentConfig {
  // Define which environment we're using - change as needed
  static const Environment currentEnvironment = Environment.dev;
  
  // API base URL based on environment
  static String get apiBaseUrl {
    // If a build-time variable is provided, use that instead
    final definedUrl = const String.fromEnvironment('API_BASE_URL');
    if (definedUrl.isNotEmpty) {
      return definedUrl;
    }
    
    // Otherwise use environment-specific defaults
    switch (currentEnvironment) {
      case Environment.dev:
        return 'http://localhost:3000/api';
      case Environment.staging:
        return 'https://staging-api.toteapp.com/api';
      case Environment.prod:
        return 'https://api.toteapp.com/api';
    }
  }
} 
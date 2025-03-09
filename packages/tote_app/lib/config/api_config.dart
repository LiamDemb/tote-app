import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Configuration for API endpoints
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();
  
  // Manual override for testing
  static String? _manualOverrideUrl;
  
  /// Set a manual override URL for testing
  static Future<void> setManualOverrideUrl(String? url) async {
    _manualOverrideUrl = url;
    
    // Save to preferences if not null
    if (url != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('api_override_url', url);
      print('API URL manually set to: $url');
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('api_override_url');
      print('API URL manual override cleared');
    }
  }
  
  /// Load any saved manual override URL
  static Future<void> loadSavedOverrideUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('api_override_url');
      if (savedUrl != null && savedUrl.isNotEmpty) {
        _manualOverrideUrl = savedUrl;
        print('Loaded saved API URL override: $savedUrl');
      }
    } catch (e) {
      print('Error loading saved API URL override: $e');
    }
  }
  
  /// Base URL for API requests
  static String get baseUrl {
    // First check for manual override
    if (_manualOverrideUrl != null) {
      return _manualOverrideUrl!;
    }
    
    // Check for environment variables
    if (const bool.fromEnvironment('API_URL') != null) {
      return const String.fromEnvironment('API_URL');
    }
    
    // Production URL (replace with your actual Render URL once deployed)
    const renderUrl = 'https://tote-api.onrender.com';
    
    if (kReleaseMode) {
      // Production environment
      return renderUrl;
    } else {
      // Development environment - still use the Render URL for consistency
      // This ensures all developers use the same API
      return renderUrl;
      
      // Uncomment below if you want to use localhost for development
      // return 'http://localhost:5000';
    }
  }
  
  /// Check if the API is available
  static Future<bool> checkApiAvailability() async {
    try {
      final client = http.Client();
      print('Checking API availability at: ${getUrl('health')}');
      final response = await client.get(Uri.parse(getUrl('health')))
          .timeout(const Duration(seconds: 5));
      client.close();
      print('API health check response: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API availability check failed: $e');
      return false;
    }
  }
  
  /// Get the full URL for an API endpoint
  static String getUrl(String endpoint) {
    // Ensure endpoint starts with a slash if not empty
    if (endpoint.isNotEmpty && !endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    
    return '$baseUrl$endpoint';
  }
  
  /// Timeout duration for API requests in seconds
  static const int timeoutSeconds = 30;
  
  /// API version
  static const String apiVersion = 'v1';
} 
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:tote_app/config/api_config.dart';

/// Service for handling API requests and diagnostics
class ApiService {
  // Private constructor to prevent instantiation
  ApiService._();
  
  /// Check if the API is available and working
  static Future<Map<String, dynamic>> checkApiStatus() async {
    final results = <String, dynamic>{
      'baseUrl': ApiConfig.baseUrl,
      'timestamp': DateTime.now().toIso8601String(),
      'platform': kIsWeb ? 'web' : 'native',
    };
    
    try {
      print('Checking API status at base URL: ${ApiConfig.baseUrl}');
      
      // Check health endpoint
      try {
        final healthUrl = ApiConfig.getUrl('health');
        print('Checking health endpoint: $healthUrl');
        
        final healthResponse = await http.get(
          Uri.parse(healthUrl),
        ).timeout(Duration(seconds: 5));
        
        print('Health response: ${healthResponse.statusCode} - ${healthResponse.body}');
        
        results['healthEndpoint'] = {
          'statusCode': healthResponse.statusCode,
          'body': healthResponse.body,
          'success': healthResponse.statusCode == 200,
        };
      } catch (e) {
        print('Health endpoint error: $e');
        results['healthEndpoint'] = {
          'error': e.toString(),
          'success': false,
        };
      }
      
      // Check database connectivity
      try {
        final dbTestUrl = ApiConfig.getUrl('api/users/test-db');
        print('Checking database endpoint: $dbTestUrl');
        
        final dbTestResponse = await http.get(
          Uri.parse(dbTestUrl),
        ).timeout(Duration(seconds: 5));
        
        print('DB test response: ${dbTestResponse.statusCode} - ${dbTestResponse.body}');
        
        results['dbTestEndpoint'] = {
          'statusCode': dbTestResponse.statusCode,
          'body': dbTestResponse.body,
          'success': dbTestResponse.statusCode == 200,
        };
        
        if (dbTestResponse.statusCode == 200) {
          try {
            final data = json.decode(dbTestResponse.body);
            results['dbConnected'] = data['success'] == true;
            results['userCount'] = data['userCount'];
          } catch (e) {
            print('Error parsing DB test response: $e');
            results['dbParseError'] = e.toString();
          }
        }
      } catch (e) {
        print('DB test endpoint error: $e');
        results['dbTestEndpoint'] = {
          'error': e.toString(),
          'success': false,
        };
      }
      
      // Overall status
      results['success'] = results['healthEndpoint']?['success'] == true;
      
      return results;
    } catch (e) {
      print('API status check failed: $e');
      results['error'] = e.toString();
      results['success'] = false;
      return results;
    }
  }
  
  /// Make a GET request to the API
  static Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    final url = ApiConfig.getUrl(endpoint);
    print('API GET request to: $url');
    
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      
      _logResponse('GET', url, response);
      return response;
    } catch (e) {
      print('API GET request failed: $e');
      rethrow;
    }
  }
  
  /// Make a POST request to the API
  static Future<http.Response> post(
    String endpoint, 
    {Map<String, String>? headers, dynamic body}
  ) async {
    final url = ApiConfig.getUrl(endpoint);
    print('API POST request to: $url');
    if (body != null) {
      print('Request body: $body');
    }
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      
      _logResponse('POST', url, response, body: body);
      return response;
    } catch (e) {
      print('API POST request failed: $e');
      rethrow;
    }
  }
  
  /// Make a PATCH request to the API
  static Future<http.Response> patch(
    String endpoint, 
    {Map<String, String>? headers, dynamic body}
  ) async {
    final url = ApiConfig.getUrl(endpoint);
    print('API PATCH request to: $url');
    if (body != null) {
      print('Request body: $body');
    }
    
    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ...?headers,
        },
        body: body != null ? json.encode(body) : null,
      ).timeout(Duration(seconds: ApiConfig.timeoutSeconds));
      
      _logResponse('PATCH', url, response, body: body);
      return response;
    } catch (e) {
      print('API PATCH request failed: $e');
      rethrow;
    }
  }
  
  /// Log API response for debugging
  static void _logResponse(
    String method, 
    String url, 
    http.Response response, 
    {dynamic body}
  ) {
    print('API $method $url');
    if (body != null) {
      print('Request body: $body');
    }
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}');
  }
} 
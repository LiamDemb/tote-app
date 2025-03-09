import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tote_app/models/product.dart';
import 'package:tote_app/config/environment.dart';

class ProductService {
  // Base URL for the API from environment configuration
  static final String baseUrl = EnvironmentConfig.apiBaseUrl;
  
  // Fetch all products from the API
  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      // If there's a network error or other exception, return mock data as a fallback
      return mockProducts;
    }
  }
  
  // Fetch generic products from the API
  Future<List<Product>> getGenericProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products/generic'));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load generic products: ${response.statusCode}');
      }
    } catch (e) {
      // Return a smaller set of basic generic products as fallback
      return [
        Product(
          id: 'generic-1',
          name: 'Generic Fruit',
          categoryId: 'fruits-vegetables',
          description: 'Any fruit',
        ),
        Product(
          id: 'generic-2',
          name: 'Generic Vegetable',
          categoryId: 'fruits-vegetables',
          description: 'Any vegetable',
        ),
        Product(
          id: 'generic-3',
          name: 'Generic Dairy',
          categoryId: 'dairy-eggs',
          description: 'Any dairy product',
        ),
        Product(
          id: 'generic-4',
          name: 'Generic Meat',
          categoryId: 'meat-seafood',
          description: 'Any meat product',
        ),
        Product(
          id: 'generic-5',
          name: 'Generic Pantry Item',
          categoryId: 'pantry',
          description: 'Any pantry item',
        ),
      ];
    }
  }
  
  // Search products by query
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=${Uri.encodeComponent(query)}')
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      // Filter mock data as fallback
      return mockProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (product.brand?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }
  }
} 
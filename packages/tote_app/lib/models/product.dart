import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

// Represents a product category
class ProductCategory {
  final String id;
  final String name;
  final String? iconName;

  const ProductCategory({
    required this.id,
    required this.name,
    this.iconName,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconName: json['icon_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (iconName != null) 'icon_name': iconName,
    };
  }
}

// Represents a product that can be added to a shopping list
class Product {
  final String id;
  final String name;
  final String? description;
  final String categoryId;
  final String? barcode;
  final String? imageUrl;
  final String? brand;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.categoryId,
    this.barcode,
    this.imageUrl,
    this.brand,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      barcode: json['barcode'] as String?,
      imageUrl: json['image_url'] as String?,
      brand: json['brand'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'category_id': categoryId,
      if (barcode != null) 'barcode': barcode,
      if (imageUrl != null) 'image_url': imageUrl,
      if (brand != null) 'brand': brand,
    };
  }
}

// Mock data for product categories
final List<ProductCategory> mockCategories = [
  const ProductCategory(
    id: 'fruits-vegetables',
    name: 'Fruits & Vegetables',
    iconName: '🍎',
  ),
  const ProductCategory(
    id: 'dairy-eggs',
    name: 'Dairy & Eggs',
    iconName: '🐄',
  ),
  const ProductCategory(
    id: 'bakery',
    name: 'Bakery',
    iconName: '🍞',
  ),
  const ProductCategory(
    id: 'meat-seafood',
    name: 'Meat & Seafood',
    iconName: '🥩',
  ),
  const ProductCategory(
    id: 'pantry',
    name: 'Pantry',
    iconName: '🥫',
  ),
];

// Mock data for products
final List<Product> mockProducts = [
  Product(
    id: const Uuid().v4(),
    name: 'Bananas',
    categoryId: 'fruits-vegetables',
    description: 'Fresh yellow bananas',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Fresh Carrots',
    categoryId: 'fruits-vegetables',
    description: 'Organic carrots',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Milk',
    categoryId: 'dairy-eggs',
    description: '2% milk',
    brand: 'Dairy Farmers',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Organic Eggs',
    categoryId: 'dairy-eggs',
    description: 'Free-range organic eggs',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Butter',
    categoryId: 'dairy-eggs',
    description: 'Unsalted butter',
    brand: 'Western Star',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Cheddar Cheese',
    categoryId: 'dairy-eggs',
    description: 'Aged cheddar cheese',
    brand: 'Bega Tasty',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Yogurt',
    categoryId: 'dairy-eggs',
    description: 'Greek yogurt',
    brand: 'Chobani',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Whole Wheat Bread',
    categoryId: 'bakery',
    description: 'Freshly baked whole wheat bread',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Chicken Breast',
    categoryId: 'meat-seafood',
    description: 'Boneless, skinless chicken breast',
  ),
  Product(
    id: const Uuid().v4(),
    name: 'Rice',
    categoryId: 'pantry',
    description: 'Long grain white rice',
  ),
];

// Helper function to get category by ID
ProductCategory getCategoryById(String id) {
  return mockCategories.firstWhere(
    (category) => category.id == id,
    orElse: () => const ProductCategory(
      id: 'unknown',
      name: 'Unknown',
    ),
  );
} 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/models/product.dart';
import 'package:tote_app/services/product_service.dart';

// State class for products
class ProductsState {
  final List<Product> products;
  final List<Product> genericProducts;
  final bool isLoading;
  final String? error;

  ProductsState({
    this.products = const [],
    this.genericProducts = const [],
    this.isLoading = false,
    this.error,
  });

  ProductsState copyWith({
    List<Product>? products,
    List<Product>? genericProducts,
    bool? isLoading,
    String? error,
  }) {
    return ProductsState(
      products: products ?? this.products,
      genericProducts: genericProducts ?? this.genericProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Get all products (both regular and generic)
  List<Product> get allProducts => [...products, ...genericProducts];
}

// Products notifier
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductService _productService;

  ProductsNotifier(this._productService) : super(ProductsState(isLoading: true)) {
    // Load products when initialized
    _loadProducts();
  }

  // Load products from the backend
  Future<void> _loadProducts() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Load both regular and generic products
      final products = await _productService.getProducts();
      final genericProducts = await _productService.getGenericProducts();
      
      state = state.copyWith(
        products: products,
        genericProducts: genericProducts,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh products from the backend
  Future<void> refreshProducts() async {
    await _loadProducts();
  }

  // Search products by query
  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) {
      return state.allProducts;
    }
    
    try {
      // Search from API
      final searchResults = await _productService.searchProducts(query);
      return searchResults;
    } catch (e) {
      // Fallback to local filtering if API search fails
      return state.allProducts.where((product) {
        return product.name.toLowerCase().contains(query.toLowerCase()) ||
               (product.description?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
               (product.brand?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }
  }
}

// Provider for the product service
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Provider for product state
final productsProvider = StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productService = ref.watch(productServiceProvider);
  return ProductsNotifier(productService);
});

// Provider for searching products
final productSearchProvider = StateProvider<String>((ref) => '');

// Provider for filtered products based on search query
final filteredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productsNotifier = ref.watch(productsProvider.notifier);
  final searchQuery = ref.watch(productSearchProvider);
  
  // Return search results
  return productsNotifier.searchProducts(searchQuery);
}); 
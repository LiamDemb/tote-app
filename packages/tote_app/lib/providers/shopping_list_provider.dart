import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/models/product.dart';
import 'package:tote_app/models/shopping_list_item.dart';

// State class for shopping list
class ShoppingListState {
  final List<ShoppingListItem> items;
  final bool isLoading;
  final String? error;

  ShoppingListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  ShoppingListState copyWith({
    List<ShoppingListItem>? items,
    bool? isLoading,
    String? error,
  }) {
    return ShoppingListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Helper method to get items organized by category
  Map<ProductCategory, List<ShoppingListItem>> getItemsByCategory() {
    final Map<ProductCategory, List<ShoppingListItem>> result = {};
    
    // Group items by category
    for (final item in items) {
      final category = getCategoryById(item.product.categoryId);
      
      if (!result.containsKey(category)) {
        result[category] = [];
      }
      
      result[category]!.add(item);
    }
    
    return result;
  }

  // Check if the shopping list is empty
  bool get isEmpty => items.isEmpty;
}

// Shopping list notifier
class ShoppingListNotifier extends StateNotifier<ShoppingListState> {
  ShoppingListNotifier() : super(ShoppingListState()) {
    // Initialize with empty state
    // We'll load items when needed
  }

  // Add an item to the shopping list
  void addItem(Product product, {String quantity = "1", String? preferredStore}) {
    // Check if the product already exists in the list
    final existingItemIndex = state.items.indexWhere(
      (item) => item.productId == product.id
    );

    if (existingItemIndex != -1) {
      // Update the existing item
      final updatedItems = [...state.items];
      updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
        quantity: quantity,
        preferredStore: preferredStore,
      );
      
      state = state.copyWith(items: updatedItems);
    } else {
      // Add a new item
      final newItem = ShoppingListItem(
        productId: product.id,
        product: product,
        quantity: quantity,
        preferredStore: preferredStore,
      );
      
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  // Update an item in the shopping list
  void updateItem(String itemId, {String? quantity, bool? isChecked, String? notes, String? preferredStore}) {
    final updatedItems = [...state.items];
    final itemIndex = updatedItems.indexWhere((item) => item.id == itemId);
    
    if (itemIndex != -1) {
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        quantity: quantity,
        isChecked: isChecked,
        notes: notes,
        preferredStore: preferredStore,
      );
      
      state = state.copyWith(items: updatedItems);
    }
  }

  // Remove an item from the shopping list
  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  // Clear the entire shopping list
  void clearList() {
    state = state.copyWith(items: []);
  }

  // Toggle the checked state of an item
  void toggleItemChecked(String itemId) {
    final updatedItems = [...state.items];
    final itemIndex = updatedItems.indexWhere((item) => item.id == itemId);
    
    if (itemIndex != -1) {
      updatedItems[itemIndex] = updatedItems[itemIndex].copyWith(
        isChecked: !updatedItems[itemIndex].isChecked,
      );
      
      state = state.copyWith(items: updatedItems);
    }
  }

  // Load a demo shopping list with sample items
  void loadDemoList() {
    state = state.copyWith(items: ShoppingListItem.getMockItems());
  }
}

// Provider for shopping list state
final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, ShoppingListState>((ref) {
  return ShoppingListNotifier();
}); 
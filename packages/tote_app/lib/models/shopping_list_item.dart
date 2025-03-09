import 'package:uuid/uuid.dart';
import 'package:tote_app/models/product.dart';

// Represents an item in a shopping list
class ShoppingListItem {
  final String id;
  final String productId;
  final String quantity;
  final String? notes;
  final bool isChecked;
  final Product product;
  final String? preferredStore;

  ShoppingListItem({
    String? id,
    required this.productId,
    this.quantity = "1",
    this.notes,
    this.isChecked = false,
    required this.product,
    this.preferredStore,
  }) : id = id ?? const Uuid().v4();

  factory ShoppingListItem.fromProduct(Product product) {
    return ShoppingListItem(
      productId: product.id,
      product: product,
    );
  }

  ShoppingListItem copyWith({
    String? id,
    String? productId,
    String? quantity,
    String? notes,
    bool? isChecked,
    Product? product,
    String? preferredStore,
  }) {
    return ShoppingListItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
      isChecked: isChecked ?? this.isChecked,
      product: product ?? this.product,
      preferredStore: preferredStore ?? this.preferredStore,
    );
  }

  // Mock data for shopping list items
  static List<ShoppingListItem> getMockItems() {
    return [
      ShoppingListItem(
        productId: mockProducts[0].id,
        product: mockProducts[0],
        quantity: '6',
      ),
      ShoppingListItem(
        productId: mockProducts[0].id, // Duplicating bananas as in the mockup
        product: mockProducts[0],
        quantity: '6',
      ),
      ShoppingListItem(
        productId: mockProducts[1].id,
        product: mockProducts[1],
        quantity: '1kg',
      ),
      ShoppingListItem(
        productId: mockProducts[2].id,
        product: mockProducts[2],
        quantity: '2L',
        preferredStore: 'Dairy Farmers',
      ),
      ShoppingListItem(
        productId: mockProducts[3].id,
        product: mockProducts[3],
        quantity: '1 dozen',
      ),
      ShoppingListItem(
        productId: mockProducts[4].id,
        product: mockProducts[4],
        quantity: '500g',
        preferredStore: 'Western Star',
      ),
      ShoppingListItem(
        productId: mockProducts[5].id,
        product: mockProducts[5],
        quantity: '1kg (1 block)',
        preferredStore: 'Bega Tasty',
      ),
      ShoppingListItem(
        productId: mockProducts[6].id,
        product: mockProducts[6],
        quantity: '4 tubs (200g each)',
        preferredStore: 'Chobani',
      ),
    ];
  }
} 
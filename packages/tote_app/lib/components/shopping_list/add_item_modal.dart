import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/models/product.dart';
import 'package:tote_app/providers/shopping_list_provider.dart';
import 'package:tote_app/providers/product_provider.dart';
import 'package:tote_app/theme/index.dart';

class AddItemModal extends ConsumerWidget {
  const AddItemModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = ref.watch(productSearchProvider);
    final filteredProductsAsync = ref.watch(filteredProductsProvider);
    final productsState = ref.watch(productsProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Add Item to Shopping List',
                  style: AppTypography.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Search field
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => ref.read(productSearchProvider.notifier).state = '',
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.md),
              ),
            ),
            onChanged: (value) {
              ref.read(productSearchProvider.notifier).state = value;
            },
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Results with loading and error handling
          Flexible(
            fit: FlexFit.loose,
            child: filteredProductsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.neutral[600],
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    // Add a visual indicator for generic products
                    final isGeneric = productsState.genericProducts.any((p) => p.id == product.id);
                    
                    return _ProductSearchItem(
                      product: product,
                      isGeneric: isGeneric,
                      onTap: () {
                        _selectProduct(context, ref, product);
                      },
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error loading products',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton(
                      onPressed: () => ref.refresh(filteredProductsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectProduct(BuildContext context, WidgetRef ref, Product product) {
    // Add the product to the shopping list
    ref.read(shoppingListProvider.notifier).addItem(product);
    
    // Close the modal
    Navigator.pop(context);
  }
}

class _ProductSearchItem extends StatelessWidget {
  final Product product;
  final bool isGeneric;
  final VoidCallback onTap;

  const _ProductSearchItem({
    Key? key,
    required this.product,
    this.isGeneric = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final category = getCategoryById(product.categoryId);
    
    return ListTile(
      leading: _buildProductImage(),
      title: Row(
        children: [
          Expanded(
            child: Text(
              product.name,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isGeneric)
            Container(
              margin: const EdgeInsets.only(left: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs, 
                vertical: 2
              ),
              decoration: BoxDecoration(
                color: AppColors.secondary[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Generic',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.secondary[800],
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        product.brand != null
          ? '${category.name} • ${product.brand}'
          : category.name,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      trailing: const Icon(Icons.add_circle_outline),
      onTap: onTap,
    );
  }
  
  Widget _buildProductImage() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutral[300]!),
      ),
      child: product.imageUrl != null && product.imageUrl!.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
            ),
          )
        : _buildFallbackImage(),
    );
  }
  
  Widget _buildFallbackImage() {
    // Fallback image by category
    IconData iconData;
    Color iconColor;
    
    switch (product.categoryId) {
      case 'fruits-vegetables':
        iconData = Icons.eco;
        iconColor = Colors.green;
        break;
      case 'dairy-eggs':
        iconData = Icons.egg;
        iconColor = Colors.amber;
        break;
      case 'bakery':
        iconData = Icons.breakfast_dining;
        iconColor = Colors.brown;
        break;
      case 'meat-seafood':
        iconData = Icons.restaurant;
        iconColor = Colors.redAccent;
        break;
      case 'pantry':
        iconData = Icons.kitchen;
        iconColor = Colors.blueGrey;
        break;
      default:
        iconData = Icons.shopping_basket;
        iconColor = AppColors.primary;
    }
    
    return Center(
      child: Icon(
        iconData,
        color: iconColor,
        size: 28,
      ),
    );
  }
}

// Function to show the add item modal
void showAddItemModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(16),
      ),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: const AddItemModal(),
      ),
    ),
  );
} 
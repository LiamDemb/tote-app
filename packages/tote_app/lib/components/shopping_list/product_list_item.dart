import 'package:flutter/material.dart';
import 'package:tote_app/models/shopping_list_item.dart';
import 'package:tote_app/theme/index.dart';

class ProductListItem extends StatelessWidget {
  final ShoppingListItem item;
  final VoidCallback onToggleCheck;
  final VoidCallback onRemove;
  final Function(String) onUpdateQuantity;

  const ProductListItem({
    Key? key,
    required this.item,
    required this.onToggleCheck,
    required this.onRemove,
    required this.onUpdateQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          // Product image
          _buildProductImage(),
          const SizedBox(width: AppSpacing.md),
          
          // Product details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTypography.titleMedium.copyWith(
                    decoration: item.isChecked 
                        ? TextDecoration.lineThrough 
                        : TextDecoration.none,
                  ),
                ),
                Text(
                  // Show brand if available, otherwise "Any"
                  item.product.brand ?? (item.preferredStore ?? 'Any'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.neutral[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity
          SizedBox(
            width: 120,
            child: Text(
              item.quantity,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.neutral[600],
              ),
              textAlign: TextAlign.end,
            ),
          ),
          
          // Menu options
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.neutral[600]),
            onSelected: (value) {
              if (value == 'remove') {
                onRemove();
              } else if (value == 'edit') {
                _showEditDialog(context);
              } else if (value == 'toggle') {
                onToggleCheck();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(Icons.check_box_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Toggle checked'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18),
                    SizedBox(width: 8),
                    Text('Remove'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
      child: item.product.imageUrl != null && item.product.imageUrl!.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.imageUrl!,
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
    
    switch (item.product.categoryId) {
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

  void _showEditDialog(BuildContext context) {
    String quantity = item.quantity;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${item.product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: quantity),
              onChanged: (value) => quantity = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              onUpdateQuantity(quantity);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:tote_app/models/product.dart';
import 'package:tote_app/models/shopping_list_item.dart';
import 'package:tote_app/theme/index.dart';
import 'package:tote_app/components/shopping_list/product_list_item.dart';

class CategorySection extends StatefulWidget {
  final ProductCategory category;
  final List<ShoppingListItem> items;
  final Function(String) onToggleCheck;
  final Function(String) onRemoveItem;
  final Function(String, String) onUpdateQuantity;

  const CategorySection({
    Key? key,
    required this.category,
    required this.items,
    required this.onToggleCheck,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
  }) : super(key: key);

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header with collapse/expand button
        InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                if (widget.category.iconName != null)
                  Text(
                    widget.category.iconName!,
                    style: const TextStyle(fontSize: 20),
                  ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    widget.category.name,
                    style: AppTypography.titleLarge,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.neutral[600],
                ),
              ],
            ),
          ),
        ),
        
        // Divider
        Divider(height: 1, thickness: 1, color: AppColors.neutral[300]),
        
        // Collapsible list of items
        if (_isExpanded)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (context, index) {
              final item = widget.items[index];
              return ProductListItem(
                item: item,
                onToggleCheck: () => widget.onToggleCheck(item.id),
                onRemove: () => widget.onRemoveItem(item.id),
                onUpdateQuantity: (quantity) => widget.onUpdateQuantity(item.id, quantity),
              );
            },
          ),
      ],
    );
  }
} 
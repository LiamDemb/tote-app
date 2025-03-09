import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tote_app/components/shopping_list/add_item_modal.dart';
import 'package:tote_app/components/shopping_list/bottom_action_buttons.dart';
import 'package:tote_app/components/shopping_list/category_section.dart';
import 'package:tote_app/components/shopping_list/empty_list_view.dart';
import 'package:tote_app/models/product.dart';
import 'package:tote_app/providers/shopping_list_provider.dart';
import 'package:tote_app/theme/index.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingListState = ref.watch(shoppingListProvider);
    final itemsByCategory = shoppingListState.getItemsByCategory();
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with optional clear button
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shopping List',
                    style: AppTypography.headlineLarge,
                  ),
                  
                  // Clear list button - only visible when list has items
                  if (shoppingListState.items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Show confirmation dialog before clearing
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Clear shopping list?'),
                              content: const Text('This will remove all items from your shopping list.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref.read(shoppingListProvider.notifier).clearList();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          foregroundColor: AppColors.neutral[700],
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Main content - either empty state or list of items
              Expanded(
                child: shoppingListState.isEmpty
                    ? const EmptyListView()
                    : ListView.builder(
                        itemCount: itemsByCategory.length,
                        itemBuilder: (context, index) {
                          final category = itemsByCategory.keys.elementAt(index);
                          final items = itemsByCategory[category] ?? [];
                          
                          return CategorySection(
                            category: category,
                            items: items,
                            onToggleCheck: (itemId) {
                              ref.read(shoppingListProvider.notifier).toggleItemChecked(itemId);
                            },
                            onRemoveItem: (itemId) {
                              ref.read(shoppingListProvider.notifier).removeItem(itemId);
                            },
                            onUpdateQuantity: (itemId, quantity) {
                              ref.read(shoppingListProvider.notifier).updateItem(
                                itemId,
                                quantity: quantity,
                              );
                            },
                          );
                        },
                      ),
              ),
              
              // Bottom action buttons
              BottomActionButtons(
                onAddItem: () => showAddItemModal(context),
                onFindRoute: () {
                  // For now, this will do nothing as per requirements
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Find Route feature coming soon!'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
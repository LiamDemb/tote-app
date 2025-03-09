import 'package:flutter/material.dart';
import 'package:tote_app/theme/index.dart';

class BottomActionButtons extends StatelessWidget {
  final VoidCallback onAddItem;
  final VoidCallback onFindRoute;

  const BottomActionButtons({
    Key? key,
    required this.onAddItem,
    required this.onFindRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Add Item Button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onAddItem,
              icon: const Icon(AppIcons.add),
              label: const Text('Add item'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          
          // Find Route Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onFindRoute,
              icon: IconTheme(
                data: const IconThemeData(
                  color: Colors.white,
                ),
                child: const Icon(AppIcons.map),
              ),
              label: const Text('Find Route'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.lg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
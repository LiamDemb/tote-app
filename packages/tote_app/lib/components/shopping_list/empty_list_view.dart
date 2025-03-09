import 'package:flutter/material.dart';
import 'package:tote_app/theme/index.dart';

class EmptyListView extends StatelessWidget {
  const EmptyListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 64,
            color: AppColors.primary[300],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your shopping list is empty...',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.neutral[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'start adding items!',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.neutral[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 
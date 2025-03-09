import 'package:flutter/material.dart';
import 'package:tote_app/theme/app_colors.dart';

/// Text styles for the Tote app
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // Base font
  static const String _fontFamily = 'Host Grotesk';
  
  // Display styles
  static final TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral[900],
  );
  
  // Headline styles
  static final TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  // Title styles
  static final TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  // Body styles
  static final TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.neutral[900],
  );
  
  // Label styles
  static final TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
  
  static final TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.neutral[900],
  );
} 
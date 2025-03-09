import 'package:flutter/material.dart';
import 'package:tote_app/theme/app_colors.dart';

/// Typography styles for the Tote app
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  static const String fontFamily = 'Host Grotesk';
  
  // Create a text style with the app's font family
  static TextStyle _createTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
  
  // Display Styles (Large headlines, hero sections)
  static TextStyle displayLarge = _createTextStyle(
    fontSize: 34.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.neutral[900]!,
  );
  
  static TextStyle displayMedium = _createTextStyle(
    fontSize: 30.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.neutral[900]!,
  );
  
  static TextStyle displaySmall = _createTextStyle(
    fontSize: 26.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    color: AppColors.neutral[900]!,
  );
  
  // Headline Styles (Section headers)
  static TextStyle headlineLarge = _createTextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.neutral[900]!,
  );
  
  static TextStyle headlineMedium = _createTextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.neutral[900]!,
  );
  
  static TextStyle headlineSmall = _createTextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.neutral[900]!,
  );
  
  // Title Styles (Card titles, subsections)
  static TextStyle titleLarge = _createTextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral[800]!,
  );
  
  static TextStyle titleMedium = _createTextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral[800]!,
  );
  
  static TextStyle titleSmall = _createTextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.neutral[800]!,
  );
  
  // Body Styles (Main content text)
  static TextStyle bodyLarge = _createTextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.neutral[800]!,
  );
  
  static TextStyle bodyMedium = _createTextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.neutral[700]!,
  );
  
  static TextStyle bodySmall = _createTextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.neutral[700]!,
  );
  
  // Label Styles (Form labels, badges, chips)
  static TextStyle labelLarge = _createTextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.neutral[700]!,
  );
  
  static TextStyle labelMedium = _createTextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.neutral[700]!,
  );
  
  static TextStyle labelSmall = _createTextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: AppColors.neutral[700]!,
  );
  
  // Button Text Styles
  static TextStyle buttonLarge = _createTextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.white,
  );
  
  static TextStyle buttonMedium = _createTextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.white,
  );
  
  static TextStyle buttonSmall = _createTextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.white,
  );
} 
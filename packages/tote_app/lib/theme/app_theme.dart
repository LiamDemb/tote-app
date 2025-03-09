import 'package:flutter/material.dart';
import 'package:tote_app/theme/app_colors.dart';
import 'package:tote_app/theme/app_typography.dart';
import 'package:tote_app/theme/app_dimensions.dart';

/// Design system for the Tote app
/// 
/// Organized using the Atomic Design methodology with:
/// - tokens (colors, typography, spacing, etc.)
/// - components (inputs, buttons, etc.)
/// 
/// This centralized approach allows for consistent styling and easy updates.

/// Main theme configuration for the Tote app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Input Decoration Factory
  static InputDecoration getInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    bool isError = false,
    BuildContext? context,
  }) {
    final theme = context != null ? Theme.of(context) : ThemeData.light();
    
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 24, right: 14),
        child: Icon(
          prefixIcon,
          size: 22,
        ),
      ),
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        borderSide: BorderSide(color: AppColors.neutral[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        borderSide: BorderSide(color: AppColors.neutral[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xl),
        borderSide: BorderSide(color: AppColors.error),
      ),
      errorText: isError ? '' : null,
      errorStyle: const TextStyle(height: 0),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }

  /// Error Message Widget Factory
  static Widget buildErrorMessage(String message, BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.error_outline_rounded,
          color: AppColors.error,
          size: 20,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  /// Main Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      // Base Properties
      fontFamily: AppTypography.fontFamily,
      primarySwatch: AppColors.primary,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        primaryContainer: AppColors.primary[600]!,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondary[600]!,
        tertiary: AppColors.accent,
        tertiaryContainer: AppColors.accent[600]!,
        background: AppColors.background,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onTertiary: AppColors.neutral[900]!,
        onBackground: AppColors.neutral[900]!,
        onSurface: AppColors.neutral[900]!,
        onError: AppColors.white,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.background,

      // Text Theme
      textTheme: TextTheme(
        // Display styles
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        
        // Headline styles
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        
        // Title styles
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        
        // Body styles
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        
        // Label styles
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        size: 22,
        color: AppColors.neutral[600]!,
      ),

      // Primary Icon Theme
      primaryIconTheme: IconThemeData(
        size: 22,
        color: AppColors.primary,
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          borderSide: BorderSide(color: AppColors.neutral[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          borderSide: BorderSide(color: AppColors.neutral[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          borderSide: BorderSide(color: AppColors.error),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        prefixIconColor: AppColors.neutral[600]!,
        hintStyle: AppTypography.bodyLarge.copyWith(
          color: AppColors.neutral[500]!,
        ),
        labelStyle: AppTypography.labelMedium,
        errorStyle: AppTypography.bodySmall.copyWith(
          color: AppColors.error,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 22,
          minHeight: 22,
          maxWidth: 50,
        ),
        isDense: true,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          elevation: 0,
          textStyle: AppTypography.buttonLarge,
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          side: BorderSide(color: AppColors.neutral[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          textStyle: AppTypography.buttonLarge.copyWith(
            color: AppColors.primary,
          ),
          minimumSize: const Size(double.infinity, 56),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          textStyle: AppTypography.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
      ),
      
      // Card Theme
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        margin: EdgeInsets.all(AppSpacing.sm),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral[900]!,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral[500]!,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.labelSmall,
        unselectedLabelStyle: AppTypography.labelSmall,
      ),
    );
  }
} 
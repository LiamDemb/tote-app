import 'package:flutter/material.dart';

/// Color palette with complete shade ranges for the Tote app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Brand Primary Colors
  static const MaterialColor primary = MaterialColor(
    0xFF004E64, // 500
    <int, Color>{
      50: Color(0xFFE0F0F5),
      100: Color(0xFFB3D9E6),
      200: Color(0xFF80BFD5),
      300: Color(0xFF4DA5C4),
      400: Color(0xFF2692B7),
      500: Color(0xFF004E64),
      600: Color(0xFF00475C),
      700: Color(0xFF003D52),
      800: Color(0xFF003548),
      900: Color(0xFF002535),
    },
  );

  // Brand Secondary Colors
  static const MaterialColor secondary = MaterialColor(
    0xFF329D9C, // 500
    <int, Color>{
      50: Color(0xFFE6F5F5),
      100: Color(0xFFBFE6E6),
      200: Color(0xFF95D5D5),
      300: Color(0xFF6AC4C3),
      400: Color(0xFF4AB8B7),
      500: Color(0xFF329D9C),
      600: Color(0xFF2D8F8E),
      700: Color(0xFF267E7D),
      800: Color(0xFF1F6E6D),
      900: Color(0xFF135251),
    },
  );

  // Brand Accent Colors
  static const MaterialColor accent = MaterialColor(
    0xFF7BE495, // 500
    <int, Color>{
      50: Color(0xFFF2FCF4),
      100: Color(0xFFDFF8E4),
      200: Color(0xFFCAF3D3),
      300: Color(0xFFB5EEC2),
      400: Color(0xFF98E9A8),
      500: Color(0xFF7BE495),
      600: Color(0xFF60D078),
      700: Color(0xFF45BB5D),
      800: Color(0xFF35A34C),
      900: Color(0xFF278A3C),
    },
  );

  // Neutral Colors (Grays)
  static const MaterialColor neutral = MaterialColor(
    0xFF9E9E9E, // 500
    <int, Color>{
      50: Color(0xFFFAFAFA),
      100: Color(0xFFF5F5F5),
      200: Color(0xFFEEEEEE),
      300: Color(0xFFE0E0E0),
      400: Color(0xFFBDBDBD),
      500: Color(0xFF9E9E9E),
      600: Color(0xFF757575),
      700: Color(0xFF616161),
      800: Color(0xFF424242),
      900: Color(0xFF212121),
    },
  );

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Common Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Background Colors
  static const Color background = white;
  static const Color surfaceLight = Color(0xFFF8F8F8);
  static const Color surface = white;
} 
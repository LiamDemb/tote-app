import 'package:flutter/material.dart';

/// Spacing constants for consistent layout
class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();
  
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  
  // Content padding
  static const EdgeInsets contentPadding = EdgeInsets.all(md);
}

/// Border radius constants for consistent component styling
class AppBorderRadius {
  // Private constructor to prevent instantiation
  AppBorderRadius._();
  
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 30.0;
  static const double circle = 999.0;
  
  // BorderRadius presets
  static final BorderRadius smallAll = BorderRadius.circular(sm);
  static final BorderRadius mediumAll = BorderRadius.circular(md);
  static final BorderRadius largeAll = BorderRadius.circular(lg);
  static final BorderRadius xLargeAll = BorderRadius.circular(xl);
  static final BorderRadius circleAll = BorderRadius.circular(circle);
} 
import 'package:campus_compass/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';

/// App Colors Class - Resource class for storing app-level color constants
class AppColors {
  AppColors._(); // private constructor to prevent instantiation

  static const primaryBlue = Color(0xFF369DF4);
  static const _lightSecondaryBlue = Color(0xFFB8D7FE);
  static const _darkSecondaryBlue = Color(0xFF20384F);
  static const _lightPageBackground = Color(0xFFF7F7F8);
  static const _darkPageBackground = Color(0xFF0D1117);
  static const _lightSoftBackground = Color(0xFFF7F7F8);
  static const _darkSoftBackground = Color(0xFF11161D);
  static const _lightDarkText = Color(0xFF171717);
  static const _darkDarkText = Color(0xFFF3F4F6);
  static const _lightMutedText = Color(0xFF6B7280);
  static const _darkMutedText = Color(0xFF9AA4B2);
  static const _lightCardBorder = Color(0xFFE5E7EB);
  static const _darkCardBorder = Color(0xFF2B3340);
  static const _lightCircleColor = Color(0xFFF3F4F6);
  static const _darkCircleColor = Color(0xFF202734);
  static const _lightQuoteBackground = Color(0xFFF8F8F8);
  static const _darkQuoteBackground = Color(0xFF171C24);
  static const _lightMapBackground = Color(0xFFE8E8E8);
  static const _darkMapBackground = Color(0xFF11161D);
  static const _lightSurface = Colors.white;
  static const _darkSurface = Color(0xFF151A21);

  static bool get _isDark => AppThemeController.instance.isDarkMode;

  static Color get secondaryBlue =>
      _isDark ? _darkSecondaryBlue : _lightSecondaryBlue;
  static Color get pageBackground =>
      _isDark ? _darkPageBackground : _lightPageBackground;
  static Color get softBackground =>
      _isDark ? _darkSoftBackground : _lightSoftBackground;
  static Color get darkText => _isDark ? _darkDarkText : _lightDarkText;
  static Color get mutedText => _isDark ? _darkMutedText : _lightMutedText;
  static Color get cardBorder => _isDark ? _darkCardBorder : _lightCardBorder;
  static Color get lightCircle =>
      _isDark ? _darkCircleColor : _lightCircleColor;
  static Color get quoteBackground =>
      _isDark ? _darkQuoteBackground : _lightQuoteBackground;

  // Status colors for safety screens
  static const statusNormal = Color(0xFF4CAF50);    // Green - campus is calm
  static const statusCaution = Color(0xFFFFC107);   // Yellow/Amber - caution
  static const statusHighRisk = Color(0xFFF44336);  // Red - high risk
  
  // Additional colors for map and incidents
  static const safeRoute = Color(0xFF4CAF50);       // Green route
  static const tensionZone = Color(0xFFF44336);     // Red zone
  static const verifiedBadge = Color(0xFF4CAF50);   // Green verified badge
  static Color get mapBackground =>
      _isDark ? _darkMapBackground : _lightMapBackground;
  static Color get white => _isDark ? _darkSurface : _lightSurface;
}

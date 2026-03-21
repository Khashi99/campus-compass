import 'package:flutter/material.dart';

/// App Colors Class - Resource class for storing app-level color constants
class AppColors {
  AppColors._(); // private constructor to prevent instantiation

  static const primaryBlue = Color(0xFF369DF4);
  static const secondaryBlue = Color(0xFFb8d7fe);
  static const pageBackground = Color(0xFFF7F7F8);
  static const softBackground = Color(0xFFF7F7F8);
  static const darkText = Color(0xFF171717);
  static const mutedText = Color(0xFF6B7280);
  static const cardBorder = Color(0xFFE5E7EB);
  static const lightCircle = Color(0xFFF3F4F6);
  static const quoteBackground = Color(0xFFF8F8F8);

  // Status colors for safety screens
  static const statusNormal = Color(0xFF4CAF50);    // Green - campus is calm
  static const statusCaution = Color(0xFFFFC107);   // Yellow/Amber - caution
  static const statusHighRisk = Color(0xFFF44336);  // Red - high risk
  
  // Additional colors for map and incidents
  static const safeRoute = Color(0xFF4CAF50);       // Green route
  static const tensionZone = Color(0xFFF44336);     // Red zone
  static const verifiedBadge = Color(0xFF4CAF50);   // Green verified badge
  static const mapBackground = Color(0xFFE8E8E8);   // Map placeholder bg
  static const white = Colors.white;
}

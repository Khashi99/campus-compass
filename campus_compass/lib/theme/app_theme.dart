import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._(); // private constructor to prevent instantiation

  // Button Theme Data
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      textStyle: TextStyle(color: AppColors.white, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), 
      elevation: 1.4,
    )
  );

  // Button Theme Data
  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      textStyle: linkStyle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), 
      elevation: 1.4,

    )
  );

  // Text Theme Data
  static TextTheme textTheme = TextTheme(
    bodyLarge: GoogleFonts.lexend(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.primaryBlue,
    ),
  );

  // App Theme Data
  static ThemeData appTheme = ThemeData(
    textTheme: textTheme,
    textButtonTheme: textButtonTheme, 
    elevatedButtonTheme: elevatedButtonTheme,
  );

  // MaterialBanner theme data
  static MaterialBannerThemeData materialBannerTheme = MaterialBannerThemeData(
    backgroundColor: AppColors.primaryBlue,
    contentTextStyle: textTheme.bodyLarge,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.darkText,
    height: 1.2,
  );

  static const TextStyle descriptionStyle = TextStyle(
    fontSize: 14,
    color: AppColors.mutedText,
    height: 1.6,
  );

  static const TextStyle bulletStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle optionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.darkText,
  );

  static const TextStyle optionSubtitleStyle = TextStyle(
    fontSize: 14,
    color: AppColors.mutedText,
    height: 1.4,
  );

  static const TextStyle quoteStyle = TextStyle(
    fontSize: 13,
    height: 1.6,
    color: AppColors.mutedText,
    fontStyle: FontStyle.italic,
  );

    static const TextStyle linkStyle = TextStyle(
    fontSize: 14.5,
    height: 1.6,
    color: AppColors.primaryBlue,
    fontWeight: FontWeight.bold,
  );
}

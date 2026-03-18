import 'package:flutter/material.dart';
import 'package:campus_compass/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._(); // private constructor to prevent instantiation

  // Button Theme Data
  static ButtonThemeData buttonTheme = ButtonThemeData(
    buttonColor: AppColors.primary,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );

  // Text Theme Data
  static TextTheme textTheme = TextTheme(
    bodyLarge: GoogleFonts.lexend(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.primary,
    ),
  );

  // App Theme Data
  static ThemeData appTheme = ThemeData(
    buttonTheme: buttonTheme,
    textTheme: textTheme,
  );

  // MaterialBanner theme data
  static MaterialBannerThemeData materialBannerTheme = MaterialBannerThemeData(
    backgroundColor: AppColors.primary,
    contentTextStyle: textTheme.bodyLarge,
  );
}

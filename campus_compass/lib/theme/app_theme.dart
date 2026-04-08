import 'package:campus_compass/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static ElevatedButtonThemeData get elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          textStyle: TextStyle(fontSize: 14),
          minimumSize: Size.fromHeight(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1.4,
        ),
      );

  static TextButtonThemeData get textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: linkStyle,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 1.4,
        ),
      );

  static OutlinedButtonThemeData get outlinedButtonTheme =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: Size.fromHeight(50),
          side: BorderSide(width: 1.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );

  static TextTheme get textTheme {
    final base = TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.primaryBlue,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.darkText,
      ),
    );

    return GoogleFonts.openSansTextTheme(base);
  }

  static String get _appFontFamily => 'Open Sans';

  static ThemeData get themeData {
    final brightness = AppColors.pageBackground.computeLuminance() < 0.2
        ? Brightness.dark
        : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.pageBackground,
      canvasColor: AppColors.pageBackground,
      cardColor: AppColors.white,
      dividerColor: AppColors.cardBorder,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: brightness,
      ).copyWith(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        secondary: AppColors.primaryBlue,
        surface: AppColors.white,
        onSurface: AppColors.darkText,
        outline: AppColors.cardBorder,
      ),
      fontFamily: _appFontFamily,
      textTheme: textTheme,
      textButtonTheme: textButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.darkText,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCircle,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.primaryBlue,
            width: 1.4,
          ),
        ),
        hintStyle: TextStyle(color: AppColors.mutedText),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: brightness == Brightness.dark ? Colors.grey[800] : Colors.black,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
    );
  }

  static MaterialBannerThemeData get materialBannerTheme =>
      MaterialBannerThemeData(
        backgroundColor: AppColors.primaryBlue,
        contentTextStyle: textTheme.bodyLarge,
      );

  static TextStyle get titleStyle => GoogleFonts.openSans(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: AppColors.darkText,
        height: 1.2,
      );

  static TextStyle get descriptionStyle => GoogleFonts.openSans(
        fontSize: 14,
        color: AppColors.mutedText,
        height: 1.6,
      );

  static TextStyle get bulletStyle => GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.darkText,
      );

  static TextStyle get optionTitleStyle => GoogleFonts.openSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.darkText,
      );

  static TextStyle get optionSubtitleStyle => GoogleFonts.openSans(
        fontSize: 14,
        color: AppColors.mutedText,
        height: 1.4,
      );

  static TextStyle get quoteStyle => GoogleFonts.openSans(
        fontSize: 14,
        height: 1.6,
        color: AppColors.mutedText,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get linkStyle => GoogleFonts.openSans(
        fontSize: 14.5,
        height: 1.6,
        color: AppColors.primaryBlue,
        fontWeight: FontWeight.bold,
      );
}

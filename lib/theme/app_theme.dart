import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF4E67E8);
  static const Color secondaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFF00C9A7);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF2D3748);
  static const Color subtitleColor = Color(0xFF718096);
  static const Color errorColor = Color(0xFFE53E3E);
  
  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF1A202C);
  static const Color darkCardColor = Color(0xFF2D3748);
  static const Color darkTextColor = Color(0xFFE2E8F0);
  static const Color darkSubtitleColor = Color(0xFFA0AEC0);

  static ThemeData get lightTheme {
    final baseTheme = ThemeData.light();
    
    // Use a try-catch block to handle potential font loading issues
    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: textColor,
        displayColor: textColor,
      );
    } catch (e) {
      // Fallback to system fonts if Google Fonts fails
      textTheme = baseTheme.textTheme.apply(
        bodyColor: textColor,
        displayColor: textColor,
      );
    }
    
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      textTheme: textTheme,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTheme = ThemeData.dark();
    
    // Use a try-catch block to handle potential font loading issues
    TextTheme textTheme;
    try {
      textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme).apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      );
    } catch (e) {
      // Fallback to system fonts if Google Fonts fails
      textTheme = baseTheme.textTheme.apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      );
    }
    
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,
      textTheme: textTheme,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: darkCardColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCardColor,
        foregroundColor: darkTextColor,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryColor),
        ),
      ),
    );
  }
}

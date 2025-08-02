import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.grey[50],
    textTheme: GoogleFonts.robotoTextTheme(),
    
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(  // Đã sửa: CardTheme -> CardThemeData
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
  );
  
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme),
    
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    
    cardTheme: CardThemeData(  // Đã sửa: CardTheme -> CardThemeData
      color: const Color(0xFF1F1F1F),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}
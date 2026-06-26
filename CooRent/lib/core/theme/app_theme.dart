import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
        primary: Colors.indigo,
        secondary: Colors.indigoAccent,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.dark,
        primary: Colors.indigoAccent,
        secondary: Colors.indigo,
        surface: const Color(0xFF121212),
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardTheme(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ライトテーマ
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      colorScheme: const ColorScheme.light(
        primary: Colors.indigo,
        secondary: Colors.teal,
        surface: Color(0xFFF0F2F5),
      ),
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFFF0F2F5),
      ),
    );
  }

  // ダークテーマ
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: Colors.cyanAccent,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: const ColorScheme.dark(
        primary: Colors.cyanAccent,
        secondary: Colors.tealAccent,
        surface: Color(0xFF121212),
      ),
      textTheme: GoogleFonts.notoSansJpTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Color(0xFF1E1E1E),
      ),
    );
  }
}

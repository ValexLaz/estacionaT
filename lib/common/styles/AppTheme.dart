import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      colorScheme: const ColorScheme(
        primary: Color.fromARGB(255, 66, 133, 244),
        primaryContainer: Color.fromARGB(255, 35, 102, 210),
        secondary: Color.fromARGB(200, 27, 141, 228),
        secondaryContainer:  Color.fromRGBO(122, 173, 255, 1),
        surface: Color(0xFFFFFFFF),
        background: Color(0xFFF5F5F5),
        error: Color(0xFFB00020),
        onPrimary: Color(0xFFFFFFFF),
        onSecondary: Color(0xFF000000),
        onSurface: Color(0xFF000000),
        onBackground: Color(0xFF000000),
        onError: Color(0xFFFFFFFF),
        brightness: Brightness.light,
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AppTheme {
  static final dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xffe23d3d),
      brightness: Brightness.dark,
      surface: const Color(0xff111318),
    ),
    scaffoldBackgroundColor: const Color(0xff080a0f),
    cardTheme: CardTheme(
      color: const Color(0xff151922),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xff10131a),
      indicatorColor: Color(0xff273142),
    ),
  );
}

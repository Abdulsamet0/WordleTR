import 'package:flutter/material.dart';

class ThemePalette {
  final Color backgroundColor;
  final Color textColor;
  final Color dialogBackgroundColor;
  final Color keyboardBackgroundColor;
  final Color keyColor;
  final Color emptyBoxColor;
  final Color emptyBoxBorderColor;
  final Color iconColor;
  final Color dividerColor;
  final Color absentKeyColor;

  const ThemePalette({
    required this.backgroundColor,
    required this.textColor,
    required this.dialogBackgroundColor,
    required this.keyboardBackgroundColor,
    required this.keyColor,
    required this.emptyBoxColor,
    required this.emptyBoxBorderColor,
    required this.iconColor,
    required this.dividerColor,
    required this.absentKeyColor,
  });

  static ThemePalette getTheme(int index) {
    switch (index) {
      case 0: // Beyaz (Varsayılan)
        return const ThemePalette(
          backgroundColor: Colors.white,
          textColor: Colors.black,
          dialogBackgroundColor: Color(0xFFF0F0F0),
          keyboardBackgroundColor: Colors.white,
          keyColor: Color(0xFFD3D6DA),
          emptyBoxColor: Colors.transparent,
          emptyBoxBorderColor: Color(0xFFD3D6DA),
          iconColor: Colors.black,
          dividerColor: Color(0xFFD3D6DA),
          absentKeyColor: Color(0xFF787C7E),
        );
      case 1: // Koyu Gri
        return const ThemePalette(
          backgroundColor: Color(0xFF121213),
          textColor: Colors.white,
          dialogBackgroundColor: Color(0xFF1E1E1E),
          keyboardBackgroundColor: Color(0xFF121213),
          keyColor: Color(0xFF818384),
          emptyBoxColor: Colors.transparent,
          emptyBoxBorderColor: Color(0xFF3A3A3C),
          iconColor: Colors.white,
          dividerColor: Color(0xFF3A3A3C),
          absentKeyColor: Color(0xFF3A3A3C),
        );
      case 2: // Gece Mavisi
        return const ThemePalette(
          backgroundColor: Color(0xFF0F172A),
          textColor: Colors.white,
          dialogBackgroundColor: Color(0xFF1E293B),
          keyboardBackgroundColor: Color(0xFF0F172A),
          keyColor: Color(0xFF334155),
          emptyBoxColor: Colors.transparent,
          emptyBoxBorderColor: Color(0xFF334155),
          iconColor: Colors.white,
          dividerColor: Color(0xFF334155),
          absentKeyColor: Color(0xFF1E293B),
        );
      case 3: // Sepya
        return const ThemePalette(
          backgroundColor: Color(0xFFFDF6E3),
          textColor: Color(0xFF4C4035),
          dialogBackgroundColor: Color(0xFFF4ECD8),
          keyboardBackgroundColor: Color(0xFFFDF6E3),
          keyColor: Color(0xFFF1E8D9),
          emptyBoxColor: Colors.transparent,
          emptyBoxBorderColor: Color(0xFFE6DBC8),
          iconColor: Color(0xFF4C4035),
          dividerColor: Color(0xFFE6DBC8),
          absentKeyColor: Color(0xFFA69B8D),
        );
      case 4: // Nane Yeşili
        return const ThemePalette(
          backgroundColor: Color(0xFFF0FFF4),
          textColor: Color(0xFF1A202C),
          dialogBackgroundColor: Color(0xFFE6FFFA),
          keyboardBackgroundColor: Color(0xFFF0FFF4),
          keyColor: Color(0xFFE6FFFA),
          emptyBoxColor: Colors.transparent,
          emptyBoxBorderColor: Color(0xFF9AE6B4),
          iconColor: Color(0xFF1A202C),
          dividerColor: Color(0xFF9AE6B4),
          absentKeyColor: Color(0xFF718096),
        );
      case 5: // Sakura
        return const ThemePalette(
          backgroundColor: Color(0xFFFFF5F5),
          textColor: Color(0xFF4A0E2E),
          dialogBackgroundColor: Color(0xFFFFEBEB),
          keyboardBackgroundColor: Color(0xFFFFF5F5),
          keyColor: Color(0xFFFFEBEB),
          emptyBoxColor: Colors.transparent,
          emptyBoxBorderColor: Color(0xFFFEB2B2),
          iconColor: Color(0xFF4A0E2E),
          dividerColor: Color(0xFFFEB2B2),
          absentKeyColor: Color(0xFFD5A6A6),
        );
      default:
        return getTheme(0);
    }
  }

  static String getThemeName(int index) {
    switch (index) {
      case 0: return "Beyaz Tema";
      case 1: return "Koyu Gri";
      case 2: return "Gece Mavisi";
      case 3: return "Sepya";
      case 4: return "Nane Yeşili";
      case 5: return "Sakura";
      default: return "Beyaz Tema";
    }
  }
}

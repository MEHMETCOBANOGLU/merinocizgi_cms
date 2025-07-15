import 'package:flutter/material.dart';

class AppColors {
  // static const primary = Color(0xFFB4EEDF);
  static final primary = HSLColor.fromColor(const Color(0xFFB4EEDF))
      .withLightness(
          (HSLColor.fromColor(const Color(0xFFB4EEDF)).lightness - 0.05)
              .clamp(0.0, 1.0))
      .toColor();
  static const accent = Color.fromARGB(255, 255, 201, 189);
  static const bg = Color.fromARGB(255, 240, 255, 251);
  static const buttonBg = Colors.black;
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
  static const Color darkColor = Color(0xFF171717);
  static final MaterialColor primarySwatch = generateMaterialColor(
    HSLColor.fromColor(const Color(0xFFB4EEDF))
        .withLightness(
            (HSLColor.fromColor(const Color(0xFFB4EEDF)).lightness - 0.05)
                .clamp(0.0, 1.0))
        .toColor(),
  );
}

MaterialColor generateMaterialColor(Color color) {
  final hslColor = HSLColor.fromColor(color);
  return MaterialColor(
    color.value,
    {
      for (int i = 1; i <= 9; i++)
        i * 100: hslColor
            .withLightness(
                (hslColor.lightness + (i - 5) * 0.05).clamp(0.0, 1.0))
            .toColor(),
    },
  );
}

// A2E7D4
// 9AE6D1
// B4EEDF primary
// C5F1E4
// D5F6ED
// D8F8F0

// class AppColors {
//   static const primary = Color(0xFF82DCC1);
//   static const accent = Color(0xFFFFB2A0);
//   static const bg = Color.fromARGB(255, 240, 255, 251);
//   static const buttonBg = Colors.black;
//   static const textPrimary = Colors.white;
//   static const textSecondary = Colors.white70;
// }

class AppColorsDark {
  static const primary = Color(0xFF82DCC1);
  static const accent = Color(0xFF00F7FF);
  static const bg = Color(0xFF07113C);
  static const buttonBg = Colors.black;
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.white70;
}

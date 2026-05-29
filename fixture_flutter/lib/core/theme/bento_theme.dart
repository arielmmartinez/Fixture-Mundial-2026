import 'package:flutter/material.dart';

class BentoColors {
  // Light Mode Colors
  static const Color soccerGreen = Color(0xFF00D2E5);
  static const Color worldCupGold = Color(0xFFD4AF37);
  static const Color deepSlate = Color(0xFF0F172A);
  static const Color softWhite = Color(0xFFFBFBF9);

  // Dark Mode Colors
  static const Color electricGreen = Color(0xFF00E5FF);
  static const Color bronzeGold = Color(0xFFE5B83B);
  static const Color pitchDark = Color(0xFF070B14);
  static const Color cardDark = Color(0xFF0E1726);

  // Bento helpers
  static const Color bentoBorderLight = Color(0xFFD4AF37);
  static const Color bentoBorderDark = Color(0xFF8F702B);
  static const Color bentoSlate500 = Color(0xFF8F9BB3);
}

class BentoTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: BentoColors.soccerGreen,
      scaffoldBackgroundColor: BentoColors.softWhite,
      cardColor: Colors.white,
      dividerColor: BentoColors.bentoBorderLight,
      colorScheme: const ColorScheme.light(
        primary: BentoColors.soccerGreen,
        secondary: BentoColors.worldCupGold,
        tertiary: BentoColors.deepSlate,
        background: BentoColors.softWhite,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: BentoColors.deepSlate,
        onBackground: BentoColors.deepSlate,
        onSurface: BentoColors.deepSlate,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, color: BentoColors.deepSlate),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: BentoColors.deepSlate),
        titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: BentoColors.deepSlate),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BentoColors.softWhite,
        indicatorColor: BentoColors.soccerGreen.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BentoColors.soccerGreen);
          }
          return const TextStyle(fontSize: 10, color: BentoColors.bentoSlate500);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: BentoColors.soccerGreen);
          }
          return const IconThemeData(color: BentoColors.bentoSlate500);
        }),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: BentoColors.electricGreen,
      scaffoldBackgroundColor: BentoColors.pitchDark,
      cardColor: BentoColors.cardDark,
      dividerColor: BentoColors.bentoBorderDark,
      colorScheme: const ColorScheme.dark(
        primary: BentoColors.electricGreen,
        secondary: BentoColors.bronzeGold,
        tertiary: BentoColors.bronzeGold,
        background: BentoColors.pitchDark,
        surface: BentoColors.cardDark,
        onPrimary: BentoColors.softWhite,
        onSecondary: BentoColors.deepSlate,
        onBackground: BentoColors.softWhite,
        onSurface: BentoColors.softWhite,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, color: BentoColors.softWhite),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: BentoColors.bentoSlate500),
        titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.bold, color: BentoColors.softWhite),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: BentoColors.pitchDark,
        indicatorColor: BentoColors.soccerGreen.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: BentoColors.soccerGreen);
          }
          return const TextStyle(fontSize: 10, color: BentoColors.bentoSlate500);
        }),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: BentoColors.soccerGreen);
          }
          return const IconThemeData(color: BentoColors.bentoSlate500);
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';

abstract final class AppColors {
  // Gradient stops (light mode)
  static const Color gradientTop = Color(0xFFE8D5B7); // warm beige
  static const Color gradientBottom = Color(0xFFCBC3E8); // soft lavender

  // Surface
  static const Color cardBackground = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF5F5F5);

  // Primary action
  static const Color buttonPrimary = Color(0xFF1A1A1A);
  static const Color buttonPrimaryText = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFAAAAAA);

  // Status badges
  static const Color statusPlanning = Color(0xFF6DB8E8);
  static const Color statusActive = Color(0xFF4CAF50);
  static const Color statusFinished = Color(0xFF9E9E9E);

  // Navbar
  static const Color navbarBackground = Colors.white;
  static const Color navbarSelected = Color(0xFF1A1A1A);
  static const Color navbarUnselected = Color(0xFFAAAAAA);

  // Input
  static const Color inputBorder = Color(0xFFE0E0E0);
  static const Color inputFill = Color(0xFFF9F9F9);

  // Link / accent
  static const Color accent = Color(0xFF5B8DEF);

  // Dark mode equivalents
  static const Color darkGradientTop = Color(0xFF2E1F1A);
  static const Color darkGradientBottom = Color(0xFF1E1525);
  static const Color darkCardBackground = Color(0xFF2C2C2E);
  static const Color darkTextPrimary = Color(0xFFF2F2F7);
  static const Color darkTextSecondary = Color(0xFFAEAEB2);
  static const Color darkInputFill = Color(0xFF3A3A3C);
  static const Color darkInputBorder = Color(0xFF48484A);
  static const Color darkNavbarBackground = Color(0xFF1C1C1E);
  static const Color darkNavbarSelected = Color(0xFFF2F2F7);
  static const Color darkNavbarUnselected = Color(0xFF636366);
}

abstract final class AppGradients {
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.gradientTop, AppColors.gradientBottom],
  );

  static const LinearGradient backgroundDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.darkGradientTop, AppColors.darkGradientBottom],
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'SF Pro Display', // falls back to system sans-serif
      colorScheme: ColorScheme.light(
        primary: AppColors.buttonPrimary,
        onPrimary: AppColors.buttonPrimaryText,
        surface: AppColors.cardBackground,
        onSurface: AppColors.textPrimary,
        inverseSurface: AppColors.buttonPrimary,
        onInverseSurface: Colors.white,
      ),
      textTheme: _textTheme(AppColors.textPrimary),
      inputDecorationTheme: _inputDecorationTheme(
        fill: AppColors.inputFill,
        border: AppColors.inputBorder,
        hint: AppColors.textHint,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonPrimary,
          foregroundColor: AppColors.buttonPrimaryText,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.inputBorder, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.buttonPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'SF Pro Display',
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkTextPrimary,
        onPrimary: AppColors.darkCardBackground,
        surface: AppColors.darkCardBackground,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: _textTheme(AppColors.darkTextPrimary),
      inputDecorationTheme: _inputDecorationTheme(
        fill: AppColors.darkInputFill,
        border: AppColors.darkInputBorder,
        hint: AppColors.darkTextSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkTextPrimary,
          foregroundColor: AppColors.darkCardBackground,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          minimumSize: const Size(double.infinity, 54),
          shape: const StadiumBorder(),
          side: const BorderSide(color: AppColors.darkInputBorder, width: 1.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF2C2C2E),
        contentTextStyle: TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _textTheme(Color base) {
    return TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: base,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: base,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: base,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: base,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: base,
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fill,
    required Color border,
    required Color hint,
  }) {
    final outlineBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: border, width: 1),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: hint, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: outlineBorder,
      enabledBorder: outlineBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Palet warna Smart Campus Event (diambil dari desain Figma).
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF00236F);
  static const Color navyLight = Color(0xFF1E3A8A);
  static const Color navyDark = Color(0xFF091124);

  static const Color accent = Color(0xFFFEA619);
  static const Color accentSoft = Color(0xFFFFDDB8);
  static const Color accentDark = Color(0xFF2A1700);

  static const Color periwinkle = Color(0xFFDCE1FF);

  static const Color background = Color(0xFFF7F9FB);
  static const Color surface = Colors.white;
  static const Color surfaceLow = Color(0xFFF2F4F6);
  static const Color surfaceHigh = Color(0xFFECEEF0);
  static const Color outline = Color(0xFFC5C5D3);

  static const Color textPrimary = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF444651);
  static const Color textMuted = Color(0xFF757682);

  static const Color success = Color(0xFF059669);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color danger = Color(0xFFBA1A1A);
}

/// Nama font. Jika file font belum didaftarkan di pubspec.yaml,
/// Flutter otomatis memakai font bawaan sehingga tidak error.
class AppFonts {
  AppFonts._();

  static const String body = 'Inter';
  static const String heading = 'Plus Jakarta Sans';
}

/// Path gambar lokal (Asset Image) yang didaftarkan di pubspec.yaml.
class AppImages {
  AppImages._();

  static const String logo = 'assets/images/logo.png';
}

ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.navy,
    brightness: Brightness.light,
    primary: AppColors.navy,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: AppColors.accentDark,
    error: AppColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: AppFonts.body,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.navy,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.heading,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: AppColors.navy,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.surfaceHigh),
      ),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.navy,
      unselectedLabelColor: AppColors.textMuted,
      indicatorColor: AppColors.navy,
      dividerColor: AppColors.surfaceHigh,
      labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      unselectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.navy,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: AppFonts.body,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

/// Dekorasi input yang dipakai bersama (login, pencarian, dll).
InputDecoration appInputDecoration({
  String? label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    labelText: label,
    hintText: hint,
    hintStyle: const TextStyle(color: AppColors.textMuted),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: AppColors.textMuted, size: 22),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(AppColors.outline),
    enabledBorder: border(AppColors.outline),
    focusedBorder: border(AppColors.navy, 2),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 2),
  );
}
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

/// Palet warna Smart Campus Event — terang, bersih, profesional.
///
/// Mengikuti palet web referensi: satu aksen biru untuk tombol, tautan, dan
/// ikon; teks gelap kebiruan; latar putih/abu kebiruan.
class AppColors {
  AppColors._();

  // --- Aksen biru -------------------------------------------------------------
  static const Color primary = Color(0xFF1D5FD0);
  static const Color primaryHover = Color(0xFF164FB0);

  /// Biru untuk teks, ikon, dan garis aktif (sama dengan [primary]).
  static const Color glow = Color(0xFF1D5FD0);

  /// Biru muda untuk aksen di atas latar gelap (pemindai QR).
  static const Color primaryOnDark = Color(0xFF8FB0FF);

  /// Biru sangat muda: latar ikon, badge, label kecil.
  static const Color primarySoft = Color(0xFFE8F0FD);

  /// Biru muda: avatar, garis panel lembut.
  static const Color primaryTint = Color(0xFFD6E4FB);

  // --- Teks -------------------------------------------------------------------
  /// Teks judul.
  static const Color ink = Color(0xFF0A1A2F);

  static const Color textPrimary = Color(0xFF0A1A2F);
  static const Color textSecondary = Color(0xFF24344A);
  static const Color textMuted = Color(0xFF5A6779);

  /// Teks gelap di atas permukaan terang (tombol putih, kertas, QR).
  static const Color onLight = Color(0xFF0A1A2F);

  // --- Permukaan ----------------------------------------------------------------
  static const Color background = Color(0xFFF4F7FC);
  static const Color surface = Colors.white;
  static const Color surfaceLow = Color(0xFFF4F7FC);
  static const Color surfaceHigh = Color(0xFFE9EEF6);
  static const Color outline = Color(0xFFC9D3E1);

  /// Garis tepi kartu & input.
  static const Color border = Color(0xFFE1E7F0);

  // --- Status ------------------------------------------------------------------
  static const Color success = Color(0xFF1F7A5A);
  static const Color successSoft = Color(0xFFDFF3EA);
  static const Color successStrong = Color(0xFF1F7A5A);

  /// Status "menunggu" (kuning kalem, hanya untuk status).
  static const Color warning = Color(0xFF8A5A00);
  static const Color warningSoft = Color(0xFFFDF1DC);

  static const Color danger = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFDECEA);
  static const Color dangerStrong = Color(0xFFB42318);

  /// Latar halaman pemindai QR (tetap gelap seperti jendela kamera).
  static const Color scannerBg = Color(0xFF07142A);
  static const Color scannerSurface = Color(0xFF10223D);
}

/// Nama font (dibundel di assets/fonts, didaftarkan di pubspec.yaml).
class AppFonts {
  AppFonts._();

  static const String body = 'Inter';
  static const String heading = 'Plus Jakarta Sans';

}

/// Radius sudut yang dipakai konsisten di seluruh aplikasi.
class AppRadius {
  AppRadius._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 22;
}

/// Bayangan lembut.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> soft = [];

  static const List<BoxShadow> raised = [
    BoxShadow(color: Color(0x0D0A1A2F), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(
      color: Color(0x290A1A2F),
      blurRadius: 28,
      spreadRadius: -16,
      offset: Offset(0, 12),
    ),
  ];

  /// Bayangan halus untuk tombol/panel utama.
  static const List<BoxShadow> lift = [
    BoxShadow(
      color: Color(0x261D5FD0),
      blurRadius: 16,
      spreadRadius: -6,
      offset: Offset(0, 6),
    ),
  ];
}

/// Dekorasi panel yang dipakai berulang.
class AppDecorations {
  AppDecorations._();

  /// Gradasi biru diagonal untuk panel utama.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2B6FE0), AppColors.primary, Color(0xFF1550B8)],
  );

  /// Panel biru utama (hero/banner): gradasi + ornamen gelembung
  /// putih transparan agar tidak polos. [borderRadius] menggantikan
  /// [radius] bila perlu sudut berbeda (mis. hanya atas).
  static BoxDecoration brandPanel({
    double radius = AppRadius.xl,
    BorderRadius? borderRadius,
    bool shadow = true,
  }) {
    return BoxDecoration(
      gradient: brandGradient,
      image: const DecorationImage(
        image: AssetImage(AppImages.panelPattern),
        fit: BoxFit.cover,
        alignment: Alignment.topRight,
      ),
      borderRadius: borderRadius ?? BorderRadius.circular(radius),
      boxShadow: shadow ? AppShadows.lift : null,
    );
  }

  /// Kartu putih dengan garis tipis.
  static BoxDecoration card({
    double radius = AppRadius.lg,
    Color color = AppColors.surface,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.border),
    );
  }
}

/// Path gambar lokal (Asset Image) yang didaftarkan di pubspec.yaml.
class AppImages {
  AppImages._();

  static const String logo = 'assets/images/logo.png';

  /// Foto suasana kampus (halaman masuk & splash).
  static const String campus = 'assets/images/campus.jpg';

  /// Ornamen gelembung putih transparan untuk panel biru.
  static const String panelPattern = 'assets/images/pattern_panel.png';
}

/// Bentuk tombol & chip: sudut membulat.
const OutlinedBorder buttonShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(AppRadius.md)),
);

ThemeData buildAppTheme() {
  final ColorScheme scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.primary,
    onSecondary: Colors.white,
    error: AppColors.danger,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textMuted,
    surfaceContainerHighest: AppColors.surfaceHigh,
    outline: AppColors.outline,
    outlineVariant: AppColors.border,
  );

  const TextStyle body = TextStyle(
    fontFamily: AppFonts.body,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );
  const TextStyle heading = TextStyle(
    fontFamily: AppFonts.heading,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  final TextTheme textTheme = TextTheme(
    displaySmall: heading.copyWith(fontSize: 32, letterSpacing: -0.5),
    headlineMedium: heading.copyWith(fontSize: 26, letterSpacing: -0.4),
    headlineSmall: heading.copyWith(fontSize: 22, letterSpacing: -0.3),
    titleLarge: heading.copyWith(fontSize: 19, letterSpacing: -0.2),
    titleMedium: body.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
    titleSmall: body.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
    bodyLarge: body.copyWith(fontSize: 15, height: 1.45),
    bodyMedium: body.copyWith(fontSize: 14, height: 1.45),
    bodySmall: body.copyWith(fontSize: 12, color: AppColors.textMuted),
    labelLarge: body.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: body.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
  );

  const TextStyle buttonText = TextStyle(
    fontFamily: AppFonts.body,
    fontSize: 14.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
  const Size buttonSize = Size(64, 50);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    fontFamily: AppFonts.body,
    textTheme: textTheme,
    scaffoldBackgroundColor: AppColors.background,
    // Transisi halaman: memudar sambil bergeser halus.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    canvasColor: AppColors.background,
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: const DividerThemeData(
      color: AppColors.border,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: AppFonts.heading,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.ink,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    // --- Tombol: sudut terpotong, tinggi seragam ---------------------------
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.surfaceHigh,
        disabledForegroundColor: AppColors.textMuted,
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: buttonShape,
        textStyle: buttonText,
        elevation: 0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: buttonSize,
        shape: buttonShape,
        textStyle: buttonText,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: buttonSize,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: buttonShape,
        foregroundColor: AppColors.glow,
        side: const BorderSide(color: AppColors.outline),
        textStyle: buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.glow,
        shape: buttonShape,
        textStyle: buttonText.copyWith(fontSize: 13.5),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: AppColors.textPrimary),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textSecondary,
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
        side: const BorderSide(color: AppColors.border),
        shape: buttonShape,
        textStyle: buttonText.copyWith(fontSize: 13),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surface,
      selectedColor: AppColors.primary,
      disabledColor: AppColors.surfaceLow,
      side: const BorderSide(color: AppColors.border),
      shape: buttonShape,
      showCheckmark: false,
      labelStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) =>
            s.contains(WidgetState.selected) ? AppColors.primary : null,
      ),
      checkColor: WidgetStateProperty.all(Colors.white),
      side: const BorderSide(color: AppColors.outline, width: 1.5),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) => s.contains(WidgetState.selected)
            ? AppColors.glow
            : AppColors.outline,
      ),
    ),
    // --- Navigasi -----------------------------------------------------------
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppColors.primarySoft,
      elevation: 0,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        final bool selected = s.contains(WidgetState.selected);
        return TextStyle(
          fontFamily: AppFonts.body,
          fontSize: 11.5,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? AppColors.glow : AppColors.textMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> s) {
        return IconThemeData(
          size: 23,
          color: s.contains(WidgetState.selected)
              ? AppColors.glow
              : AppColors.textMuted,
        );
      }),
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.glow,
      unselectedLabelColor: AppColors.textMuted,
      indicatorColor: AppColors.glow,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: AppColors.border,
      labelStyle: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ),
    // --- Permukaan mengambang -----------------------------------------------
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.border),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppFonts.heading,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.ink,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14,
        height: 1.5,
        color: AppColors.textSecondary,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: AppColors.outline,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: AppColors.border),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: const TimePickerThemeData(
      backgroundColor: AppColors.surface,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.ink,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontFamily: AppFonts.body,
        fontSize: 13.5,
      ),
      actionTextColor: AppColors.primaryOnDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) => s.contains(WidgetState.selected)
            ? AppColors.primary
            : AppColors.surfaceHigh,
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith(
        (Set<WidgetState> s) => s.contains(WidgetState.selected)
            ? Colors.transparent
            : AppColors.outline,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.glow,
      linearTrackColor: AppColors.surfaceHigh,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.glow,
      selectionColor: AppColors.primaryTint,
      selectionHandleColor: AppColors.glow,
    ),
    inputDecorationTheme: _inputTheme(),
  );
}

InputDecorationTheme _inputTheme() {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    isDense: false,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    hintStyle: const TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14.5,
      color: AppColors.textMuted,
    ),
    labelStyle: const TextStyle(
      fontFamily: AppFonts.body,
      fontSize: 14.5,
      color: AppColors.textMuted,
    ),
    floatingLabelStyle: const TextStyle(color: AppColors.glow),
    helperStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
    counterStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
    border: border(AppColors.border),
    enabledBorder: border(AppColors.border),
    disabledBorder: border(AppColors.border),
    focusedBorder: border(AppColors.glow, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
    errorStyle: const TextStyle(fontSize: 12, color: AppColors.danger),
    prefixIconColor: AppColors.textMuted,
    suffixIconColor: AppColors.textMuted,
  );
}

/// Dekorasi input yang dipakai bersama (login, pencarian, dll).
///
/// Warna, garis tepi, dan jarak diambil dari inputDecorationTheme di
/// [buildAppTheme]; fungsi ini hanya mengisi teks dan ikon.
InputDecoration appInputDecoration({
  String? label,
  String? hint,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
    suffixIcon: suffixIcon,
  );
}

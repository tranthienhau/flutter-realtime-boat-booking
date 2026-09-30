import 'package:flutter/material.dart';

/// Tokens ported 1:1 from the Stitch design system (design/DESIGN.md).
class AppColors {
  static const bg = Color(0xFFF9F8F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF1EEEA);
  static const graphite = Color(0xFF2B2A28);
  static const graphitePressed = Color(0xFF1C1B1A);
  static const graphiteTint = Color(0xFFEAE9E8);
  static const brass = Color(0xFFD4B06A);
  static const brassTint = Color(0xFFF7EFDD);
  static const brassText = Color(0xFF8A6A2A);
  static const text = Color(0xFF181614);
  static const text2 = Color(0xFF5E5952);
  static const text3 = Color(0xFF8A8580);
  static const hairline = Color(0xFFE7E3DD);
  static const disabled = Color(0xFFD9D5CF);
  static const success = Color(0xFF16A34A);
  static const successTint = Color(0xFFE6F4EA);
  static const warning = Color(0xFFD97706);
  static const warningTint = Color(0xFFFDF1E0);
  static const danger = Color(0xFFDC2626);
}

class AppRadius {
  static const card = 20.0;
  static const control = 14.0;
  static const input = 12.0;
}

const kCardShadow = [
  BoxShadow(color: Color(0x0A181614), blurRadius: 2, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x0F181614), blurRadius: 24, offset: Offset(0, 8)),
];

/// Montserrat for UI + numerals, Playfair Display for hero titles.
class T {
  static TextStyle display({double size = 32, Color color = AppColors.text}) => TextStyle(
      fontFamily: 'Playfair Display',
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.4,
      height: 1.15);
  static TextStyle title({double size = 20, Color color = AppColors.text}) =>
      TextStyle(fontFamily: 'Montserrat', fontSize: size, fontWeight: FontWeight.w600, color: color, height: 1.25);
  static TextStyle body({double size = 16, Color color = AppColors.text2, FontWeight w = FontWeight.w400}) =>
      TextStyle(fontFamily: 'Montserrat', fontSize: size, fontWeight: w, color: color, height: 1.45);
  static TextStyle label({double size = 14, Color color = AppColors.text, FontWeight w = FontWeight.w500}) =>
      TextStyle(fontFamily: 'Montserrat', fontSize: size, fontWeight: w, color: color);
  static TextStyle caption({Color color = AppColors.text3, double size = 13, FontWeight w = FontWeight.w500}) =>
      TextStyle(fontFamily: 'Montserrat', fontSize: size, fontWeight: w, color: color);
  static TextStyle overline({Color color = AppColors.text3}) =>
      TextStyle(fontFamily: 'Montserrat', fontSize: 11, fontWeight: FontWeight.w600, color: color, letterSpacing: 1.1);
  static TextStyle numeral({double size = 32, Color color = AppColors.text, FontWeight w = FontWeight.w700}) =>
      TextStyle(
          fontFamily: 'Montserrat',
          fontSize: size,
          fontWeight: w,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()]);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.graphite,
      primary: AppColors.graphite,
      secondary: AppColors.brass,
      surface: AppColors.surface,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'Montserrat', bodyColor: AppColors.text, displayColor: AppColors.text),
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.brass : Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.graphite : AppColors.disabled),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.graphite,
      contentTextStyle:
          TextStyle(fontFamily: 'Montserrat', color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.control)),
    ),
  );
}

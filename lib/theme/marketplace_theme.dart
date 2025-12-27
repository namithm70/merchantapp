import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketplaceTheme {
  static ThemeData light() {
    const seed = Color(0xFF102A43);
    const sand = Color(0xFFF6F2EC);
    const mist = Color(0xFFFDFBF8);
    const lagoon = Color(0xFF2F9C95);
    const sunset = Color(0xFFF5A06A);
    const ink = Color(0xFF1B2430);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      surface: mist,
      secondary: lagoon,
      tertiary: sunset,
      onSurface: ink,
      onPrimary: Colors.white,
    );

    final baseText = GoogleFonts.spaceGroteskTextTheme();
    final display = GoogleFonts.frauncesTextTheme();

    final textTheme = baseText.copyWith(
      headlineLarge: display.headlineLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      headlineMedium: display.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      titleLarge: display.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        color: ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: sand,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      cardTheme: CardThemeData(
        color: mist,
        elevation: 1.2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: mist,
        selectedColor: lagoon.withValues(alpha: 0.2),
        labelStyle: textTheme.labelMedium?.copyWith(color: ink),
        side: BorderSide(color: seed.withValues(alpha: 0.08)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mist,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seed.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seed.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: seed, width: 1.4),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: mist,
        indicatorColor: sunset.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        height: 70,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: seed.withValues(alpha: 0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: seed,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

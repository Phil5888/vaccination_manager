import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  // ── Vitalis Blue (light) ─────────────────────────────────────────────────
  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF00478D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF005EB8),
    onPrimaryContainer: Color(0xFFC8DAFF),
    secondary: Color(0xFF006A6A),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFF8CF3F3),
    onSecondaryContainer: Color(0xFF007070),
    tertiary: Color(0xFF5F4300),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFF7D5900),
    onTertiaryContainer: Color(0xFFFFD489),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF93000A),
    surface: Color(0xFFF8F9FA),
    onSurface: Color(0xFF191C1D),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF3F4F5),
    surfaceContainer: Color(0xFFEDEEEF),
    surfaceContainerHigh: Color(0xFFE7E8E9),
    surfaceContainerHighest: Color(0xFFE1E3E4),
    onSurfaceVariant: Color(0xFF424752),
    outline: Color(0xFF727783),
    outlineVariant: Color(0xFFC2C6D4),
    inverseSurface: Color(0xFF2E3132),
    onInverseSurface: Color(0xFFF0F1F2),
    inversePrimary: Color(0xFFA9C7FF),
    surfaceTint: Color(0xFF005DB6),
  );

  // ── Vitalis Midnight (dark) ──────────────────────────────────────────────
  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF85ADFF),
    onPrimary: Color(0xFF002E6E),
    primaryContainer: Color(0xFF004099),
    onPrimaryContainer: Color(0xFFD6E3FF),
    secondary: Color(0xFF4DD9D9),
    onSecondary: Color(0xFF003737),
    secondaryContainer: Color(0xFF005050),
    onSecondaryContainer: Color(0xFF6FF6F6),
    tertiary: Color(0xFFFBABFF),
    onTertiary: Color(0xFF5A005E),
    tertiaryContainer: Color(0xFF7E0083),
    onTertiaryContainer: Color(0xFFFFD6FE),
    error: Color(0xFFFF716C),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF060E20),
    onSurface: Color(0xFFDEE5FF),
    surfaceContainerLowest: Color(0xFF010915),
    surfaceContainerLow: Color(0xFF091328),
    surfaceContainer: Color(0xFF0F1930),
    surfaceContainerHigh: Color(0xFF192338),
    surfaceContainerHighest: Color(0xFF1F2B49),
    onSurfaceVariant: Color(0xFFA3AAC4),
    outline: Color(0xFF6D7490),
    outlineVariant: Color(0xFF40485D),
    inverseSurface: Color(0xFFDEE5FF),
    onInverseSurface: Color(0xFF06163A),
    inversePrimary: Color(0xFF00478D),
    surfaceTint: Color(0xFF85ADFF),
  );

  // ── Shared text theme helpers ────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color foreground) {
    final headlineStyle = GoogleFonts.manropeTextTheme().copyWith(
      displayLarge: GoogleFonts.manrope(
          color: foreground, fontSize: 57, fontWeight: FontWeight.w400),
      displayMedium: GoogleFonts.manrope(
          color: foreground, fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall: GoogleFonts.manrope(
          color: foreground, fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge: GoogleFonts.manrope(
          color: foreground, fontSize: 32, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.manrope(
          color: foreground, fontSize: 28, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.manrope(
          color: foreground, fontSize: 24, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.manrope(
          color: foreground, fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.inter(
          color: foreground, fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.inter(
          color: foreground, fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.inter(
          color: foreground, fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.inter(
          color: foreground, fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: GoogleFonts.inter(
          color: foreground, fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.inter(
          color: foreground, fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: GoogleFonts.inter(
          color: foreground, fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.inter(
          color: foreground, fontSize: 11, fontWeight: FontWeight.w500),
    );
    return headlineStyle;
  }

  static final light = ThemeData(
    useMaterial3: true,
    colorScheme: _lightScheme,
    textTheme: _buildTextTheme(const Color(0xFF191C1D)),
    scaffoldBackgroundColor: const Color(0xFFF8F9FA),
  );

  static final dark = ThemeData(
    useMaterial3: true,
    colorScheme: _darkScheme,
    textTheme: _buildTextTheme(const Color(0xFFDEE5FF)),
    scaffoldBackgroundColor: const Color(0xFF060E20),
  );
}


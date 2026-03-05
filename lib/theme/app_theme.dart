// ============================================================
//  FILE: lib/theme/app_theme.dart
//
//  All colours, text styles and decoration are centralised
//  here so the rest of the app stays clean.
// ============================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Colour palette ─────────────────────────────────────────
  static const Color bg          = Color(0xFF0D0D1A); // deep navy-black
  static const Color surface     = Color(0xFF1A1A2E); // card background
  static const Color surfaceAlt  = Color(0xFF16213E); // slight variant
  static const Color accent      = Color(0xFF6C63FF); // vivid purple
  static const Color accentLight = Color(0xFF9D97FF); // lighter purple
  static const Color gold        = Color(0xFFFFD700); // grade highlight
  static const Color success     = Color(0xFF2ECC71); // pass colour
  static const Color danger      = Color(0xFFE74C3C); // fail colour
  static const Color textPrimary = Color(0xFFEAEAFF);
  static const Color textSecond  = Color(0xFF9B9BC8);
  static const Color divider     = Color(0xFF2A2A4A);

  // ── Grade colours ───────────────────────────────────────────
  static Color gradeColor(String grade) {
    return switch (grade) {
      'A'  => const Color(0xFF2ECC71),
      'B+' => const Color(0xFF27AE60),
      'B'  => const Color(0xFF3498DB),
      'C+' => const Color(0xFF2980B9),
      'C'  => const Color(0xFFF39C12),
      'D+' => const Color(0xFFE67E22),
      'D'  => const Color(0xFFE74C3C),
      _    => const Color(0xFF95A5A6),
    };
  }

  // ── Typography ──────────────────────────────────────────────
  static TextTheme get textTheme => TextTheme(
        displayLarge: GoogleFonts.rajdhani(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.rajdhani(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: GoogleFonts.rajdhani(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.rajdhani(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: textSecond,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
      );

  // ── MaterialTheme ────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentLight,
          surface: surface,
          error: danger,
        ),
        textTheme: textTheme,
        dividerColor: divider,
        cardTheme: CardTheme(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: divider),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceAlt,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 2),
          ),
          labelStyle: const TextStyle(color: textSecond),
          hintStyle: const TextStyle(color: textSecond),
        ),
      );
}
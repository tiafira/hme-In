import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografi Plus Jakarta Sans sesuai token ukuran teks di HTML referensi:
/// - headline-xl: 28 / 36 bold (w700)
/// - headline-lg: 22 / 30 bold (w700)
/// - headline-md: 18 / 26 semibold (w600)
/// - headline-sm: 16 / 24 semibold (w600)
/// - body-lg:     15 / 22 regular (w400)
/// - body-md:     14 / 20 regular (w400)
/// - body-sm:     12 / 18 regular (w400)
/// - label-lg:    14 / 20 semibold (w600)
/// - label-md:    12 / 16 semibold (w600)
/// - label-sm:    10 / 14 bold (w700), letterSpacing 0.5
class AppTypography {
  AppTypography._();

  static TextStyle get headlineXl => GoogleFonts.plusJakartaSans(
        fontSize: 28,
        height: 36 / 28,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.3,
      );

  static TextStyle get headlineLg => GoogleFonts.plusJakartaSans(
        fontSize: 22,
        height: 30 / 22,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
        letterSpacing: -0.2,
      );

  static TextStyle get headlineMd => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get headlineSm => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyLg => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        height: 22 / 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodyMd => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurface,
      );

  static TextStyle get bodySm => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 18 / 12,
        fontWeight: FontWeight.w400,
        color: AppColors.onSurfaceVariant,
      );

  static TextStyle get labelLg => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get labelMd => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        color: AppColors.onSurface,
      );

  static TextStyle get labelSm => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        height: 14 / 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      );

  static TextTheme get textTheme => TextTheme(
        displaySmall: headlineXl,
        headlineLarge: headlineXl,
        headlineMedium: headlineLg,
        headlineSmall: headlineMd,
        titleLarge: headlineMd,
        titleMedium: headlineSm,
        titleSmall: labelLg,
        bodyLarge: bodyLg,
        bodyMedium: bodyMd,
        bodySmall: bodySm,
        labelLarge: labelLg,
        labelMedium: labelMd,
        labelSmall: labelSm,
      );
}

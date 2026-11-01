import 'package:flutter/material.dart';

/// Token warna Material 3 dari desain referensi HTML Tailwind "Home-In".
class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF005CAB);
  static const Color primaryContainer = Color(0xFF0075D5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFEFCFF);
  static const Color primaryFixed = Color(0xFFD4E3FF);
  static const Color primaryFixedDim = Color(0xFFA5C8FF);
  static const Color onPrimaryFixed = Color(0xFF001C3A);
  static const Color onPrimaryFixedVariant = Color(0xFF004785);
  static const Color inversePrimary = Color(0xFFA5C8FF);

  // Secondary
  static const Color secondary = Color(0xFF00668A);
  static const Color secondaryContainer = Color(0xFF8CD5FF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF005D7F);
  static const Color secondaryFixed = Color(0xFFC4E7FF);
  static const Color secondaryFixedDim = Color(0xFF85CFFA);
  static const Color onSecondaryFixed = Color(0xFF001E2C);
  static const Color onSecondaryFixedVariant = Color(0xFF004C69);

  // Tertiary (Hijau Aksen Masuk / Siap Huni / Live Sync)
  static const Color tertiary = Color(0xFF006948);
  static const Color tertiaryContainer = Color(0xFF00855C);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFFF5FFF7);
  static const Color tertiaryFixed = Color(0xFF7BFAC1);
  static const Color tertiaryFixedDim = Color(0xFF5CDDA6);
  static const Color onTertiaryFixed = Color(0xFF002114);
  static const Color onTertiaryFixedVariant = Color(0xFF005237);

  // Error (Nunggak / Lewat Jam Malam / Peringatan)
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF93000A);

  // Warning (Kuning/Amber untuk Masa Tinggal <= 7 Hari / Menunggu Konfirmasi)
  static const Color warning = Color(0xFFB25E02);
  static const Color warningContainer = Color(0xFFFFE0B2);
  static const Color onWarningContainer = Color(0xFF4E2600);

  // Surface & Background
  static const Color surface = Color(0xFFF8F9FF);
  static const Color background = Color(0xFFF8F9FF);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceDim = Color(0xFFD0DBEB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFEEF4FF);
  static const Color surfaceContainer = Color(0xFFE4EFFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE9FA);
  static const Color surfaceContainerHighest = Color(0xFFD8E3F4);
  static const Color surfaceVariant = Color(0xFFD8E3F4);
  static const Color surfaceTint = Color(0xFF005FAF);

  // On-Surface & Outline
  static const Color onSurface = Color(0xFF111C28);
  static const Color onBackground = Color(0xFF111C28);
  static const Color onSurfaceVariant = Color(0xFF414752);
  static const Color outline = Color(0xFF717784);
  static const Color outlineVariant = Color(0xFFC1C7D4);

  // Inverse
  static const Color inverseSurface = Color(0xFF26313E);
  static const Color inverseOnSurface = Color(0xFFE9F1FF);

  // Gradients
  static const LinearGradient primaryClockGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );
}

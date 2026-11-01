import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// ThemeExtension khusus Home-In untuk menyimpan token radius, spacing,
/// warna surface bertingkat, dan bayangan lembut biru sesuai desain HTML.
@immutable
class HomeInTokens extends ThemeExtension<HomeInTokens> {
  const HomeInTokens({
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.primaryFixed,
    required this.primaryFixedDim,
    required this.secondaryFixed,
    required this.onSecondaryFixedVariant,
    required this.tertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryContainer,
    required this.warning,
    required this.warningContainer,
    required this.radiusDefault,
    required this.radiusLg,
    required this.radiusXl,
    required this.radiusPill,
    required this.pageMargin,
    required this.gutter,
    required this.guardActionMinHeight,
    required this.softBlueShadow,
    required this.elevatedBlueShadow,
    required this.alertRedShadow,
    required this.pillNavShadow,
    required this.clockGradient,
  });

  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color primaryFixed;
  final Color primaryFixedDim;
  final Color secondaryFixed;
  final Color onSecondaryFixedVariant;
  final Color tertiaryFixed;
  final Color tertiaryFixedDim;
  final Color onTertiaryContainer;
  final Color warning;
  final Color warningContainer;

  final double radiusDefault; // 16
  final double radiusLg; // 32
  final double radiusXl; // 48
  final double radiusPill; // 9999

  final double pageMargin; // 20
  final double gutter; // 16
  final double guardActionMinHeight; // 64

  final List<BoxShadow> softBlueShadow;
  final List<BoxShadow> elevatedBlueShadow;
  final List<BoxShadow> alertRedShadow;
  final List<BoxShadow> pillNavShadow;
  final Gradient clockGradient;

  static const HomeInTokens light = HomeInTokens(
    surfaceContainerLowest: AppColors.surfaceContainerLowest,
    surfaceContainerLow: AppColors.surfaceContainerLow,
    surfaceContainer: AppColors.surfaceContainer,
    surfaceContainerHigh: AppColors.surfaceContainerHigh,
    surfaceContainerHighest: AppColors.surfaceContainerHighest,
    primaryFixed: AppColors.primaryFixed,
    primaryFixedDim: AppColors.primaryFixedDim,
    secondaryFixed: AppColors.secondaryFixed,
    onSecondaryFixedVariant: AppColors.onSecondaryFixedVariant,
    tertiaryFixed: AppColors.tertiaryFixed,
    tertiaryFixedDim: AppColors.tertiaryFixedDim,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    warning: AppColors.warning,
    warningContainer: AppColors.warningContainer,
    radiusDefault: 16.0,
    radiusLg: 32.0,
    radiusXl: 48.0,
    radiusPill: 9999.0,
    pageMargin: 20.0,
    gutter: 16.0,
    guardActionMinHeight: 64.0,
    softBlueShadow: [
      BoxShadow(
        color: Color(0x14005CAB), // rgba(0, 92, 171, 0.08)
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
    elevatedBlueShadow: [
      BoxShadow(
        color: Color(0x47005CAB), // rgba(0, 92, 171, 0.28)
        blurRadius: 28,
        offset: Offset(0, 12),
      ),
    ],
    alertRedShadow: [
      BoxShadow(
        color: Color(0x24BA1A1A), // rgba(186, 26, 26, 0.14)
        blurRadius: 26,
        offset: Offset(0, 10),
      ),
    ],
    pillNavShadow: [
      BoxShadow(
        color: Color(0x1F1C2733), // rgba(28, 39, 51, 0.12)
        blurRadius: 40,
        offset: Offset(0, 16),
      ),
    ],
    clockGradient: AppColors.primaryClockGradient,
  );

  @override
  HomeInTokens copyWith({
    Color? surfaceContainerLowest,
    Color? surfaceContainerLow,
    Color? surfaceContainer,
    Color? surfaceContainerHigh,
    Color? surfaceContainerHighest,
    Color? primaryFixed,
    Color? primaryFixedDim,
    Color? secondaryFixed,
    Color? onSecondaryFixedVariant,
    Color? tertiaryFixed,
    Color? tertiaryFixedDim,
    Color? onTertiaryContainer,
    Color? warning,
    Color? warningContainer,
    double? radiusDefault,
    double? radiusLg,
    double? radiusXl,
    double? radiusPill,
    double? pageMargin,
    double? gutter,
    double? guardActionMinHeight,
    List<BoxShadow>? softBlueShadow,
    List<BoxShadow>? elevatedBlueShadow,
    List<BoxShadow>? alertRedShadow,
    List<BoxShadow>? pillNavShadow,
    Gradient? clockGradient,
  }) {
    return HomeInTokens(
      surfaceContainerLowest:
          surfaceContainerLowest ?? this.surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow ?? this.surfaceContainerLow,
      surfaceContainer: surfaceContainer ?? this.surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh ?? this.surfaceContainerHigh,
      surfaceContainerHighest:
          surfaceContainerHighest ?? this.surfaceContainerHighest,
      primaryFixed: primaryFixed ?? this.primaryFixed,
      primaryFixedDim: primaryFixedDim ?? this.primaryFixedDim,
      secondaryFixed: secondaryFixed ?? this.secondaryFixed,
      onSecondaryFixedVariant:
          onSecondaryFixedVariant ?? this.onSecondaryFixedVariant,
      tertiaryFixed: tertiaryFixed ?? this.tertiaryFixed,
      tertiaryFixedDim: tertiaryFixedDim ?? this.tertiaryFixedDim,
      onTertiaryContainer: onTertiaryContainer ?? this.onTertiaryContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      radiusDefault: radiusDefault ?? this.radiusDefault,
      radiusLg: radiusLg ?? this.radiusLg,
      radiusXl: radiusXl ?? this.radiusXl,
      radiusPill: radiusPill ?? this.radiusPill,
      pageMargin: pageMargin ?? this.pageMargin,
      gutter: gutter ?? this.gutter,
      guardActionMinHeight: guardActionMinHeight ?? this.guardActionMinHeight,
      softBlueShadow: softBlueShadow ?? this.softBlueShadow,
      elevatedBlueShadow: elevatedBlueShadow ?? this.elevatedBlueShadow,
      alertRedShadow: alertRedShadow ?? this.alertRedShadow,
      pillNavShadow: pillNavShadow ?? this.pillNavShadow,
      clockGradient: clockGradient ?? this.clockGradient,
    );
  }

  @override
  HomeInTokens lerp(ThemeExtension<HomeInTokens>? other, double t) {
    if (other is! HomeInTokens) return this;
    return this;
  }
}

extension HomeInThemeExtension on BuildContext {
  HomeInTokens get tokens =>
      Theme.of(this).extension<HomeInTokens>() ?? HomeInTokens.light;
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      surfaceContainerLowest: AppColors.surfaceContainerLowest,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      surfaceContainer: AppColors.surfaceContainer,
      surfaceContainerHigh: AppColors.surfaceContainerHigh,
      surfaceContainerHighest: AppColors.surfaceContainerHighest,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      inversePrimary: AppColors.inversePrimary,
      surfaceTint: AppColors.surfaceTint,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: AppTypography.textTheme,
      extensions: const [HomeInTokens.light],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headlineMd,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        labelStyle: AppTypography.labelLg.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.labelLg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.outlineVariant),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: AppTypography.labelLg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.inverseOnSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Komponen ErrorState untuk menangani kondisi gagal muat data atau offline
/// dengan pesan ramah dalam bahasa Indonesia dan tombol coba lagi.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title = 'Terjadi Kendala',
    this.isOffline = false,
    this.onRetry,
  });

  final String title;
  final String message;
  final bool isOffline;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(tokens.pageMargin),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: tokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            boxShadow: tokens.softBlueShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  isOffline ? Symbols.wifi_off : Symbols.error_outline,
                  size: 30,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isOffline ? 'Tidak Ada Koneksi Internet' : title,
                textAlign: TextAlign.center,
                style: AppTypography.headlineSm,
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Symbols.refresh, size: 18),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

enum StatCardVariant {
  primary,
  tertiary,
  secondary,
  errorAlert,
}

/// Kartu ringkasan metrik (2x2 Grid di Beranda Admin/Owner & Penghuni)
/// dengan sudut rounded-32 (`radiusLg`), bayangan lembut biru, dan varian alert merah.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.badgeText,
    required this.value,
    required this.label,
    this.variant = StatCardVariant.primary,
    this.showBadgeDot = false,
    this.onTap,
  });

  final IconData icon;
  final String badgeText;
  final String value;
  final String label;
  final StatCardVariant variant;
  final bool showBadgeDot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final isAlert = variant == StatCardVariant.errorAlert;

    final Color cardBg = isAlert
        ? AppColors.errorContainer
        : tokens.surfaceContainerLowest;

    final Color iconCircleBg = switch (variant) {
      StatCardVariant.primary => tokens.surfaceContainerLow,
      StatCardVariant.tertiary => tokens.surfaceContainerLow,
      StatCardVariant.secondary => tokens.secondaryFixed,
      StatCardVariant.errorAlert => tokens.surfaceContainerLowest,
    };

    final Color iconColor = switch (variant) {
      StatCardVariant.primary => AppColors.primary,
      StatCardVariant.tertiary => AppColors.tertiary,
      StatCardVariant.secondary => AppColors.primary,
      StatCardVariant.errorAlert => AppColors.error,
    };

    final Color badgeBg = switch (variant) {
      StatCardVariant.primary => tokens.surfaceContainer,
      StatCardVariant.tertiary => tokens.surfaceContainer,
      StatCardVariant.secondary => tokens.secondaryFixed,
      StatCardVariant.errorAlert => tokens.surfaceContainerLowest,
    };

    final Color badgeFg = switch (variant) {
      StatCardVariant.primary => AppColors.onSurfaceVariant,
      StatCardVariant.tertiary => AppColors.tertiary,
      StatCardVariant.secondary => AppColors.primary,
      StatCardVariant.errorAlert => AppColors.error,
    };

    final Color valueColor = isAlert ? AppColors.error : AppColors.onSurface;
    final Color labelColor =
        isAlert ? AppColors.error : AppColors.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            boxShadow: isAlert ? tokens.alertRedShadow : tokens.softBlueShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconCircleBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (showBadgeDot) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: badgeFg,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              badgeText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSm.copyWith(
                                color: badgeFg,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineXl.copyWith(
                      color: valueColor,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: labelColor,
                      fontWeight: isAlert ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

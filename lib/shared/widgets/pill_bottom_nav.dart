import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

class PillNavItem {
  const PillNavItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final int badgeCount;
}

/// Bottom navigation bar berbentuk pill melayang dengan efek backdrop blur
/// sesuai desain HTML Penjaga dan Admin/Owner.
class PillBottomNav extends StatelessWidget {
  const PillBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<PillNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          tokens.pageMargin,
          0,
          tokens.pageMargin,
          12,
        ),
        child: Center(
          heightFactor: 1.0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(tokens.radiusPill),
                boxShadow: tokens.pillNavShadow,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusPill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: tokens.surfaceContainerLowest.withValues(
                        alpha: 0.92,
                      ),
                      borderRadius: BorderRadius.circular(tokens.radiusPill),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: List.generate(items.length, (index) {
                        final item = items[index];
                        final isSelected = index == currentIndex;

                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onTap(index),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOutCubic,
                              height: 48,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusPill,
                                ),
                                boxShadow: isSelected
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x54005CAB),
                                          blurRadius: 18,
                                          offset: Offset(0, 6),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 20,
                                        color: isSelected
                                            ? AppColors.onPrimary
                                            : AppColors.onSurfaceVariant,
                                      ),
                                      if (item.badgeCount > 0)
                                        Positioned(
                                          right: -6,
                                          top: -4,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.error,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors.primary
                                                    : Colors.white,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: Text(
                                              item.badgeCount > 99
                                                  ? '99+'
                                                  : '${item.badgeCount}',
                                              style: AppTypography.labelSm
                                                  .copyWith(
                                                    fontSize: 8,
                                                    color: AppColors.onError,
                                                  ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      item.label,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTypography.labelMd.copyWith(
                                        color: isSelected
                                            ? AppColors.onPrimary
                                            : AppColors.onSurfaceVariant,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

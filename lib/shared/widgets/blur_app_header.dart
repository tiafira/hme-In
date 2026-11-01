import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

/// Header atas dengan efek backdrop blur sesuai HTML Penjaga & Admin/Owner.
class BlurAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const BlurAppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.unreadNotificationCount = 0,
    this.onNotificationTap,
    this.onProfileTap,
    this.extraActions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final List<Widget> extraActions;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.88),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F1E7FE0),
                blurRadius: 20,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: tokens.pageMargin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          if (leading != null) ...[
                            leading!,
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (subtitle != null)
                                  Text(
                                    subtitle!.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.secondary,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                Text(
                                  title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTypography.headlineMd,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...extraActions,
                        if (onNotificationTap != null)
                          IconButton(
                            onPressed: onNotificationTap,
                            tooltip: 'Buka Notifikasi',
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Symbols.notifications,
                                  size: 22,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                if (unreadNotificationCount > 0)
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        if (onProfileTap != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onProfileTap,
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x33005CAB),
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Symbols.person,
                                size: 18,
                                color: AppColors.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

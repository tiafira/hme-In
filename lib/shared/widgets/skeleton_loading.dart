import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Komponen animasi Skeleton loading halus untuk state memuat data.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 12,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final color = Color.lerp(
          AppColors.surfaceContainer,
          AppColors.surfaceContainerHighest,
          _controller.value,
        );
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

/// Kartu skeleton untuk mewakili daftar kartu saat sedang memuat dari API.
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 3,
    this.cardHeight = 112,
  });

  final int itemCount;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Column(
      children: List.generate(itemCount, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 14),
          child: Container(
            height: cardHeight,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: tokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(tokens.radiusLg),
              boxShadow: tokens.softBlueShadow,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 44, height: 44, borderRadius: 999),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 140, height: 16),
                          SizedBox(height: 8),
                          SkeletonBox(width: 96, height: 12),
                        ],
                      ),
                    ),
                    SkeletonBox(width: 72, height: 24, borderRadius: 999),
                  ],
                ),
                SkeletonBox(width: double.infinity, height: 14),
              ],
            ),
          ),
        );
      }),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';

enum StatusBadgeTone {
  success, // Hijau (Lunas, Aktif, Sesuai Aturan, Siap Huni, Disetujui)
  info, // Biru (Terisi, Diproses, Standby)
  warning, // Amber/Kuning (Menunggu Konfirmasi, Dibooking, <= 7 Hari)
  danger, // Merah (Nunggak, Telat, Lewat Jam Malam, Ditolak)
  neutral, // Abu/Surface (Selesai Berkunjung, Nonaktif, Maintenance)
  solidDanger, // Pill merah solid (Nunggak Rp 1.850.000)
}

/// Badge status berbentuk pill sesuai referensi HTML Penjaga dan Admin.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = StatusBadgeTone.info,
    this.icon,
    this.compact = false,
  });

  final String label;
  final StatusBadgeTone tone;
  final IconData? icon;
  final bool compact;

  /// Helper otomatis menentukan tone dari string status backend database.
  factory StatusBadge.fromStatus(
    String rawStatus, {
    String? customLabel,
    IconData? icon,
    bool compact = false,
  }) {
    final normalized = rawStatus.trim().toLowerCase();
    final (tone, defaultText) = switch (normalized) {
      'lunas' ||
      'aktif' ||
      'kosong' ||
      'disetujui' ||
      'dikonfirmasi' ||
      'diterima' ||
      'hadir' =>
        (StatusBadgeTone.success, _humanize(normalized)),
      'terisi' || 'diproses' => (StatusBadgeTone.info, _humanize(normalized)),
      'menunggu' ||
      'menunggu_konfirmasi' ||
      'menunggu_pembayaran' ||
      'menunggu_persetujuan' ||
      'ditawarkan_alternatif' ||
      'dibooking' ||
      'baru' ||
      'terlambat' =>
        (StatusBadgeTone.warning, _humanize(normalized)),
      'telat' ||
      'nunggak' ||
      'belum_bayar' ||
      'ditolak' ||
      'darurat' ||
      'alpha' =>
        (StatusBadgeTone.danger, _humanize(normalized)),
      _ => (StatusBadgeTone.neutral, _humanize(normalized)),
    };

    return StatusBadge(
      label: customLabel ?? defaultText,
      tone: tone,
      icon: icon,
      compact: compact,
    );
  }

  static String _humanize(String status) {
    return status
        .split('_')
        .where((e) => e.isNotEmpty)
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    final (Color bg, Color fg) = switch (tone) {
      StatusBadgeTone.success => (tokens.surfaceContainer, AppColors.tertiary),
      StatusBadgeTone.info => (tokens.secondaryFixed, AppColors.primary),
      StatusBadgeTone.warning => (
        AppColors.warningContainer,
        AppColors.onWarningContainer,
      ),
      StatusBadgeTone.danger => (
        AppColors.errorContainer,
        AppColors.onErrorContainer,
      ),
      StatusBadgeTone.solidDanger => (AppColors.error, AppColors.onError),
      StatusBadgeTone.neutral => (
        tokens.surfaceContainerHighest,
        AppColors.onSurfaceVariant,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(tokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 13 : 15, color: fg),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSm.copyWith(
                color: fg,
                fontSize: compact ? 10 : 11,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

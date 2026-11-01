import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/blur_app_header.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/pill_bottom_nav.dart';
import '../../shared/widgets/stat_card.dart';
import '../../shared/widgets/status_badge.dart';
import '../auth/auth_provider.dart';

/// Halaman Beranda Admin/Pemilik Home-In:
/// - Header dengan selector cabang, indikator Live Sync, dan notifikasi
/// - Grid 2x2 ringkasan metrik (Kamar Terisi, Okupansi, Pemasukan, Tunggakan)
/// - Banner cepat status komplain dan booking
/// - Daftar "Perlu Perhatian" (tunggakan terlama) dengan aksi langsung WhatsApp
/// - Bottom navigation pill melayang dengan menu placeholder dan logout
class AdminHomeScreen extends ConsumerStatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  ConsumerState<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends ConsumerState<AdminHomeScreen> {
  int _navIndex = 0;
  String _selectedCabang = 'Kost Singgah Teduh (Pusat)';

  final List<String> _daftarCabang = [
    'Kost Singgah Teduh (Pusat)',
    'Kost Singgah Teduh (Cabang 2 - Mulyorejo)',
  ];

  // Data contoh yang terstruktur sesuai skema database Home-In
  final int _totalKamar = 20;
  final int _kamarTerisi = 18;
  final int _penghuniAktif = 18;
  final double _pemasukanBulanIni = 24500000;
  final double _totalTunggakan = 3200000;
  final int _jumlahTunggakan = 2;
  final int _komplainBaruCount = 1;
  final int _bookingBaruCount = 2;

  // Daftar prioritas "Perlu Perhatian"
  final List<Map<String, dynamic>> _daftarPerluPerhatian = [
    {
      'id': 1,
      'nama': 'Dimas Pratama',
      'kamar': 'Kamar 102 (Lt. 1)',
      'hari_tunggakan': 5,
      'jumlah_tagihan': 1500000.0,
      'no_hp': '081234567890',
      'avatar_initial': 'DP',
    },
    {
      'id': 2,
      'nama': 'Rian Saputra',
      'kamar': 'Kamar 204 (Lt. 2)',
      'hari_tunggakan': 12,
      'jumlah_tagihan': 1700000.0,
      'no_hp': '081987654321',
      'avatar_initial': 'RS',
    },
  ];

  void _showPlaceholder(String featureName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final tokens = context.tokens;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: tokens.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(tokens.radiusLg),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: tokens.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Symbols.construction_rounded,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Menu $featureName',
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Halaman $featureName siap dihubungkan ke endpoint backend pada tahap selanjutnya sesuai arsitektur.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMd.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(tokens.radiusDefault),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleHubungiWhatsApp(String noHp, String nama, double tagihan) async {
    final pesan = 'Halo Kak $nama, mengingatkan tagihan sewa kost di '
        '$_selectedCabang sebesar ${AppFormatters.rupiah(tagihan)} '
        'telah jatuh tempo. Mohon kesediaannya untuk melakukan pembayaran. Terima kasih.';

    final uri = AppFormatters.buildWhatsAppUri(phone: noHp, message: pesan);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat membuka WhatsApp ke nomor $noHp')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Keluar dari Akun?',
      message: 'Anda harus masuk kembali untuk mengelola kost Home-In.',
      confirmLabel: 'Ya, Keluar',
      cancelLabel: 'Batal',
      isDestructive: true,
      icon: Symbols.logout_rounded,
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final userName = user?.nama ?? 'Administrator';

    final occupancyPercent = ((_kamarTerisi / _totalKamar) * 100).round();

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      appBar: BlurAppHeader(
        title: _selectedCabang,
        subtitle: 'Halo, $userName',
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tokens.surfaceContainerLow,
            borderRadius: BorderRadius.circular(tokens.radiusDefault),
          ),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Symbols.domain_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            tooltip: 'Pilih Cabang Kost',
            onSelected: (cabang) {
              setState(() {
                _selectedCabang = cabang;
              });
            },
            itemBuilder: (context) => _daftarCabang
                .map(
                  (c) => PopupMenuItem(
                    value: c,
                    child: Text(
                      c,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: c == _selectedCabang
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: c == _selectedCabang
                            ? AppColors.primary
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        extraActions: [
          // Live Sync Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tokens.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(tokens.radiusPill),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live Sync',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        unreadNotificationCount: _komplainBaruCount + _bookingBaruCount,
        onNotificationTap: () => _showPlaceholder('Notifikasi'),
        onProfileTap: _handleLogout,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            tokens.pageMargin,
            12,
            tokens.pageMargin,
            100, // Ruang lega untuk floating pill nav
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Grid 2x2 Ringkasan Metrik
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: tokens.gutter,
                  mainAxisSpacing: tokens.gutter,
                  childAspectRatio: 1.12,
                  children: [
                    StatCard(
                      icon: Symbols.door_front_rounded,
                      badgeText: '$occupancyPercent% Okupansi',
                      value: '$_kamarTerisi / $_totalKamar',
                      label: 'Kamar Terisi',
                      variant: StatCardVariant.primary,
                      onTap: () => _showPlaceholder('Kamar'),
                    ),
                    StatCard(
                      icon: Symbols.group_rounded,
                      badgeText: '$occupancyPercent% Kapasitas',
                      value: '$_penghuniAktif Orang',
                      label: 'Penyewa Aktif',
                      variant: StatCardVariant.tertiary,
                      showBadgeDot: true,
                      onTap: () => _showPlaceholder('Penghuni'),
                    ),
                    StatCard(
                      icon: Symbols.payments_rounded,
                      badgeText: '+12% MoM',
                      value: AppFormatters.rupiah(_pemasukanBulanIni),
                      label: 'Pemasukan Bln Ini',
                      variant: StatCardVariant.secondary,
                      onTap: () => _showPlaceholder('Laporan Keuangan'),
                    ),
                    StatCard(
                      icon: Symbols.warning_rounded,
                      badgeText: '$_jumlahTunggakan Kamar',
                      value: AppFormatters.rupiah(_totalTunggakan),
                      label: 'Perlu Ditagih',
                      variant: StatCardVariant.errorAlert,
                      onTap: () => _showPlaceholder('Daftar Tunggakan'),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 2. Quick Highlight Pills (Komplain & Booking)
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showPlaceholder('Komplain Masuk'),
                        borderRadius:
                            BorderRadius.circular(tokens.radiusDefault),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.surfaceContainerLowest,
                            borderRadius:
                                BorderRadius.circular(tokens.radiusDefault),
                            boxShadow: tokens.softBlueShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: tokens.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Symbols.report_problem_rounded,
                                  color: AppColors.warning,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$_komplainBaruCount Komplain',
                                      style: AppTypography.labelLg.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Belum ditangani',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showPlaceholder('Booking Masuk'),
                        borderRadius:
                            BorderRadius.circular(tokens.radiusDefault),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: tokens.surfaceContainerLowest,
                            borderRadius:
                                BorderRadius.circular(tokens.radiusDefault),
                            boxShadow: tokens.softBlueShadow,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: tokens.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Symbols.bookmark_add_rounded,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '$_bookingBaruCount Booking',
                                      style: AppTypography.labelLg.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Perlu ditinjau',
                                      style: AppTypography.bodySm.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 3. Section "Perlu Perhatian"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Perlu Perhatian',
                          style: AppTypography.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: '$_jumlahTunggakan Tunggakan',
                          tone: StatusBadgeTone.danger,
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showPlaceholder('Semua Tunggakan'),
                      child: Text(
                        'Lihat Semua',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kartu Tunggakan Prioritas
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _daftarPerluPerhatian.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _daftarPerluPerhatian[index];
                    final nama = item['nama'] as String;
                    final kamar = item['kamar'] as String;
                    final hari = item['hari_tunggakan'] as int;
                    final tagihan = item['jumlah_tagihan'] as double;
                    final noHp = item['no_hp'] as String;
                    final initial = item['avatar_initial'] as String;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: tokens.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(tokens.radiusLg),
                        boxShadow: tokens.softBlueShadow,
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: tokens.surfaceContainer,
                            child: Text(
                              initial,
                              style: AppTypography.labelLg.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Info Penghuni & Kamar
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  style: AppTypography.bodyLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  kamar,
                                  style: AppTypography.bodySm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.errorContainer,
                                        borderRadius: BorderRadius.circular(
                                          tokens.radiusPill,
                                        ),
                                      ),
                                      child: Text(
                                        'Nunggak $hari Hari',
                                        style: AppTypography.labelSm.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppFormatters.rupiah(tagihan),
                                      style: AppTypography.labelMd.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Aksi Chat WhatsApp Langsung
                          IconButton.filledTonal(
                            onPressed: () =>
                                _handleHubungiWhatsApp(noHp, nama, tagihan),
                            icon: const Icon(
                              Symbols.chat_rounded,
                              size: 20,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.tertiaryFixed,
                              foregroundColor: AppColors.onTertiaryFixed,
                              padding: const EdgeInsets.all(12),
                            ),
                            tooltip: 'Hubungi via WhatsApp',
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: PillBottomNav(
        currentIndex: _navIndex,
        items: const [
          PillNavItem(
            icon: Symbols.home_rounded,
            label: 'Beranda',
          ),
          PillNavItem(
            icon: Symbols.meeting_room_rounded,
            label: 'Kamar',
          ),
          PillNavItem(
            icon: Symbols.receipt_long_rounded,
            label: 'Tagihan',
          ),
          PillNavItem(
            icon: Symbols.person_rounded,
            label: 'Akun',
          ),
        ],
        onTap: (index) {
          if (index == 3) {
            _handleLogout();
          } else if (index != 0) {
            _showPlaceholder(
              index == 1 ? 'Kamar & Gedung' : 'Pembayaran & Tagihan',
            );
          } else {
            setState(() {
              _navIndex = index;
            });
          }
        },
      ),
    );
  }
}


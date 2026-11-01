import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/blur_app_header.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/pill_bottom_nav.dart';
import '../../shared/widgets/status_badge.dart';
import '../auth/auth_provider.dart';

/// Halaman Beranda Penghuni Home-In dengan desain humanis, lega, dan ergonomis:
/// - Hero card masa tinggal aktif (countdown hari)
/// - Kartu tagihan sewa bulan berjalan dengan status dan tombol bayar
/// - 4 Tombol aksi cepat: Lapor Tamu, Izin Keluar, Komplain, Lapor Pulang
/// - Pengumuman terkini kost & ringkasan aturan jam malam
/// - Bottom navigation pill melayang dengan proteksi akun
class PenghuniHomeScreen extends ConsumerStatefulWidget {
  const PenghuniHomeScreen({super.key});

  @override
  ConsumerState<PenghuniHomeScreen> createState() => _PenghuniHomeScreenState();
}

class _PenghuniHomeScreenState extends ConsumerState<PenghuniHomeScreen> {
  int _navIndex = 0;

  // Data contoh sesuai struktur database penghuni, kamar, dan pembayaran
  final String _nomorKamar = '102';
  final int _lantai = 1;
  final String _namaCabang = 'Kost Singgah Teduh';
  final double _jumlahTagihan = 1500000;
  final String _statusTagihan = 'belum_bayar'; // 'lunas', 'menunggu_verifikasi', 'belum_bayar'
  final DateTime _jatuhTempo = DateTime(2026, 10, 25);
  final DateTime _masaTinggalSampai = DateTime(2026, 11, 1);

  void _showActionBottomSheet({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
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
                  child: const Text('Mengerti'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Keluar dari Akun?',
      message: 'Anda harus masuk kembali untuk mengakses informasi kamar Anda.',
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
    final userName = user?.nama ?? 'Penghuni';

    final sisaHari = _masaTinggalSampai.difference(DateTime.now()).inDays;
    final sisaHariFormatted = sisaHari >= 0 ? '$sisaHari Hari Lagi' : 'Berakhir';

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBody: true,
      appBar: BlurAppHeader(
        title: 'Halo, $userName 👋',
        subtitle: 'Kamar $_nomorKamar (Lt. $_lantai) • $_namaCabang',
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primaryContainer,
          child: Text(
            user?.initial ?? 'P',
            style: AppTypography.labelMd.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        unreadNotificationCount: 1,
        onNotificationTap: () => _showActionBottomSheet(
          title: 'Notifikasi Penghuni',
          description:
              'Fitur notifikasi push dan pesan pengingat tagihan akan aktif pada tahap Firebase selanjutnya.',
          icon: Symbols.notifications_rounded,
          iconColor: AppColors.primary,
        ),
        onProfileTap: _handleLogout,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            tokens.pageMargin,
            12,
            tokens.pageMargin,
            100, // Ruang lapang untuk floating bottom nav
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Card: Masa Tinggal Countdown Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusPill),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Symbols.timer_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Masa Tinggal Aktif',
                                  style: AppTypography.labelSm.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Kamar $_nomorKamar',
                            style: AppTypography.labelMd.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        sisaHariFormatted,
                        style: AppTypography.headlineXl.copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berlaku hingga ${AppFormatters.shortDate(_masaTinggalSampai)}',
                        style: AppTypography.bodySm.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Tombol Aksi Perpanjang
                      SizedBox(
                        height: 40,
                        child: FilledButton.tonal(
                          onPressed: () => _showActionBottomSheet(
                            title: 'Perpanjang Masa Sewa',
                            description:
                                'Fitur perpanjangan masa sewa kamar $_nomorKamar akan diproses langsung oleh admin kost.',
                            icon: Symbols.event_repeat_rounded,
                            iconColor: AppColors.primary,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusPill),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Perpanjang Sewa',
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Symbols.arrow_forward_rounded,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 2. Kartu Tagihan Bulan Ini (Monthly Bill)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: tokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                    boxShadow: tokens.softBlueShadow,
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: tokens.surfaceContainerLow,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Symbols.receipt_long_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tagihan Sewa Bulan Ini',
                                    style: AppTypography.bodyMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Periode Oktober 2026',
                                    style: AppTypography.bodySm.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          StatusBadge(
                            label: _statusTagihan == 'lunas'
                                ? 'Lunas'
                                : 'Belum Bayar',
                            tone: _statusTagihan == 'lunas'
                                ? StatusBadgeTone.success
                                : StatusBadgeTone.danger,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            AppFormatters.rupiah(_jumlahTagihan),
                            style: AppTypography.headlineLg.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '/ bulan',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jatuh tempo: ${AppFormatters.shortDate(_jatuhTempo)}',
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // CTA Bayar / Konfirmasi
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () => _showActionBottomSheet(
                            title: 'Pembayaran Sewa',
                            description:
                                'Fitur upload bukti transfer dan gateway pembayaran Midtrans/manual akan siap dihubungkan pada modul pembayaran.',
                            icon: Symbols.payments_rounded,
                            iconColor: AppColors.primary,
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(tokens.radiusDefault),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Symbols.upload_file_rounded,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Bayar / Unggah Bukti Transfer',
                                style: AppTypography.labelLg.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Empat Tombol Aksi Cepat (4 Quick Action Buttons)
                Text(
                  'Layanan Penghuni',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: tokens.gutter,
                  mainAxisSpacing: tokens.gutter,
                  childAspectRatio: 1.4,
                  children: [
                    _buildQuickActionCard(
                      title: 'Lapor Tamu',
                      subtitle: 'Izin bertamu / inap',
                      icon: Symbols.person_add_rounded,
                      color: AppColors.primary,
                      onTap: () => _showActionBottomSheet(
                        title: 'Lapor Tamu Berkunjung',
                        description:
                            'Daftarkan tamu yang berkunjung atau menginap demi ketertiban dan keamanan bersama.',
                        icon: Symbols.person_add_rounded,
                        iconColor: AppColors.primary,
                      ),
                    ),
                    _buildQuickActionCard(
                      title: 'Izin Keluar',
                      subtitle: 'Pulang larut / izin',
                      icon: Symbols.door_open_rounded,
                      color: AppColors.secondary,
                      onTap: () => _showActionBottomSheet(
                        title: 'Pengajuan Izin Keluar',
                        description:
                            'Ajukan izin keluar melewati jam malam (23:00) atau menginap di luar kost.',
                        icon: Symbols.door_open_rounded,
                        iconColor: AppColors.secondary,
                      ),
                    ),
                    _buildQuickActionCard(
                      title: 'Komplain',
                      subtitle: 'Fasilitas & kendala',
                      icon: Symbols.report_problem_rounded,
                      color: AppColors.warning,
                      onTap: () => _showActionBottomSheet(
                        title: 'Kirim Komplain Fasilitas',
                        description:
                            'Laporkan kerusakan fasilitas kamar atau gangguan ketertiban langsung ke admin/penjaga.',
                        icon: Symbols.report_problem_rounded,
                        iconColor: AppColors.warning,
                      ),
                    ),
                    _buildQuickActionCard(
                      title: 'Lapor Pulang',
                      subtitle: 'Checkout akhir sewa',
                      icon: Symbols.home_pin_rounded,
                      color: AppColors.tertiary,
                      onTap: () => _showActionBottomSheet(
                        title: 'Lapor Selesai Sewa',
                        description:
                            'Ajukan pengembalian kunci dan inventaris kamar sebelum tanggal selesai sewa.',
                        icon: Symbols.home_pin_rounded,
                        iconColor: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 4. Pengumuman Terkini Kost
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: tokens.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(tokens.radiusLg),
                    boxShadow: tokens.softBlueShadow,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: tokens.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Symbols.campaign_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pengumuman Kost',
                                  style: AppTypography.labelLg.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Hari ini, 09:00',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pembersihan Tandon Air & Maintenance WiFi',
                              style: AppTypography.bodyMd.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Akan diadakan pemeliharaan rutin pada hari Sabtu pukul 10:00 - 13:00 WIB. Mohon tampung air secukupnya.',
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

                const SizedBox(height: 16),

                // 5. Aturan Jam Malam & Info Gerbang
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: tokens.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(tokens.radiusDefault),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Symbols.lock_clock_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jam Malam: 23:00 WIB',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'Gerbang otomatis terkunci. Gunakan kartu akses atau ajukan izin keluar jika pulang larut.',
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
            icon: Symbols.receipt_long_rounded,
            label: 'Tagihan',
          ),
          PillNavItem(
            icon: Symbols.history_rounded,
            label: 'Riwayat',
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
            _showActionBottomSheet(
              title: index == 1 ? 'Daftar Tagihan' : 'Riwayat Aktivitas',
              description:
                  'Halaman ini siap dihubungkan pada modul pembayaran & riwayat di tahap berikutnya.',
              icon: index == 1
                  ? Symbols.receipt_long_rounded
                  : Symbols.history_rounded,
              iconColor: AppColors.primary,
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

  Widget _buildQuickActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final tokens = context.tokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusDefault),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: tokens.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(tokens.radiusDefault),
            boxShadow: tokens.softBlueShadow,
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: AppTypography.labelLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


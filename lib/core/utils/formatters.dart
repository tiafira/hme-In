import 'package:intl/intl.dart';

/// Utilitas pemformatan mata uang Rupiah, tanggal/waktu Indonesia (WIB),
/// sisa masa tinggal, dan konversi nomor WhatsApp (`08xx` -> `628xx`).
class AppFormatters {
  AppFormatters._();

  static final NumberFormat _rupiahFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static const List<String> _hariIndonesia = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _bulanSingkat = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<String> _bulanLengkap = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Mengubah angka menjadi format `Rp 5.550.000`.
  static String rupiah(num? value) {
    if (value == null) return 'Rp 0';
    return _rupiahFormatter.format(value);
  }

  /// Konversi waktu ke zona Asia/Jakarta (UTC+7 / WIB).
  static DateTime toWib(DateTime dateTime) {
    final utc = dateTime.toUtc();
    return utc.add(const Duration(hours: 7));
  }

  /// Waktu sekarang dalam zona Asia/Jakarta (WIB).
  static DateTime nowWib() => toWib(DateTime.now());

  /// Format jam `HH:mm` (contoh: `00:42`).
  static String timeHm(DateTime dateTime) {
    final wib = toWib(dateTime);
    final h = wib.hour.toString().padLeft(2, '0');
    final m = wib.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Format jam `HH:mm WIB` (contoh: `00:35 WIB`).
  static String timeHmWib(DateTime dateTime) => '${timeHm(dateTime)} WIB';

  /// Format tanggal lengkap dengan hari (contoh: `Kamis, 07 Nov 2024`).
  static String fullDayDate(DateTime dateTime) {
    final hari = _hariIndonesia[dateTime.weekday - 1];
    final tgl = dateTime.day.toString().padLeft(2, '0');
    final bln = _bulanSingkat[dateTime.month - 1];
    return '$hari, $tgl $bln ${dateTime.year}';
  }

  /// Format tanggal singkat (contoh: `05 Nov 2026` atau `05 Nov`).
  static String shortDate(DateTime? dateTime, {bool withYear = true}) {
    if (dateTime == null) return '-';
    final tgl = dateTime.day.toString().padLeft(2, '0');
    final bln = _bulanSingkat[dateTime.month - 1];
    return withYear ? '$tgl $bln ${dateTime.year}' : '$tgl $bln';
  }

  /// Nama periode bulan & tahun (contoh: `Oktober 2026`).
  static String monthYear(int month, int year) {
    final idx = (month - 1).clamp(0, 11);
    return '${_bulanLengkap[idx]} $year';
  }

  /// Menghitung sisa hari menuju `masa_tinggal_sampai`.
  /// Mengembalikan nilai negatif jika sudah lewat.
  static int? remainingDays(DateTime? masaTinggalSampai) {
    if (masaTinggalSampai == null) return null;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final target = DateTime(
      masaTinggalSampai.year,
      masaTinggalSampai.month,
      masaTinggalSampai.day,
    );
    return target.difference(today).inDays;
  }

  /// Label penghitung masa tinggal ("12 hari lagi", "Hari terakhir", "Lewat 3 hari").
  static String remainingStayLabel(DateTime? masaTinggalSampai) {
    final days = remainingDays(masaTinggalSampai);
    if (days == null) return 'Belum diatur';
    if (days > 0) return '$days hari lagi';
    if (days == 0) return 'Berakhir hari ini';
    return 'Lewat ${days.abs()} hari';
  }

  /// Mengubah nomor HP `08xx` atau `+628xx` menjadi `628xx` untuk tautan `wa.me/<nomor>`.
  static String normalizeWhatsAppPhone(String? rawPhone) {
    if (rawPhone == null || rawPhone.trim().isEmpty) return '';
    var digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('08')) {
      digits = '62${digits.substring(1)}';
    } else if (digits.startsWith('8')) {
      digits = '62$digits';
    }
    return digits;
  }

  /// Membuat URL `https://wa.me/<nomor>?text=<pesan>` dengan nomor terformat `628xx`.
  static Uri buildWhatsAppUri({
    required String phone,
    required String message,
  }) {
    final normalized = normalizeWhatsAppPhone(phone);
    return Uri.parse(
      'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}',
    );
  }

  /// Mengambil inisial maksimal 2 huruf dari nama lengkap.
  static String initials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'HI';
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'HI';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

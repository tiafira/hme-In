/// Konfigurasi lingkungan aplikasi Home-In.
///
/// Seluruh kredensial dan URL diambil dari `--dart-define` saat build/run
/// sehingga tidak ada rahasia atau URL produksi yang di-hardcode di kode sumber.
///
/// Contoh penggunaan:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
class AppConfig {
  AppConfig._();

  static const String brandName = 'Home-In';

  /// Base URL API Laravel Sanctum.
  /// Default lokal mengarah ke `http://10.0.2.2:8000/api` (emulator Android)
  /// atau dapat diubah lewat `--dart-define=API_BASE_URL=...`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api',
  );

  /// Base URL storage publik untuk gambar bukti pembayaran, kamar, profil, dll.
  static const String storageBaseUrl = String.fromEnvironment(
    'STORAGE_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/storage',
  );

  /// Radius maksimal absensi penjaga dari titik koordinat cabang (dalam meter).
  static const double maxAttendanceRadiusMeters = 100.0;

  /// Konfigurasi Firebase dari environment (opsional jika memakai google-services.json).
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String firebaseProjectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');

  static bool get hasFirebaseEnvConfig =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseMessagingSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

  /// Mengubah path relatif foto dari backend menjadi URL penuh.
  static String resolveMediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('storage/')) {
      final hostUrl = storageBaseUrl.replaceAll(RegExp(r'/storage/?$'), '');
      return '$hostUrl/$cleanPath';
    }
    return '$storageBaseUrl/$cleanPath';
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Client HTTP Dio dengan token Sanctum dan penanganan error standar.
class ApiClient {
  ApiClient({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ?? const FlutterSecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Tangani 401 Unauthorized: hapus token jika kedaluwarsa
          if (error.response?.statusCode == 401) {
            await _storage.delete(key: _tokenKey);
          }
          return handler.next(error);
        },
      ),
    );
  }

  static const String _tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  late final Dio _dio;
  final FlutterSecureStorage _storage;

  Dio get dio => _dio;
  FlutterSecureStorage get storage => _storage;

  /// Simpan token Sanctum ke secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Ambil token Sanctum
  Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// Hapus token dan sesi
  Future<void> clearAuth() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: userKey);
  }
}


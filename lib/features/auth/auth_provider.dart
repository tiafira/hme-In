import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_model.dart';
import '../../core/network/api_client.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.token,
    this.errorMessage,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

/// Provider instance ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider state AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(apiClient);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._apiClient) : super(const AuthState());

  final ApiClient _apiClient;

  /// Memeriksa sesi tersimpan saat aplikasi pertama kali dijalankan (di Splash)
  Future<void> checkAuthStatus() async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final token = await _apiClient.getToken();
      final userJsonStr = await _apiClient.storage.read(key: ApiClient.userKey);

      if (token == null || token.isEmpty || userJsonStr == null) {
        state = state.copyWith(status: AuthStatus.unauthenticated);
        return;
      }

      final userMap = jsonDecode(userJsonStr) as Map<String, dynamic>;
      final user = UserModel.fromJson(userMap);

      // Verifikasi status penghuni jika role adalah penghuni
      if (user.role == UserRole.penghuni && !user.isActivePenghuni) {
        await _apiClient.clearAuth();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          token: null,
          errorMessage: 'Akun belum/tidak lagi aktif sebagai penghuni kost.',
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
      );
    } catch (e) {
      await _apiClient.clearAuth();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        token: null,
      );
    }
  }

  /// Melakukan login dengan email dan password ke endpoint Laravel Sanctum
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final response = await _apiClient.dio.post(
        '/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['status'] != 'success') {
        final message = responseData['message'] as String? ?? 'Login gagal.';
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: message,
        );
        return false;
      }

      final data = responseData['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final rawUser = data['user'] as Map<String, dynamic>;

      final user = UserModel.fromJson(rawUser);

      // 1. Validasi status aktif akun
      if (!user.statusAktif) {
        await _apiClient.clearAuth();
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage:
              'Akun Anda dinonaktifkan. Silakan hubungi admin atau pemilik kost.',
        );
        return false;
      }

      // 2. Validasi khusus role penghuni: WAJIB berstatus aktif
      if (user.role == UserRole.calonPenghuni) {
        await _apiClient.clearAuth();
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage:
              'Akun Anda masih berstatus calon penghuni dan belum dapat masuk ke aplikasi.',
        );
        return false;
      }

      if (user.role == UserRole.penghuni) {
        if (!user.isActivePenghuni) {
          await _apiClient.clearAuth();
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                'Akun belum/tidak lagi aktif sebagai penghuni kost.',
          );
          return false;
        }
      }

      // Simpan kredensial ke secure storage
      await _apiClient.saveToken(token);
      await _apiClient.storage.write(
        key: ApiClient.userKey,
        value: jsonEncode(user.toJson()),
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        token: token,
        errorMessage: null,
      );

      return true;
    } on DioException catch (dioErr) {
      String message = 'Terjadi kesalahan jaringan atau server tidak merespons.';

      if (dioErr.response != null && dioErr.response?.data is Map) {
        final errData = dioErr.response!.data as Map<String, dynamic>;
        message = errData['message'] as String? ?? message;
      } else if (dioErr.type == DioExceptionType.connectionTimeout ||
          dioErr.type == DioExceptionType.receiveTimeout) {
        message = 'Koneksi ke server timeout. Periksa jaringan Anda.';
      } else if (dioErr.type == DioExceptionType.connectionError) {
        message = 'Tidak dapat terhubung ke server API (${_apiClient.dio.options.baseUrl}).';
      }

      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Gagal melakukan login: ${e.toString()}',
      );
      return false;
    }
  }

  /// Logout akun dan bersihkan sesi
  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/logout');
    } catch (_) {
      // Abaikan error jaringan saat logout
    } finally {
      await _apiClient.clearAuth();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}


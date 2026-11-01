import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/admin_home_screen.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/auth/login_screen.dart';
import '../../features/penghuni/penghuni_home_screen.dart';
import '../../features/splash/splash_screen.dart';

/// Provider konfigurasi GoRouter dengan proteksi rute (Route Guarding)
/// berdasarkan autentikasi dan role pengguna (Admin / Penghuni).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/penghuni',
        builder: (context, state) => const PenghuniHomeScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authProvider);
      final location = state.uri.path;

      // Izinkan rute splash berjalan tanpa intervensi redirect
      if (location == '/splash') {
        return null;
      }

      final isAuthenticated = authState.isAuthenticated && authState.user != null;
      final user = authState.user;

      // Jika belum terautentikasi dan mencoba mengakses rute terproteksi
      if (!isAuthenticated) {
        if (location == '/admin' || location == '/penghuni') {
          return '/login';
        }
        return null;
      }

      // Jika sudah terautentikasi dan berada di /login, arahkan ke halaman utama role
      if (location == '/login') {
        if (user!.isAdminOrPemilik) {
          return '/admin';
        } else if (user.isActivePenghuni) {
          return '/penghuni';
        }
        return null;
      }

      // Proteksi silang antar role:
      // 1. Admin dilarang masuk ke rute penghuni
      if (location.startsWith('/penghuni')) {
        if (user!.isAdminOrPemilik) {
          return '/admin';
        }
        if (!user.isActivePenghuni) {
          return '/login';
        }
      }

      // 2. Penghuni dilarang masuk ke rute admin
      if (location.startsWith('/admin')) {
        if (!user!.isAdminOrPemilik) {
          return user.isActivePenghuni ? '/penghuni' : '/login';
        }
      }

      return null;
    },
  );
});


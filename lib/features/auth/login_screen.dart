import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import 'auth_provider.dart';

/// Halaman Login Home-In sesuai referensi desain:
/// - Logo aplikasi dengan ambient glow lembut
/// - Form kredensial tunggal (email & password)
/// - Indikator status loading pada CTA
/// - Pesan error yang informatif
/// - Arahkan sesuai role (Admin / Penghuni Aktif)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Tutup keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _localError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final user = ref.read(authProvider).user;
      if (user != null) {
        if (user.isAdminOrPemilik) {
          context.go('/admin');
        } else if (user.isActivePenghuni) {
          context.go('/penghuni');
        } else {
          setState(() {
            _localError =
                'Akun belum/tidak lagi aktif sebagai penghuni kost. Hubungi pengelola kost.';
          });
        }
      }
    } else {
      final authError = ref.read(authProvider).errorMessage;
      setState(() {
        _localError = authError ?? 'Email atau password salah.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    final errorMessage = _localError ?? authState.errorMessage;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: tokens.pageMargin,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),

                    // 1. Logo dengan Ambient Glow Lembut
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryContainer
                                      .withValues(alpha: 0.22),
                                  blurRadius: 40,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 76,
                            height: 76,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: tokens.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(tokens.radiusLg),
                              boxShadow: tokens.softBlueShadow,
                              border: Border.all(
                                color: AppColors.outlineVariant
                                    .withValues(alpha: 0.35),
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/logo.svg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Header Judul
                    Text(
                      'Selamat Datang di Home-In',
                      style: AppTypography.headlineLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Kelola hunian kost dengan mudah dan transparan',
                      style: AppTypography.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    // Banner Error (jika ada kesalahan autentikasi / nonaktif)
                    if (errorMessage != null && errorMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Symbols.error_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                errorMessage,
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 2. Input Field Email
                    Text(
                      'Email atau Nomor HP',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: AppTypography.bodyLg,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        hintText: 'nama@email.com',
                        hintStyle: AppTypography.bodyLg.copyWith(
                          color: AppColors.outlineVariant,
                        ),
                        prefixIcon: const Icon(
                          Symbols.mail_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        filled: true,
                        fillColor: tokens.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email atau nomor HP wajib diisi.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 3. Input Field Password
                    Text(
                      'Kata Sandi',
                      style: AppTypography.labelLg.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      style: AppTypography.bodyLg,
                      enabled: !isLoading,
                      onFieldSubmitted: (_) => _handleLogin(),
                      decoration: InputDecoration(
                        hintText: 'Masukkan kata sandi',
                        hintStyle: AppTypography.bodyLg.copyWith(
                          color: AppColors.outlineVariant,
                        ),
                        prefixIcon: const Icon(
                          Symbols.lock_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Symbols.visibility_rounded
                                : Symbols.visibility_off_rounded,
                            color: AppColors.onSurfaceVariant,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: tokens.surfaceContainerLowest,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          borderSide: BorderSide(
                            color: AppColors.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(tokens.radiusDefault),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.8,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kata sandi wajib diisi.';
                        }
                        if (value.length < 6) {
                          return 'Kata sandi minimal 6 karakter.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // Ingat Saya & Lupa Kata Sandi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _rememberMe = val ?? true;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              child: Text(
                                'Ingat Saya',
                                style: AppTypography.bodySm.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Silakan hubungi administrator kost untuk reset kata sandi.',
                                ),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Lupa Sandi?',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // 4. CTA Button Masuk (Tinggi min 56px, margin lapang)
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                              AppColors.primary.withValues(alpha: 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(tokens.radiusDefault),
                          ),
                          elevation: 2,
                          shadowColor:
                              AppColors.primary.withValues(alpha: 0.4),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Masuk',
                                    style: AppTypography.labelLg.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Symbols.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Footer Bantuan
                    Center(
                      child: Text(
                        'Mengalami kendala saat masuk? Hubungi Pemilik Kost',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
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


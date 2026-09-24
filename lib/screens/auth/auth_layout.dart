import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/widgets/destination_image.dart';

/// Kerangka halaman login & register: ilustrasi gunung di atas, form di bawah.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.showBack = false,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              SizedBox(
                height: 210 + top,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const LandscapeArt(category: 'Gunung', seed: 11),
                    // Gradasi gelap tipis agar logo putih tetap terbaca.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.center,
                          colors: [
                            Colors.black.withAlpha(90),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: showBack ? 8 : 24,
                      top: top + 10,
                      child: Row(
                        children: [
                          if (showBack)
                            IconButton(
                              tooltip: 'Kembali',
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back),
                              color: Colors.white,
                            ),
                          const Icon(Icons.terrain, color: kAccent, size: 26),
                          const SizedBox(width: 8),
                          const Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Camp',
                                  style: TextStyle(color: Colors.white),
                                ),
                                TextSpan(
                                  text: 'Ku',
                                  style: TextStyle(color: kAccent),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Lengkung putih yang menyambung ke area form.
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          color: kBackground,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(28)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 14.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 24),
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Banner pesan error di atas tombol kirim.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kError.withAlpha(90)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: kError, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: kError, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VALIDATOR
// ─────────────────────────────────────────────
String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Masukkan email.';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
    return 'Format email belum benar. Contoh: nama@email.com';
  }
  return null;
}

String? validateNewPassword(String? value) {
  if (value == null || value.length < 6) {
    return 'Kata sandi minimal 6 karakter.';
  }
  return null;
}

import 'package:flutter/material.dart';

import 'package:campku/screens/auth/admin_login_screen.dart';
import 'package:campku/screens/auth/auth_layout.dart';
import 'package:campku/screens/auth/login_form.dart';
import 'package:campku/screens/auth/register_screen.dart';
import 'package:campku/services/auth_service.dart';

/// Halaman masuk untuk pengguna. Admin punya halaman sendiri
/// ([AdminLoginScreen]).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Masuk ke CampKu',
      subtitle: 'Lanjutkan petualanganmu dan temukan spot camping berikutnya.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginForm(role: UserRole.user),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Text('Belum punya akun?'),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const RegisterScreen(),
                    ),
                  ),
                  child: const Text('Daftar'),
                ),
              ],
            ),
          ),
          const Divider(height: 28),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdminLoginScreen(),
                ),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined),
              label: const Text('Masuk sebagai Admin'),
            ),
          ),
        ],
      ),
    );
  }
}

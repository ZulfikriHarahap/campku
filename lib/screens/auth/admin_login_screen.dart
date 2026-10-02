import 'package:flutter/material.dart';

import 'package:campku/screens/auth/auth_layout.dart';
import 'package:campku/screens/auth/login_form.dart';
import 'package:campku/screens/auth/login_screen.dart';
import 'package:campku/services/auth_service.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: Navigator.canPop(context),
      title: 'Masuk Admin',
      subtitle: 'Khusus pengelola CampKu untuk mengelola destinasi dan booking.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LoginForm(role: UserRole.admin),
          const Divider(height: 28),
          Center(
            child: TextButton.icon(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
              ),
              icon: const Icon(Icons.hiking),
              label: const Text('Masuk sebagai Pengguna'),
            ),
          ),
        ],
      ),
    );
  }
}

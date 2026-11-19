import 'package:flutter/material.dart';

import 'package:campku/screens/auth/admin_login_screen.dart';
import 'package:campku/screens/auth/login_screen.dart';
import 'package:campku/services/auth_service.dart';

/// Menampilkan dialog konfirmasi, lalu keluar dari akun dan kembali ke
/// halaman masuk yang sesuai (admin atau pengguna).
Future<void> confirmLogout(BuildContext context) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Keluar dari akun?'),
      content: const Text('Kamu bisa masuk kembali kapan saja.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Keluar'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  final wasAdmin = AuthService.currentUser?.isAdmin ?? false;
  await AuthService.logout();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => wasAdmin ? const AdminLoginScreen() : const LoginScreen(),
    ),
    (route) => false,
  );
}

/// Tombol "Keluar" di pojok kanan atas header admin (menggantikan tab Profil).
class AdminLogoutButton extends StatelessWidget {
  const AdminLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: () => confirmLogout(context),
      icon: const Icon(Icons.logout, size: 18),
      label: const Text('Keluar'),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white.withAlpha(40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

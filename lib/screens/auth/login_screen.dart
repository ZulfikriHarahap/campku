import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/screens/auth/auth_layout.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/screens/dashboard/dashboard_screen.dart';
import 'package:campku/screens/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final error =
        AuthService.login(email: _email.text, password: _password.text);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
    );
  }

  void _fillDemo(String email, String password) {
    _email.text = email;
    _password.text = password;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Masuk ke CampKu',
      subtitle: 'Lanjutkan petualanganmu dan temukan spot camping berikutnya.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration:
                  fieldDecoration(label: 'Email', icon: Icons.mail_outline),
              validator: validateEmail,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              onFieldSubmitted: (_) => _submit(),
              decoration: fieldDecoration(
                label: 'Kata sandi',
                icon: Icons.lock_outline,
                suffix: IconButton(
                  tooltip: _obscure
                      ? 'Tampilkan kata sandi'
                      : 'Sembunyikan kata sandi',
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Masukkan kata sandi.' : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              AuthErrorBanner(_error!),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Masuk'),
            ),
            const SizedBox(height: 20),
            _DemoAccounts(onPick: _fillDemo),
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
          ],
        ),
      ),
    );
  }
}

/// Pintasan pengisian akun demo agar dosen/penguji bisa langsung mencoba.
class _DemoAccounts extends StatelessWidget {
  const _DemoAccounts({required this.onPick});

  final void Function(String email, String password) onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coba dengan akun demo',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ActionChip(
                avatar: const Icon(Icons.hiking, size: 18, color: kPrimary),
                label: const Text('Pengguna'),
                onPressed: () => onPick('user@campku.id', 'user123'),
              ),
              ActionChip(
                avatar: const Icon(
                  Icons.admin_panel_settings_outlined,
                  size: 18,
                  color: kPrimary,
                ),
                label: const Text('Admin'),
                onPressed: () => onPick('admin@campku.id', 'admin123'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

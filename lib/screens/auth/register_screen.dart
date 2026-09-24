import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/screens/auth/auth_layout.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/screens/dashboard/dashboard_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final error = AuthService.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    // Akun baru langsung masuk; hapus halaman login & register dari riwayat.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const DashboardScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      showBack: true,
      title: 'Buat akun baru',
      subtitle: 'Simpan destinasi favoritmu dan mulai rencanakan camping.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _UserOnlyNote(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              decoration: fieldDecoration(
                label: 'Nama lengkap',
                icon: Icons.person_outline,
              ),
              validator: (v) => (v == null || v.trim().length < 2)
                  ? 'Masukkan nama lengkap.'
                  : null,
            ),
            const SizedBox(height: 16),
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              decoration: fieldDecoration(
                label: 'Kata sandi',
                icon: Icons.lock_outline,
                helper: 'Minimal 6 karakter.',
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
              validator: validateNewPassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              decoration: fieldDecoration(
                label: 'Ulangi kata sandi',
                icon: Icons.lock_reset_outlined,
              ),
              validator: (v) =>
                  v != _password.text ? 'Kata sandi belum sama.' : null,
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
                  : const Text('Buat akun'),
            ),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text('Sudah punya akun?'),
                  TextButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    child: const Text('Masuk'),
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

/// Penjelasan singkat: pendaftaran hanya membuat akun pengguna.
class _UserOnlyNote extends StatelessWidget {
  const _UserOnlyNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kPrimary.withAlpha(18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.hiking, size: 20, color: kPrimary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Akun baru terdaftar sebagai Pengguna: jelajahi destinasi dan simpan favorit.',
              style: TextStyle(color: kPrimary, fontSize: 13, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

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
  UserRole _role = UserRole.user;
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
        AuthService.login(
      email: _email.text,
      password: _password.text,
      role: _role,
    );
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

  void _selectRole(UserRole role) {
    setState(() {
      _role = role;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _role == UserRole.admin;

    return AuthLayout(
      title: 'Masuk ke CampKu',
      subtitle: 'Lanjutkan petualanganmu dan temukan spot camping berikutnya.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masuk sebagai',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _RoleOption(
                    icon: Icons.hiking,
                    label: 'Pengguna',
                    selected: !isAdmin,
                    onTap: () => _selectRole(UserRole.user),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleOption(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin',
                    selected: isAdmin,
                    onTap: () => _selectRole(UserRole.admin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAdmin
                  ? 'Akun admin bersifat tetap.\n'
                      'Email: ${AuthService.adminEmail}\n'
                      'Kata sandi: ${AuthService.adminPassword}'
                  : 'Masuk dengan akun pengguna yang sudah kamu daftarkan.',
              style: const TextStyle(color: kTextMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
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

class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? kPrimary.withAlpha(18) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected ? kPrimary : kBorder,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icon, color: selected ? kPrimary : kTextMuted),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: selected ? kPrimary : kTextDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

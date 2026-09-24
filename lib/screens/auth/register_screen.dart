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
  final _adminCode = TextEditingController();

  UserRole _role = UserRole.user;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _adminCode.dispose();
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
      role: _role,
      adminCodeInput: _adminCode.text,
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
    final isAdmin = _role == UserRole.admin;

    return AuthLayout(
      showBack: true,
      title: 'Buat akun baru',
      subtitle: 'Simpan destinasi favoritmu dan mulai rencanakan camping.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar sebagai',
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
                    onTap: () => setState(() => _role = UserRole.user),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _RoleOption(
                    icon: Icons.admin_panel_settings_outlined,
                    label: 'Admin',
                    selected: isAdmin,
                    onTap: () => setState(() => _role = UserRole.admin),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAdmin
                  ? 'Admin bisa melihat daftar pengguna yang terdaftar.'
                  : 'Pengguna bisa menjelajah destinasi dan menyimpan favorit.',
              style: const TextStyle(color: kTextMuted, fontSize: 13),
            ),
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
              textInputAction:
                  isAdmin ? TextInputAction.next : TextInputAction.done,
              decoration: fieldDecoration(
                label: 'Ulangi kata sandi',
                icon: Icons.lock_reset_outlined,
              ),
              validator: (v) =>
                  v != _password.text ? 'Kata sandi belum sama.' : null,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: isAdmin
                  ? Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: _adminCode,
                        textInputAction: TextInputAction.done,
                        autocorrect: false,
                        textCapitalization: TextCapitalization.characters,
                        decoration: fieldDecoration(
                          label: 'Kode admin',
                          icon: Icons.vpn_key_outlined,
                          helper: 'Kode demo: ${AuthService.adminCode}',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Masukkan kode admin.'
                            : null,
                      ),
                    )
                  : const SizedBox(width: double.infinity),
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

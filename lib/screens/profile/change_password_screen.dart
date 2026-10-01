import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _current.dispose();
    _newPassword.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    final error = AuthService.changePassword(
      currentPassword: _current.text,
      newPassword: _newPassword.text,
    );
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah kata sandi'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              TextFormField(
                controller: _current,
                obscureText: _obscureCurrent,
                decoration: fieldDecoration(
                  label: 'Kata sandi saat ini',
                  icon: Icons.lock_outline,
                  suffix: IconButton(
                    tooltip: _obscureCurrent ? 'Tampilkan' : 'Sembunyikan',
                    icon: Icon(_obscureCurrent
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Masukkan kata sandi saat ini' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPassword,
                obscureText: _obscureNew,
                decoration: fieldDecoration(
                  label: 'Kata sandi baru',
                  icon: Icons.lock_reset_outlined,
                  helper: 'Minimal 6 karakter.',
                  suffix: IconButton(
                    tooltip: _obscureNew ? 'Tampilkan' : 'Sembunyikan',
                    icon: Icon(_obscureNew
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Masukkan kata sandi baru';
                  if (v.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                decoration: fieldDecoration(
                  label: 'Konfirmasi kata sandi baru',
                  icon: Icons.check_circle_outline,
                  suffix: IconButton(
                    tooltip: _obscureConfirm ? 'Tampilkan' : 'Sembunyikan',
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ulangi kata sandi baru';
                  if (v != _newPassword.text) return 'Tidak cocok dengan kata sandi baru';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Simpan kata sandi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

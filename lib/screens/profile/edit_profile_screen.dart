import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';

/// Form sederhana untuk mengubah nama tampilan akun yang sedang masuk.
/// Email tidak bisa diubah karena dipakai sebagai kunci masuk dan kunci
/// data lain (favorit, booking).
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: AuthService.currentUser?.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    final error = AuthService.updateProfile(name: _name.text);
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
    final user = AuthService.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profil'),
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
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: kAccent,
                  child: Text(
                    user?.initial ?? '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _name,
                decoration: fieldDecoration(
                  label: 'Nama',
                  icon: Icons.person_outline,
                ),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _save(),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Nama wajib diisi';
                  if (t.length < 3) return 'Nama minimal 3 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.email,
                enabled: false,
                decoration: fieldDecoration(
                  label: 'Email',
                  icon: Icons.mail_outline,
                  helper: 'Email tidak bisa diubah.',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Text('Simpan perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

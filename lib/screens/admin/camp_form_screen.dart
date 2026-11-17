import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/admin_write_error.dart';
import 'package:campku/services/camp_service.dart';

/// Form untuk menambah atau mengedit camp di dalam satu [destination].
///
/// Sesuai mini SRS, camp hanya punya dua data: nama, dan destinasi
/// terkait — destinasi sudah tetap karena form ini selalu dibuka dari
/// dalam halaman detail destinasi tersebut.
class CampFormScreen extends StatefulWidget {
  const CampFormScreen({super.key, required this.destination, this.existing});

  final Destination destination;
  final Camp? existing;

  @override
  State<CampFormScreen> createState() => _CampFormScreenState();
}

class _CampFormScreenState extends State<CampFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CampService _service = CampService.instance;
  late final TextEditingController _name;
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Nama camp wajib diisi';
    if (t.length < 3) return 'Nama minimal 3 karakter';
    if (_service.nameTaken(
      t,
      destinationSlug: widget.destination.slug,
      exceptId: widget.existing?.id,
    )) {
      return 'Nama ini sudah dipakai camp lain di destinasi yang sama';
    }
    return null;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    final name = _name.text.trim();
    final camp = Camp(
      id: widget.existing?.id ?? _service.uniqueId(name),
      name: name,
      destinationSlug: widget.destination.slug,
    );

    setState(() => _saving = true);
    try {
      if (_editing) {
        await _service.edit(camp);
      } else {
        await _service.create(camp);
      }
      if (!mounted) return;
      Navigator.pop(context, camp);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(adminWriteErrorMessage(e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit camp' : 'Tambah camp'),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: kPrimary.withAlpha(18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(widget.destination.categoryIcon,
                        size: 18, color: kPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Destinasi: ${widget.destination.name}',
                        style: const TextStyle(
                          color: kPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextFormField(
                controller: _name,
                decoration: fieldDecoration(
                  label: 'Nama camp',
                  icon: Icons.holiday_village_outlined,
                  helper: 'Contoh: Camp Tepi Danau',
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_editing ? Icons.save_outlined : Icons.add),
                label: Text(_saving
                    ? 'Menyimpan...'
                    : _editing
                        ? 'Simpan perubahan'
                        : 'Tambah camp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

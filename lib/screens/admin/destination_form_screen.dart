import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/destination_service.dart';

/// Form untuk menambah destinasi baru, atau mengedit jika [existing] diisi.
///
/// Field dibatasi hanya nama, kategori, dan deskripsi sesuai "Data Utama"
/// pada mini SRS CampKu (FR-08). Menutup dirinya dengan mengembalikan
/// [Destination] yang sudah tersimpan lewat `Navigator.pop`, atau `null`
/// jika dibatalkan.
class DestinationFormScreen extends StatefulWidget {
  const DestinationFormScreen({super.key, this.existing});

  final Destination? existing;

  @override
  State<DestinationFormScreen> createState() => _DestinationFormScreenState();
}

class _DestinationFormScreenState extends State<DestinationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DestinationService _service = DestinationService.instance;

  late final TextEditingController _name;
  late final TextEditingController _description;
  late String _category;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name);
    _description = TextEditingController(text: e?.description);
    _category = e?.category ?? kCategories.first.label;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Nama wajib diisi';
    if (t.length < 3) return 'Nama minimal 3 karakter';
    if (_service.nameTaken(t, exceptSlug: widget.existing?.slug)) {
      return 'Nama ini sudah dipakai destinasi lain';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Deskripsi wajib diisi';
    if (t.length < 20) return 'Deskripsi minimal 20 karakter';
    return null;
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Ada isian yang belum benar. Periksa kolom merah.'),
          ),
        );
      return;
    }
    FocusScope.of(context).unfocus();

    final name = _name.text.trim();
    final destination = Destination(
      // Slug tidak berubah saat edit supaya favorit, foto, dan relasi camp
      // tetap valid.
      slug: widget.existing?.slug ?? _service.uniqueSlug(name),
      name: name,
      category: _category,
      description: _description.text.trim(),
    );

    if (_editing) {
      _service.update(destination);
    } else {
      _service.add(destination);
    }
    Navigator.pop(context, destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit destinasi' : 'Tambah destinasi'),
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
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              TextFormField(
                controller: _name,
                decoration: fieldDecoration(
                  label: 'Nama destinasi',
                  icon: Icons.place_outlined,
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              Text(
                'Kategori',
                style: TextStyle(
                  color: kTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in kCategories)
                    ChoiceChip(
                      avatar: Icon(
                        c.icon,
                        size: 18,
                        color: _category == c.label ? Colors.white : kPrimary,
                      ),
                      label: Text(c.label),
                      selected: _category == c.label,
                      showCheckmark: false,
                      selectedColor: kPrimary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: _category == c.label ? kPrimary : kBorder,
                      ),
                      labelStyle: TextStyle(
                        color: _category == c.label ? Colors.white : kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) => setState(() => _category = c.label),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                decoration: fieldDecoration(
                  label: 'Deskripsi',
                  icon: Icons.short_text,
                  helper: 'Penjelasan singkat tentang destinasi ini',
                ),
                minLines: 4,
                maxLines: 8,
                textCapitalization: TextCapitalization.sentences,
                validator: _validateDescription,
              ),
              const SizedBox(height: 18),
              _photoNote(),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: Icon(_editing ? Icons.save_outlined : Icons.add),
                label: Text(_editing ? 'Simpan perubahan' : 'Tambah destinasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Catatan cara memasang foto. Nama file mengikuti slug destinasi.
  Widget _photoNote() {
    return ListenableBuilder(
      listenable: _name,
      builder: (context, _) {
        final slug = widget.existing?.slug ??
            (_name.text.trim().isEmpty
                ? 'nama_destinasi'
                : _service.uniqueSlug(_name.text));
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: kAccent.withAlpha(24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.image_outlined, size: 18, color: kAccentText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Foto (opsional): simpan file di assets/images/$slug.jpg '
                  'lalu jalankan ulang aplikasi. Tanpa foto, ilustrasi '
                  'lanskap sesuai kategori akan ditampilkan.',
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    color: kAccentText,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

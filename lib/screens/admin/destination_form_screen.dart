import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/admin_write_error.dart';
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
  bool _saving = false;

  /// Foto yang akan disimpan: foto lama saat edit, atau foto baru dari galeri.
  Uint8List? _photo;

  /// Diaktifkan saat admin menekan simpan tanpa foto.
  bool _photoMissing = false;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name);
    _description = TextEditingController(text: e?.description);
    _category = e?.category ?? kCategories.first.label;
    _photo = e?.imageBytes;
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

  Future<void> _pickPhoto() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 75,
      );
      if (file == null) return; // dibatalkan
      final bytes = await file.readAsBytes();
      if (bytes.length > kMaxPhotoBytes) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text(
              'Ukuran foto terlalu besar (maks. 600 KB). Pilih foto lain.',
            ),
          ));
        return;
      }
      if (!mounted) return;
      setState(() {
        _photo = bytes;
        _photoMissing = false;
      });
    } catch (e) {
      debugPrint('DestinationFormScreen._pickPhoto: $e');
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Gagal membuka galeri. Coba lagi.'),
        ));
    }
  }

  String? _validateDescription(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Deskripsi wajib diisi';
    if (t.length < 20) return 'Deskripsi minimal 20 karakter';
    return null;
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    final photoOk = _photo != null;
    if (!photoOk) setState(() => _photoMissing = true);
    if (form == null || !form.validate() || !photoOk) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              photoOk
                  ? 'Ada isian yang belum benar. Periksa kolom merah.'
                  : 'Foto destinasi wajib diunggah.',
            ),
          ),
        );
      return;
    }
    FocusScope.of(context).unfocus();

    final name = _name.text.trim();
    final destination = Destination(
      slug: widget.existing?.slug ?? _service.uniqueSlug(name),
      name: name,
      category: _category,
      description: _description.text.trim(),
      imageBytes: _photo,
    );

    setState(() => _saving = true);
    try {
      if (_editing) {
        await _service.edit(destination);
      } else {
        await _service.create(destination);
      }
      if (!mounted) return;
      Navigator.pop(context, destination);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(adminWriteErrorMessage(e))));
    }
  }

  /// Pratinjau foto dan tombol unggah. Foto disimpan bersama data destinasi
  /// di Firestore, lalu tampil di kartu sesuai destinasinya.
  Widget _photoSection() {
    final bytes = _photo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto destinasi',
          style: TextStyle(
            color: kTextMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: bytes == null
                ? Container(
                    color: kBorder,
                    alignment: Alignment.center,
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: kPrimary),
                        SizedBox(height: 6),
                        Text(
                          'Belum ada foto',
                          style: TextStyle(color: kTextMuted),
                        ),
                      ],
                    ),
                  )
                : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _saving ? null : _pickPhoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(bytes == null ? 'Pilih foto dari galeri' : 'Ganti foto'),
        ),
        if (_photoMissing)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Foto destinasi wajib diunggah.',
              style: TextStyle(color: kError, fontSize: 12.5),
            ),
          ),
      ],
    );
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
              _photoSection(),
              const SizedBox(height: 20),
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
                        : 'Tambah destinasi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

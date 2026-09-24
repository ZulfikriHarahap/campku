import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/destination_service.dart';

/// Pilihan ikon untuk lencana (badge) di kartu destinasi.
class _BadgeIconOption {
  const _BadgeIconOption(this.label, this.icon);

  final String label;
  final IconData icon;
}

const List<_BadgeIconOption> _kBadgeIcons = [
  _BadgeIconOption('Api', Icons.local_fire_department),
  _BadgeIconOption('Bintang', Icons.star),
  _BadgeIconOption('Hati', Icons.favorite),
  _BadgeIconOption('Kompas', Icons.explore),
  _BadgeIconOption('Matahari', Icons.wb_sunny),
  _BadgeIconOption('Salju', Icons.ac_unit),
  _BadgeIconOption('Daun', Icons.eco),
  _BadgeIconOption('Spa', Icons.spa),
  _BadgeIconOption('Otot', Icons.fitness_center),
  _BadgeIconOption('Kayak', Icons.kayaking),
  _BadgeIconOption('Perahu', Icons.directions_boat),
  _BadgeIconOption('Tetes air', Icons.water_drop),
];

/// Form untuk menambah destinasi baru, atau mengedit jika [existing] diisi.
///
/// Menutup dirinya dengan mengembalikan [Destination] yang sudah tersimpan
/// lewat `Navigator.pop`, atau `null` jika dibatalkan.
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
  late final TextEditingController _location;
  late final TextEditingController _rating;
  late final TextEditingController _price;
  late final TextEditingController _badge;
  late final TextEditingController _description;
  late final TextEditingController _about;
  late final TextEditingController _activities;
  late final TextEditingController _bestTime;
  late final TextEditingController _access;
  late final TextEditingController _facilities;
  late final TextEditingController _tips;

  late String _category;
  late int _iconIndex;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name);
    _location = TextEditingController(text: e?.location);
    _rating = TextEditingController(text: e?.rating.toStringAsFixed(1));
    _price = TextEditingController(
      text: e == null || _priceAmount(e.priceLabel) == 0
          ? null
          : '${_priceAmount(e.priceLabel)}',
    );
    _badge = TextEditingController(text: e?.badge);
    _description = TextEditingController(text: e?.description);
    _about = TextEditingController(text: e?.about);
    _activities = TextEditingController(text: e?.activities.join('\n'));
    _bestTime = TextEditingController(text: e?.bestTime);
    _access = TextEditingController(text: e?.access);
    _facilities = TextEditingController(text: e?.facilities.join('\n'));
    _tips = TextEditingController(text: e?.tips.join('\n'));

    _category = e?.category ?? kCategories.first.label;
    final iconIndex = e == null
        ? 0
        : _kBadgeIcons.indexWhere((o) => o.icon == e.badgeIcon);
    _iconIndex = iconIndex == -1 ? 0 : iconIndex;
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _location,
      _rating,
      _price,
      _badge,
      _description,
      _about,
      _activities,
      _bestTime,
      _access,
      _facilities,
      _tips,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── PARSING & FORMAT ──────────────────────

  /// Angka rupiah dari label seperti "Mulai Rp 25.000" -> 25000.
  static int _priceAmount(String label) =>
      int.tryParse(label.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  /// 25000 -> "Mulai Rp 25.000" (format yang dipakai kartu & detail).
  static String _priceLabel(int amount) {
    final s = amount.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Mulai Rp $b';
  }

  /// Menerima "4.5" maupun "4,5".
  static double? _parseRating(String? text) =>
      double.tryParse((text ?? '').trim().replaceAll(',', '.'));

  /// Satu item per baris; baris kosong diabaikan.
  static List<String> _lines(String? text) => (text ?? '')
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  // ── VALIDATOR ─────────────────────────────

  String? _required(String? value, String label, {int min = 1}) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return '$label wajib diisi';
    if (t.length < min) return '$label minimal $min karakter';
    return null;
  }

  String? _validateName(String? value) {
    final error = _required(value, 'Nama', min: 3);
    if (error != null) return error;
    if (_service.nameTaken(value!, exceptSlug: widget.existing?.slug)) {
      return 'Nama ini sudah dipakai destinasi lain';
    }
    return null;
  }

  String? _validateRating(String? value) {
    final r = _parseRating(value);
    if (r == null) return 'Isi angka, mis. 4.5';
    if (r < 0 || r > 5) return 'Rating harus 0 sampai 5';
    return null;
  }

  String? _validatePrice(String? value) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null || n <= 0) return 'Isi harga lebih dari 0';
    return null;
  }

  String? _validateLines(String? value, String label) {
    if (_lines(value).isEmpty) return '$label minimal satu item';
    return null;
  }

  // ── SIMPAN ────────────────────────────────

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
    final rating = double.parse(_parseRating(_rating.text)!.toStringAsFixed(1));
    final destination = Destination(
      // Slug tidak berubah saat edit supaya favorit & nama foto tetap valid.
      slug: widget.existing?.slug ?? _service.uniqueSlug(name),
      name: name,
      category: _category,
      location: _location.text.trim(),
      rating: rating,
      priceLabel: _priceLabel(int.parse(_price.text.trim())),
      badge: _badge.text.trim(),
      badgeIcon: _kBadgeIcons[_iconIndex].icon,
      description: _description.text.trim(),
      about: _about.text.trim(),
      activities: _lines(_activities.text),
      bestTime: _bestTime.text.trim(),
      access: _access.text.trim(),
      facilities: _lines(_facilities.text),
      tips: _lines(_tips.text),
    );

    if (_editing) {
      _service.update(destination);
    } else {
      _service.add(destination);
    }
    Navigator.pop(context, destination);
  }

  // ── BUILD ─────────────────────────────────

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
              _sectionTitle('Informasi dasar'),
              _field(
                controller: _name,
                label: 'Nama destinasi',
                icon: Icons.place_outlined,
                capitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Kategori'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in kCategories)
                    _choiceChip(
                      label: c.label,
                      icon: c.icon,
                      selected: _category == c.label,
                      onTap: () => setState(() => _category = c.label),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _field(
                controller: _location,
                label: 'Lokasi',
                icon: Icons.map_outlined,
                helper: 'Contoh: Karo, Sumatera Utara',
                capitalization: TextCapitalization.words,
                validator: (v) => _required(v, 'Lokasi', min: 3),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _field(
                      controller: _rating,
                      label: 'Rating (0-5)',
                      icon: Icons.star_outline,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      formatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: _validateRating,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      controller: _price,
                      label: 'Harga mulai (Rp)',
                      icon: Icons.payments_outlined,
                      keyboardType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(9),
                      ],
                      validator: _validatePrice,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Tampilan kartu'),
              _field(
                controller: _badge,
                label: 'Teks lencana',
                icon: Icons.local_offer_outlined,
                helper: 'Label singkat, mis. Populer atau Tersembunyi',
                capitalization: TextCapitalization.words,
                maxLength: 20,
                validator: (v) => _required(v, 'Teks lencana'),
              ),
              const SizedBox(height: 6),
              const _FieldLabel('Ikon lencana'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < _kBadgeIcons.length; i++)
                    _choiceChip(
                      label: _kBadgeIcons[i].label,
                      icon: _kBadgeIcons[i].icon,
                      selected: _iconIndex == i,
                      onTap: () => setState(() => _iconIndex = i),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _field(
                controller: _description,
                label: 'Deskripsi singkat',
                icon: Icons.short_text,
                helper: 'Tampil di kartu dan jendela ringkasan',
                minLines: 3,
                maxLines: 6,
                validator: (v) => _required(v, 'Deskripsi', min: 20),
              ),
              const SizedBox(height: 24),
              _sectionTitle('Halaman detail'),
              _field(
                controller: _about,
                label: 'Tentang tempat ini',
                icon: Icons.article_outlined,
                minLines: 3,
                maxLines: 8,
                validator: (v) => _required(v, 'Penjelasan', min: 20),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _activities,
                label: 'Yang bisa dilakukan',
                icon: Icons.hiking,
                helper: 'Satu item per baris',
                minLines: 3,
                maxLines: 8,
                validator: (v) => _validateLines(v, 'Aktivitas'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _bestTime,
                label: 'Waktu terbaik',
                icon: Icons.wb_sunny_outlined,
                minLines: 2,
                maxLines: 5,
                validator: (v) => _required(v, 'Waktu terbaik'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _access,
                label: 'Cara menuju',
                icon: Icons.directions_car_outlined,
                minLines: 2,
                maxLines: 5,
                validator: (v) => _required(v, 'Cara menuju'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _facilities,
                label: 'Fasilitas',
                icon: Icons.holiday_village_outlined,
                helper: 'Satu item per baris',
                minLines: 3,
                maxLines: 8,
                validator: (v) => _validateLines(v, 'Fasilitas'),
              ),
              const SizedBox(height: 14),
              _field(
                controller: _tips,
                label: 'Tips berkunjung',
                icon: Icons.lightbulb_outline,
                helper: 'Satu item per baris',
                minLines: 3,
                maxLines: 8,
                validator: (v) => _validateLines(v, 'Tips'),
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

  // ── KOMPONEN ──────────────────────────────

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helper,
    int minLines = 1,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? formatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: fieldDecoration(label: label, icon: icon, helper: helper),
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      inputFormatters: formatters,
      validator: validator,
    );
  }

  Widget _choiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      avatar: Icon(icon, size: 18, color: selected ? Colors.white : kPrimary),
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: kPrimary,
      backgroundColor: Colors.white,
      side: BorderSide(color: selected ? kPrimary : kBorder),
      labelStyle: TextStyle(
        color: selected ? Colors.white : kTextDark,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) => onTap(),
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

/// Label kecil di atas kelompok chip.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: kTextMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

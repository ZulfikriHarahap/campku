import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/services/tent_service.dart';

/// Form untuk menambah atau mengedit tipe tenda di dalam satu [camp].
///
/// Field mengikuti "Data Utama" mini SRS: nama, harga, kapasitas (jumlah
/// orang), dan jumlah/stok (FR-09).
class TentFormScreen extends StatefulWidget {
  const TentFormScreen({super.key, required this.camp, this.existing});

  final Camp camp;
  final TentType? existing;

  @override
  State<TentFormScreen> createState() => _TentFormScreenState();
}

class _TentFormScreenState extends State<TentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TentService _service = TentService.instance;

  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _capacity;
  late final TextEditingController _stock;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name);
    _price = TextEditingController(text: e == null ? null : '${e.price}');
    _capacity = TextEditingController(text: e == null ? null : '${e.capacity}');
    _stock = TextEditingController(text: e == null ? null : '${e.stock}');
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _capacity.dispose();
    _stock.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    final t = (value ?? '').trim();
    if (t.isEmpty) return 'Nama tipe tenda wajib diisi';
    if (t.length < 3) return 'Nama minimal 3 karakter';
    if (_service.nameTaken(
      t,
      campId: widget.camp.id,
      exceptId: widget.existing?.id,
    )) {
      return 'Nama ini sudah dipakai tipe tenda lain di camp yang sama';
    }
    return null;
  }

  String? _validatePositiveInt(String? value, String label, {int min = 1}) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null || n < min) return '$label minimal $min';
    return null;
  }

  void _save() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    FocusScope.of(context).unfocus();

    final name = _name.text.trim();
    final tent = TentType(
      id: widget.existing?.id ?? _service.uniqueId(name),
      campId: widget.camp.id,
      name: name,
      price: int.parse(_price.text.trim()),
      capacity: int.parse(_capacity.text.trim()),
      stock: int.parse(_stock.text.trim()),
    );

    if (_editing) {
      _service.update(tent);
    } else {
      _service.add(tent);
    }
    Navigator.pop(context, tent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit tipe tenda' : 'Tambah tipe tenda'),
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
                    const Icon(Icons.holiday_village_outlined,
                        size: 18, color: kPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Camp: ${widget.camp.name}',
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
                  label: 'Nama tipe tenda',
                  icon: Icons.cabin_outlined,
                  helper: 'Contoh: Tenda Dome 2 Orang',
                ),
                textCapitalization: TextCapitalization.words,
                validator: _validateName,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _price,
                decoration: fieldDecoration(
                  label: 'Harga per malam (Rp)',
                  icon: Icons.payments_outlined,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                ],
                validator: (v) => _validatePositiveInt(v, 'Harga'),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _capacity,
                      decoration: fieldDecoration(
                        label: 'Kapasitas (orang)',
                        icon: Icons.groups_outlined,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      validator: (v) =>
                          _validatePositiveInt(v, 'Kapasitas'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stock,
                      decoration: fieldDecoration(
                        label: 'Jumlah/stok',
                        icon: Icons.inventory_2_outlined,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (v) =>
                          _validatePositiveInt(v, 'Stok', min: 0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: Icon(_editing ? Icons.save_outlined : Icons.add),
                label:
                    Text(_editing ? 'Simpan perubahan' : 'Tambah tipe tenda'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

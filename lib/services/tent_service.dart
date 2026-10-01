import 'package:flutter/foundation.dart';

import 'package:campku/data/tent_data.dart';
import 'package:campku/services/auth_service.dart';

/// Penyimpanan tipe tenda di memori yang bisa diubah oleh admin (FR-09).
///
/// Sama seperti [DestinationService] dan [CampService], data hanya
/// bertahan selama aplikasi berjalan. Setiap tipe tenda terhubung ke satu
/// camp lewat [TentType.campId].
class TentService extends ChangeNotifier {
  TentService._();

  static final TentService instance = TentService._();

  final List<TentType> _items = List<TentType>.of(kTentTypes);

  // ── READ ──────────────────────────────────

  List<TentType> get all => List<TentType>.unmodifiable(_items);

  List<TentType> byCamp(String campId) =>
      _items.where((t) => t.campId == campId).toList();

  TentType? findById(String id) {
    for (final t in _items) {
      if (t.id == id) return t;
    }
    return null;
  }

  bool nameTaken(String name, {required String campId, String? exceptId}) {
    final target = _normalize(name);
    return _items.any(
      (t) =>
          t.id != exceptId &&
          t.campId == campId &&
          _normalize(t.name) == target,
    );
  }

  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _slugify(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'tenda' : slug;
  }

  /// Id unik berbasis nama, contoh: "Tenda Dome" -> "tt_tenda_dome".
  String uniqueId(String name) {
    final base = 'tt_${_slugify(name)}';
    var id = base;
    var n = 2;
    while (findById(id) != null) {
      id = '${base}_$n';
      n++;
    }
    return id;
  }

  // ── CREATE / UPDATE / DELETE (khusus admin) ─

  TentType add(TentType t) {
    _requireAdmin();
    if (findById(t.id) != null) {
      throw ArgumentError('Id "${t.id}" sudah dipakai.');
    }
    _items.add(t);
    notifyListeners();
    return t;
  }

  void update(TentType t) {
    _requireAdmin();
    final i = _items.indexWhere((e) => e.id == t.id);
    if (i == -1) {
      throw ArgumentError('Tipe tenda "${t.id}" tidak ditemukan.');
    }
    _items[i] = t;
    notifyListeners();
  }

  /// Mengembalikan `false` jika id tidak ditemukan.
  bool delete(String id) {
    _requireAdmin();
    final before = _items.length;
    _items.removeWhere((t) => t.id == id);
    if (_items.length == before) return false;
    notifyListeners();
    return true;
  }

  /// Dipanggil oleh [CampService] saat camp dihapus, supaya tipe tenda
  /// yatim piatu ikut terhapus. Tidak memerlukan login admin karena hanya
  /// dipanggil dari alur hapus camp yang sudah divalidasi di sana.
  void deleteByCamp(String campId) {
    final before = _items.length;
    _items.removeWhere((t) => t.campId == campId);
    if (_items.length != before) notifyListeners();
  }

  /// Mengembalikan data ke kondisi awal ([kTentTypes]). Untuk pengujian.
  @visibleForTesting
  void reset() {
    _items.clear();
    _items.addAll(kTentTypes);
    notifyListeners();
  }

  static void _requireAdmin() {
    if (!(AuthService.currentUser?.isAdmin ?? false)) {
      throw StateError('Hanya admin yang boleh mengubah data tipe tenda.');
    }
  }
}

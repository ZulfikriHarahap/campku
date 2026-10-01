import 'package:flutter/foundation.dart';

import 'package:campku/data/camp_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/tent_service.dart';

/// Penyimpanan camp di memori yang bisa diubah oleh admin (FR-08).
///
/// Sama seperti [DestinationService], data hanya bertahan selama aplikasi
/// berjalan. Setiap camp terhubung ke satu destinasi lewat
/// [Camp.destinationSlug].
class CampService extends ChangeNotifier {
  CampService._();

  static final CampService instance = CampService._();

  final List<Camp> _items = List<Camp>.of(kCamps);

  // ── READ ──────────────────────────────────

  List<Camp> get all => List<Camp>.unmodifiable(_items);

  List<Camp> byDestination(String destinationSlug) =>
      _items.where((c) => c.destinationSlug == destinationSlug).toList();

  Camp? findById(String id) {
    for (final c in _items) {
      if (c.id == id) return c;
    }
    return null;
  }

  bool nameTaken(
    String name, {
    required String destinationSlug,
    String? exceptId,
  }) {
    final target = _normalize(name);
    return _items.any(
      (c) =>
          c.id != exceptId &&
          c.destinationSlug == destinationSlug &&
          _normalize(c.name) == target,
    );
  }

  static String _normalize(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String _slugify(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'camp' : slug;
  }

  /// Id unik berbasis nama, contoh: "Camp Tepi Danau" -> "camp_tepi_danau".
  String uniqueId(String name) {
    final base = 'camp_${_slugify(name)}';
    var id = base;
    var n = 2;
    while (findById(id) != null) {
      id = '${base}_$n';
      n++;
    }
    return id;
  }

  // ── CREATE / UPDATE / DELETE (khusus admin) ─

  Camp add(Camp c) {
    _requireAdmin();
    if (findById(c.id) != null) {
      throw ArgumentError('Id "${c.id}" sudah dipakai.');
    }
    _items.add(c);
    notifyListeners();
    return c;
  }

  void update(Camp c) {
    _requireAdmin();
    final i = _items.indexWhere((e) => e.id == c.id);
    if (i == -1) {
      throw ArgumentError('Camp "${c.id}" tidak ditemukan.');
    }
    _items[i] = c;
    notifyListeners();
  }

  /// Menghapus camp beserta seluruh tipe tenda yang terhubung.
  /// Mengembalikan `false` jika id tidak ditemukan.
  bool delete(String id) {
    _requireAdmin();
    final before = _items.length;
    _items.removeWhere((c) => c.id == id);
    if (_items.length == before) return false;
    TentService.instance.deleteByCamp(id);
    notifyListeners();
    return true;
  }

  /// Dipanggil oleh [DestinationService] saat destinasi dihapus, supaya
  /// camp yatim piatu (dan tenda-tendanya) ikut terhapus. Tidak memerlukan
  /// login admin karena hanya dipanggil dari alur hapus destinasi yang
  /// sudah divalidasi di sana.
  void deleteByDestination(String destinationSlug) {
    final ids = _items
        .where((c) => c.destinationSlug == destinationSlug)
        .map((c) => c.id)
        .toList();
    if (ids.isEmpty) return;
    _items.removeWhere((c) => c.destinationSlug == destinationSlug);
    for (final id in ids) {
      TentService.instance.deleteByCamp(id);
    }
    notifyListeners();
  }

  /// Mengembalikan data ke kondisi awal ([kCamps]). Untuk pengujian.
  @visibleForTesting
  void reset() {
    _items.clear();
    _items.addAll(kCamps);
    notifyListeners();
  }

  static void _requireAdmin() {
    if (!(AuthService.currentUser?.isAdmin ?? false)) {
      throw StateError('Hanya admin yang boleh mengubah data camp.');
    }
  }
}

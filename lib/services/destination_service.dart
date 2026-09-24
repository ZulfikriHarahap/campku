import 'package:flutter/foundation.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/auth_service.dart';

/// Penyimpanan destinasi di memori yang bisa diubah oleh admin (CRUD).
///
/// Data awal berasal dari [kDestinations]. Seperti [AuthService], perubahan
/// hanya bertahan selama aplikasi berjalan karena belum ada backend/database.
/// Layar yang menampilkan destinasi cukup memanggil [addListener] supaya ikut
/// diperbarui ketika admin menambah, mengubah, atau menghapus destinasi.
///
/// Langkah berikutnya: ganti isi [add], [update], dan [delete] dengan
/// `shared_preferences`, SQLite, atau Firebase Firestore.
class DestinationService extends ChangeNotifier {
  DestinationService._();

  static final DestinationService instance = DestinationService._();

  final List<Destination> _items = List<Destination>.of(kDestinations);

  // ── READ ──────────────────────────────────

  List<Destination> get all => List<Destination>.unmodifiable(_items);

  int get count => _items.length;

  List<Destination> byCategory(String label) =>
      _items.where((d) => d.category == label).toList();

  Destination? findBySlug(String slug) {
    for (final d in _items) {
      if (d.slug == slug) return d;
    }
    return null;
  }

  /// Apakah [name] sudah dipakai destinasi lain (tanpa membedakan huruf
  /// besar/kecil). [exceptSlug] dipakai saat mengedit destinasi itu sendiri.
  bool nameTaken(String name, {String? exceptSlug}) {
    final target = _normalizeName(name);
    return _items.any(
      (d) => d.slug != exceptSlug && _normalizeName(d.name) == target,
    );
  }

  static String _normalizeName(String s) =>
      s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  /// Mengubah nama menjadi slug, contoh: "Danau Toba!" -> "danau_toba".
  /// Slug dipakai sebagai kunci favorit dan nama file foto.
  static String slugify(String name) {
    final slug = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return slug.isEmpty ? 'destinasi' : slug;
  }

  /// Slug dari [name] yang dijamin belum dipakai (ditambah _2, _3, ...).
  String uniqueSlug(String name) {
    final base = slugify(name);
    var slug = base;
    var n = 2;
    while (findBySlug(slug) != null) {
      slug = '${base}_$n';
      n++;
    }
    return slug;
  }

  // ── CREATE / UPDATE / DELETE (khusus admin) ─

  /// Menambah destinasi baru. Diletakkan di akhir kelompok kategorinya agar
  /// urutan daftar tetap rapi per kategori.
  Destination add(Destination d) {
    _requireAdmin();
    if (findBySlug(d.slug) != null) {
      throw ArgumentError('Slug "${d.slug}" sudah dipakai.');
    }
    final last = _items.lastIndexWhere((e) => e.category == d.category);
    if (last == -1) {
      _items.add(d);
    } else {
      _items.insert(last + 1, d);
    }
    notifyListeners();
    return d;
  }

  /// Mengganti data destinasi yang slug-nya sama dengan [d.slug].
  void update(Destination d) {
    _requireAdmin();
    final i = _items.indexWhere((e) => e.slug == d.slug);
    if (i == -1) {
      throw ArgumentError('Destinasi "${d.slug}" tidak ditemukan.');
    }
    _items[i] = d;
    notifyListeners();
  }

  /// Menghapus destinasi (dan menghapusnya dari favorit semua akun).
  /// Mengembalikan `false` jika slug tidak ditemukan.
  bool delete(String slug) {
    _requireAdmin();
    final before = _items.length;
    _items.removeWhere((d) => d.slug == slug);
    if (_items.length == before) return false;
    AuthService.forgetDestination(slug);
    notifyListeners();
    return true;
  }

  /// Mengembalikan data ke kondisi awal ([kDestinations]). Untuk pengujian.
  @visibleForTesting
  void reset() {
    _items.clear();
    _items.addAll(kDestinations);
    notifyListeners();
  }

  static void _requireAdmin() {
    if (!(AuthService.currentUser?.isAdmin ?? false)) {
      throw StateError('Hanya admin yang boleh mengubah data destinasi.');
    }
  }
}

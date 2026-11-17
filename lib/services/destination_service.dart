import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';

/// Penyimpanan destinasi yang bisa diubah oleh admin (FR-08).
///
/// Data dibaca langsung dari koleksi Firestore `destinations` lewat [start].
/// Metode [create], [edit], dan [remove] menulis ke Firestore; [add],
/// [update], dan [delete] hanya memperbarui cache lokal (dipakai tes).
/// Layar cukup memanggil [addListener] supaya ikut diperbarui.
class DestinationService extends ChangeNotifier {
  DestinationService._();

  static final DestinationService instance = DestinationService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final List<Destination> _items = List<Destination>.of(kDestinations);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// Mulai mendengarkan Firestore (koleksi `destinations`). Dipanggil sekali dari
  /// `main()` setelah Firebase diinisialisasi. Tidak dipanggil di tes, jadi
  /// tes tetap memakai data contoh lokal.
  void start() {
    if (_sub != null) return;
    _sub = FirebaseFirestore.instance
        .collection('destinations')
        .orderBy('order')
        .snapshots()
        .listen(
      (snap) {
        _items
          ..clear()
          ..addAll(snap.docs.map((d) => Destination.fromMap(d.id, d.data())));
        notifyListeners();
      },
      onError: (Object e) => debugPrint('DestinationService: $e'),
    );
  }

  /// Berhenti mendengarkan Firestore (dipanggil saat keluar dari akun).
  void stop() {
    _sub?.cancel();
    _sub = null;
  }

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
  /// Slug dipakai sebagai kunci favorit, relasi Camp, dan nama file foto.
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

  /// Menyimpan destinasi baru ke Firestore lalu memperbarui cache lokal.
  Future<Destination> create(Destination d) async {
    _requireAdmin();
    if (findBySlug(d.slug) != null) {
      throw ArgumentError('Slug "${d.slug}" sudah dipakai.');
    }
    await _db.collection('destinations').doc(d.slug).set({
      ...d.toMap(),
      'order': _items.length,
    });
    return _insert(d);
  }

  /// Menyimpan perubahan destinasi ke Firestore lalu memperbarui cache lokal.
  Future<void> edit(Destination d) async {
    _requireAdmin();
    _requireIndex(d.slug);
    await _db.collection('destinations').doc(d.slug).set(
          d.toMap(),
          SetOptions(merge: true),
        );
    final i = _items.indexWhere((e) => e.slug == d.slug);
    if (i != -1) _replace(i, d);
  }

  /// Menghapus destinasi beserta camp dan tipe tendanya dari Firestore.
  /// Mengembalikan `false` jika slug tidak ditemukan.
  Future<bool> remove(String slug) async {
    _requireAdmin();
    _requireIndex(slug);
    final camps = CampService.instance.byDestination(slug);
    final batch = _db.batch();
    batch.delete(_db.collection('destinations').doc(slug));
    for (final camp in camps) {
      batch.delete(_db.collection('camps').doc(camp.id));
      for (final tent in TentService.instance.byCamp(camp.id)) {
        batch.delete(_db.collection('tent_types').doc(tent.id));
      }
    }
    await batch.commit();
    return delete(slug);
  }

  Destination add(Destination d) {
    _requireAdmin();
    if (findBySlug(d.slug) != null) {
      throw ArgumentError('Slug "${d.slug}" sudah dipakai.');
    }
    return _insert(d);
  }

  /// Mengganti data destinasi yang slug-nya sama dengan [d.slug].
  void update(Destination d) {
    _requireAdmin();
    _replace(_requireIndex(d.slug), d);
  }

  /// Menghapus destinasi beserta seluruh camp (dan tipe tendanya) yang
  /// terhubung, dan menghapusnya dari favorit semua akun.
  /// Mengembalikan `false` jika slug tidak ditemukan.
  bool delete(String slug) {
    _requireAdmin();
    final i = _items.indexWhere((d) => d.slug == slug);
    if (i == -1) return false;
    _items.removeAt(i);
    AuthService.forgetDestination(slug);
    CampService.instance.deleteByDestination(slug);
    notifyListeners();
    return true;
  }

  int _requireIndex(String slug) {
    final i = _items.indexWhere((e) => e.slug == slug);
    if (i == -1) throw ArgumentError('Destinasi "$slug" tidak ditemukan.');
    return i;
  }

  Destination _insert(Destination d) {
    _items.add(d);
    notifyListeners();
    return d;
  }

  void _replace(int i, Destination d) {
    _items[i] = d;
    notifyListeners();
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

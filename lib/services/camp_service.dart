import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:campku/data/camp_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/tent_service.dart';

/// Penyimpanan camp yang bisa diubah oleh admin (FR-08).
///
/// Data dibaca dari koleksi Firestore `camps` lewat [start]. Metode [create],
/// [edit], dan [remove] menulis ke Firestore; [add], [update], dan [delete]
/// hanya memperbarui cache lokal (dipakai tes). Setiap camp terhubung ke satu
/// destinasi lewat [Camp.destinationSlug].
class CampService extends ChangeNotifier {
  CampService._();

  static final CampService instance = CampService._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  final List<Camp> _items = List<Camp>.of(kCamps);

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  /// Mulai mendengarkan Firestore (koleksi `camps`). Dipanggil sekali dari
  /// `main()` setelah Firebase diinisialisasi. Tidak dipanggil di tes, jadi
  /// tes tetap memakai data contoh lokal.
  void start() {
    if (_sub != null) return;
    _sub = FirebaseFirestore.instance
        .collection('camps')
        .orderBy('order')
        .snapshots()
        .listen(
      (snap) {
        _items
          ..clear()
          ..addAll(snap.docs.map((d) => Camp.fromMap(d.id, d.data())));
        notifyListeners();
      },
      onError: (Object e) => debugPrint('CampService: $e'),
    );
  }

  /// Berhenti mendengarkan Firestore (dipanggil saat keluar dari akun).
  void stop() {
    _sub?.cancel();
    _sub = null;
  }

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

  /// Menyimpan camp baru ke Firestore lalu memperbarui cache lokal.
  Future<Camp> create(Camp c) async {
    _requireAdmin();
    if (findById(c.id) != null) {
      throw ArgumentError('Id "${c.id}" sudah dipakai.');
    }
    await _db.collection('camps').doc(c.id).set({
      ...c.toMap(),
      'order': _items.length,
    });
    // Listener Firestore (snapshots) sering sudah memasukkan dokumen ini ke
    // cache lokal begitu `set()` dipanggil. Tambahkan hanya jika belum ada,
    // supaya data tidak tampil dobel.
    return findById(c.id) ?? _insert(c);
  }

  /// Menyimpan perubahan camp ke Firestore lalu memperbarui cache lokal.
  Future<void> edit(Camp c) async {
    _requireAdmin();
    _requireIndex(c.id);
    await _db.collection('camps').doc(c.id).set(
          c.toMap(),
          SetOptions(merge: true),
        );
    final i = _items.indexWhere((e) => e.id == c.id);
    if (i != -1) _replace(i, c);
  }

  /// Menghapus camp beserta tipe tendanya dari Firestore.
  /// Mengembalikan `false` jika id tidak ditemukan.
  Future<bool> remove(String id) async {
    _requireAdmin();
    _requireIndex(id);
    final batch = _db.batch();
    batch.delete(_db.collection('camps').doc(id));
    for (final tent in TentService.instance.byCamp(id)) {
      batch.delete(_db.collection('tent_types').doc(tent.id));
    }
    await batch.commit();
    return delete(id);
  }

  Camp add(Camp c) {
    _requireAdmin();
    if (findById(c.id) != null) {
      throw ArgumentError('Id "${c.id}" sudah dipakai.');
    }
    return _insert(c);
  }

  void update(Camp c) {
    _requireAdmin();
    _replace(_requireIndex(c.id), c);
  }

  /// Menghapus camp beserta seluruh tipe tenda yang terhubung.
  /// Mengembalikan `false` jika id tidak ditemukan.
  bool delete(String id) {
    _requireAdmin();
    final i = _items.indexWhere((c) => c.id == id);
    if (i == -1) return false;
    _items.removeAt(i);
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

  int _requireIndex(String id) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i == -1) throw ArgumentError('Camp "$id" tidak ditemukan.');
    return i;
  }

  Camp _insert(Camp c) {
    _items.add(c);
    notifyListeners();
    return c;
  }

  void _replace(int i, Camp c) {
    _items[i] = c;
    notifyListeners();
  }

  static void _requireAdmin() {
    if (!(AuthService.currentUser?.isAdmin ?? false)) {
      throw StateError('Hanya admin yang boleh mengubah data camp.');
    }
  }
}

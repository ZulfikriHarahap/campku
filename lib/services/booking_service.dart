import 'package:flutter/foundation.dart';

import 'package:campku/data/booking_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/tent_service.dart';

/// Penyimpanan booking di memori (FR-06, FR-07, FR-10).
///
/// Alur: user memilih camp & tipe tenda, memilih tanggal dan jumlah
/// malam, sistem menghitung total harga, lalu [create] dipanggil setelah
/// simulasi pembayaran berhasil. Booking baru berstatus
/// [BookingApproval.menunggu] sampai admin menyetujui atau menolaknya
/// lewat [approve]/[reject].
class BookingService extends ChangeNotifier {
  BookingService._();

  static final BookingService instance = BookingService._();

  final List<Booking> _items = [];

  // ── READ ──────────────────────────────────

  List<Booking> get all =>
      List<Booking>.unmodifiable(_items.reversed.toList());

  /// Booking milik satu akun, terbaru lebih dulu (FR-07: tiket/riwayat).
  List<Booking> byUser(String email) =>
      _items.where((b) => b.userEmail == email).toList().reversed.toList();

  List<Booking> get pending =>
      _items.where((b) => b.approval == BookingApproval.menunggu).toList();

  Booking? findById(String id) {
    for (final b in _items) {
      if (b.id == id) return b;
    }
    return null;
  }

  String _uniqueId() {
    var id = 'BK${DateTime.now().millisecondsSinceEpoch}';
    while (findById(id) != null) {
      id = 'BK${DateTime.now().millisecondsSinceEpoch}';
    }
    return id;
  }

  // ── BUAT BOOKING (user) ──────────────────────

  /// Membuat booking baru untuk akun yang sedang masuk, lalu mengurangi
  /// stok [tent] sebanyak satu unit. Melempar [StateError] jika belum
  /// masuk atau stok habis.
  Booking create({
    required String destinationName,
    required Camp camp,
    required TentType tent,
    required DateTime checkIn,
    required int nights,
  }) {
    final user = AuthService.currentUser;
    if (user == null) {
      throw StateError('Harus masuk untuk melakukan booking.');
    }
    if (tent.stock <= 0) {
      throw StateError('Stok tipe tenda ini sudah habis.');
    }
    if (nights < 1) {
      throw ArgumentError('Jumlah malam minimal 1.');
    }

    final booking = Booking(
      id: _uniqueId(),
      userEmail: user.email,
      destinationName: destinationName,
      campId: camp.id,
      campName: camp.name,
      tentTypeId: tent.id,
      tentName: tent.name,
      pricePerNight: tent.price,
      checkIn: checkIn,
      nights: nights,
      totalPrice: tent.price * nights,
      createdAt: DateTime.now(),
    );
    _items.add(booking);
    TentService.instance.adjustStock(tent.id, -1);
    notifyListeners();
    return booking;
  }

  // ── PERSETUJUAN (admin) ──────────────────────

  void approve(String id) {
    _requireAdmin();
    _setApproval(id, BookingApproval.disetujui);
  }

  /// Menolak booking dan mengembalikan satu unit stok tipe tendanya.
  void reject(String id) {
    _requireAdmin();
    final b = findById(id);
    if (b == null) throw ArgumentError('Booking "$id" tidak ditemukan.');
    if (b.approval != BookingApproval.ditolak) {
      TentService.instance.adjustStock(b.tentTypeId, 1);
    }
    _setApproval(id, BookingApproval.ditolak);
  }

  void _setApproval(String id, BookingApproval approval) {
    final i = _items.indexWhere((b) => b.id == id);
    if (i == -1) throw ArgumentError('Booking "$id" tidak ditemukan.');
    _items[i] = _items[i].copyWith(approval: approval);
    notifyListeners();
  }

  /// Mengembalikan data ke kondisi kosong. Untuk pengujian.
  @visibleForTesting
  void reset() {
    _items.clear();
    notifyListeners();
  }

  static void _requireAdmin() {
    if (!(AuthService.currentUser?.isAdmin ?? false)) {
      throw StateError('Hanya admin yang boleh menyetujui/menolak booking.');
    }
  }
}

import 'package:flutter/foundation.dart';

import 'package:campku/data/booking_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/services/auth_service.dart';

/// Penyimpanan booking di memori (FR-06, FR-07, FR-10).
///
/// Alur: user memilih camp & tipe tenda, memilih tanggal dan jumlah
/// malam, sistem menghitung total harga, lalu [create] dipanggil setelah
/// simulasi pembayaran berhasil. Booking baru berstatus
/// [BookingApproval.menunggu] sampai admin menyetujui atau menolaknya
/// lewat [approve]/[reject].
///
/// Stok tipe tenda ([TentType.stock]) adalah jumlah total unit yang
/// dimiliki camp dan tidak pernah berkurang secara permanen. Yang berubah
/// per pemesanan adalah stok yang tersedia untuk *tanggal tertentu*,
/// dihitung lewat [availableStock] dengan membandingkan stok total
/// terhadap jumlah booking aktif (bukan [BookingApproval.ditolak]) yang
/// rentang tanggalnya tumpang tindih dengan tanggal yang diminta.
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

  // ── STOK PER TANGGAL ──────────────────────────

  bool _isBooked(Booking b) => b.approval != BookingApproval.ditolak;

  bool _overlaps(Booking b, DateTime checkIn, DateTime checkOut) =>
      b.checkIn.isBefore(checkOut) && checkIn.isBefore(b.checkOut);

  /// Jumlah unit tipe tenda [tentTypeId] yang sudah terpakai booking aktif
  /// (bukan yang ditolak) pada rentang tanggal [checkIn]..[checkIn]+[nights].
  int bookedUnits({
    required String tentTypeId,
    required DateTime checkIn,
    required int nights,
  }) {
    final checkOut = checkIn.add(Duration(days: nights));
    return _items
        .where((b) =>
            b.tentTypeId == tentTypeId &&
            _isBooked(b) &&
            _overlaps(b, checkIn, checkOut))
        .length;
  }

  /// Sisa stok [tent] yang masih bisa dibooking untuk [checkIn] sebanyak
  /// [nights] malam. Bisa dipakai untuk menampilkan sisa stok per tanggal
  /// sebelum user melanjutkan ke pembayaran.
  int availableStock(TentType tent, DateTime checkIn, int nights) {
    final terpakai = bookedUnits(
      tentTypeId: tent.id,
      checkIn: checkIn,
      nights: nights,
    );
    final sisa = tent.stock - terpakai;
    return sisa < 0 ? 0 : sisa;
  }

  // ── BUAT BOOKING (user) ──────────────────────

  /// Membuat booking baru untuk akun yang sedang masuk. Melempar
  /// [StateError] jika belum masuk atau stok tipe tenda ini sudah habis
  /// untuk tanggal yang dipilih.
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
    if (nights < 1) {
      throw ArgumentError('Jumlah malam minimal 1.');
    }
    if (availableStock(tent, checkIn, nights) <= 0) {
      throw StateError(
        'Stok tipe tenda ini sudah habis untuk tanggal yang dipilih.',
      );
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
    notifyListeners();
    return booking;
  }

  // ── PERSETUJUAN (admin) ──────────────────────

  void approve(String id) {
    _requireAdmin();
    _setApproval(id, BookingApproval.disetujui);
  }

  /// Menolak booking. Karena stok dihitung dinamis per tanggal lewat
  /// [availableStock] (yang mengecualikan booking berstatus ditolak),
  /// menolak booking otomatis membebaskan kembali slot tanggalnya untuk
  /// dibooking user lain.
  void reject(String id) {
    _requireAdmin();
    if (findById(id) == null) {
      throw ArgumentError('Booking "$id" tidak ditemukan.');
    }
    _setApproval(id, BookingApproval.ditolak);
  }

  /// Menghapus booking dari riwayat secara permanen (berbeda dari
  /// [reject], yang hanya mengubah status). Karena stok dihitung dinamis
  /// dari daftar booking aktif lewat [availableStock], menghapus booking
  /// otomatis mengembalikan stok tanggalnya seperti semula.
  /// Mengembalikan `false` jika id tidak ditemukan.
  bool delete(String id) {
    _requireAdmin();
    final before = _items.length;
    _items.removeWhere((b) => b.id == id);
    if (_items.length == before) return false;
    notifyListeners();
    return true;
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

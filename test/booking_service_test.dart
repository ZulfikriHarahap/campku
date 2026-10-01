import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/data/booking_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';
import 'package:campku/services/booking_service.dart';

const _destination = Destination(
  slug: 'bukit_contoh',
  name: 'Bukit Contoh',
  category: 'Gunung',
  description: 'Destinasi contoh untuk pengujian booking.',
);
const _camp = Camp(id: 'camp_contoh', name: 'Camp Contoh', destinationSlug: 'bukit_contoh');
const _tent = TentType(
  id: 'tt_contoh',
  campId: 'camp_contoh',
  name: 'Tenda Contoh',
  price: 75000,
  capacity: 2,
  stock: 2,
);

void _loginAsAdmin() {
  final error = AuthService.login(
    email: AuthService.adminEmail,
    password: AuthService.adminPassword,
    role: UserRole.admin,
  );
  expect(error, isNull);
}

void _loginAsNewUser({String email = 'petualang@campku.id'}) {
  AuthService.logout();
  final error = AuthService.register(
    name: 'Petualang', email: email, password: 'user123',
  );
  expect(error, isNull);
}

void main() {
  final destinations = DestinationService.instance;
  final camps = CampService.instance;
  final tents = TentService.instance;
  final bookings = BookingService.instance;

  setUp(() {
    AuthService.logout();
    AuthService.resetUsers();
    destinations.reset();
    camps.reset();
    tents.reset();
    bookings.reset();

    _loginAsAdmin();
    destinations.add(_destination);
    camps.add(_camp);
    tents.add(_tent);
    AuthService.logout();
  });

  group('BookingService - buat booking (FR-06)', () {
    test('booking berhasil, total harga benar, dan stok berkurang', () {
      _loginAsNewUser();
      final checkIn = DateTime(2027, 1, 10);

      final booking = bookings.create(
        destinationName: _destination.name,
        camp: _camp,
        tent: tents.findById('tt_contoh')!,
        checkIn: checkIn,
        nights: 3,
      );

      expect(booking.totalPrice, 75000 * 3);
      expect(booking.approval, BookingApproval.menunggu);
      expect(booking.userEmail, 'petualang@campku.id');
      expect(tents.findById('tt_contoh')?.stock, 1);
    });

    test('harus masuk (login) untuk booking', () {
      expect(
        () => bookings.create(
          destinationName: _destination.name,
          camp: _camp,
          tent: tents.findById('tt_contoh')!,
          checkIn: DateTime(2027, 1, 10),
          nights: 1,
        ),
        throwsStateError,
      );
    });

    test('booking gagal saat stok habis', () {
      _loginAsAdmin();
      tents.update(TentType(
        id: _tent.id,
        campId: _tent.campId,
        name: _tent.name,
        price: _tent.price,
        capacity: _tent.capacity,
        stock: 0,
      ));
      _loginAsNewUser();

      expect(
        () => bookings.create(
          destinationName: _destination.name,
          camp: _camp,
          tent: tents.findById('tt_contoh')!,
          checkIn: DateTime(2027, 1, 10),
          nights: 1,
        ),
        throwsStateError,
      );
    });

    test('booking milik akun sendiri muncul di byUser, bukan akun lain', () {
      _loginAsNewUser(email: 'a@campku.id');
      bookings.create(
        destinationName: _destination.name,
        camp: _camp,
        tent: tents.findById('tt_contoh')!,
        checkIn: DateTime(2027, 1, 10),
        nights: 1,
      );
      _loginAsNewUser(email: 'b@campku.id');

      expect(bookings.byUser('a@campku.id'), hasLength(1));
      expect(bookings.byUser('b@campku.id'), isEmpty);
    });
  });

  group('BookingService - persetujuan admin (FR-10)', () {
    late Booking booking;

    setUp(() {
      _loginAsNewUser();
      booking = bookings.create(
        destinationName: _destination.name,
        camp: _camp,
        tent: tents.findById('tt_contoh')!,
        checkIn: DateTime(2027, 1, 10),
        nights: 1,
      );
      AuthService.logout();
    });

    test('admin dapat menyetujui booking', () {
      _loginAsAdmin();
      bookings.approve(booking.id);
      expect(bookings.findById(booking.id)?.approval, BookingApproval.disetujui);
    });

    test('admin menolak booking mengembalikan stok', () {
      _loginAsAdmin();
      final stockBefore = tents.findById('tt_contoh')!.stock;

      bookings.reject(booking.id);

      expect(bookings.findById(booking.id)?.approval, BookingApproval.ditolak);
      expect(tents.findById('tt_contoh')?.stock, stockBefore + 1);
    });

    test('bukan admin tidak bisa menyetujui/menolak', () {
      _loginAsNewUser(email: 'lain@campku.id');
      expect(() => bookings.approve(booking.id), throwsStateError);
      expect(() => bookings.reject(booking.id), throwsStateError);
    });

    test('pending hanya berisi booking yang masih menunggu', () {
      _loginAsAdmin();
      expect(bookings.pending, hasLength(1));
      bookings.approve(booking.id);
      expect(bookings.pending, isEmpty);
    });
  });
}

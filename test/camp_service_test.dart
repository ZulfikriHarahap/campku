import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/camp_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';

Camp _sample({
  String id = 'camp_contoh',
  String name = 'Camp Contoh',
  String destinationSlug = 'sibayak',
}) {
  return Camp(id: id, name: name, destinationSlug: destinationSlug);
}

void _loginAsAdmin() {
  final error = AuthService.login(
    email: AuthService.adminEmail,
    password: AuthService.adminPassword,
    role: UserRole.admin,
  );
  expect(error, isNull);
}

void main() {
  final destinations = DestinationService.instance;
  final camps = CampService.instance;
  final tents = TentService.instance;

  setUp(() {
    AuthService.logout();
    destinations.reset();
    camps.reset();
    tents.reset();
  });

  group('CampService - baca', () {
    test('data awal sama dengan kCamps', () {
      expect(camps.all.length, kCamps.length);
      expect(camps.byDestination('sibayak'), isNotEmpty);
      expect(camps.byDestination('sibayak').every(
        (c) => c.destinationSlug == 'sibayak',
      ), isTrue);
    });

    test('nameTaken hanya membandingkan camp di destinasi yang sama', () {
      final existingName = camps.byDestination('sibayak').first.name;
      expect(
        camps.nameTaken(existingName, destinationSlug: 'sibayak'),
        isTrue,
      );
      expect(
        camps.nameTaken(existingName, destinationSlug: 'toba'),
        isFalse,
      );
    });

    test('uniqueId menghasilkan id yang belum dipakai', () {
      final id = camps.uniqueId('Camp Baru Sekali');
      expect(camps.findById(id), isNull);
    });
  });

  group('CampService - CRUD admin', () {
    test('tambah camp baru', () {
      _loginAsAdmin();
      var notified = 0;
      camps.addListener(() => notified++);

      camps.add(_sample());

      expect(camps.findById('camp_contoh'), isNotNull);
      expect(notified, 1);
    });

    test('id yang sama tidak boleh ditambahkan dua kali', () {
      _loginAsAdmin();
      camps.add(_sample());
      expect(() => camps.add(_sample()), throwsArgumentError);
    });

    test('update mengganti data camp', () {
      _loginAsAdmin();
      camps.add(_sample());

      camps.update(_sample(name: 'Camp Contoh Baru'));

      expect(camps.findById('camp_contoh')?.name, 'Camp Contoh Baru');
    });

    test('hapus camp menghilangkan tipe tendanya', () {
      _loginAsAdmin();
      final campId = camps.byDestination('sibayak').first.id;
      expect(tents.byCamp(campId), isNotEmpty);

      expect(camps.delete(campId), isTrue);

      expect(camps.findById(campId), isNull);
      expect(tents.byCamp(campId), isEmpty);
      expect(camps.delete(campId), isFalse);
    });
  });

  group('CampService - hak akses', () {
    test('tanpa login tidak bisa mengubah data', () {
      expect(() => camps.add(_sample()), throwsStateError);
    });

    test('pengguna biasa tidak bisa mengubah data', () {
      final error = AuthService.login(
        email: 'user@campku.id',
        password: 'user123',
        role: UserRole.user,
      );
      expect(error, isNull);
      expect(() => camps.add(_sample()), throwsStateError);
    });
  });
}

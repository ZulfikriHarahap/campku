import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';

Camp _sample({
  String id = 'camp_contoh',
  String name = 'Camp Contoh',
  String destinationSlug = 'bukit_contoh',
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
    AuthService.resetUsers();
    destinations.reset();
    camps.reset();
    tents.reset();
    _loginAsAdmin();
    destinations.add(const Destination(
      slug: 'bukit_contoh',
      name: 'Bukit Contoh',
      category: 'Gunung',
      description: 'Destinasi contoh untuk pengujian camp.',
    ));
    AuthService.logout();
  });

  group('CampService - baca', () {
    test('data awal berisi camp bawaan, destinasi baru belum punya camp', () {
      expect(camps.all.length, kCamps.length);
      expect(camps.byDestination('bukit_contoh'), isEmpty);
    });

    test('byDestination hanya mengembalikan camp destinasi tersebut', () {
      _loginAsAdmin();
      camps.add(_sample());
      camps.add(_sample(id: 'camp_lain', destinationSlug: 'lain'));

      expect(camps.byDestination('bukit_contoh').map((c) => c.id), ['camp_contoh']);
    });

    test('nameTaken hanya membandingkan camp di destinasi yang sama', () {
      _loginAsAdmin();
      camps.add(_sample());

      expect(camps.nameTaken('Camp Contoh', destinationSlug: 'bukit_contoh'), isTrue);
      expect(camps.nameTaken('Camp Contoh', destinationSlug: 'lain'), isFalse);
    });

    test('uniqueId menghasilkan id yang belum dipakai', () {
      _loginAsAdmin();
      camps.add(_sample());
      final id = camps.uniqueId('Camp Contoh');
      expect(id, isNot('camp_contoh'));
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
      camps.add(_sample());
      tents.add(const TentType(
        id: 'tt_contoh',
        campId: 'camp_contoh',
        name: 'Tenda Contoh',
        price: 50000,
        capacity: 2,
        stock: 3,
      ));

      expect(camps.delete('camp_contoh'), isTrue);

      expect(camps.findById('camp_contoh'), isNull);
      expect(tents.byCamp('camp_contoh'), isEmpty);
      expect(camps.delete('camp_contoh'), isFalse);
    });
  });

  group('CampService - hak akses', () {
    test('tanpa login tidak bisa mengubah data', () {
      expect(() => camps.add(_sample()), throwsStateError);
    });

    test('pengguna biasa tidak bisa mengubah data', () {
      final error = AuthService.register(
        name: 'Petualang', email: 'biasa@campku.id', password: 'user123',
      );
      expect(error, isNull);
      expect(() => camps.add(_sample()), throwsStateError);
    });
  });
}
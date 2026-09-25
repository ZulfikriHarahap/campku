import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';

Destination _sample({
  String slug = 'bukit_contoh',
  String name = 'Bukit Contoh',
  String category = 'Gunung',
}) {
  return Destination(
    slug: slug,
    name: name,
    category: category,
    description: 'Bukit contoh untuk pengujian layanan destinasi.',
  );
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
  });

  group('DestinationService - baca', () {
    test('data awal berisi destinasi bawaan (dummy demo)', () {
      expect(destinations.count, kDestinations.length);
      expect(destinations.count, greaterThan(0));
      expect(destinations.findBySlug('sibayak')?.name, 'Gunung Sibayak');
      expect(destinations.findBySlug('tidak_ada'), isNull);
    });

    test('byCategory hanya mengembalikan kategori yang diminta', () {
      _loginAsAdmin();
      final before = destinations.byCategory('Gunung').length;
      destinations.add(_sample(slug: 'a', name: 'A', category: 'Gunung'));
      destinations.add(_sample(slug: 'b', name: 'B', category: 'Danau'));

      final gunung = destinations.byCategory('Gunung');
      expect(gunung.length, before + 1);
      expect(gunung.every((d) => d.category == 'Gunung'), isTrue);
      expect(gunung.map((d) => d.slug), contains('a'));
    });

    test('nameTaken tidak membedakan huruf besar/kecil', () {
      _loginAsAdmin();
      destinations.add(_sample());

      expect(destinations.nameTaken('  bukit   CONTOH '), isTrue);
      expect(
        destinations.nameTaken('Bukit Contoh', exceptSlug: 'bukit_contoh'),
        isFalse,
      );
      expect(destinations.nameTaken('Nama Baru'), isFalse);
    });

    test('slugify dan uniqueSlug menghasilkan slug yang aman', () {
      _loginAsAdmin();
      destinations.add(_sample());

      expect(DestinationService.slugify('  Danau Toba!! '), 'danau_toba');
      expect(DestinationService.slugify('???'), 'destinasi');
      expect(destinations.uniqueSlug('Bukit Contoh'), 'bukit_contoh_2');
    });
  });

  group('DestinationService - CRUD admin', () {
    test('tambah destinasi baru', () {
      _loginAsAdmin();
      var notified = 0;
      destinations.addListener(() => notified++);

      destinations.add(_sample());

      expect(destinations.findBySlug('bukit_contoh'), isNotNull);
      expect(destinations.count, kDestinations.length + 1);
      expect(notified, 1);
    });

    test('slug yang sama tidak boleh ditambahkan dua kali', () {
      _loginAsAdmin();
      destinations.add(_sample());
      expect(() => destinations.add(_sample()), throwsArgumentError);
    });

    test('update mengganti data', () {
      _loginAsAdmin();
      destinations.add(_sample());

      destinations.update(_sample(name: 'Bukit Contoh Baru'));

      expect(destinations.findBySlug('bukit_contoh')?.name, 'Bukit Contoh Baru');
    });

    test('update slug yang tidak ada melempar error', () {
      _loginAsAdmin();
      expect(
            () => destinations.update(_sample(slug: 'hantu')),
        throwsArgumentError,
      );
    });

    test('hapus menghilangkan destinasi dan favoritnya', () {
      _loginAsAdmin();
      destinations.add(_sample());
      AuthService.favorites.add('bukit_contoh');

      expect(destinations.delete('bukit_contoh'), isTrue);

      expect(destinations.findBySlug('bukit_contoh'), isNull);
      expect(AuthService.favorites.contains('bukit_contoh'), isFalse);
      expect(destinations.delete('bukit_contoh'), isFalse);
    });

    test('hapus destinasi ikut menghapus camp dan tipe tendanya', () {
      _loginAsAdmin();
      destinations.add(_sample());
      final camp = camps.add(
        const Camp(id: 'camp_x', name: 'Camp X', destinationSlug: 'bukit_contoh'),
      );
      tents.add(const TentType(
        id: 'tt_x',
        campId: 'camp_x',
        name: 'Tenda X',
        price: 50000,
        capacity: 2,
        stock: 3,
      ));

      destinations.delete('bukit_contoh');

      expect(camps.findById(camp.id), isNull);
      expect(tents.byCamp('camp_x'), isEmpty);
    });
  });

  group('DestinationService - hak akses', () {
    test('tanpa login tidak bisa mengubah data', () {
      expect(() => destinations.add(_sample()), throwsStateError);
    });

    test('pengguna biasa tidak bisa mengubah data', () {
      AuthService.register(
        name: 'Petualang', email: 'biasa@campku.id', password: 'user123',
      );
      expect(() => destinations.add(_sample()), throwsStateError);
      expect(destinations.count, kDestinations.length);
    });
  });
}
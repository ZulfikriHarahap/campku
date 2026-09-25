import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
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
    destinations.reset();
    camps.reset();
    tents.reset();
  });

  group('DestinationService - baca', () {
    test('data awal sama dengan kDestinations', () {
      expect(destinations.count, kDestinations.length);
      expect(destinations.findBySlug('sibayak')?.name, 'Gunung Sibayak');
      expect(destinations.findBySlug('tidak_ada'), isNull);
    });

    test('byCategory hanya mengembalikan kategori yang diminta', () {
      final gunung = destinations.byCategory('Gunung');
      expect(gunung, isNotEmpty);
      expect(gunung.every((d) => d.category == 'Gunung'), isTrue);
    });

    test('nameTaken tidak membedakan huruf besar/kecil', () {
      expect(destinations.nameTaken('  gunung   SIBAYAK '), isTrue);
      expect(
        destinations.nameTaken('Gunung Sibayak', exceptSlug: 'sibayak'),
        isFalse,
      );
      expect(destinations.nameTaken('Nama Baru'), isFalse);
    });

    test('slugify dan uniqueSlug menghasilkan slug yang aman', () {
      expect(DestinationService.slugify('  Danau Toba!! '), 'danau_toba');
      expect(DestinationService.slugify('???'), 'destinasi');
      expect(destinations.uniqueSlug('Gunung Sibayak'), 'gunung_sibayak');
      expect(destinations.uniqueSlug('Sibayak'), 'sibayak_2');
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

    test('update mengganti data tanpa mengubah urutan', () {
      _loginAsAdmin();
      final index = destinations.all.indexWhere((d) => d.slug == 'sibayak');

      destinations.update(_sample(slug: 'sibayak', name: 'Sibayak Baru'));

      expect(destinations.all[index].name, 'Sibayak Baru');
      expect(destinations.count, kDestinations.length);
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
      AuthService.favorites.add('sibayak');

      expect(destinations.delete('sibayak'), isTrue);

      expect(destinations.findBySlug('sibayak'), isNull);
      expect(AuthService.favorites.contains('sibayak'), isFalse);
      expect(destinations.delete('sibayak'), isFalse);
    });

    test('hapus destinasi ikut menghapus camp dan tipe tendanya', () {
      _loginAsAdmin();
      expect(camps.byDestination('sibayak'), isNotEmpty);
      final campIds =
          camps.byDestination('sibayak').map((c) => c.id).toList();
      expect(campIds.any((id) => tents.byCamp(id).isNotEmpty), isTrue);

      destinations.delete('sibayak');

      expect(camps.byDestination('sibayak'), isEmpty);
      for (final id in campIds) {
        expect(tents.byCamp(id), isEmpty);
      }
    });
  });

  group('DestinationService - hak akses', () {
    test('tanpa login tidak bisa mengubah data', () {
      expect(() => destinations.add(_sample()), throwsStateError);
      expect(() => destinations.delete('sibayak'), throwsStateError);
    });

    test('pengguna biasa tidak bisa mengubah data', () {
      final error = AuthService.login(
        email: 'user@campku.id',
        password: 'user123',
        role: UserRole.user,
      );
      expect(error, isNull);

      expect(() => destinations.add(_sample()), throwsStateError);
      expect(
        () => destinations.update(_sample(slug: 'sibayak')),
        throwsStateError,
      );
      expect(() => destinations.delete('sibayak'), throwsStateError);
      expect(destinations.count, kDestinations.length);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/destination_service.dart';

Destination _sample({
  String slug = 'bukit_contoh',
  String name = 'Bukit Contoh',
  String category = 'Gunung',
}) {
  return Destination(
    slug: slug,
    name: name,
    category: category,
    location: 'Karo, Sumatera Utara',
    rating: 4.5,
    priceLabel: 'Mulai Rp 10.000',
    badge: 'Baru',
    badgeIcon: Icons.star,
    description: 'Bukit contoh untuk pengujian layanan destinasi.',
    about: 'Penjelasan lengkap bukit contoh untuk pengujian.',
    activities: const ['Mendaki'],
    bestTime: 'Musim kemarau',
    access: 'Dari Medan sekitar 2 jam berkendara',
    facilities: const ['Warung'],
    tips: const ['Bawa jas hujan'],
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
  final service = DestinationService.instance;

  setUp(() {
    AuthService.logout();
    service.reset();
  });

  group('DestinationService - baca', () {
    test('data awal sama dengan kDestinations', () {
      expect(service.count, kDestinations.length);
      expect(service.findBySlug('sibayak')?.name, 'Gunung Sibayak');
      expect(service.findBySlug('tidak_ada'), isNull);
    });

    test('byCategory hanya mengembalikan kategori yang diminta', () {
      final gunung = service.byCategory('Gunung');
      expect(gunung, isNotEmpty);
      expect(gunung.every((d) => d.category == 'Gunung'), isTrue);
    });

    test('nameTaken tidak membedakan huruf besar/kecil', () {
      expect(service.nameTaken('  gunung   SIBAYAK '), isTrue);
      expect(service.nameTaken('Gunung Sibayak', exceptSlug: 'sibayak'),
          isFalse);
      expect(service.nameTaken('Nama Baru'), isFalse);
    });

    test('slugify dan uniqueSlug menghasilkan slug yang aman', () {
      expect(DestinationService.slugify('  Danau Toba!! '), 'danau_toba');
      expect(DestinationService.slugify('???'), 'destinasi');
      expect(service.uniqueSlug('Gunung Sibayak'), 'gunung_sibayak');
      expect(service.uniqueSlug('Sibayak'), 'sibayak_2');
    });
  });

  group('DestinationService - CRUD admin', () {
    test('tambah destinasi masuk ke akhir kelompok kategorinya', () {
      _loginAsAdmin();
      var notified = 0;
      service.addListener(() => notified++);

      service.add(_sample());

      final gunung = service.byCategory('Gunung');
      expect(gunung.last.slug, 'bukit_contoh');
      expect(service.count, kDestinations.length + 1);
      expect(notified, 1);
    });

    test('slug yang sama tidak boleh ditambahkan dua kali', () {
      _loginAsAdmin();
      service.add(_sample());
      expect(() => service.add(_sample()), throwsArgumentError);
    });

    test('update mengganti data tanpa mengubah urutan', () {
      _loginAsAdmin();
      final index = service.all.indexWhere((d) => d.slug == 'sibayak');

      service.update(_sample(slug: 'sibayak', name: 'Sibayak Baru'));

      expect(service.all[index].name, 'Sibayak Baru');
      expect(service.count, kDestinations.length);
    });

    test('update slug yang tidak ada melempar error', () {
      _loginAsAdmin();
      expect(() => service.update(_sample(slug: 'hantu')), throwsArgumentError);
    });

    test('hapus menghilangkan destinasi dan favoritnya', () {
      _loginAsAdmin();
      AuthService.favorites.add('sibayak');

      expect(service.delete('sibayak'), isTrue);

      expect(service.findBySlug('sibayak'), isNull);
      expect(AuthService.favorites.contains('sibayak'), isFalse);
      expect(service.delete('sibayak'), isFalse);
    });
  });

  group('DestinationService - hak akses', () {
    test('tanpa login tidak bisa mengubah data', () {
      expect(() => service.add(_sample()), throwsStateError);
      expect(() => service.delete('sibayak'), throwsStateError);
    });

    test('pengguna biasa tidak bisa mengubah data', () {
      final error = AuthService.login(
        email: 'user@campku.id',
        password: 'user123',
        role: UserRole.user,
      );
      expect(error, isNull);

      expect(() => service.add(_sample()), throwsStateError);
      expect(() => service.update(_sample(slug: 'sibayak')), throwsStateError);
      expect(() => service.delete('sibayak'), throwsStateError);
      expect(service.count, kDestinations.length);
    });
  });
}

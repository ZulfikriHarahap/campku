import 'package:flutter_test/flutter_test.dart';

import 'package:campku/data/tent_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';

TentType _sample({
  String id = 'tt_contoh',
  String campId = 'camp_sibayak_raja_berneh',
  String name = 'Tenda Contoh',
  int price = 50000,
  int capacity = 2,
  int stock = 3,
}) {
  return TentType(
    id: id,
    campId: campId,
    name: name,
    price: price,
    capacity: capacity,
    stock: stock,
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

  group('TentService - baca', () {
    test('data awal sama dengan kTentTypes', () {
      expect(tents.all.length, kTentTypes.length);
      final list = tents.byCamp('camp_sibayak_raja_berneh');
      expect(list, isNotEmpty);
      expect(list.every((t) => t.campId == 'camp_sibayak_raja_berneh'), isTrue);
    });

    test('priceLabel dan capacityLabel terformat dengan benar', () {
      const t = TentType(
        id: 'x',
        campId: 'y',
        name: 'Tes',
        price: 125000,
        capacity: 4,
        stock: 1,
      );
      expect(t.priceLabel, 'Rp 125.000 / malam');
      expect(t.capacityLabel, 'Muat 4 orang');
    });

    test('nameTaken hanya membandingkan tenda di camp yang sama', () {
      final existing = tents.byCamp('camp_sibayak_raja_berneh').first.name;
      expect(
        tents.nameTaken(existing, campId: 'camp_sibayak_raja_berneh'),
        isTrue,
      );
      expect(
        tents.nameTaken(existing, campId: 'camp_toba_tuktuk'),
        isFalse,
      );
    });
  });

  group('TentService - CRUD admin', () {
    test('tambah tipe tenda baru', () {
      _loginAsAdmin();
      var notified = 0;
      tents.addListener(() => notified++);

      tents.add(_sample());

      expect(tents.findById('tt_contoh'), isNotNull);
      expect(notified, 1);
    });

    test('id yang sama tidak boleh ditambahkan dua kali', () {
      _loginAsAdmin();
      tents.add(_sample());
      expect(() => tents.add(_sample()), throwsArgumentError);
    });

    test('update mengganti harga dan stok', () {
      _loginAsAdmin();
      tents.add(_sample());

      tents.update(_sample(price: 60000, stock: 1));

      final t = tents.findById('tt_contoh')!;
      expect(t.price, 60000);
      expect(t.stock, 1);
    });

    test('hapus tipe tenda', () {
      _loginAsAdmin();
      tents.add(_sample());
      expect(tents.delete('tt_contoh'), isTrue);
      expect(tents.findById('tt_contoh'), isNull);
      expect(tents.delete('tt_contoh'), isFalse);
    });
  });

  group('TentService - hak akses', () {
    test('tanpa login tidak bisa mengubah data', () {
      expect(() => tents.add(_sample()), throwsStateError);
    });

    test('pengguna biasa tidak bisa mengubah data', () {
      final error = AuthService.login(
        email: 'user@campku.id',
        password: 'user123',
        role: UserRole.user,
      );
      expect(error, isNull);
      expect(() => tents.add(_sample()), throwsStateError);
    });
  });
}

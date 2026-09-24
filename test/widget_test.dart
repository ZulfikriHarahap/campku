import 'package:campku/services/auth_service.dart';
import 'package:campku/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AuthService.logout);

  group('AuthService', () {
    test('login berhasil dengan akun demo', () {
      final error = AuthService.login(
        email: 'USER@campku.id ',
        password: 'user123',
      );
      expect(error, isNull);
      expect(AuthService.currentUser?.role, UserRole.user);
    });

    test('login gagal jika kata sandi salah', () {
      final error =
          AuthService.login(email: 'user@campku.id', password: 'salah');
      expect(error, isNotNull);
      expect(AuthService.currentUser, isNull);
    });

    test('daftar sebagai admin butuh kode yang benar', () {
      final gagal = AuthService.register(
        name: 'Budi',
        email: 'budi@campku.id',
        password: 'rahasia1',
        role: UserRole.admin,
        adminCodeInput: 'SALAH',
      );
      expect(gagal, isNotNull);

      final berhasil = AuthService.register(
        name: 'Budi',
        email: 'budi@campku.id',
        password: 'rahasia1',
        role: UserRole.admin,
        adminCodeInput: AuthService.adminCode,
      );
      expect(berhasil, isNull);
      expect(AuthService.currentUser?.isAdmin, isTrue);
    });

    test('email yang sama tidak bisa didaftarkan dua kali', () {
      final error = AuthService.register(
        name: 'Dobel',
        email: 'admin@campku.id',
        password: 'rahasia1',
        role: UserRole.user,
      );
      expect(error, isNotNull);
    });
  });

  testWidgets('aplikasi dibuka di halaman login', (tester) async {
    await tester.pumpWidget(const CampKuApp());

    expect(find.text('Masuk ke CampKu'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
  });
}

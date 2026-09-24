import 'package:campku/services/auth_service.dart';
import 'package:campku/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(AuthService.logout);

  group('AuthService', () {
    test('login pengguna berhasil dengan akun demo', () {
      final error = AuthService.login(
        email: 'USER@campku.id ',
        password: 'user123',
        role: UserRole.user,
      );
      expect(error, isNull);
      expect(AuthService.currentUser?.role, UserRole.user);
    });

    test('login admin memakai akun statis', () {
      final error = AuthService.login(
        email: AuthService.adminEmail,
        password: AuthService.adminPassword,
        role: UserRole.admin,
      );
      expect(error, isNull);
      expect(AuthService.currentUser?.isAdmin, isTrue);
    });

    test('login gagal jika kata sandi salah', () {
      final error = AuthService.login(
        email: 'user@campku.id',
        password: 'salah',
        role: UserRole.user,
      );
      expect(error, isNotNull);
      expect(AuthService.currentUser, isNull);
    });

    test('login gagal jika peran yang dipilih tidak cocok', () {
      final sebagaiAdmin = AuthService.login(
        email: 'user@campku.id',
        password: 'user123',
        role: UserRole.admin,
      );
      final sebagaiUser = AuthService.login(
        email: AuthService.adminEmail,
        password: AuthService.adminPassword,
        role: UserRole.user,
      );
      expect(sebagaiAdmin, isNotNull);
      expect(sebagaiUser, isNotNull);
      expect(AuthService.currentUser, isNull);
    });

    test('daftar akun selalu menjadi pengguna', () {
      final error = AuthService.register(
        name: 'Budi',
        email: 'budi@campku.id',
        password: 'rahasia1',
      );
      expect(error, isNull);
      expect(AuthService.currentUser?.role, UserRole.user);
    });

    test('email yang sama tidak bisa didaftarkan dua kali', () {
      final error = AuthService.register(
        name: 'Dobel',
        email: AuthService.adminEmail,
        password: 'rahasia1',
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

import 'package:flutter_test/flutter_test.dart';

import 'package:campku/main.dart';
import 'package:campku/services/auth_service.dart';

import 'test_session.dart';

void main() {
  setUp(() => AuthService.setSessionForTest(null));

  group('AuthService (sesi)', () {
    test('tanpa sesi, tidak ada pengguna yang masuk', () {
      expect(AuthService.currentUser, isNull);
    });

    test('sesi admin dikenali sebagai admin', () {
      AuthService.setSessionForTest(testAdmin);
      expect(AuthService.currentUser?.isAdmin, isTrue);
    });

    test('sesi pengguna bukan admin', () {
      AuthService.setSessionForTest(testUser);
      expect(AuthService.currentUser?.role, UserRole.user);
      expect(AuthService.currentUser?.isAdmin, isFalse);
    });
  });

  testWidgets('aplikasi dibuka di halaman login', (tester) async {
    await tester.pumpWidget(const CampKuApp());

    expect(find.text('Masuk ke CampKu'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Kata sandi'), findsOneWidget);
  });
}

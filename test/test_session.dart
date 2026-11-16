import 'package:campku/services/auth_service.dart';

/// Akun tiruan untuk tes. Tes tidak memakai Firebase, jadi sesinya
/// ditetapkan langsung lewat [AuthService.setSessionForTest].
const testAdmin = AppUser(
  uid: 'test-admin',
  name: 'Admin Tes',
  email: 'admin@tes.id',
  role: UserRole.admin,
);

const testUser = AppUser(
  uid: 'test-user',
  name: 'Pengguna Tes',
  email: 'user@tes.id',
  role: UserRole.user,
);

enum UserRole { user, admin }

class AppUser {
  const AppUser({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final String name;
  final String email;
  final String password;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
  String get roleLabel => isAdmin ? 'Admin' : 'Pengguna';
  String get firstName => name.trim().split(' ').first;
  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// Autentikasi sederhana untuk keperluan demo (tanpa backend).
///
/// Data akun hanya disimpan di memori, jadi akun yang didaftarkan hilang
/// saat aplikasi ditutup. Langkah berikutnya: simpan ke `shared_preferences`
/// atau Firebase Auth. Jangan pakai pola kata sandi teks-biasa ini di produksi.
class AuthService {
  AuthService._();

  /// Akun admin bersifat statis: tetap, dan tidak bisa dibuat lewat pendaftaran.
  static const String adminEmail = 'admin@campku.id';
  static const String adminPassword = 'admin123';

  static final List<AppUser> _users = [
    const AppUser(
      name: 'Admin CampKu',
      email: adminEmail,
      password: adminPassword,
      role: UserRole.admin,
    ),
    const AppUser(
      name: 'Petualang',
      email: 'user@campku.id',
      password: 'user123',
      role: UserRole.user,
    ),
  ];

  static final Map<String, Set<String>> _favorites = {};

  static AppUser? currentUser;

  static List<AppUser> get users => List.unmodifiable(_users);

  /// Slug destinasi favorit milik akun yang sedang masuk.
  static Set<String> get favorites =>
      _favorites.putIfAbsent(currentUser?.email ?? 'tamu', () => <String>{});

  static String _normalize(String email) => email.trim().toLowerCase();

  /// Mengembalikan pesan error, atau `null` jika berhasil.
  ///
  /// [role] adalah peran yang dipilih di halaman masuk dan harus cocok dengan
  /// peran akunnya.
  static String? login({
    required String email,
    required String password,
    required UserRole role,
  }) {
    final matches = _users.where((u) => u.email == _normalize(email));
    if (matches.isEmpty) {
      return role == UserRole.admin
          ? 'Email admin tidak dikenali. Gunakan akun admin yang tersedia.'
          : 'Email belum terdaftar. Daftar dulu untuk membuat akun.';
    }
    final user = matches.first;
    if (user.role != role) {
      return user.isAdmin
          ? 'Ini akun admin. Pilih "Admin" di atas lalu coba masuk lagi.'
          : 'Ini akun pengguna. Pilih "Pengguna" di atas lalu coba masuk lagi.';
    }
    if (user.password != password) {
      return 'Kata sandi salah. Periksa lagi lalu coba masuk.';
    }
    currentUser = user;
    return null;
  }

  /// Pendaftaran hanya untuk pengguna; akun admin tidak bisa didaftarkan.
  ///
  /// Mengembalikan pesan error, atau `null` jika berhasil (otomatis masuk).
  static String? register({
    required String name,
    required String email,
    required String password,
  }) {
    if (_users.any((u) => u.email == _normalize(email))) {
      return 'Email sudah dipakai. Masuk atau gunakan email lain.';
    }
    final user = AppUser(
      name: name.trim(),
      email: _normalize(email),
      password: password,
      role: UserRole.user,
    );
    _users.add(user);
    currentUser = user;
    return null;
  }

  static void logout() => currentUser = null;

  /// Menghapus destinasi dari favorit semua akun. Dipanggil saat admin
  /// menghapus destinasi supaya tidak ada favorit yang menunjuk ke data hilang.
  static void forgetDestination(String slug) {
    for (final slugs in _favorites.values) {
      slugs.remove(slug);
    }
  }
}

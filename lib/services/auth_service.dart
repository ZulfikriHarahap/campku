import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'package:campku/services/camp_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/tent_service.dart';

enum UserRole { user, admin }

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;

  bool get isAdmin => role == UserRole.admin;
  String get roleLabel => isAdmin ? 'Admin' : 'Pengguna';
  String get firstName => name.trim().split(' ').first;
  String get initial =>
      name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}

/// Autentikasi memakai Firebase Authentication (email & kata sandi).
///
/// Profil dan peran pengguna disimpan di koleksi Firestore `users/{uid}`.
/// Peran `admin` hanya bisa dibuat secara manual di Firebase Console dan
/// dijaga oleh aturan keamanan Firestore, sehingga pendaftaran di aplikasi
/// selalu membuat akun `user`.
///
/// [currentUser] adalah salinan lokal profil yang sedang masuk. Layanan lain
/// (booking, destinasi, camp) membacanya secara sinkron untuk cek peran.
class AuthService {
  AuthService._();

  static AppUser? currentUser;

  static final Map<String, Set<String>> _favorites = {};

  /// Slug destinasi favorit milik akun yang sedang masuk.
  static Set<String> get favorites =>
      _favorites.putIfAbsent(currentUser?.email ?? 'tamu', () => <String>{});

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  static String _normalize(String email) => email.trim().toLowerCase();

  /// Dipanggil sekali saat aplikasi dibuka: memulihkan sesi yang masih aktif
  /// supaya pengguna tidak perlu masuk ulang.
  static Future<void> restoreSession() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return;
    try {
      final user = await _loadProfile(fbUser);
      if (user == null) {
        await _auth.signOut();
        return;
      }
      currentUser = user;
      _startData();
    } catch (e) {
      debugPrint('AuthService.restoreSession: $e');
      await _auth.signOut();
    }
  }

  /// Membaca profil dari Firestore. Mengembalikan `null` jika belum ada.
  static Future<AppUser?> _loadProfile(User fbUser) async {
    final snap = await _db.collection('users').doc(fbUser.uid).get();
    final data = snap.data();
    if (data == null) return null;
    return AppUser(
      uid: fbUser.uid,
      name: (data['name'] as String?) ?? '',
      email: (data['email'] as String?) ?? fbUser.email ?? '',
      role: data['role'] == 'admin' ? UserRole.admin : UserRole.user,
    );
  }

  /// Mengembalikan pesan error, atau `null` jika berhasil.
  ///
  /// [role] adalah peran yang dipilih di halaman masuk dan harus cocok dengan
  /// peran akun di Firestore.
  static Future<String?> login({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: _normalize(email),
        password: password,
      );
      final user = await _loadProfile(cred.user!);
      if (user == null) {
        await _auth.signOut();
        return 'Akun ini belum terdaftar sebagai akun CampKu.';
      }
      if (user.role != role) {
        await _auth.signOut();
        return user.isAdmin
            ? 'Ini akun admin. Gunakan halaman "Masuk sebagai Admin".'
            : 'Ini akun pengguna. Gunakan halaman masuk pengguna.';
      }
      currentUser = user;
      _startData();
      return null;
    } on FirebaseAuthException catch (e) {
      return _authMessage(e);
    } catch (e) {
      debugPrint('AuthService.login: $e');
      return 'Terjadi kesalahan. Periksa koneksi lalu coba lagi.';
    }
  }

  /// Pendaftaran hanya untuk pengguna. Mengembalikan pesan error, atau `null`
  /// jika berhasil (otomatis masuk).
  static Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final mail = _normalize(email);
    final trimmedName = name.trim();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: mail,
        password: password,
      );
      final uid = cred.user!.uid;
      await _db.collection('users').doc(uid).set({
        'name': trimmedName,
        'email': mail,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      currentUser = AppUser(
        uid: uid,
        name: trimmedName,
        email: mail,
        role: UserRole.user,
      );
      _startData();
      return null;
    } on FirebaseAuthException catch (e) {
      return _authMessage(e);
    } catch (e) {
      debugPrint('AuthService.register: $e');
      return 'Gagal membuat akun. Periksa koneksi lalu coba lagi.';
    }
  }

  static Future<void> logout() async {
    await _auth.signOut();
    currentUser = null;
    _stopData();
  }

  /// Mengubah nama akun yang sedang masuk. Mengembalikan pesan error,
  /// atau `null` jika berhasil.
  static Future<String?> updateProfile({required String name}) async {
    final user = currentUser;
    if (user == null) return 'Harus masuk untuk mengubah profil.';
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Nama tidak boleh kosong.';
    if (trimmed.length < 3) return 'Nama minimal 3 karakter.';
    try {
      await _db.collection('users').doc(user.uid).update({'name': trimmed});
      currentUser = AppUser(
        uid: user.uid,
        name: trimmed,
        email: user.email,
        role: user.role,
      );
      return null;
    } catch (e) {
      debugPrint('AuthService.updateProfile: $e');
      return 'Gagal menyimpan profil. Periksa koneksi lalu coba lagi.';
    }
  }

  /// Mengubah kata sandi akun yang sedang masuk. Mengembalikan pesan error,
  /// atau `null` jika berhasil.
  static Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final fbUser = _auth.currentUser;
    if (currentUser == null || fbUser == null || fbUser.email == null) {
      return 'Harus masuk untuk mengubah kata sandi.';
    }
    if (newPassword.length < 6) {
      return 'Kata sandi baru minimal 6 karakter.';
    }
    try {
      // Verifikasi kata sandi lama sebelum menggantinya.
      await fbUser.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: fbUser.email!,
          password: currentPassword,
        ),
      );
      await fbUser.updatePassword(newPassword);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'wrong-password') {
        return 'Kata sandi saat ini salah.';
      }
      return _authMessage(e);
    }
  }

  /// Hanya untuk tes: menetapkan sesi tanpa Firebase.
  @visibleForTesting
  static void setSessionForTest(AppUser? user) {
    currentUser = user;
  }

  /// Menghapus destinasi dari favorit semua akun. Dipanggil saat admin
  /// menghapus destinasi supaya tidak ada favorit yang menunjuk ke data hilang.
  static void forgetDestination(String slug) {
    for (final slugs in _favorites.values) {
      slugs.remove(slug);
    }
  }

  // ── LISTENER DATA ─────────────────────────

  /// Listener Firestore baru boleh berjalan setelah login, karena aturan
  /// keamanan menolak pembacaan dari pengguna yang belum masuk.
  static void _startData() {
    DestinationService.instance.start();
    CampService.instance.start();
    TentService.instance.start();
  }

  static void _stopData() {
    DestinationService.instance.stop();
    CampService.instance.stop();
    TentService.instance.stop();
  }

  static String _authMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email atau kata sandi salah.';
      case 'invalid-email':
        return 'Format email belum benar. Contoh: nama@email.com';
      case 'email-already-in-use':
        return 'Email sudah dipakai. Masuk atau gunakan email lain.';
      case 'weak-password':
        return 'Kata sandi minimal 6 karakter.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      case 'requires-recent-login':
        return 'Sesi sudah lama. Keluar lalu masuk lagi, kemudian coba ulang.';
      default:
        return 'Terjadi kesalahan (${e.code}). Coba lagi.';
    }
  }
}

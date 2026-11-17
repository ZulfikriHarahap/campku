import 'package:cloud_firestore/cloud_firestore.dart';

String adminWriteErrorMessage(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return 'Akses ditolak. Pastikan akun ini berperan sebagai admin.';
      case 'unavailable':
        return 'Firebase sedang tidak tersedia. Coba lagi.';
      default:
        return error.message ?? 'Gagal menyimpan ke Firebase. Coba lagi.';
    }
  }
  if (error is StateError || error is ArgumentError) {
    return error.toString().replaceFirst(RegExp(r'^\w+:\s*'), '');
  }
  return 'Gagal menyimpan data. Periksa koneksi lalu coba lagi.';
}

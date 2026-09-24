import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/screens/admin/destination_form_screen.dart';

/// Membuka form tambah ([existing] kosong) atau edit destinasi.
///
/// Mengembalikan destinasi yang tersimpan, atau `null` jika dibatalkan.
Future<Destination?> openDestinationForm(
  BuildContext context, {
  Destination? existing,
}) {
  return Navigator.of(context).push<Destination>(
    MaterialPageRoute<Destination>(
      builder: (_) => DestinationFormScreen(existing: existing),
    ),
  );
}

/// Menampilkan dialog konfirmasi lalu menghapus destinasi.
///
/// Mengembalikan `true` jika destinasi benar-benar terhapus.
Future<bool> confirmDeleteDestination(
  BuildContext context,
  Destination d,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus destinasi?'),
      content: Text(
        '${d.name} akan dihapus dari daftar dan dari semua favorit. '
        'Tindakan ini tidak bisa dibatalkan.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: kError,
            minimumSize: const Size(96, 44),
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  return DestinationService.instance.delete(d.slug);
}

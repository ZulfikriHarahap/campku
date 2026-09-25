import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/tent_service.dart';
import 'package:campku/screens/admin/destination_form_screen.dart';
import 'package:campku/screens/admin/camp_form_screen.dart';
import 'package:campku/screens/admin/tent_form_screen.dart';

// ── DESTINASI ───────────────────────────────

/// Membuka form tambah ([existing] kosong) atau edit destinasi.
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

/// Menampilkan dialog konfirmasi lalu menghapus destinasi (beserta camp
/// dan tipe tendanya). Mengembalikan `true` jika benar-benar terhapus.
Future<bool> confirmDeleteDestination(
  BuildContext context,
  Destination d,
) async {
  final ok = await _confirm(
    context,
    title: 'Hapus destinasi?',
    message:
        '${d.name} akan dihapus beserta seluruh camp dan tipe tendanya, '
        'dan dari semua favorit. Tindakan ini tidak bisa dibatalkan.',
  );
  if (!ok) return false;
  return DestinationService.instance.delete(d.slug);
}

// ── CAMP ────────────────────────────────────

/// Membuka form tambah atau edit camp di dalam [destination].
Future<Camp?> openCampForm(
  BuildContext context, {
  required Destination destination,
  Camp? existing,
}) {
  return Navigator.of(context).push<Camp>(
    MaterialPageRoute<Camp>(
      builder: (_) =>
          CampFormScreen(destination: destination, existing: existing),
    ),
  );
}

/// Menampilkan dialog konfirmasi lalu menghapus camp (beserta tipe
/// tendanya). Mengembalikan `true` jika benar-benar terhapus.
Future<bool> confirmDeleteCamp(BuildContext context, Camp c) async {
  final ok = await _confirm(
    context,
    title: 'Hapus camp?',
    message:
        '${c.name} akan dihapus beserta seluruh tipe tendanya. '
        'Tindakan ini tidak bisa dibatalkan.',
  );
  if (!ok) return false;
  return CampService.instance.delete(c.id);
}

// ── TIPE TENDA ──────────────────────────────

/// Membuka form tambah atau edit tipe tenda di dalam [camp].
Future<TentType?> openTentForm(
  BuildContext context, {
  required Camp camp,
  TentType? existing,
}) {
  return Navigator.of(context).push<TentType>(
    MaterialPageRoute<TentType>(
      builder: (_) => TentFormScreen(camp: camp, existing: existing),
    ),
  );
}

/// Menampilkan dialog konfirmasi lalu menghapus tipe tenda.
/// Mengembalikan `true` jika benar-benar terhapus.
Future<bool> confirmDeleteTent(BuildContext context, TentType t) async {
  final ok = await _confirm(
    context,
    title: 'Hapus tipe tenda?',
    message: '${t.name} akan dihapus. Tindakan ini tidak bisa dibatalkan.',
  );
  if (!ok) return false;
  return TentService.instance.delete(t.id);
}

// ── DIALOG BERSAMA ──────────────────────────

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
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
  return ok ?? false;
}

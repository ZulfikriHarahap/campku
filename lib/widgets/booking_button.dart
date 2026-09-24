import 'package:flutter/material.dart';

import 'package:campku/data/destinations_data.dart';

/// Tombol "Booking Tenda". Sifatnya statis: belum ada proses pemesanan,
/// hanya menampilkan dialog pemberitahuan.
///
/// Untuk membuat fitur booking sungguhan, ganti isi [showBookingInfo]
/// dengan navigasi ke halaman pemesanan.
class BookingButton extends StatelessWidget {
  const BookingButton({super.key, required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => showBookingInfo(context, destination),
      icon: const Icon(Icons.event_available),
      label: const Text('Booking Tenda'),
    );
  }
}

Future<void> showBookingInfo(BuildContext context, Destination d) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Booking Tenda'),
      content: Text(
        'Fitur booking tenda untuk ${d.name} akan segera tersedia.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Oke'),
        ),
      ],
    ),
  );
}

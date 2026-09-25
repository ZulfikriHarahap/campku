import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/booking_data.dart';

/// Tiket/bukti booking (FR-07). Dipakai dua kali: langsung setelah
/// pembayaran ([justPaid] true, dengan tombol "Selesai"), dan saat dibuka
/// kembali dari daftar riwayat booking ([justPaid] false, dengan tombol
/// "Tutup").
class TicketScreen extends StatelessWidget {
  const TicketScreen({
    super.key,
    required this.booking,
    this.justPaid = false,
  });

  final Booking booking;
  final bool justPaid;

  Color get _approvalColor => switch (booking.approval) {
        BookingApproval.menunggu => kAccentText,
        BookingApproval.disetujui => kPrimary,
        BookingApproval.ditolak => kError,
      };

  IconData get _approvalIcon => switch (booking.approval) {
        BookingApproval.menunggu => Icons.hourglass_top,
        BookingApproval.disetujui => Icons.check_circle,
        BookingApproval.ditolak => Icons.cancel,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !justPaid,
        title: const Text('Tiket Booking'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          if (justPaid) ...[
            const Icon(Icons.celebration, size: 56, color: kAccent),
            const SizedBox(height: 12),
            Text(
              'Pembayaran berhasil!',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tiketmu sudah dibuat dan menunggu persetujuan admin.',
              textAlign: TextAlign.center,
              style: TextStyle(color: kTextMuted),
            ),
            const SizedBox(height: 24),
          ],
          _ticketCard(context),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (justPaid) {
                Navigator.of(context).popUntil((r) => r.isFirst);
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(justPaid ? 'Selesai' : 'Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kBorder),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.id,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: kTextMuted,
                  fontSize: 12.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _approvalColor.withAlpha(24),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_approvalIcon, size: 14, color: _approvalColor),
                    const SizedBox(width: 4),
                    Text(
                      booking.approval.label,
                      style: TextStyle(
                        color: _approvalColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            booking.tentName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            '${booking.campName} · ${booking.destinationName}',
            style: const TextStyle(color: kTextMuted, fontSize: 13),
          ),
          const SizedBox(height: 14),
          const CustomPaint(size: Size(double.infinity, 1), painter: _DashedLinePainter()),
          const SizedBox(height: 14),
          _detailRow(Icons.calendar_today_outlined, 'Check-in', booking.checkInLabel),
          _detailRow(Icons.nights_stay_outlined, 'Durasi', booking.nightsLabel),
          _detailRow(Icons.payments_outlined, 'Total harga', booking.totalPriceLabel),
          _detailRow(Icons.verified_outlined, 'Status pembayaran', booking.paymentStatusLabel),
          _detailRow(Icons.person_outline, 'Dipesan oleh', booking.userEmail),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: kTextMuted, fontSize: 11.5)),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Garis putus-putus sederhana, memberi kesan sobekan tiket.
class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kBorder
      ..strokeWidth = 1;
    const dashWidth = 6.0;
    const gap = 5.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

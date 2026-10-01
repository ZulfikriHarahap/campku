import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/booking_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/booking_service.dart';

/// Tiket/bukti booking (FR-07). Dipakai dua kali: langsung setelah
/// pembayaran ([justPaid] true, dengan tombol "Selesai" yang hanya
/// menutup layar), dan saat dibuka kembali dari daftar riwayat booking
/// ([justPaid] false). Saat dibuka admin dari riwayat, tombolnya juga
/// bertuliskan "Selesai" tapi berfungsi menandai booking ini selesai
/// dengan menghapusnya dari riwayat (stok tanggalnya otomatis kembali
/// seperti semula); untuk pengguna biasa tombolnya "Tutup" saja.
class TicketScreen extends StatefulWidget {
  const TicketScreen({
    super.key,
    required this.booking,
    this.justPaid = false,
  });

  final Booking booking;
  final bool justPaid;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  Booking get booking => widget.booking;
  bool get justPaid => widget.justPaid;
  bool get _isAdmin => AuthService.currentUser?.isAdmin ?? false;

  /// Tombol ini menghapus booking (bukan hanya menutup layar) hanya saat
  /// admin membuka riwayat booking yang bukan baru saja dibayar.
  bool get _finishesBooking => !justPaid && _isAdmin;

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

  Future<void> _onPrimaryButton() async {
    if (justPaid) {
      Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }
    if (!_finishesBooking) {
      Navigator.pop(context);
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Selesaikan booking?'),
        content: Text(
          'Booking ${booking.id} (${booking.tentName}) akan ditandai '
          'selesai dan dihapus dari riwayat. Stok tanggalnya akan '
          'kembali seperti semula.',
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
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    BookingService.instance.delete(booking.id);
    if (mounted) Navigator.pop(context, true);
  }

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
            onPressed: _onPrimaryButton,
            style: _finishesBooking
                ? FilledButton.styleFrom(backgroundColor: kError)
                : null,
            child: Text(justPaid || _finishesBooking ? 'Selesai' : 'Tutup'),
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

import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/data/booking_data.dart';
import 'package:campku/services/booking_service.dart';
import 'package:campku/screens/booking/ticket_screen.dart';

/// Langkah 2 alur booking (FR-06): ringkasan pesanan dan simulasi
/// pembayaran. Tidak ada payment gateway asli — menekan "Bayar Sekarang"
/// langsung menandai booking lunas dan menunggu persetujuan admin.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.destination,
    required this.camp,
    required this.tent,
    required this.checkIn,
    required this.nights,
  });

  final Destination destination;
  final Camp camp;
  final TentType tent;
  final DateTime checkIn;
  final int nights;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _processing = false;

  int get _total => widget.tent.price * widget.nights;

  Future<void> _pay() async {
    setState(() => _processing = true);
    // Simulasi proses pembayaran singkat (tidak ada payment gateway asli).
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    try {
      final booking = BookingService.instance.create(
        destinationName: widget.destination.name,
        camp: widget.camp,
        tent: widget.tent,
        checkIn: widget.checkIn,
        nights: widget.nights,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => TicketScreen(booking: booking, justPaid: true),
        ),
      );
    } catch (e) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text('Ringkasan pesanan',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          _summaryCard(),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kAccent.withAlpha(24),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 18, color: kAccentText),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ini simulasi pembayaran untuk keperluan demo, bukan '
                    'payment gateway sungguhan. Tidak ada uang yang '
                    'benar-benar berpindah.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.4,
                      color: kAccentText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _processing ? null : _pay,
            icon: _processing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.payments_outlined),
            label: Text(_processing ? 'Memproses...' : 'Bayar Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _row('Destinasi', widget.destination.name),
          _row('Camp', widget.camp.name),
          _row('Tipe tenda', widget.tent.name),
          _row('Check-in', Booking.formatDate(widget.checkIn)),
          _row('Jumlah malam', '${widget.nights} malam'),
          const Divider(height: 24, color: kBorder),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total harga',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Text(
                Booking.formatRupiah(_total),
                style: const TextStyle(
                  color: kAccentText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kTextMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

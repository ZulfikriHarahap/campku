import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/data/booking_data.dart';
import 'package:campku/screens/booking/payment_screen.dart';

/// Langkah 1 alur booking (FR-05): pilih tanggal check-in dan jumlah
/// malam, sistem menghitung total harga secara langsung.
class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    required this.destination,
    required this.camp,
    required this.tent,
  });

  final Destination destination;
  final Camp camp;
  final TentType tent;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _checkIn;
  int _nights = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkIn = DateTime(now.year, now.month, now.day + 1);
  }

  int get _total => widget.tent.price * _nights;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _checkIn.isBefore(firstDate) ? firstDate : _checkIn,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      helpText: 'Pilih tanggal check-in',
    );
    if (picked != null) setState(() => _checkIn = picked);
  }

  void _changeNights(int delta) {
    setState(() {
      final next = _nights + delta;
      if (next >= 1 && next <= 30) _nights = next;
    });
  }

  void _continue() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PaymentScreen(
          destination: widget.destination,
          camp: widget.camp,
          tent: widget.tent,
          checkIn: _checkIn,
          nights: _nights,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Tenda'),
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _summaryCard(),
          const SizedBox(height: 20),
          Text(
            'Tanggal check-in',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(Booking.formatDate(_checkIn)),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              alignment: Alignment.centerLeft,
              foregroundColor: kTextDark,
              side: const BorderSide(color: kBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Jumlah malam',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _nightsStepper(),
          const SizedBox(height: 24),
          _totalCard(),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _continue,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Lanjut ke Pembayaran'),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kPrimary.withAlpha(18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(widget.destination.categoryIcon, size: 16, color: kPrimary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.destination.name,
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${widget.camp.name} · ${widget.tent.name}',
              style: const TextStyle(color: kTextDark, fontSize: 13)),
          const SizedBox(height: 2),
          Text(
            '${widget.tent.priceLabel} · ${widget.tent.capacityLabel}',
            style: const TextStyle(color: kTextMuted, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _nightsStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _nights > 1 ? () => _changeNights(-1) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Expanded(
            child: Center(
              child: Text(
                '$_nights malam',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _nights < 30 ? () => _changeNights(1) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }

  Widget _totalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${widget.tent.priceLabel.split(' / ').first} × $_nights malam',
            style: const TextStyle(color: kTextMuted),
          ),
          Text(
            Booking.formatRupiah(_total),
            style: const TextStyle(
              color: kAccentText,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

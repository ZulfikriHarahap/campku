import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/booking_data.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/booking_service.dart';
import 'package:campku/screens/booking/ticket_screen.dart';

/// Tab "Tiket" khusus pengguna: daftar booking miliknya, terbaru lebih
/// dulu (FR-07).
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  final BookingService _bookings = BookingService.instance;

  @override
  void initState() {
    super.initState();
    _bookings.addListener(_onChanged);
  }

  @override
  void dispose() {
    _bookings.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  Color _approvalColor(BookingApproval a) => switch (a) {
        BookingApproval.menunggu => kAccentText,
        BookingApproval.disetujui => kPrimary,
        BookingApproval.ditolak => kError,
      };

  @override
  Widget build(BuildContext context) {
    final email = AuthService.currentUser?.email ?? '';
    final items = _bookings.byUser(email);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header(items.length)),
        if (items.isEmpty)
          SliverToBoxAdapter(child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _tile(items[i]),
            ),
          ),
      ],
    );
  }

  Widget _header(int count) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPrimary, kPrimaryLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiket saya',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count riwayat booking',
            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _tile(Booking b) {
    final color = _approvalColor(b.approval);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => TicketScreen(booking: b)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    b.tentName,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${b.campName} · ${b.destinationName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kTextMuted, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${b.checkInLabel} · ${b.nightsLabel} · ${b.totalPriceLabel}',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withAlpha(24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                b.approval.label,
                style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          const Icon(Icons.confirmation_number_outlined, size: 56, color: kTextMuted),
          const SizedBox(height: 16),
          Text(
            'Belum ada booking',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih camp dan tipe tenda dari halaman destinasi untuk mulai booking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

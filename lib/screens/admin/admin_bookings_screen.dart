import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/booking_data.dart';
import 'package:campku/services/booking_service.dart';
import 'package:campku/screens/booking/ticket_screen.dart';

/// Tab "Booking" khusus admin: seluruh data booking dari semua user
/// (FR-10), dengan filter status dan aksi setuju/tolak untuk yang masih
/// menunggu persetujuan.
class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final BookingService _bookings = BookingService.instance;
  BookingApproval? _filter; // null = semua

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

  List<Booking> get _items {
    final all = _bookings.all;
    if (_filter == null) return all;
    return all.where((b) => b.approval == _filter).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _approve(Booking b) {
    _bookings.approve(b.id);
    _showMessage('Booking ${b.id} disetujui');
  }

  Future<void> _reject(Booking b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tolak booking?'),
        content: Text(
          'Booking ${b.id} (${b.tentName}) akan ditolak dan stok tendanya '
          'dikembalikan.',
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
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _bookings.reject(b.id);
    _showMessage('Booking ${b.id} ditolak');
  }

  Color _color(BookingApproval a) => switch (a) {
        BookingApproval.menunggu => kAccentText,
        BookingApproval.disetujui => kPrimary,
        BookingApproval.ditolak => kError,
      };

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _header()),
        SliverToBoxAdapter(child: _filterChips()),
        if (items.isEmpty)
          SliverToBoxAdapter(child: _emptyState())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _tile(items[i]),
            ),
          ),
      ],
    );
  }

  Widget _header() {
    final pending = _bookings.pending.length;
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
            'Data booking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_bookings.all.length} booking · $pending menunggu persetujuan',
            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    Widget chip(String label, BookingApproval? value) {
      final selected = _filter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          selectedColor: kPrimary,
          backgroundColor: Colors.white,
          side: BorderSide(color: selected ? kPrimary : kBorder),
          labelStyle: TextStyle(
            color: selected ? Colors.white : kTextDark,
            fontWeight: FontWeight.w600,
          ),
          onSelected: (_) => setState(() => _filter = value),
        ),
      );
    }

    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        children: [
          chip('Semua', null),
          chip('Menunggu', BookingApproval.menunggu),
          chip('Disetujui', BookingApproval.disetujui),
          chip('Ditolak', BookingApproval.ditolak),
        ],
      ),
    );
  }

  Widget _tile(Booking b) {
    final color = _color(b.approval);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
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
                      const SizedBox(height: 2),
                      Text(
                        b.userEmail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: kTextMuted, fontSize: 12),
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
          if (b.approval == BookingApproval.menunggu) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _reject(b),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Tolak'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: kError,
                      side: BorderSide(color: kError.withAlpha(120)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _approve(b),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Setujui'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.fact_check_outlined, size: 56, color: kTextMuted),
          const SizedBox(height: 16),
          Text(
            'Belum ada booking',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Booking dari pengguna akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

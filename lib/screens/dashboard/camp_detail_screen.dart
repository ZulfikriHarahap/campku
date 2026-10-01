import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/tent_service.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/data/tent_data.dart';
import 'package:campku/screens/admin/admin_actions.dart';
import 'package:campku/screens/booking/booking_screen.dart';

enum _TentAction { edit, delete }

/// Halaman detail camp (FR-05): daftar tipe tenda yang bisa dipilih.
/// Tombol "Booking Tenda" membuka alur booking lengkap (FR-06, FR-07):
/// pilih tanggal & malam → simulasi pembayaran → tiket.
class CampDetailScreen extends StatefulWidget {
  const CampDetailScreen({
    super.key,
    required this.destination,
    required this.camp,
  });

  final Destination destination;
  final Camp camp;

  @override
  State<CampDetailScreen> createState() => _CampDetailScreenState();
}

class _CampDetailScreenState extends State<CampDetailScreen> {
  final TentService _tents = TentService.instance;

  bool get _isAdmin => AuthService.currentUser?.isAdmin ?? false;
  List<TentType> get _items => _tents.byCamp(widget.camp.id);

  @override
  void initState() {
    super.initState();
    _tents.addListener(_onChanged);
  }

  @override
  void dispose() {
    _tents.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addTent() async {
    final saved = await openTentForm(context, camp: widget.camp);
    if (saved != null && mounted) _showMessage('${saved.name} ditambahkan');
  }

  Future<void> _editTent(TentType t) async {
    final saved = await openTentForm(context, camp: widget.camp, existing: t);
    if (saved != null && mounted) _showMessage('${saved.name} diperbarui');
  }

  Future<void> _deleteTent(TentType t) async {
    final deleted = await confirmDeleteTent(context, t);
    if (deleted && mounted) _showMessage('${t.name} dihapus');
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _addTent,
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tenda'),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          if (items.isEmpty)
            SliverToBoxAdapter(child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, i) => _tentTile(items[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        12,
        MediaQuery.paddingOf(context).top + 8,
        20,
        24,
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
          IconButton(
            tooltip: 'Kembali',
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(40),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.camp.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(widget.destination.categoryIcon,
                        size: 16, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.destination.name,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tentTile(TentType t) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  t.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: kTextDark,
                  ),
                ),
              ),
              if (_isAdmin)
                PopupMenuButton<_TentAction>(
                  tooltip: 'Aksi untuk ${t.name}',
                  onSelected: (action) {
                    switch (action) {
                      case _TentAction.edit:
                        _editTent(t);
                      case _TentAction.delete:
                        _deleteTent(t);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<_TentAction>(
                      value: _TentAction.edit,
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem<_TentAction>(
                      value: _TentAction.delete,
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: kError),
                        title: Text('Hapus', style: TextStyle(color: kError)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(Icons.payments_outlined, t.priceLabel),
              _pill(Icons.groups_outlined, t.capacityLabel),
              _pill(
                Icons.inventory_2_outlined,
                t.stock > 0 ? 'Stok: ${t.stock}' : 'Stok habis',
              ),
            ],
          ),
          // Admin hanya mengelola tipe tenda (CRUD), bukan memesannya —
          // tombol "Booking Tenda" hanya tampil untuk peran Pengguna.
          if (!_isAdmin) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: t.stock > 0
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BookingScreen(
                              destination: widget.destination,
                              camp: widget.camp,
                              tent: t,
                            ),
                          ),
                        )
                    : null,
                icon: const Icon(Icons.event_available),
                label: const Text('Booking Tenda'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kPrimary.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: kPrimary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.cabin_outlined, size: 56, color: kTextMuted),
          const SizedBox(height: 16),
          Text(
            'Belum ada tipe tenda di camp ini',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _isAdmin
                ? 'Ketuk tombol Tenda untuk menambah tipe tenda pertama.'
                : 'Admin belum menambahkan tipe tenda untuk camp ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

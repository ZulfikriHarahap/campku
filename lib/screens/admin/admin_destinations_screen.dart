import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/widgets/admin_destination_tile.dart';
import 'package:campku/widgets/category_card.dart';
import 'package:campku/screens/admin/admin_actions.dart';
import 'package:campku/screens/admin/admin_category_screen.dart';
import 'package:campku/screens/dashboard/destination_detail_screen.dart';

/// Tab "Kelola" khusus admin. Tampilannya sama seperti beranda pengguna:
/// kartu kategori bergambar. Mengetik di kolom pencarian menampilkan hasil
/// destinasi langsung, dengan tombol tambah, edit, dan hapus.
class AdminDestinationsScreen extends StatefulWidget {
  const AdminDestinationsScreen({super.key});

  @override
  State<AdminDestinationsScreen> createState() =>
      _AdminDestinationsScreenState();
}

class _AdminDestinationsScreenState extends State<AdminDestinationsScreen> {
  final DestinationService _service = DestinationService.instance;
  final CampService _camps = CampService.instance;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    // Ikut refresh saat jumlah camp berubah (ditambah/dihapus dari halaman
    // detail destinasi), supaya jumlah "N camp" di sini selalu akurat.
    _camps.addListener(_onChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _camps.removeListener(_onChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  List<Destination> get _results {
    final q = _query.trim().toLowerCase();
    return _service.all.where((d) {
      return d.name.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ── AKSI CRUD ─────────────────────────────

  Future<void> _add() async {
    final saved = await openDestinationForm(context);
    if (saved != null && mounted) _showMessage('${saved.name} ditambahkan');
  }

  Future<void> _edit(Destination d) async {
    final saved = await openDestinationForm(context, existing: d);
    if (saved != null && mounted) _showMessage('${saved.name} diperbarui');
  }

  Future<void> _delete(Destination d) async {
    final deleted = await confirmDeleteDestination(context, d);
    if (deleted && mounted) _showMessage('${d.name} dihapus');
  }

  Future<void> _openDetail(Destination d) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DestinationDetailScreen(destination: d),
      ),
    );
  }

  Future<void> _openCategory(Category c) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AdminCategoryScreen(category: c)),
    );
    if (mounted) setState(() {});
  }

  // ── BUILD ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        backgroundColor: kAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _header()),
          if (searching)
            _searchResults()
          else
            SliverToBoxAdapter(child: _categoryCards()),
        ],
      ),
    );
  }

  Widget _header() {
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
            'Kelola destinasi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_service.count} destinasi · tambah, ubah, atau hapus',
            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari nama atau lokasi',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                      onPressed: _clearSearch,
                    ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Kartu kategori bergambar, sama seperti di beranda pengguna.
  Widget _categoryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih kategori',
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < kCategories.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            CategoryCard(
              category: kCategories[i],
              count: _service.byCategory(kCategories[i].label).length,
              onTap: () => _openCategory(kCategories[i]),
            ),
          ],
        ],
      ),
    );
  }

  /// Hasil pencarian destinasi lintas kategori.
  Widget _searchResults() {
    final items = _results;
    if (items.isEmpty) {
      return SliverToBoxAdapter(child: _emptyState());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      sliver: SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final d = items[i];
          return AdminDestinationTile(
            destination: d,
            campCount: _camps.byDestination(d.slug).length,
            onOpen: () => _openDetail(d),
            onEdit: () => _edit(d),
            onDelete: () => _delete(d),
          );
        },
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Icon(
            _service.count == 0 ? Icons.landscape_outlined : Icons.search_off,
            size: 56,
            color: kTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            _service.count == 0
                ? 'Belum ada destinasi'
                : 'Destinasi tidak ditemukan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Coba kata kunci lain atau ketuk tombol Tambah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextMuted, height: 1.4),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _clearSearch,
            child: const Text('Reset pencarian'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/widgets/destination_image.dart';
import 'package:campku/screens/admin/admin_actions.dart';
import 'package:campku/screens/dashboard/destination_detail_screen.dart';

enum _TileAction { edit, delete }

/// Tab "Kelola" khusus admin: daftar semua destinasi dengan pencarian,
/// filter kategori, serta tombol tambah, edit, dan hapus.
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
  String? _category; // null = semua kategori

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

  List<Destination> get _items {
    final q = _query.trim().toLowerCase();
    return _service.all.where((d) {
      final inCategory = _category == null || d.category == _category;
      final matches = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.description.toLowerCase().contains(q);
      return inCategory && matches;
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

  // ── BUILD ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final items = _items;

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
          SliverToBoxAdapter(child: _categoryFilter()),
          if (items.isEmpty)
            SliverToBoxAdapter(child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, i) => _tile(items[i]),
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

  Widget _categoryFilter() {
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
        children: [
          _filterChip(
            label: 'Semua (${_service.count})',
            selected: _category == null,
            onTap: () => setState(() => _category = null),
          ),
          for (final c in kCategories) ...[
            const SizedBox(width: 8),
            _filterChip(
              label: '${c.label} (${_service.byCategory(c.label).length})',
              selected: _category == c.label,
              onTap: () => setState(() => _category = c.label),
            ),
          ],
        ],
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
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
      onSelected: (_) => onTap(),
    );
  }

  Widget _tile(Destination d) {
    return Card(
      elevation: 0,
      color: kCardBg,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder),
      ),
      child: InkWell(
        onTap: () => _openDetail(d),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: DestinationImage(destination: d),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: kTextDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      d.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextMuted, fontSize: 12.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      d.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: kTextMuted, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.holiday_village_outlined,
                            size: 14, color: kPrimary),
                        const SizedBox(width: 4),
                        Text(
                          '${_camps.byDestination(d.slug).length} camp',
                          style: const TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_TileAction>(
                tooltip: 'Aksi untuk ${d.name}',
                onSelected: (action) {
                  switch (action) {
                    case _TileAction.edit:
                      _edit(d);
                    case _TileAction.delete:
                      _delete(d);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<_TileAction>(
                    value: _TileAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<_TileAction>(
                    value: _TileAction.delete,
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
        ),
      ),
    );
  }

  Widget _emptyState() {
    final noData = _service.count == 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Icon(
            noData ? Icons.landscape_outlined : Icons.search_off,
            size: 56,
            color: kTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            noData ? 'Belum ada destinasi' : 'Destinasi tidak ditemukan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            noData
                ? 'Ketuk tombol Tambah untuk membuat destinasi pertama.'
                : 'Coba kata kunci lain atau ganti filter kategori.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextMuted, height: 1.4),
          ),
          if (!noData) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                _clearSearch();
                setState(() => _category = null);
              },
              child: const Text('Reset pencarian'),
            ),
          ],
        ],
      ),
    );
  }
}

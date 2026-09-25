import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/widgets/destination_image.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/data/camp_data.dart';
import 'package:campku/screens/admin/admin_actions.dart';
import 'package:campku/screens/dashboard/camp_detail_screen.dart';

enum _CampAction { edit, delete }

/// Halaman detail destinasi (FR-03): info singkat lalu daftar camp yang
/// tersedia (FR-04). Admin bisa mengedit/menghapus destinasi ini serta
/// menambah, mengedit, dan menghapus camp di dalamnya (FR-08).
class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key, required this.destination});

  final Destination destination;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final CampService _camps = CampService.instance;

  Destination get d => widget.destination;
  bool get _fav => AuthService.favorites.contains(d.slug);
  bool get _isAdmin => AuthService.currentUser?.isAdmin ?? false;
  List<Camp> get _items => _camps.byDestination(d.slug);

  @override
  void initState() {
    super.initState();
    _camps.addListener(_onChanged);
  }

  @override
  void dispose() {
    _camps.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  void _toggleFavorite() {
    setState(() {
      if (!AuthService.favorites.remove(d.slug)) {
        AuthService.favorites.add(d.slug);
      }
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addCamp() async {
    final saved = await openCampForm(context, destination: d);
    if (saved != null && mounted) _showMessage('${saved.name} ditambahkan');
  }

  Future<void> _editCamp(Camp c) async {
    final saved = await openCampForm(context, destination: d, existing: c);
    if (saved != null && mounted) _showMessage('${saved.name} diperbarui');
  }

  Future<void> _deleteCamp(Camp c) async {
    final deleted = await confirmDeleteCamp(context, c);
    if (deleted && mounted) _showMessage('${c.name} dihapus');
  }

  void _openCamp(Camp c) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CampDetailScreen(destination: d, camp: c),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _addCamp,
              backgroundColor: kAccent,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Camp'),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(4),
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: () => Navigator.pop(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(235),
                  foregroundColor: kTextDark,
                ),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            actions: [
              if (_isAdmin) ...[
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    tooltip: 'Edit destinasi',
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final saved =
                          await openDestinationForm(context, existing: d);
                      if (saved == null) return;
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(
                            content: Text('${saved.name} diperbarui')));
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(235),
                    ),
                    icon: const Icon(Icons.edit_outlined, color: kTextDark),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: IconButton(
                    tooltip: 'Hapus destinasi',
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(context);
                      final name = d.name;
                      final deleted = await confirmDeleteDestination(context, d);
                      if (!deleted) return;
                      messenger
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text('$name dihapus')));
                      navigator.pop();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withAlpha(235),
                    ),
                    icon: const Icon(Icons.delete_outline, color: kError),
                  ),
                ),
              ],
              Padding(
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  tooltip: _fav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                  onPressed: _toggleFavorite,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(235),
                  ),
                  icon: Icon(
                    _fav ? Icons.favorite : Icons.favorite_border,
                    color: _fav ? const Color(0xFFD64545) : kTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DestinationImage(destination: d),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  _pill(d.categoryIcon, d.category),
                  const SizedBox(height: 16),
                  Text(
                    d.description,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: Color(0xFF3A3A3A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: _sectionHeader(items.length)),
          if (items.isEmpty)
            SliverToBoxAdapter(child: _emptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, i) => _campTile(items[i]),
              ),
            ),
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
          Icon(icon, size: 16, color: kPrimary),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: kPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Camp tersedia',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
            ),
          ),
          Text('$count camp', style: const TextStyle(color: kTextMuted)),
        ],
      ),
    );
  }

  Widget _campTile(Camp c) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: ListTile(
        onTap: () => _openCamp(c),
        contentPadding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        leading: CircleAvatar(
          backgroundColor: kPrimary.withAlpha(30),
          child: const Icon(Icons.holiday_village_outlined, color: kPrimary),
        ),
        title: Text(
          c.name,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        subtitle: const Text('Ketuk untuk lihat tipe tenda'),
        trailing: _isAdmin
            ? PopupMenuButton<_CampAction>(
                tooltip: 'Aksi untuk ${c.name}',
                onSelected: (action) {
                  switch (action) {
                    case _CampAction.edit:
                      _editCamp(c);
                    case _CampAction.delete:
                      _deleteCamp(c);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem<_CampAction>(
                    value: _CampAction.edit,
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem<_CampAction>(
                    value: _CampAction.delete,
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: kError),
                      title: Text('Hapus', style: TextStyle(color: kError)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              )
            : const Icon(Icons.chevron_right, color: kTextMuted),
      ),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        children: [
          const Icon(Icons.holiday_village_outlined,
              size: 56, color: kTextMuted),
          const SizedBox(height: 16),
          Text(
            'Belum ada camp di destinasi ini',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _isAdmin
                ? 'Ketuk tombol Camp untuk menambah camp pertama.'
                : 'Admin belum menambahkan camp untuk destinasi ini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: kTextMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/services/camp_service.dart';
import 'package:campku/services/destination_service.dart';
import 'package:campku/screens/admin/admin_actions.dart';
import 'package:campku/screens/dashboard/destination_detail_screen.dart';
import 'package:campku/widgets/admin_destination_tile.dart';

/// Daftar destinasi dalam satu kategori untuk admin. Dibuka dengan mengetuk
/// kartu kategori di halaman Kelola, sama seperti alur pada sisi pengguna.
class AdminCategoryScreen extends StatefulWidget {
  const AdminCategoryScreen({super.key, required this.category});

  final Category category;

  @override
  State<AdminCategoryScreen> createState() => _AdminCategoryScreenState();
}

class _AdminCategoryScreenState extends State<AdminCategoryScreen> {
  final DestinationService _service = DestinationService.instance;
  final CampService _camps = CampService.instance;

  Category get _category => widget.category;

  List<Destination> get _items => _service.byCategory(_category.label);

  @override
  void initState() {
    super.initState();
    _service.addListener(_onChanged);
    _camps.addListener(_onChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _camps.removeListener(_onChanged);
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

  @override
  Widget build(BuildContext context) {
    final items = _items;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(items.length)),
            if (items.isEmpty)
              const SliverToBoxAdapter(child: _EmptyCategory())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverList.separated(
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(int count) {
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
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: kAccent,
                  child: Icon(_category.icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _category.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count destinasi · ${_category.tagline}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tampil saat kategori belum punya destinasi.
class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        children: [
          Icon(Icons.landscape_outlined, size: 56, color: kTextMuted),
          SizedBox(height: 16),
          Text(
            'Belum ada destinasi di kategori ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kTextDark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tambahkan destinasi baru dari halaman Kelola.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextMuted, height: 1.4),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/widgets/destination_card.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/screens/dashboard/destination_detail_screen.dart';

/// Halaman yang menampilkan semua destinasi dalam satu kategori,
/// misalnya semua gunung setelah kartu "Gunung" diketuk.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, required this.category});

  final Category category;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Category get _category => widget.category;
  Set<String> get _favorites => AuthService.favorites;

  List<Destination> get _items =>
      kDestinations.where((d) => d.category == _category.label).toList();

  void _toggleFavorite(Destination d) {
    setState(() {
      if (!_favorites.remove(d.slug)) _favorites.add(d.slug);
    });
  }

  Future<void> _openDetail(Destination d) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DestinationDetailScreen(destination: d),
      ),
    );
    if (mounted) setState(() {});
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 240,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.56,
                ),
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final d = items[i];
                  return DestinationCard(
                    destination: d,
                    isFavorite: _favorites.contains(d.slug),
                    onTap: () => _openDetail(d),
                    onDetail: () => _openDetail(d),
                    onToggleFavorite: () => _toggleFavorite(d),
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

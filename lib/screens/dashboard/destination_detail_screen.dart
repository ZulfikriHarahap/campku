import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/widgets/booking_button.dart';
import 'package:campku/widgets/destination_image.dart';
import 'package:campku/data/destinations_data.dart';

/// Halaman "Lihat selengkapnya": info lengkap satu destinasi.
class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({super.key, required this.destination});

  final Destination destination;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  Destination get d => widget.destination;
  bool get _fav => AuthService.favorites.contains(d.slug);

  void _toggleFavorite() {
    setState(() {
      if (!AuthService.favorites.remove(d.slug)) {
        AuthService.favorites.add(d.slug);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 16,
                        color: kTextMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          d.location,
                          style: const TextStyle(color: kTextMuted),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(
                        Icons.star_rounded,
                        '${d.rating.toStringAsFixed(1)} rating',
                      ),
                      _pill(d.categoryIcon, d.category),
                      _pill(d.badgeIcon, d.badge),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    d.about,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.55,
                      color: Color(0xFF3A3A3A),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _priceCard(),
                  _sectionTitle(Icons.hiking, 'Yang bisa dilakukan'),
                  _bullets(d.activities, Icons.check_circle_outline),
                  _sectionTitle(Icons.wb_sunny_outlined, 'Waktu terbaik'),
                  _paragraph(d.bestTime),
                  _sectionTitle(Icons.directions_car_outlined, 'Cara menuju'),
                  _paragraph(d.access),
                  _sectionTitle(Icons.holiday_village_outlined, 'Fasilitas'),
                  _bullets(d.facilities, Icons.check_circle_outline),
                  _sectionTitle(Icons.lightbulb_outline, 'Tips berkunjung'),
                  _bullets(d.tips, Icons.tips_and_updates_outlined),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kAccent.withAlpha(24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: kAccentText),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Informasi bersifat umum. Harga, akses, dan kondisi '
                            'lokasi bisa berubah, jadi konfirmasi ke pengelola '
                            'atau warga setempat sebelum berangkat.',
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
                  const SizedBox(height: 20),
                  BookingButton(destination: d),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── KOMPONEN ──────────────────────────────

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

  Widget _priceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Harga mulai dari', style: TextStyle(color: kTextMuted)),
          Text(
            d.priceShort,
            style: const TextStyle(
              color: kAccentText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kPrimary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 17),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paragraph(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14.5,
        height: 1.55,
        color: Color(0xFF3A3A3A),
      ),
    );
  }

  Widget _bullets(List<String> items, IconData icon) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 18, color: kPrimaryLight),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.45,
                      color: Color(0xFF3A3A3A),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

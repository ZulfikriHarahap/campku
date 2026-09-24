import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/widgets/destination_image.dart';
import 'package:campku/data/destinations_data.dart';

/// Kartu destinasi yang dipakai di beranda, favorit, dan halaman kategori.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.isFavorite,
    required this.onTap,
    required this.onDetail,
    required this.onToggleFavorite,
  });

  final Destination destination;
  final bool isFavorite;

  /// Ketuk badan kartu.
  final VoidCallback onTap;

  /// Ketuk tombol "Lihat selengkapnya".
  final VoidCallback onDetail;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    final d = destination;
    final fav = isFavorite;
    return Card(
      elevation: 1.5,
      color: kCardBg,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DestinationImage(destination: d),
                  Positioned(
                    left: 8,
                    top: 10,
                    right: 48,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _badge(d),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: _favoriteButton(fav),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      height: 1.2,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: kTextMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          d.city,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          d.priceShort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kAccentText,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      const Icon(Icons.star_rounded, size: 16, color: kAccent),
                      const SizedBox(width: 2),
                      Text(
                        d.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: OutlinedButton(
                      onPressed: onDetail,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        foregroundColor: kPrimary,
                        side: BorderSide(color: kPrimary.withAlpha(90)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Lihat selengkapnya',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(Destination d) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(d.badgeIcon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              d.badge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _favoriteButton(bool fav) {
    return IconButton(
      tooltip: fav ? 'Hapus dari favorit' : 'Simpan ke favorit',
      onPressed: onToggleFavorite,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withAlpha(235),
        minimumSize: const Size(36, 36),
        padding: EdgeInsets.zero,
      ),
      icon: Icon(
        fav ? Icons.favorite : Icons.favorite_border,
        size: 20,
        color: fav ? const Color(0xFFD64545) : kTextDark,
      ),
    );
  }
}

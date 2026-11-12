import 'package:flutter/material.dart';

import 'package:campku/data/destinations_data.dart';
import 'package:campku/theme/app_theme.dart';
import 'package:campku/widgets/destination_image.dart';

/// Kartu kategori bergambar (foto latar, label, tagline, dan jumlah destinasi).
/// Dipakai bersama oleh beranda pengguna dan halaman Kelola admin.
class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.category,
    required this.count,
    required this.onTap,
  });

  final Category category;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = category;

    return Semantics(
      button: true,
      label: 'Buka kategori ${c.label}, $count destinasi',
      child: Card(
        elevation: 3,
        color: kCardBg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black38,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  c.imageAsset,
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  // Cadangan jika foto belum ada: ilustrasi lanskap.
                  errorBuilder: (_, __, ___) =>
                      LandscapeArt(category: c.label),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00000000), Color(0xCC000000)],
                      stops: [0.3, 1],
                    ),
                  ),
                ),
                // Label kategori di pojok kiri atas.
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 14, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          c.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.tagline,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$count destinasi',
                              style: const TextStyle(
                                color: Color(0xFFFFC46B),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

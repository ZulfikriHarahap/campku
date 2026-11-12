import 'package:flutter/material.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/widgets/destination_image.dart';

enum _TileAction { edit, delete }

/// Baris destinasi untuk halaman Kelola admin: foto kecil, nama, kategori,
/// jumlah camp, dan menu Edit/Hapus.
class AdminDestinationTile extends StatelessWidget {
  const AdminDestinationTile({
    super.key,
    required this.destination,
    required this.campCount,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final Destination destination;
  final int campCount;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = destination;
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
        onTap: onOpen,
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
                          '$campCount camp',
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
                      onEdit();
                    case _TileAction.delete:
                      onDelete();
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
}

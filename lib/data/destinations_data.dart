import 'package:flutter/material.dart';

class Category {
  const Category(this.label, this.icon);
  final String label;
  final IconData icon;
}

const List<Category> kCategories = [
  Category('Gunung', Icons.terrain),
  Category('Danau', Icons.water),
  Category('Air Terjun', Icons.waves),
  Category('Hutan', Icons.forest),
  Category('Sungai', Icons.rowing),
];

class Destination {
  const Destination({
    required this.slug,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.priceLabel,
    required this.badge,
    required this.badgeIcon,
    required this.description,
  });

  /// Nama unik dipakai untuk nama file foto: assets/images/<slug>.jpg
  final String slug;
  final String name;
  final String category;
  final String location;
  final double rating;
  final String priceLabel;
  final String badge;
  final IconData badgeIcon;
  final String description;

  String get imageAsset => 'assets/images/$slug.jpg';
  String get priceShort => priceLabel.replaceFirst('Mulai ', '');
  String get city => location.split(',').first;
  IconData get categoryIcon =>
      kCategories.firstWhere((c) => c.label == category).icon;
}

const List<Destination> kDestinations = [
  // ── Gunung ────────────────────────────────
  Destination(
    slug: 'sibayak',
    name: 'Gunung Sibayak',
    category: 'Gunung',
    location: 'Karo, Sumatera Utara',
    rating: 4.8,
    priceLabel: 'Mulai Rp 25.000',
    badge: 'Populer',
    badgeIcon: Icons.local_fire_department,
    description:
        'Gunung berapi di atas Berastagi dengan kawah belerang dan sumber air panas. Pendakian ke kawah biasanya memakan 2–4 jam, cocok untuk pemula yang ingin camping di ketinggian.',
  ),
  Destination(
    slug: 'sibuatan',
    name: 'Gunung Sibuatan',
    category: 'Gunung',
    location: 'Karo, Sumatera Utara',
    rating: 4.6,
    priceLabel: 'Mulai Rp 20.000',
    badge: 'Menantang',
    badgeIcon: Icons.fitness_center,
    description:
        'Gunung dengan hutan lebat dan jalur pendakian yang menantang. Siapkan stamina dan perlengkapan untuk udara dingin di ketinggian.',
  ),
  Destination(
    slug: 'sinabung',
    name: 'Gunung Sinabung',
    category: 'Gunung',
    location: 'Karo, Sumatera Utara',
    rating: 4.7,
    priceLabel: 'Mulai Rp 30.000',
    badge: 'Ikonik',
    badgeIcon: Icons.star,
    description:
        'Gunung berapi aktif yang menjadi ikon Tanah Karo. Area puncaknya sering ditutup karena aktivitas erupsi, jadi cek status terbaru di PVMBG sebelum berencana ke sana.',
  ),
  // ── Danau ─────────────────────────────────
  Destination(
    slug: 'toba',
    name: 'Danau Toba',
    category: 'Danau',
    location: 'Samosir, Sumatera Utara',
    rating: 4.9,
    priceLabel: 'Mulai Rp 15.000',
    badge: 'Terlaris',
    badgeIcon: Icons.favorite,
    description:
        'Salah satu danau vulkanik terbesar di dunia, dikelilingi bukit dan pantai. Pulau Samosir punya banyak area camping tepi danau.',
  ),
  Destination(
    slug: 'lau_kawar',
    name: 'Danau Lau Kawar',
    category: 'Danau',
    location: 'Karo, Sumatera Utara',
    rating: 4.5,
    priceLabel: 'Mulai Rp 10.000',
    badge: 'Tersembunyi',
    badgeIcon: Icons.explore,
    description:
        'Danau kecil di kaki Gunung Sinabung yang dikenal sebagai area camping dengan udara sejuk dan pemandangan gunung.',
  ),
  Destination(
    slug: 'sidihoni',
    name: 'Danau Sidihoni',
    category: 'Danau',
    location: 'Samosir, Sumatera Utara',
    rating: 4.4,
    priceLabel: 'Mulai Rp 10.000',
    badge: 'Unik',
    badgeIcon: Icons.wb_sunny,
    description:
        'Danau di Pulau Samosir, yaitu pulau yang berada di tengah Danau Toba. Suasananya tenang untuk camping santai.',
  ),
  // ── Air Terjun ────────────────────────────
  Destination(
    slug: 'sipiso_piso',
    name: 'Air Terjun Sipiso-piso',
    category: 'Air Terjun',
    location: 'Karo, Sumatera Utara',
    rating: 4.8,
    priceLabel: 'Mulai Rp 15.000',
    badge: 'Populer',
    badgeIcon: Icons.local_fire_department,
    description:
        'Air terjun setinggi sekitar 120 meter di ujung utara Danau Toba. Sediakan waktu untuk menuruni tangga ke dasarnya dan menikmati pemandangan lembah.',
  ),
  Destination(
    slug: 'efrata',
    name: 'Air Terjun Efrata',
    category: 'Air Terjun',
    location: 'Dairi, Sumatera Utara',
    rating: 4.3,
    priceLabel: 'Mulai Rp 10.000',
    badge: 'Sejuk',
    badgeIcon: Icons.ac_unit,
    description:
        'Air terjun berair sejuk yang dikelilingi pepohonan, cocok untuk singgah sambil bermain air.',
  ),
  Destination(
    slug: 'binanga_bolon',
    name: 'Air Terjun Binanga Bolon',
    category: 'Air Terjun',
    location: 'Tapanuli Utara, Sumatera Utara',
    rating: 4.2,
    priceLabel: 'Mulai Rp 8.000',
    badge: 'Alami',
    badgeIcon: Icons.eco,
    description:
        'Air terjun alami di tengah hutan dengan suasana sepi. Bawa alas kaki anti licin untuk jalur menuju air terjun.',
  ),
  // ── Hutan ─────────────────────────────────
  Destination(
    slug: 'bahorok',
    name: 'Hutan Bahorok',
    category: 'Hutan',
    location: 'Langkat, Sumatera Utara',
    rating: 4.7,
    priceLabel: 'Mulai Rp 20.000',
    badge: 'Populer',
    badgeIcon: Icons.local_fire_department,
    description:
        'Kawasan hutan hujan di tepi Sungai Bahorok yang dikenal lewat wisata pengamatan orangutan. Cocok untuk trekking ringan dan camping dekat sungai.',
  ),
  Destination(
    slug: 'leuser',
    name: 'Taman Nasional Gunung Leuser',
    category: 'Hutan',
    location: 'Langkat, Sumatera Utara',
    rating: 4.9,
    priceLabel: 'Mulai Rp 50.000',
    badge: 'Warisan UNESCO',
    badgeIcon: Icons.star,
    description:
        'Bagian dari Warisan Hutan Hujan Tropis Sumatera yang diakui UNESCO, rumah bagi orangutan, harimau, dan gajah Sumatera. Kunjungan biasanya butuh izin dan pemandu.',
  ),
  Destination(
    slug: 'mangrove_serdang',
    name: 'Hutan Mangrove Serdang',
    category: 'Hutan',
    location: 'Serdang Bedagai, Sumatera Utara',
    rating: 4.2,
    priceLabel: 'Mulai Rp 10.000',
    badge: 'Unik',
    badgeIcon: Icons.spa,
    description:
        'Hutan bakau pesisir tempat burung air mencari makan. Datang pagi atau sore agar tidak terlalu panas.',
  ),
  // ── Sungai ────────────────────────────────
  Destination(
    slug: 'alas',
    name: 'Sungai Alas',
    category: 'Sungai',
    location: 'Langkat, Sumatera Utara',
    rating: 4.6,
    priceLabel: 'Mulai Rp 35.000',
    badge: 'Arung Jeram',
    badgeIcon: Icons.kayaking,
    description:
        'Sungai berarus deras yang populer untuk arung jeram. Ikuti operator berpengalaman dan selalu pakai pelampung.',
  ),
  Destination(
    slug: 'wampu',
    name: 'Sungai Wampu',
    category: 'Sungai',
    location: 'Langkat, Sumatera Utara',
    rating: 4.4,
    priceLabel: 'Mulai Rp 30.000',
    badge: 'Petualangan',
    badgeIcon: Icons.directions_boat,
    description:
        'Sungai panjang yang mengalir melewati hutan dan kebun. Cocok untuk susur sungai dan camping di tepiannya.',
  ),
  Destination(
    slug: 'bah_bolon',
    name: 'Sungai Bah Bolon',
    category: 'Sungai',
    location: 'Simalungun, Sumatera Utara',
    rating: 4.3,
    priceLabel: 'Mulai Rp 15.000',
    badge: 'Jernih',
    badgeIcon: Icons.water_drop,
    description:
        'Sungai berair jernih dengan bebatuan di tepiannya. Nyaman untuk berendam dan camping keluarga.',
  ),
];

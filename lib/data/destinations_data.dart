import 'package:flutter/material.dart';

/// Kategori wisata (FR-02): daftar tetap yang tidak diubah lewat CRUD admin.
class Category {
  const Category(this.label, this.icon, this.tagline);
  final String label;
  final IconData icon;

  /// Kalimat singkat yang tampil di kartu kategori pada beranda.
  final String tagline;
}

const List<Category> kCategories = [
  Category('Gunung', Icons.terrain, 'Pendakian dan camping di ketinggian'),
  Category('Danau', Icons.water, 'Camping tepi danau yang tenang'),
  Category('Air Terjun', Icons.waves, 'Suara air dan udara yang sejuk'),
  Category('Hutan', Icons.forest, 'Trekking dan bertemu satwa liar'),
  Category('Sungai', Icons.rowing, 'Susur sungai dan arung jeram'),
];

/// Data destinasi wisata (FR-03).
///
/// Field sengaja dibatasi hanya nama, kategori, dan deskripsi sesuai
/// "Data Utama" pada mini SRS CampKu. Info camp dan tipe tenda ada di
/// [Camp] dan [TentType] pada `camp_data.dart` dan `tent_data.dart`.
class Destination {
  const Destination({
    required this.slug,
    required this.name,
    required this.category,
    required this.description,
  });

  /// Kunci unik, dipakai untuk relasi Camp, nama file foto, dan favorit.
  /// Bukan bagian dari data SRS, murni kebutuhan teknis aplikasi.
  final String slug;
  final String name;
  final String category;
  final String description;

  String get imageAsset => 'assets/images/$slug.jpg';

  IconData get categoryIcon =>
      kCategories.firstWhere((c) => c.label == category).icon;
}

const List<Destination> kDestinations = [
  Destination(
    slug: 'sibayak',
    name: 'Gunung Sibayak',
    category: 'Gunung',
    description:
        'Gunung berapi di atas Berastagi dengan kawah belerang dan sumber air panas. Pendakian ke kawah biasanya memakan 2–4 jam, cocok untuk pemula yang ingin camping di ketinggian.',
  ),
  Destination(
    slug: 'sibuatan',
    name: 'Gunung Sibuatan',
    category: 'Gunung',
    description:
        'Gunung dengan hutan lebat dan jalur pendakian yang menantang. Siapkan stamina dan perlengkapan untuk udara dingin di ketinggian.',
  ),
  Destination(
    slug: 'sinabung',
    name: 'Gunung Sinabung',
    category: 'Gunung',
    description:
        'Gunung berapi aktif yang menjadi ikon Tanah Karo. Area puncaknya sering ditutup karena aktivitas erupsi, jadi cek status terbaru di PVMBG sebelum berencana ke sana.',
  ),
  Destination(
    slug: 'toba',
    name: 'Danau Toba',
    category: 'Danau',
    description:
        'Salah satu danau vulkanik terbesar di dunia, dikelilingi bukit dan pantai. Pulau Samosir punya banyak area camping tepi danau.',
  ),
  Destination(
    slug: 'lau_kawar',
    name: 'Danau Lau Kawar',
    category: 'Danau',
    description:
        'Danau kecil di kaki Gunung Sinabung yang dikenal sebagai area camping dengan udara sejuk dan pemandangan gunung.',
  ),
  Destination(
    slug: 'sidihoni',
    name: 'Danau Sidihoni',
    category: 'Danau',
    description:
        'Danau di Pulau Samosir, yaitu pulau yang berada di tengah Danau Toba. Suasananya tenang untuk camping santai.',
  ),
  Destination(
    slug: 'sipiso_piso',
    name: 'Air Terjun Sipiso-piso',
    category: 'Air Terjun',
    description:
        'Air terjun setinggi sekitar 120 meter di ujung utara Danau Toba. Sediakan waktu untuk menuruni tangga ke dasarnya dan menikmati pemandangan lembah.',
  ),
  Destination(
    slug: 'efrata',
    name: 'Air Terjun Efrata',
    category: 'Air Terjun',
    description:
        'Air terjun berair sejuk yang dikelilingi pepohonan, cocok untuk singgah sambil bermain air.',
  ),
  Destination(
    slug: 'binanga_bolon',
    name: 'Air Terjun Binanga Bolon',
    category: 'Air Terjun',
    description:
        'Air terjun alami di tengah hutan dengan suasana sepi. Bawa alas kaki anti licin untuk jalur menuju air terjun.',
  ),
  Destination(
    slug: 'bahorok',
    name: 'Hutan Bahorok',
    category: 'Hutan',
    description:
        'Kawasan hutan hujan di tepi Sungai Bahorok yang dikenal lewat wisata pengamatan orangutan. Cocok untuk trekking ringan dan camping dekat sungai.',
  ),
  Destination(
    slug: 'leuser',
    name: 'Taman Nasional Gunung Leuser',
    category: 'Hutan',
    description:
        'Bagian dari Warisan Hutan Hujan Tropis Sumatera yang diakui UNESCO, rumah bagi orangutan, harimau, dan gajah Sumatera. Kunjungan biasanya butuh izin dan pemandu.',
  ),
  Destination(
    slug: 'mangrove_serdang',
    name: 'Hutan Mangrove Serdang',
    category: 'Hutan',
    description:
        'Hutan bakau pesisir tempat burung air mencari makan. Datang pagi atau sore agar tidak terlalu panas.',
  ),
  Destination(
    slug: 'alas',
    name: 'Sungai Alas',
    category: 'Sungai',
    description:
        'Sungai berarus deras yang populer untuk arung jeram. Ikuti operator berpengalaman dan selalu pakai pelampung.',
  ),
  Destination(
    slug: 'wampu',
    name: 'Sungai Wampu',
    category: 'Sungai',
    description:
        'Sungai panjang yang mengalir melewati hutan dan kebun. Cocok untuk susur sungai dan camping di tepiannya.',
  ),
  Destination(
    slug: 'bah_bolon',
    name: 'Sungai Bah Bolon',
    category: 'Sungai',
    description:
        'Sungai berair jernih dengan bebatuan di tepiannya. Nyaman untuk berendam dan camping keluarga.',
  ),
];

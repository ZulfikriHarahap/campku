import 'package:flutter/material.dart';

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
    required this.about,
    required this.activities,
    required this.bestTime,
    required this.access,
    required this.facilities,
    required this.tips,
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

  // ── Info untuk halaman "Lihat selengkapnya" ──
  /// Penjelasan lebih panjang tentang tempat ini.
  final String about;

  /// Hal yang bisa dilakukan di sana.
  final List<String> activities;

  /// Waktu kunjungan yang disarankan.
  final String bestTime;

  /// Cara menuju lokasi.
  final String access;

  /// Fasilitas yang umumnya tersedia.
  final List<String> facilities;

  /// Tips dan hal yang perlu diperhatikan.
  final List<String> tips;

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
    about:
        'Gunung Sibayak (sekitar 2.212 mdpl) adalah gunung berapi di atas Berastagi yang punya kawah belerang dengan asap fumarol dan sumber air panas alami di kakinya. Jalurnya relatif ramah untuk pendaki pemula, dan pemandangan dari atas sangat luas saat cuaca cerah.',
    activities: [
      'Pendakian pagi menuju kawah',
      'Berendam di air panas setelah turun',
      'Berburu matahari terbit',
      'Camping di area yang diizinkan pengelola',
    ],
    bestTime:
        'Musim kemarau (sekitar Mei sampai September). Mulai mendaki pagi hari agar terhindar dari kabut dan hujan siang.',
    access:
        'Dari Medan ke Berastagi sekitar 2 jam berkendara, lalu lanjut ke titik awal pendakian di Jaridan atau Raja Berneh.',
    facilities: [
      'Warung di dekat titik awal pendakian',
      'Pemandian air panas di kaki gunung',
      'Penginapan dan homestay di Berastagi',
    ],
    tips: [
      'Bawa masker atau buff karena bau belerang di sekitar kawah',
      'Jangan mendekati fumarol dan tetap ikuti jalur yang ada',
      'Siapkan jaket dan jas hujan karena cuaca cepat berubah',
    ],
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
    about:
        'Gunung Sibuatan (sekitar 2.457 mdpl) dikenal dengan hutan hujan pegunungan yang lebat, lumut tebal, dan jalur yang lebih panjang dibanding gunung lain di Karo. Pendakiannya biasanya dilakukan dua hari satu malam, jadi cocok untuk kamu yang ingin pengalaman camping di tengah hutan.',
    activities: [
      'Pendakian 2 hari 1 malam',
      'Camping di jalur pendakian',
      'Fotografi hutan berlumut',
      'Mengamati flora dan fauna hutan',
    ],
    bestTime:
        'Musim kemarau (sekitar Mei sampai September). Hindari hujan deras karena jalur menjadi sangat licin.',
    access:
        'Dari Medan menuju Kabanjahe, lalu ke arah Barusjahe dan desa terdekat titik awal pendakian (umumnya Desa Sukanalu). Tanyakan rute terbaru ke warga atau pengelola.',
    facilities: [
      'Warung sederhana di desa dekat titik awal',
      'Fasilitas di jalur sangat terbatas',
      'Bawa perlengkapan camping lengkap sendiri',
    ],
    tips: [
      'Beri tahu keluarga dan lapor ke warga atau pengelola sebelum naik',
      'Pakai kaus kaki panjang atau gaiter karena ada pacet',
      'Bawa air dan alat penjernih, serta pertimbangkan pemandu lokal',
    ],
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
    about:
        'Gunung Sinabung (sekitar 2.460 mdpl) adalah gunung berapi yang aktif erupsi sejak 2010 dan menjadi ikon Tanah Karo. Pemerintah menetapkan zona bahaya di sekitar kawahnya, sehingga pendakian ke puncak umumnya tidak diperbolehkan. Kamu tetap bisa menikmatinya dari titik pandang yang aman.',
    activities: [
      'Menikmati panorama dari Berastagi atau Bukit Gundaling',
      'Camping di Danau Lau Kawar bila area dibuka',
      'Memotret siluet gunung saat matahari terbit',
    ],
    bestTime:
        'Pagi hari yang cerah. Selalu cek status terbaru di MAGMA Indonesia (PVMBG) sebelum berangkat.',
    access:
        'Dari Medan ke Berastagi atau Kabanjahe sekitar 2 sampai 3 jam. Danau Lau Kawar di kaki gunung menjadi titik terdekat yang biasa dikunjungi.',
    facilities: [
      'Penginapan dan restoran di Berastagi dan Kabanjahe',
      'Area camping di Danau Lau Kawar (cek status dibuka)',
    ],
    tips: [
      'Patuhi larangan masuk zona bahaya',
      'Pantau MAGMA Indonesia sebelum dan selama perjalanan',
      'Siapkan masker jika terjadi hujan abu',
    ],
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
    about:
        'Danau Toba terbentuk dari letusan supervulkanik puluhan ribu tahun lalu dan kini menjadi danau vulkanik terbesar di dunia dengan Pulau Samosir di tengahnya. Kawasannya telah diakui sebagai UNESCO Global Geopark. Tepiannya punya banyak pantai, bukit, dan desa Batak yang bisa dijelajahi.',
    activities: [
      'Menyeberang naik kapal ke Pulau Samosir',
      'Bersepeda atau bermotor keliling Samosir',
      'Mengunjungi desa adat dan situs budaya Batak',
      'Camping di tepi danau',
      'Mencicipi kuliner khas Batak',
    ],
    bestTime:
        'Musim kemarau (sekitar Mei sampai September) untuk cuaca cerah dan penyeberangan yang lebih nyaman.',
    access:
        'Dari Medan ke Parapat sekitar 4 sampai 5 jam lewat darat, lalu naik kapal feri dari Ajibata ke Tomok atau Tuktuk. Bandara Silangit juga melayani penerbangan ke kawasan Toba.',
    facilities: [
      'Hotel, homestay, dan restoran di Parapat, Tuktuk, dan Tomok',
      'Penyewaan sepeda, motor, dan kapal',
      'Beberapa area camping di tepi danau',
    ],
    tips: [
      'Cek jadwal kapal dan cuaca sebelum menyeberang',
      'Bawa jaket karena malam hari sejuk',
      'Ikuti aturan area camping dan jangan tinggalkan sampah',
    ],
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
    about:
        'Danau Lau Kawar adalah danau kecil di kaki Gunung Sinabung yang dikelilingi perbukitan dan padang rumput. Tempatnya sederhana dan tenang, sehingga banyak dipilih untuk camping santai dengan latar gunung. Kondisi akses dan area yang dibuka bisa berubah mengikuti aktivitas Sinabung.',
    activities: [
      'Camping tepi danau',
      'Memotret gunung dan danau saat pagi',
      'Piknik dan bersantai di tepi air',
    ],
    bestTime:
        'Musim kemarau dan pagi hari agar pemandangan gunung tidak tertutup kabut.',
    access:
        'Dari Berastagi atau Kabanjahe menuju kawasan kaki Sinabung, lalu ikuti petunjuk arah ke Danau Lau Kawar. Cek status terbuka atau tidaknya sebelum berangkat.',
    facilities: [
      'Lahan camping',
      'Warung sederhana',
      'Fasilitas terbatas, siapkan perbekalan sendiri',
    ],
    tips: [
      'Pantau status Sinabung di MAGMA Indonesia',
      'Malam hari sangat dingin, bawa sleeping bag dan jaket tebal',
      'Bawa kembali semua sampahmu',
    ],
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
    about:
        'Danau Sidihoni dijuluki danau di atas pulau di tengah danau: sebuah danau kecil di dataran tinggi Pulau Samosir, yang berada di tengah Danau Toba. Sekelilingnya padang rumput hijau dan bukit landai, dan suasananya sangat tenang.',
    activities: [
      'Camping santai di tepi danau',
      'Trekking ringan di sekitar danau',
      'Melihat matahari terbit dan terbenam',
      'Fotografi lanskap',
    ],
    bestTime:
        'Musim kemarau (sekitar Mei sampai September). Pagi hari udara paling sejuk dan langit lebih jernih.',
    access:
        'Lewat jalur darat dari Pangururan atau dengan menyeberang ke Samosir, lalu naik ke dataran tinggi di wilayah Desa Sabungan Nihuta. Jalannya menanjak, gunakan peta digital atau tanya warga.',
    facilities: [
      'Area rumput luas untuk tenda',
      'Fasilitas sangat terbatas, bawa perbekalan sendiri',
    ],
    tips: [
      'Isi bahan bakar dan perbekalan sebelum naik',
      'Jalan bisa licin setelah hujan',
      'Jaga kebersihan karena danau ini juga menjadi sumber air warga',
    ],
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
    about:
        'Air Terjun Sipiso-piso jatuh dari tebing setinggi sekitar 120 meter di Desa Tongging, Kabupaten Karo, tepat di ujung utara Danau Toba. Dari bibir tebing kamu bisa melihat air terjun dan lembah di bawahnya, atau menuruni tangga sampai ke dasar.',
    activities: [
      'Menikmati pemandangan dari pos pandang',
      'Menuruni tangga sampai ke dasar air terjun',
      'Memotret Danau Toba dari ketinggian',
      'Singgah di Tongging',
    ],
    bestTime:
        'Pagi hari sebelum kabut naik, dan musim kemarau agar tangga tidak licin.',
    access:
        'Dari Medan lewat Berastagi atau Kabanjahe ke arah Merek dan Tongging, sekitar 3 sampai 4 jam berkendara.',
    facilities: [
      'Area parkir',
      'Warung dan penjual oleh-oleh',
      'Pos pandang dan anak tangga menuju dasar',
    ],
    tips: [
      'Turunnya mudah tetapi naiknya melelahkan, sisakan tenaga',
      'Pakai alas kaki yang tidak licin',
      'Cuaca cepat berubah, bawa jas hujan',
    ],
  ),
  Destination(
    slug: 'efrata',
    name: 'Air Terjun Efrata',
    category: 'Air Terjun',
    location: 'Samosir, Sumatera Utara',
    rating: 4.3,
    priceLabel: 'Mulai Rp 10.000',
    badge: 'Sejuk',
    badgeIcon: Icons.ac_unit,
    description:
        'Air terjun berair sejuk yang dikelilingi pepohonan, cocok untuk singgah sambil bermain air.',
    about:
        'Air Terjun Efrata, juga dikenal sebagai Sampuran Efrata, berada di Desa Sosor Dolok, Kecamatan Harian, Pulau Samosir. Tingginya sekitar 20 sampai 26 meter dengan latar hutan dan sawah hijau. Jaraknya cukup dekat dari area parkir sehingga mudah dikunjungi.',
    activities: [
      'Menikmati air terjun dan foto',
      'Menikmati suasana sawah dan perbukitan sekitar',
      'Digabung dengan kunjungan ke Menara Pandang Tele',
    ],
    bestTime:
        'Musim kemarau agar air lebih jernih dan jalan tidak licin.',
    access:
        'Dari Medan sekitar 186 km ke Desa Sosor Dolok, Kecamatan Harian, dekat Menara Pandang Tele. Perjalanan sekitar 5 jam atau lebih tergantung kondisi jalan.',
    facilities: [
      'Area parkir dengan jalan kaki pendek ke air terjun',
      'Warung sederhana di sekitar desa',
    ],
    tips: [
      'Air bisa keruh setelah hujan, cek dulu sebelum berenang',
      'Bawa alas kaki anti licin',
      'Bawa uang tunai secukupnya untuk tiket dan parkir',
    ],
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
    about:
        'Air Terjun Binanga Bolon adalah air terjun alami di tengah hutan Tapanuli Utara yang masih sepi pengunjung. Karena belum banyak dikelola, suasananya alami dan cocok untuk kamu yang suka tempat tenang.',
    activities: [
      'Trekking ringan menuju air terjun',
      'Menikmati suasana hutan yang sepi',
      'Fotografi alam',
    ],
    bestTime:
        'Musim kemarau. Hindari datang saat atau sesudah hujan deras karena debit naik dan jalur licin.',
    access:
        'Menuju Tapanuli Utara (pusat kabupaten di Tarutung), lalu ikuti petunjuk arah atau tanya warga. Sebagian jalur berupa jalan setapak.',
    facilities: [
      'Fasilitas sangat terbatas',
      'Bawa air minum, makanan, dan kantong sampah sendiri',
    ],
    tips: [
      'Pakai alas kaki anti licin',
      'Jangan berenang saat debit air besar',
      'Konfirmasi rute dengan warga karena penunjuk arah mungkin minim',
    ],
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
    about:
        'Hutan Bahorok di kawasan Bukit Lawang, Langkat, adalah pintu masuk populer ke hutan hujan tropis Sumatera. Di sinilah orangutan semi-liar bisa dilihat dari dekat, dengan sungai jernih yang mengalir di sampingnya.',
    activities: [
      'Trekking mengamati orangutan bersama pemandu',
      'Tubing menyusuri Sungai Bahorok',
      'Camping di tepi sungai',
      'Menyusuri jalur hutan di tepi sungai',
    ],
    bestTime:
        'Musim kemarau (sekitar Mei sampai September) agar jalur tidak becek dan arus sungai lebih aman.',
    access:
        'Dari Medan ke Bukit Lawang sekitar 3 jam lewat darat melalui Bahorok.',
    facilities: [
      'Penginapan dan homestay di tepi sungai',
      'Warung dan restoran',
      'Pemandu lokal untuk trekking',
    ],
    tips: [
      'Gunakan pemandu resmi dan jaga jarak dari orangutan',
      'Jangan memberi makan atau menyentuh satwa',
      'Waspada banjir bandang saat hujan deras di hulu sungai',
    ],
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
    about:
        'Taman Nasional Gunung Leuser merupakan bagian dari Warisan Hutan Hujan Tropis Sumatera yang diakui UNESCO. Kawasannya membentang di Aceh dan Sumatera Utara dan menjadi habitat orangutan, harimau, gajah, dan badak Sumatera. Kunjungan biasanya membutuhkan izin dan pemandu.',
    activities: [
      'Trekking hutan hujan bersama pemandu',
      'Mengamati orangutan dan burung rangkong',
      'Camping di area yang diizinkan',
      'Menyusuri sungai di sekitar hutan',
    ],
    bestTime:
        'Musim kemarau untuk jalur yang lebih aman. Hutan hujan tetap lembap sepanjang tahun, jadi siapkan jas hujan.',
    access:
        'Dari Medan lewat gerbang Bukit Lawang atau Tangkahan di Langkat, sekitar 3 jam berkendara. Urus izin masuk lewat Balai Besar Taman Nasional Gunung Leuser.',
    facilities: [
      'Pemandu resmi',
      'Penginapan di Bukit Lawang dan Tangkahan',
      'Fasilitas di dalam hutan sangat terbatas',
    ],
    tips: [
      'Urus izin dan gunakan pemandu resmi',
      'Jangan mengambil tumbuhan atau mengganggu satwa',
      'Bawa pulang semua sampah',
    ],
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
    about:
        'Hutan mangrove di pesisir Serdang Bedagai menjadi rumah bagi burung air, kepiting, dan ikan kecil, sekaligus penahan abrasi pantai. Suasananya teduh dan cocok untuk jalan santai, mengamati burung, atau memotret saat pagi dan sore.',
    activities: [
      'Menyusuri jalur atau jembatan mangrove',
      'Mengamati burung air',
      'Fotografi saat golden hour',
      'Ikut penanaman bibit mangrove bila ada program',
    ],
    bestTime:
        'Pagi atau sore hari. Hindari siang terik dan saat air pasang tinggi.',
    access:
        'Dari Medan ke pesisir Serdang Bedagai (misalnya kawasan Pantai Cermin), sekitar 1 sampai 2 jam berkendara. Lokasi tiap kawasan mangrove berbeda, cek peta digital.',
    facilities: [
      'Jalur atau jembatan pengamatan di beberapa lokasi',
      'Warung sederhana',
      'Fasilitas berbeda-beda tiap kawasan',
    ],
    tips: [
      'Pakai lotion anti nyamuk dan alas kaki tertutup',
      'Perhatikan jadwal pasang surut',
      'Jangan memetik bibit atau membuang sampah di area mangrove',
    ],
  ),
  // ── Sungai ────────────────────────────────
  Destination(
    slug: 'alas',
    name: 'Sungai Alas',
    category: 'Sungai',
    location: 'Aceh Tenggara, Aceh',
    rating: 4.6,
    priceLabel: 'Mulai Rp 35.000',
    badge: 'Arung Jeram',
    badgeIcon: Icons.kayaking,
    description:
        'Sungai berarus deras yang populer untuk arung jeram. Ikuti operator berpengalaman dan selalu pakai pelampung.',
    about:
        'Sungai Alas di kawasan Ketambe, Aceh Tenggara, mengalir melewati Taman Nasional Gunung Leuser dan terkenal sebagai salah satu lokasi arung jeram terbaik di Indonesia. Arusnya bervariasi dari sedang sampai menantang, dengan kemungkinan bertemu burung rangkong, monyet, bahkan orangutan liar dari perahu.',
    activities: [
      'Arung jeram bersama operator berpengalaman',
      'Mengamati satwa liar di sepanjang sungai',
      'Trekking di hutan sekitar Ketambe',
    ],
    bestTime:
        'Saat debit air sedang. Hindari sungai ketika banjir atau setelah hujan deras di hulu.',
    access:
        'Dari Medan lewat darat menuju Kutacane dan Ketambe di Aceh Tenggara, sekitar 7 jam perjalanan.',
    facilities: [
      'Operator arung jeram lokal',
      'Penginapan dan homestay di Ketambe',
      'Pemandu wisata warga setempat',
    ],
    tips: [
      'Selalu pakai pelampung dan helm',
      'Pilih operator yang punya pemandu berpengalaman',
      'Jangan berteriak atau mengganggu satwa di tepi sungai',
    ],
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
    about:
        'Sungai Wampu mengalir dari dataran tinggi melewati hutan dan kebun di Langkat sebelum bermuara ke Selat Malaka. Alurnya panjang dan tepiannya banyak yang masih alami, cocok untuk susur sungai santai atau camping di pinggir sungai.',
    activities: [
      'Susur sungai',
      'Camping di tepi sungai',
      'Memancing',
      'Menikmati suasana kebun dan hutan sekitar',
    ],
    bestTime:
        'Musim kemarau saat debit air stabil. Jangan berkegiatan di sungai ketika hujan deras di hulu.',
    access:
        'Dari Medan ke Kabupaten Langkat sekitar 1 sampai 2 jam. Titik masuk ke sungai beragam, tanyakan ke operator atau warga setempat.',
    facilities: [
      'Fasilitas tergantung titik yang dikunjungi',
      'Bawa perlengkapan camping dan air minum sendiri',
    ],
    tips: [
      'Pakai pelampung untuk kegiatan di air',
      'Cek cuaca dan debit air sebelum berangkat',
      'Jangan meninggalkan sampah di tepi sungai',
    ],
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
    about:
        'Sungai Bah Bolon di Simalungun dikenal dengan airnya yang jernih dan bebatuan di tepiannya. Arusnya tidak terlalu deras di bagian tertentu sehingga nyaman untuk berendam dan piknik keluarga.',
    activities: [
      'Berendam dan bermain air',
      'Piknik keluarga',
      'Camping santai di tepi sungai',
    ],
    bestTime:
        'Musim kemarau saat air jernih dan arus tenang.',
    access:
        'Dari Medan menuju Kabupaten Simalungun lewat jalur Pematang Siantar, lalu ikuti petunjuk arah atau tanya warga. Cek peta digital untuk titik masuk terbaru.',
    facilities: [
      'Area tepi sungai untuk duduk dan tenda',
      'Fasilitas terbatas, siapkan perbekalan sendiri',
    ],
    tips: [
      'Awasi anak-anak saat bermain air',
      'Bebatuan licin, pakai alas kaki yang cocok',
      'Hindari sungai setelah hujan deras',
    ],
  ),
];

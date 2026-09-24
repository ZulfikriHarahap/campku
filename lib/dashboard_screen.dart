import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// KONSTANTA WARNA
// ─────────────────────────────────────────────
const Color kPrimary = Color(0xFF1B4D3E); // Earthy Dark Green
const Color kAccent = Color(0xFFD97706); // Soft Amber / Woody Gold
const Color kBackground = Color(0xFFF8F9FA); // Light Natural Beige
const Color kCardBg = Colors.white;
const Color kTextDark = Color(0xFF1A1A1A);
const Color kTextMuted = Color(0xFF7A7A7A);

// ─────────────────────────────────────────────
// MODEL DATA
// ─────────────────────────────────────────────
class Destination {
  final String name;
  final String location;
  final double rating;
  final String priceLabel;
  final String imageUrl;
  final String badge;
  final IconData badgeIcon;

  const Destination({
    required this.name,
    required this.location,
    required this.rating,
    required this.priceLabel,
    required this.imageUrl,
    required this.badge,
    required this.badgeIcon,
  });
}

// ─────────────────────────────────────────────
// DATA STATIS PER KATEGORI
// ─────────────────────────────────────────────
const List<Map<String, dynamic>> _categories = [
  {'label': 'Gunung', 'icon': Icons.terrain},
  {'label': 'Danau', 'icon': Icons.water},
  {'label': 'Air Terjun', 'icon': Icons.waves},
  {'label': 'Hutan', 'icon': Icons.forest},
  {'label': 'Sungai', 'icon': Icons.rowing},
];

const Map<String, List<Destination>> _destinationsByCategory = {
  'Gunung': [
    Destination(
      name: 'Gunung Sibayak',
      location: 'Karo, Sumatera Utara',
      rating: 4.8,
      priceLabel: 'Mulai Rp 25.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Mount_Sibayak.jpg/1280px-Mount_Sibayak.jpg',
      badge: 'Populer',
      badgeIcon: Icons.local_fire_department,
    ),
    Destination(
      name: 'Gunung Sibuatan',
      location: 'Karo, Sumatera Utara',
      rating: 4.6,
      priceLabel: 'Mulai Rp 20.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Sibuatan.jpg/1280px-Sibuatan.jpg',
      badge: 'Menantang',
      badgeIcon: Icons.fitness_center,
    ),
    Destination(
      name: 'Gunung Sinabung',
      location: 'Karo, Sumatera Utara',
      rating: 4.7,
      priceLabel: 'Mulai Rp 30.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b9/Sinabung_2010.jpg/1280px-Sinabung_2010.jpg',
      badge: 'Ikonik',
      badgeIcon: Icons.star,
    ),
  ],
  'Danau': [
    Destination(
      name: 'Danau Toba',
      location: 'Samosir, Sumatera Utara',
      rating: 4.9,
      priceLabel: 'Mulai Rp 15.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Lake_Toba_Caldera.jpg/1280px-Lake_Toba_Caldera.jpg',
      badge: 'Terlaris',
      badgeIcon: Icons.favorite,
    ),
    Destination(
      name: 'Danau Lau Kawar',
      location: 'Karo, Sumatera Utara',
      rating: 4.5,
      priceLabel: 'Mulai Rp 10.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Lau_Kawar.jpg/1280px-Lau_Kawar.jpg',
      badge: 'Tersembunyi',
      badgeIcon: Icons.explore,
    ),
    Destination(
      name: 'Danau Sidihoni',
      location: 'Samosir, Sumatera Utara',
      rating: 4.4,
      priceLabel: 'Mulai Rp 10.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f4/Sidihoni.jpg/1280px-Sidihoni.jpg',
      badge: 'Unik',
      badgeIcon: Icons.wb_sunny,
    ),
  ],
  'Air Terjun': [
    Destination(
      name: 'Air Terjun Sipiso-piso',
      location: 'Karo, Sumatera Utara',
      rating: 4.8,
      priceLabel: 'Mulai Rp 15.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Sipiso-piso_waterfall.jpg/800px-Sipiso-piso_waterfall.jpg',
      badge: 'Populer',
      badgeIcon: Icons.local_fire_department,
    ),
    Destination(
      name: 'Air Terjun Efrata',
      location: 'Dairi, Sumatera Utara',
      rating: 4.3,
      priceLabel: 'Mulai Rp 10.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Waterfall.jpg/800px-Waterfall.jpg',
      badge: 'Sejuk',
      badgeIcon: Icons.ac_unit,
    ),
    Destination(
      name: 'Air Terjun Binanga Bolon',
      location: 'Tapanuli Utara, Sumatera Utara',
      rating: 4.2,
      priceLabel: 'Mulai Rp 8.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/Waterfall_in_forest.jpg/800px-Waterfall_in_forest.jpg',
      badge: 'Alami',
      badgeIcon: Icons.eco,
    ),
  ],
  'Hutan': [
    Destination(
      name: 'Hutan Bahorok',
      location: 'Langkat, Sumatera Utara',
      rating: 4.7,
      priceLabel: 'Mulai Rp 20.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Bukit_Lawang_jungle.jpg/1280px-Bukit_Lawang_jungle.jpg',
      badge: 'Populer',
      badgeIcon: Icons.local_fire_department,
    ),
    Destination(
      name: 'Taman Nasional Gunung Leuser',
      location: 'Langkat, Sumatera Utara',
      rating: 4.9,
      priceLabel: 'Mulai Rp 50.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Gunung_Leuser.jpg/1280px-Gunung_Leuser.jpg',
      badge: 'Warisan UNESCO',
      badgeIcon: Icons.star,
    ),
    Destination(
      name: 'Hutan Mangrove Serdang',
      location: 'Serdang Bedagai, Sumatera Utara',
      rating: 4.2,
      priceLabel: 'Mulai Rp 10.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Mangrove_forest.jpg/1280px-Mangrove_forest.jpg',
      badge: 'Unik',
      badgeIcon: Icons.spa,
    ),
  ],
  'Sungai': [
    Destination(
      name: 'Sungai Alas',
      location: 'Langkat, Sumatera Utara',
      rating: 4.6,
      priceLabel: 'Mulai Rp 35.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/River_rafting.jpg/1280px-River_rafting.jpg',
      badge: 'Arung Jeram',
      badgeIcon: Icons.kayaking,
    ),
    Destination(
      name: 'Sungai Wampu',
      location: 'Langkat, Sumatera Utara',
      rating: 4.4,
      priceLabel: 'Mulai Rp 30.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a1/River_in_jungle.jpg/1280px-River_in_jungle.jpg',
      badge: 'Petualangan',
      badgeIcon: Icons.directions_boat,
    ),
    Destination(
      name: 'Sungai Bah Bolon',
      location: 'Simalungun, Sumatera Utara',
      rating: 4.3,
      priceLabel: 'Mulai Rp 15.000',
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Clear_river.jpg/1280px-Clear_river.jpg',
      badge: 'Jernih',
      badgeIcon: Icons.water_drop,
    ),
  ],
};

// ─────────────────────────────────────────────
// DASHBOARD SCREEN (StatefulWidget)
// ─────────────────────────────────────────────

/// Widget utama dashboard. Menggunakan [StatefulWidget] agar
/// perubahan kategori aktif dapat memperbarui tampilan via [setState].
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Menyimpan indeks kategori yang sedang aktif (default: 0 = Gunung)
  int _selectedCategoryIndex = 0;

  /// Mengembalikan daftar destinasi sesuai kategori yang dipilih.
  List<Destination> get _currentDestinations {
    final label = _categories[_selectedCategoryIndex]['label'] as String;
    return _destinationsByCategory[label] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      // ── AppBar ──────────────────────────────
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header & Greeting
            _buildHeader(),
            // 2. Search Bar
            _buildSearchBar(),
            const SizedBox(height: 24),
            // 3. Kategori Wisata
            _buildSectionTitle('Kategori Wisata Alam'),
            const SizedBox(height: 12),
            _buildCategoryChips(),
            const SizedBox(height: 24),
            // 4. Destinasi Populer
            _buildSectionTitle('Destinasi Populer'),
            const SizedBox(height: 4),
            _buildSectionSubtitle(),
            const SizedBox(height: 16),
            _buildDestinationGrid(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      // ── Bottom Nav Bar (statis/dekoratif) ───
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ── WIDGET BUILDERS ───────────────────────

  /// [AppBar] dengan logo & ikon notifikasi + profil.
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kPrimary,
      elevation: 0,
      title: Row(
        children: [
          const Icon(Icons.terrain, color: kAccent, size: 26),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Camp',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                TextSpan(
                  text: 'Ku',
                  style: TextStyle(
                    color: kAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Ikon notifikasi (dekoratif)
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        // Avatar profil (dekoratif)
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: kAccent.withAlpha(51),
            child: const Text(
              'P',
              style: TextStyle(
                color: kAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Section header bergradien dengan teks sapaan & deskripsi singkat.
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPrimary, Color(0xFF2D6B57)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris sapaan + cuaca/hari
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Halo, Petualang! 🌲',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Mau jelajah alam mana hari ini?',
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Badge cuaca dekoratif
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(51)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wb_sunny, color: kAccent, size: 18),
                    SizedBox(width: 4),
                    Text(
                      '28°C',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Statistik ringkasan
          Row(
            children: [
              _buildStatBadge(Icons.place, '50+', 'Destinasi'),
              const SizedBox(width: 12),
              _buildStatBadge(Icons.category, '5', 'Kategori'),
              const SizedBox(width: 12),
              _buildStatBadge(Icons.star, '4.7', 'Rata-rata'),
            ],
          ),
        ],
      ),
    );
  }

  /// Badge statistik kecil di dalam header.
  Widget _buildStatBadge(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(51)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: kAccent, size: 16),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withAlpha(178),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Search bar statis dengan ikon kaca pembesar & filter.
  Widget _buildSearchBar() {
    return Transform.translate(
      // Naikkan sedikit agar overlap dengan header (efek kartu melayang)
      offset: const Offset(0, -16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: kCardBg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: kTextMuted, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cari destinasi wisata alam...',
                  style: TextStyle(
                    color: kTextMuted.withAlpha(178),
                    fontSize: 14,
                  ),
                ),
              ),
              // Divider vertikal
              Container(width: 1, height: 28, color: const Color(0xFFE5E5E5)),
              // Tombol filter
              InkWell(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      const Icon(Icons.tune, color: kPrimary, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        'Filter',
                        style: TextStyle(
                          color: kPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Judul section dengan style konsisten.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          color: kTextDark,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Subjudul kecil di bawah "Destinasi Populer".
  Widget _buildSectionSubtitle() {
    final label = _categories[_selectedCategoryIndex]['label'] as String;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        'Menampilkan destinasi kategori: $label',
        style: const TextStyle(color: kTextMuted, fontSize: 13),
      ),
    );
  }

  /// Horizontal scroll filter chips untuk memilih kategori.
  ///
  /// Menggunakan [ListView.builder] horizontal dengan [ChoiceChip]
  /// agar hanya satu kategori bisa aktif sekaligus.
  Widget _buildCategoryChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          final cat = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              avatar: Icon(
                cat['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : kPrimary,
              ),
              label: Text(
                cat['label'] as String,
                style: TextStyle(
                  color: isSelected ? Colors.white : kPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              selectedColor: kPrimary,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? kPrimary : const Color(0xFFDDE5E2),
                width: 1.2,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              onSelected: (_) {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Grid 2 kolom berisi kartu destinasi.
  ///
  /// Menggunakan [GridView.builder] dengan [ShrinkWrap] + [NeverScrollableScrollPhysics]
  /// karena sudah berada di dalam [SingleChildScrollView].
  Widget _buildDestinationGrid() {
    final destinations = _currentDestinations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: destinations.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) {
          return _buildDestinationCard(destinations[index]);
        },
      ),
    );
  }

  /// Kartu destinasi individual (Nature Card).
  ///
  /// Berisi: gambar hero, badge, nama, lokasi, rating, dan harga.
  Widget _buildDestinationCard(Destination dest) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gambar + Badge ──────────────────
          Expanded(
            child: Stack(
              children: [
                // Gambar destinasi
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Image.network(
                    dest.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    // Placeholder saat loading
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFE8F0EC),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    // Fallback ilustrasi alam jika gambar gagal dimuat
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2D6B57), Color(0xFF1B4D3E)],
                          ),
                        ),
                        child: Stack(
                          children: [
                            // Lingkaran dekoratif latar
                            Positioned(
                              top: -18,
                              right: -18,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(15),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -12,
                              left: -12,
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withAlpha(10),
                                ),
                              ),
                            ),
                            // Konten tengah
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Ikon gunung berlapis
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(
                                        Icons.landscape,
                                        color: Colors.white.withAlpha(40),
                                        size: 52,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(top: 6),
                                        child: Icon(
                                          Icons.terrain,
                                          color: kAccent,
                                          size: 36,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Foto Alam 🌿',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Gradien gelap di bawah gambar untuk teks
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(102),
                        ],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                // Badge atas kiri
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(dest.badgeIcon, color: Colors.white, size: 11),
                        const SizedBox(width: 3),
                        Text(
                          dest.badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Ikon bookmark atas kanan
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(230),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: kPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Info Destinasi ──────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama tempat
                Text(
                  dest.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: kTextDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                // Lokasi
                Row(
                  children: [
                    const Icon(Icons.location_on, color: kAccent, size: 12),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        dest.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextMuted,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating & Harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating bintang
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: kAccent.withAlpha(26),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: kAccent, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            dest.rating.toString(),
                            style: const TextStyle(
                              color: kAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Harga
                    Flexible(
                      child: Text(
                        dest.priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom navigation bar statis (dekoratif, tanpa navigasi aktif).
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_rounded, 'Beranda', isActive: true),
              _buildNavItem(Icons.explore_outlined, 'Jelajahi'),
              _buildNavItem(Icons.favorite_border, 'Favorit'),
              _buildNavItem(Icons.person_outline, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  /// Item individual pada bottom nav bar.
  Widget _buildNavItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? kPrimary.withAlpha(26) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isActive ? kPrimary : kTextMuted,
            size: 24,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: isActive ? kPrimary : kTextMuted,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:campku/theme/app_theme.dart';
import 'package:campku/services/auth_service.dart';
import 'package:campku/widgets/destination_image.dart';
import 'package:campku/data/destinations_data.dart';
import 'package:campku/screens/auth/login_screen.dart';
import 'package:campku/screens/dashboard/destination_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _tab = 0; // 0 = Beranda, 1 = Favorit, 2 = Profil
  int _category = 0; // 0 = Semua, selanjutnya urutan kCategories + 1
  String _query = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _resultsKey = GlobalKey(); // penanda header daftar hasil

  AppUser? get _user => AuthService.currentUser;
  Set<String> get _favorites => AuthService.favorites;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── STATE HELPERS ─────────────────────────

  List<Destination> get _filtered {
    final q = _query.trim().toLowerCase();
    return kDestinations.where((d) {
      final inCategory =
          _category == 0 || d.category == kCategories[_category - 1].label;
      final inQuery = q.isEmpty ||
          d.name.toLowerCase().contains(q) ||
          d.location.toLowerCase().contains(q) ||
          d.category.toLowerCase().contains(q);
      return inCategory && inQuery;
    }).toList();
  }

  void _toggleFavorite(Destination d) {
    setState(() {
      if (!_favorites.remove(d.slug)) _favorites.add(d.slug);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  /// Ketuk kategori untuk memilih, ketuk lagi untuk kembali ke semua.
  void _selectCategory(int value) {
    final selecting = _category != value;
    setState(() => _category = selecting ? value : 0);
    if (!selecting) return;
    // Setelah daftar terfilter dibangun, gulir ke hasilnya.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _resultsKey.currentContext;
      if (!mounted || ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
    });
  }

  Future<void> _openDetail(Destination d) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DestinationDetailScreen(destination: d),
      ),
    );
    // Status favorit bisa berubah di halaman detail.
    if (mounted) setState(() {});
  }

  Future<void> _confirmLogout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text('Kamu bisa masuk kembali kapan saja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    AuthService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ── BUILD ─────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: [_homeTab(), _favoritesTab(), _profileTab()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          indicatorColor: kPrimary.withAlpha(30),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: kPrimary),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: _favorites.isNotEmpty,
                label: Text('${_favorites.length}'),
                child: const Icon(Icons.favorite_border),
              ),
              selectedIcon: const Icon(Icons.favorite, color: kPrimary),
              label: 'Favorit',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: kPrimary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  /// Header hijau dengan sudut bawah membulat, dipakai di ketiga tab.
  Widget _headerShell({required Widget child, double bottom = 24}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 12,
        20,
        bottom,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPrimary, kPrimaryLight],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: child,
    );
  }

  // ── TAB BERANDA ───────────────────────────

  Widget _homeTab() {
    final items = _filtered;
    final query = _query.trim();
    final title = query.isNotEmpty
        ? 'Hasil untuk "$query"'
        : (_category == 0
            ? 'Semua destinasi'
            : kCategories[_category - 1].label);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _homeHeader()),
        SliverToBoxAdapter(child: _categoryCards()),
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: _resultsKey,
            child: _sectionHeader(
              title,
              '${items.length} tempat',
              action: _category == 0 || query.isNotEmpty
                  ? null
                  : TextButton(
                      onPressed: () => setState(() => _category = 0),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Lihat semua'),
                    ),
            ),
          ),
        ),
        if (items.isEmpty)
          SliverToBoxAdapter(
            child: _emptyState(
              icon: Icons.search_off,
              title: 'Destinasi tidak ditemukan',
              message: 'Coba kata kunci lain atau pilih kategori Semua.',
              actionLabel: 'Reset pencarian',
              onAction: () {
                _clearSearch();
                setState(() => _category = 0);
              },
            ),
          )
        else
          _grid(items),
      ],
    );
  }

  Widget _homeHeader() {
    final user = _user;
    return _headerShell(
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terrain, color: kAccent, size: 24),
              const SizedBox(width: 8),
              const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Camp',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(text: 'Ku', style: TextStyle(color: kAccent)),
                  ],
                ),
              ),
              const Spacer(),
              if (user?.isAdmin ?? false)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Semantics(
                button: true,
                label: 'Buka profil',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _tab = 2),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withAlpha(40),
                      child: Text(
                        user?.initial ?? 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Halo, ${user?.firstName ?? 'Petualang'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Mau camping di mana akhir pekan ini?',
            style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 14),
          ),
          const SizedBox(height: 18),
          _searchField(),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _query = v),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Cari gunung, danau, atau lokasi',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                tooltip: 'Hapus pencarian',
                icon: const Icon(Icons.close),
                onPressed: _clearSearch,
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// Daftar kategori berupa kartu horizontal yang tersusun ke bawah.
  Widget _categoryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pilih kategori',
            style:
                Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < kCategories.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _categoryCard(i),
          ],
        ],
      ),
    );
  }

  Widget _categoryCard(int index) {
    final c = kCategories[index];
    final selected = _category == index + 1;
    final inCategory = kDestinations.where((d) => d.category == c.label);
    final count = inCategory.length;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Kategori ${c.label}, $count destinasi',
      child: Card(
        elevation: selected ? 3 : 1,
        color: kCardBg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black26,
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? kPrimary : kBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: () => _selectCategory(index + 1),
          child: SizedBox(
            height: 96,
            child: Row(
              children: [
                SizedBox(
                  width: 112,
                  height: double.infinity,
                  child: DestinationImage(destination: inCategory.first),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(c.icon, size: 18, color: kPrimary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                c.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: kTextDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          c.tagline,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: kTextMuted,
                            fontSize: 12.5,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$count destinasi',
                          style: const TextStyle(
                            color: kAccentText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    selected ? Icons.check_circle : Icons.chevron_right,
                    color: selected ? kPrimary : kTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String trailing, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
            ),
          ),
          Text(trailing, style: const TextStyle(color: kTextMuted)),
          if (action != null) action,
        ],
      ),
    );
  }

  // ── TAB FAVORIT ───────────────────────────

  Widget _favoritesTab() {
    final items =
        kDestinations.where((d) => _favorites.contains(d.slug)).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _headerShell(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Favorit saya',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items.isEmpty
                      ? 'Belum ada destinasi tersimpan'
                      : '${items.length} destinasi tersimpan',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _emptyState(
              icon: Icons.favorite_border,
              title: 'Belum ada favorit',
              message: 'Ketuk ikon hati pada destinasi untuk menyimpannya di sini.',
              actionLabel: 'Jelajahi destinasi',
              onAction: () => setState(() => _tab = 0),
            ),
          )
        else
          _grid(items),
      ],
    );
  }

  // ── TAB PROFIL ────────────────────────────

  Widget _profileTab() {
    final user = _user;
    final admin = user?.isAdmin ?? false;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _headerShell(
          bottom: 28,
          child: Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: kAccent,
                child: Text(
                  user?.initial ?? 'P',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Tamu',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.email ?? 'Belum masuk',
                style: TextStyle(color: Colors.white.withAlpha(220)),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      admin ? Icons.admin_panel_settings : Icons.hiking,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user?.roleLabel ?? 'Tamu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _statTile(
                      Icons.place_outlined,
                      '${kDestinations.length}',
                      'Destinasi tersedia',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statTile(
                      Icons.favorite_border,
                      '${_favorites.length}',
                      'Favorit saya',
                    ),
                  ),
                ],
              ),
              if (admin) ...[
                const SizedBox(height: 24),
                Text(
                  'Pengguna terdaftar',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 10),
                _userList(),
              ],
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text('Keluar'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  foregroundColor: kError,
                  side: BorderSide(color: kError.withAlpha(120)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: kTextMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _userList() {
    final users = AuthService.users;
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: kBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < users.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: kBorder),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: kPrimary.withAlpha(30),
                child: Text(
                  users[i].initial,
                  style: const TextStyle(
                    color: kPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                users[i].name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                users[i].email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                users[i].roleLabel,
                style: TextStyle(
                  color: users[i].isAdmin ? kAccentText : kTextMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── KARTU & GRID DESTINASI ────────────────

  Widget _grid(List<Destination> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      sliver: SliverGrid.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.56,
        ),
        itemCount: items.length,
        itemBuilder: (context, i) => _destinationCard(items[i]),
      ),
    );
  }

  Widget _destinationCard(Destination d) {
    final fav = _favorites.contains(d.slug);
    return Card(
      elevation: 1.5,
      color: kCardBg,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => _showDetail(d),
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
                    child: _favoriteButton(d, fav),
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
                      onPressed: () => _openDetail(d),
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

  Widget _favoriteButton(Destination d, bool fav) {
    return IconButton(
      tooltip: fav ? 'Hapus dari favorit' : 'Simpan ke favorit',
      onPressed: () => _toggleFavorite(d),
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

  // ── DETAIL DESTINASI ──────────────────────

  void _showDetail(Destination d) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: kBackground,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            final fav = _favorites.contains(d.slug);
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 240,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        DestinationImage(destination: d),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            tooltip: 'Tutup',
                            onPressed: () => Navigator.pop(sheetContext),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withAlpha(235),
                            ),
                            icon: const Icon(Icons.close),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.name,
                          style: Theme.of(ctx)
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
                            _infoPill(
                              Icons.star_rounded,
                              '${d.rating.toStringAsFixed(1)} rating',
                            ),
                            _infoPill(d.categoryIcon, d.category),
                            _infoPill(d.badgeIcon, d.badge),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          d.description,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.55,
                            color: Color(0xFF3A3A3A),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
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
                              const Text(
                                'Harga mulai dari',
                                style: TextStyle(color: kTextMuted),
                              ),
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
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _openDetail(d);
                          },
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Lihat selengkapnya'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            foregroundColor: kPrimary,
                            side: BorderSide(color: kPrimary.withAlpha(120)),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () {
                            _toggleFavorite(d);
                            setSheet(() {});
                          },
                          icon: Icon(
                            fav ? Icons.favorite : Icons.favorite_border,
                          ),
                          label: Text(
                            fav ? 'Hapus dari favorit' : 'Simpan ke favorit',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _infoPill(IconData icon, String text) {
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

  // ── EMPTY STATE ───────────────────────────

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: kTextMuted),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: kTextMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

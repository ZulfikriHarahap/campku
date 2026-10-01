# CampKu

Aplikasi Flutter untuk menjelajahi destinasi camping, memesan tenda, dan mengelola booking. Proyek demo tanpa backend — semua data (akun, destinasi, booking) disimpan di memori dan kembali ke data contoh setiap aplikasi ditutup.

## Fitur utama

**Pengguna**
- Jelajahi destinasi lewat kartu kategori, atau cari lewat kata kunci.
- Lihat detail destinasi → camp → tipe tenda (harga, kapasitas, stok).
- Simpan destinasi favorit.
- Booking tenda: pilih tanggal check-in & jumlah malam, lalu bayar (simulasi satu tombol).
- **Stok dihitung per tanggal** — tenda tetap bisa dibooking di tanggal lain meski penuh di tanggal tertentu.
- Pantau status booking (Menunggu / Disetujui / Ditolak) lewat tiket digital di tab Tiket.
- Profil: edit nama, ubah kata sandi, serta halaman Bantuan & FAQ dan Tentang Aplikasi.

**Admin**
- CRUD destinasi, camp, dan tipe tenda (nama, harga, kapasitas, stok).
- Setujui atau tolak booking yang masuk; menolak otomatis membuka kembali stok tanggalnya.
- Tandai booking **Selesai** dari dalam tiket — menghapusnya dari riwayat dan mengembalikan stok tanggalnya seperti semula.

## Akun demo

| Peran    | Email              | Kata sandi |
|----------|--------------------|------------|
| Admin    | admin@campku.id    | admin123   |
| Pengguna | user@campku.id     | user123    |

Akun pengguna baru juga bisa dibuat lewat halaman **Daftar**. Akun admin bersifat statis.

## Teknologi

- Flutter / Dart, state management sederhana dengan `ChangeNotifier` (tanpa package tambahan).
- Belum terhubung ke backend/database sungguhan — cocok untuk demo & prototipe.

## Menjalankan

```bash
flutter pub get
flutter run
```

## Struktur folder singkat

```
lib/
├── data/        # Model data (Destination, Camp, TentType, Booking, AppUser)
├── services/    # Logika bisnis & penyimpanan di memori (ChangeNotifier)
├── screens/     # Tampilan per fitur (auth, dashboard, booking, admin, profile)
├── widgets/     # Komponen UI yang dipakai berulang
└── theme/       # Warna, tema, dan dekorasi input bersama
```

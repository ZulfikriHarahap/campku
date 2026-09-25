# CampKu

Aplikasi Flutter untuk menjelajahi wisata alam Sumatera Utara dan camp di dalamnya:
gunung, danau, air terjun, hutan, dan sungai. Mengikuti alur mini SRS:
**Wisata → Destinasi → Camp → Tenda → Tanggal → Booking**.

## Fitur

**Semua pengguna**
- Masuk sebagai **Pengguna** atau **Admin** (akun admin statis); pendaftaran hanya untuk pengguna (FR-01)
- Beranda dengan pencarian dan kartu kategori wisata (FR-02)
- Daftar destinasi per kategori dan halaman detailnya (FR-03)
- Daftar camp di setiap destinasi (FR-04), lalu daftar tipe tenda di setiap camp beserta
  harga, kapasitas, dan stok (FR-05)
- Daftar favorit per akun, dan profil

**Khusus admin — CRUD (FR-08, FR-09)**
- Tab **Kelola**: cari, filter kategori, tambah, edit, dan hapus **destinasi**
- Di halaman detail destinasi: tambah, edit, dan hapus **camp**
- Di halaman detail camp: tambah, edit, dan hapus **tipe tenda** (nama, harga, kapasitas, stok)
- Menghapus destinasi ikut menghapus camp dan tipe tendanya (cascading); menghapus camp ikut
  menghapus tipe tendanya

## Belum dibuat (di luar cakupan pengerjaan saat ini)

Sesuai mini SRS, bagian berikut belum diimplementasikan dan jadi langkah selanjutnya:
- **Alur booking** (FR-06, FR-07): pilih tanggal, hitung total harga, simulasi pembayaran, dan
  lihat tiket/riwayat booking. Tombol "Booking Tenda" di halaman tipe tenda masih menampilkan
  info sementara.
- **Admin melihat data booking** (FR-10) — menyusul setelah alur booking ada.
- **Chatbot rekomendasi** (FR-11): input kategori + jumlah orang + budget → rekomendasi camp
  & tipe tenda dari data lokal.
- **Penyimpanan permanen dengan `sqflite`** dan sesi login dengan `shared_preferences` (NFR-02
  sebagian). Saat ini semua data (akun, destinasi, camp, tipe tenda) hanya di memori dan
  kembali ke kondisi awal setiap aplikasi ditutup.
- **Password ter-hash** (NFR-02) — saat ini kata sandi disimpan apa adanya untuk demo.

## Akun demo
| Peran | Email | Kata sandi |
| --- | --- | --- |
| Pengguna | user@campku.id | user123 |
| Admin | admin@campku.id | admin123 |

Akun admin bersifat statis (tetap) dan tidak bisa didaftarkan lewat aplikasi.

## Model data

Mengikuti "Data Utama" pada mini SRS:

| Entitas | Field | Relasi |
| --- | --- | --- |
| Destinasi | nama, kategori, deskripsi | — |
| Camp | nama, destinasi terkait | → Destinasi |
| Tipe Tenda | nama, harga, kapasitas, stok | → Camp |

`slug`/`id` pada tiap entitas adalah kunci internal aplikasi (bukan bagian dari data SRS),
dipakai untuk relasi, favorit, dan nama file foto.

## Mengelola data (admin)

1. Masuk sebagai Admin.
2. **Destinasi**: tab **Kelola** → tombol `Tambah`, atau menu titik tiga pada tiap baris untuk
   edit/hapus. Foto (opsional): simpan sebagai `assets/images/<slug>.jpg`; slug tampil di form.
   Tanpa foto, ilustrasi lanskap sesuai kategori akan ditampilkan.
3. **Camp**: buka detail sebuah destinasi → tombol `Camp` untuk menambah, menu titik tiga pada
   tiap camp untuk edit/hapus.
4. **Tipe tenda**: buka detail sebuah camp → tombol `Tenda` untuk menambah, menu titik tiga pada
   tiap tipe tenda untuk edit/hapus.

## Struktur `lib/`
```
lib/
├── main.dart                        Titik masuk aplikasi
├── theme/
│   └── app_theme.dart                Warna, tema, dan dekorasi field
├── data/
│   ├── destinations_data.dart        Kategori & data statis Destinasi (FR-02, FR-03)
│   ├── camp_data.dart                Model & data statis Camp (FR-04)
│   └── tent_data.dart                Model & data statis Tipe Tenda (FR-05)
├── services/                         Semua penyimpanan CRUD (ChangeNotifier, in-memory)
│   ├── auth_service.dart             Login, register, role, dan favorit
│   ├── destination_service.dart      CRUD destinasi + cascade hapus camp
│   ├── camp_service.dart             CRUD camp + cascade hapus tipe tenda
│   └── tent_service.dart             CRUD tipe tenda
├── widgets/
│   ├── destination_image.dart        Foto destinasi + ilustrasi cadangan
│   └── destination_card.dart         Kartu destinasi (dipakai ulang)
└── screens/
    ├── auth/
    │   ├── auth_layout.dart          Kerangka & validator login/register
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── admin/
    │   ├── admin_destinations_screen.dart  Tab Kelola: daftar + tambah/edit/hapus destinasi
    │   ├── destination_form_screen.dart    Form tambah/edit destinasi
    │   ├── camp_form_screen.dart           Form tambah/edit camp
    │   ├── tent_form_screen.dart           Form tambah/edit tipe tenda
    │   └── admin_actions.dart              Buka form & dialog konfirmasi hapus (3 entitas)
    └── dashboard/
        ├── dashboard_screen.dart     Beranda, Favorit, Kelola (admin), dan Profil
        ├── category_screen.dart      Daftar destinasi per kategori
        ├── destination_detail_screen.dart  Info destinasi + daftar camp
        └── camp_detail_screen.dart   Daftar tipe tenda + tombol booking (placeholder)
```

## Menjalankan
```
flutter pub get
flutter run
flutter test
```

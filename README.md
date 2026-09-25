# CampKu

Aplikasi Flutter untuk menjelajahi wisata alam Sumatera Utara dan camp di dalamnya:
gunung, danau, air terjun, hutan, dan sungai. Mengikuti alur mini SRS:
**Wisata → Destinasi → Camp → Tenda → Tanggal → Booking → Pembayaran → Persetujuan Admin**.

Proyek sudah dilengkapi **data contoh** (14 destinasi wisata Sumatera Utara beserta camp
dan tipe tendanya) sehingga bisa langsung dicoba tanpa mengisi data lebih dulu. Admin tetap
bisa menambah, mengubah, atau menghapus data ini kapan saja lewat CRUD.

## Fitur

**Pengguna**
- Masuk sebagai **Pengguna** atau **Admin**; pendaftaran hanya untuk pengguna (FR-01)
- Beranda dengan pencarian dan kartu kategori wisata (FR-02)
- Daftar destinasi per kategori dan halaman detailnya (FR-03)
- Daftar camp di setiap destinasi (FR-04), lalu daftar tipe tenda di setiap camp beserta
  harga, kapasitas, dan stok (FR-05)
- **Booking**: pilih tanggal check-in & jumlah malam → total harga dihitung otomatis (FR-05)
- **Simulasi pembayaran**: konfirmasi satu tombol, langsung ditandai lunas (FR-06)
- **Tiket**: bukti booking dengan status (Menunggu persetujuan / Disetujui / Ditolak);
  tab "Tiket" menyimpan riwayat booking milik akun (FR-07)
- Daftar favorit per akun, dan profil

**Admin — CRUD (FR-08, FR-09)**
- Tab **Kelola**: cari, filter kategori, tambah, edit, dan hapus **destinasi**
- Di halaman detail destinasi: tambah, edit, dan hapus **camp**
- Di halaman detail camp: tambah, edit, dan hapus **tipe tenda** (nama, harga, kapasitas, stok)
- Menghapus destinasi ikut menghapus camp dan tipe tendanya (cascading); menghapus camp ikut
  menghapus tipe tendanya

**Admin — Persetujuan booking (FR-10)**
- Tab **Booking**: seluruh data booking dari semua pengguna, dengan filter status
- **Setujui** atau **Tolak** booking yang masih menunggu; menolak booking mengembalikan
  stok tipe tenda terkait (ekstensi di luar FR-10 dasar, sesuai permintaan: booking perlu
  disetujui admin sebelum final)
- Admin **tidak bisa membuat booking untuk dirinya sendiri** — tombol "Booking Tenda" di
  halaman detail camp hanya tampil untuk peran Pengguna. Peran admin dibatasi pada
  mengelola data (destinasi/camp/tenda) dan menyetujui/menolak booking milik pengguna.

## Belum dibuat (di luar cakupan pengerjaan saat ini)

- **Chatbot rekomendasi** (FR-11): input kategori + jumlah orang + budget → rekomendasi camp
  & tipe tenda dari data lokal.
- **Penyimpanan permanen dengan `sqflite`** dan sesi login dengan `shared_preferences`. Saat
  ini akun yang didaftarkan, booking baru, dan perubahan data lewat CRUD admin hanya
  tersimpan di memori dan kembali ke data contoh awal setiap aplikasi ditutup.
- **Password ter-hash** (NFR-02) — saat ini kata sandi disimpan apa adanya untuk demo.
- **Payment gateway asli** — memang di luar cakupan SRS; pembayaran murni simulasi satu
  tombol tanpa provider pembayaran sungguhan.
- **Foto destinasi asli** — folder `assets/images/` masih kosong; setiap destinasi tanpa
  foto menampilkan ilustrasi lanskap sesuai kategorinya.

## Akun

Aplikasi sudah menyediakan dua akun contoh saat pertama kali dijalankan:

| Peran | Email | Kata sandi |
| --- | --- | --- |
| Admin | admin@campku.id | admin123 |
| Pengguna (contoh) | user@campku.id | user123 |

Akun admin bersifat statis (tetap) dan tidak bisa didaftarkan ulang lewat aplikasi. Akun
pengguna baru bisa dibuat sendiri lewat halaman **Daftar**.

## Model data

Mengikuti "Data Utama" pada mini SRS (kolom `id`/`slug` adalah kunci internal aplikasi untuk
relasi, favorit, dan foto — bukan bagian dari data SRS):

| Entitas | Field | Relasi |
| --- | --- | --- |
| Destinasi | nama, kategori, deskripsi | — |
| Camp | nama, destinasi terkait | → Destinasi |
| Tipe Tenda | nama, harga, kapasitas, stok | → Camp |
| Booking | user, camp, tipe tenda, tanggal, jumlah malam, total harga, status pembayaran, status persetujuan | → Camp, Tipe Tenda |

Data contoh saat ini: 14 destinasi (5 kategori: Gunung, Danau, Air Terjun, Hutan, Sungai),
17 camp, dan beberapa tipe tenda per camp.

## Alur booking (khusus peran Pengguna)

1. Buka destinasi → pilih camp → pilih tipe tenda → **Booking Tenda**.
2. Pilih tanggal check-in dan jumlah malam; total harga terhitung otomatis.
3. Tinjau ringkasan → **Bayar Sekarang** (simulasi, langsung sukses).
4. Tiket terbit dengan status **Menunggu persetujuan**; stok tipe tenda berkurang 1.
5. Admin membuka tab **Booking** → **Setujui** atau **Tolak** (menolak mengembalikan stok).
6. Pengguna memantau status tiketnya lewat tab **Tiket**.

## Mengelola data (khusus peran Admin)

1. Masuk sebagai Admin.
2. **Destinasi**: tab **Kelola** → tombol `Tambah`, atau menu titik tiga pada tiap baris untuk
   edit/hapus. Foto (opsional): simpan sebagai `assets/images/<slug>.jpg`; slug tampil di form.
   Tanpa foto, ilustrasi lanskap sesuai kategori akan ditampilkan.
3. **Camp**: buka detail sebuah destinasi → tombol `Camp` untuk menambah, menu titik tiga pada
   tiap camp untuk edit/hapus.
4. **Tipe tenda**: buka detail sebuah camp → tombol `Tenda` untuk menambah, menu titik tiga pada
   tiap tipe tenda untuk edit/hapus. Halaman ini tidak menampilkan tombol booking untuk admin.
5. **Booking**: tab **Booking** → **Setujui**/**Tolak** pada booking yang menunggu.

## Struktur `lib/`
```
lib/
├── main.dart                        Titik masuk aplikasi
├── theme/
│   └── app_theme.dart                Warna, tema, dan dekorasi field
├── data/
│   ├── destinations_data.dart        Kategori & model Destinasi (FR-02, FR-03) + 14 data contoh
│   ├── camp_data.dart                Model Camp (FR-04) + 17 data contoh
│   ├── tent_data.dart                Model Tipe Tenda (FR-05, FR-09) + data contoh per camp
│   └── booking_data.dart             Model Booking + status persetujuan (FR-06, FR-07)
├── services/                         Semua penyimpanan CRUD (ChangeNotifier, in-memory)
│   ├── auth_service.dart             Login, register, role, dan favorit
│   ├── destination_service.dart      CRUD destinasi + cascade hapus camp
│   ├── camp_service.dart             CRUD camp + cascade hapus tipe tenda
│   ├── tent_service.dart             CRUD tipe tenda + penyesuaian stok
│   └── booking_service.dart          Buat booking, setujui/tolak (FR-06, FR-07, FR-10)
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
    │   ├── admin_bookings_screen.dart      Tab Booking: lihat semua + setujui/tolak
    │   ├── destination_form_screen.dart    Form tambah/edit destinasi
    │   ├── camp_form_screen.dart           Form tambah/edit camp
    │   ├── tent_form_screen.dart           Form tambah/edit tipe tenda
    │   └── admin_actions.dart              Buka form & dialog konfirmasi hapus (3 entitas)
    ├── booking/
    │   ├── booking_screen.dart       Langkah 1: pilih tanggal & malam, lihat total (hanya Pengguna)
    │   ├── payment_screen.dart       Langkah 2: ringkasan + simulasi bayar
    │   ├── ticket_screen.dart        Tiket/bukti booking dengan status
    │   └── my_bookings_screen.dart   Tab Tiket: riwayat booking milik pengguna
    └── dashboard/
        ├── dashboard_screen.dart     Navigasi bawah: beda susunan tab untuk Pengguna vs Admin
        ├── category_screen.dart      Daftar destinasi per kategori
        ├── destination_detail_screen.dart  Info destinasi + daftar camp
        └── camp_detail_screen.dart   Daftar tipe tenda; tombol Booking Tenda hanya untuk Pengguna
```

## Navigasi bawah

| Peran | Tab |
| --- | --- |
| Pengguna | Beranda, Favorit, **Tiket**, Profil |
| Admin | **Kelola**, **Booking**, Profil |

Admin tidak punya tab Beranda/Favorit — perannya dibatasi pada mengelola data destinasi/
camp/tenda (tab Kelola) dan menyetujui/menolak booking pengguna (tab Booking), bukan
menjelajah atau membuat booking sendiri.

## Menjalankan
```
flutter pub get
flutter run
flutter test
```

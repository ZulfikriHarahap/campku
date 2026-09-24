# CampKu

Aplikasi Flutter untuk menjelajahi destinasi camping alam di Sumatera Utara dan membooking tenda:
gunung, danau, air terjun, hutan, dan sungai.

## Fitur
- Masuk sebagai **Pengguna** atau **Admin** (akun admin statis); pendaftaran hanya untuk pengguna
- Beranda dengan pencarian dan kartu kategori; ketuk kategori untuk membuka halaman daftar destinasinya
- Detail destinasi, tombol "Lihat selengkapnya", dan daftar favorit per akun
- Profil, dan daftar pengguna terdaftar khusus admin
- **CRUD destinasi (khusus admin)**: tab **Kelola** untuk melihat, mencari, memfilter, menambah,
  mengedit, dan menghapus destinasi; edit/hapus juga tersedia di halaman detail

## Akun demo
| Peran | Email | Kata sandi |
| --- | --- | --- |
| Pengguna | user@campku.id | user123 |
| Admin | admin@campku.id | admin123 |

Akun admin bersifat statis (tetap) dan tidak bisa didaftarkan lewat aplikasi.

> Data akun dan perubahan destinasi oleh admin disimpan di memori (tanpa backend), jadi semuanya
> kembali ke data awal saat aplikasi ditutup. Untuk menyimpan permanen, ganti isi `add`, `update`,
> dan `delete` di `services/destination_service.dart` dengan `shared_preferences`/SQLite/Firebase.

## Mengelola destinasi (admin)
1. Masuk sebagai Admin, lalu buka tab **Kelola**.
2. **Tambah**: tombol `Tambah` -> isi form -> simpan. Destinasi baru masuk ke akhir kategorinya.
3. **Edit**: menu titik tiga pada destinasi (atau ikon pensil di halaman detail).
4. **Hapus**: menu titik tiga -> Hapus (destinasi juga dihapus dari favorit semua akun).
5. Foto (opsional): simpan sebagai `assets/images/<slug>.jpg`; slug tampil di form. Tanpa foto,
   ilustrasi lanskap ditampilkan.

## Struktur `lib/`
```
lib/
├── main.dart                      Titik masuk aplikasi
├── theme/
│   └── app_theme.dart             Warna, tema, dan dekorasi field
├── data/
│   └── destinations_data.dart     Data statis kategori & destinasi
├── services/
│   ├── auth_service.dart          Login, register, role, dan favorit
│   └── destination_service.dart   Penyimpanan & CRUD destinasi (ChangeNotifier)
├── widgets/
│   ├── destination_image.dart     Foto destinasi + ilustrasi cadangan
│   └── destination_card.dart      Kartu destinasi (dipakai ulang)
└── screens/
    ├── auth/
    │   ├── auth_layout.dart       Kerangka & validator login/register
    │   ├── login_screen.dart
    │   └── register_screen.dart
    ├── admin/
    │   ├── admin_destinations_screen.dart  Tab Kelola: daftar + tambah/edit/hapus
    │   ├── destination_form_screen.dart    Form tambah/edit destinasi
    │   └── admin_actions.dart              Buka form & dialog konfirmasi hapus
    └── dashboard/
        ├── dashboard_screen.dart  Beranda, Favorit, Kelola (admin), dan Profil
        ├── category_screen.dart   Daftar destinasi per kategori
        └── destination_detail_screen.dart  Info lengkap destinasi
```

## Menjalankan
```
flutter pub get
flutter run
flutter test
```

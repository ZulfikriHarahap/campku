# CampKu

Aplikasi Flutter untuk menjelajahi destinasi camping alam di Sumatera Utara:
gunung, danau, air terjun, hutan, dan sungai.

## Fitur
- Masuk sebagai **Pengguna** atau **Admin** (akun admin statis); pendaftaran hanya untuk pengguna
- Beranda dengan pencarian dan kartu kategori; ketuk kategori untuk membuka halaman daftar destinasinya
- Detail destinasi, tombol "Lihat selengkapnya", dan daftar favorit per akun
- Profil, dan daftar pengguna terdaftar khusus admin

## Akun demo
| Peran | Email | Kata sandi |
| --- | --- | --- |
| Pengguna | user@campku.id | user123 |
| Admin | admin@campku.id | admin123 |

Akun admin bersifat statis (tetap) dan tidak bisa didaftarkan lewat aplikasi.

> Data akun disimpan di memori (tanpa backend), jadi akun baru hilang saat aplikasi ditutup.

## Menambah foto destinasi
Simpan foto (JPG) di `assets/images/` dengan nama sesuai slug destinasi, misalnya
`sibayak.jpg`, `toba.jpg`, `sipiso_piso.jpg`. Slug ada di `lib/destinations_data.dart`.
Jika foto belum ada, aplikasi menampilkan ilustrasi lanskap sesuai kategori.

## Struktur `lib/`
```
lib/
├── main.dart                      Titik masuk aplikasi
├── theme/
│   └── app_theme.dart             Warna, tema, dan dekorasi field
├── data/
│   └── destinations_data.dart     Data statis kategori & destinasi
├── services/
│   └── auth_service.dart          Login, register, role, dan favorit
├── widgets/
│   ├── destination_image.dart     Foto destinasi + ilustrasi cadangan
│   └── destination_card.dart      Kartu destinasi (dipakai ulang)
└── screens/
    ├── auth/
    │   ├── auth_layout.dart       Kerangka & validator login/register
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── dashboard/
        ├── dashboard_screen.dart  Beranda, Favorit, dan Profil
        ├── category_screen.dart   Daftar destinasi per kategori
        └── destination_detail_screen.dart  Info lengkap destinasi
```

## Menjalankan
```
flutter pub get
flutter run
flutter test
```

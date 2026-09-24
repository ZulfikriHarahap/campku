# CampKu

Aplikasi Flutter untuk menjelajahi destinasi camping alam di Sumatera Utara:
gunung, danau, air terjun, hutan, dan sungai.

## Fitur
- Login & register dengan dua peran: **Pengguna** dan **Admin**
- Beranda dengan pencarian, filter kategori, dan kartu destinasi
- Detail destinasi (ketuk kartu) dan daftar favorit per akun
- Profil, dan daftar pengguna terdaftar khusus admin

## Akun demo
| Peran | Email | Kata sandi |
| --- | --- | --- |
| Pengguna | user@campku.id | user123 |
| Admin | admin@campku.id | admin123 |

Untuk mendaftar sebagai admin, isi kode admin: `CAMPKU-ADMIN`.

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
│   └── destination_image.dart     Foto destinasi + ilustrasi cadangan
└── screens/
    ├── auth/
    │   ├── auth_layout.dart       Kerangka & validator login/register
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── dashboard/
        └── dashboard_screen.dart  Beranda, Favorit, dan Profil
```

## Menjalankan
```
flutter pub get
flutter run
flutter test
```

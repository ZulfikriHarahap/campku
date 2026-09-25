/// Status persetujuan booking oleh admin.
///
/// Bukan bagian dari "Data Utama" mini SRS (yang hanya menyebut status
/// pembayaran), tapi ditambahkan sesuai permintaan: setiap booking yang
/// sudah dibayar (simulasi) menunggu persetujuan admin sebelum dianggap
/// final (FR-10 diperluas menjadi "melihat sekaligus menyetujui/menolak").
enum BookingApproval { menunggu, disetujui, ditolak }

extension BookingApprovalLabel on BookingApproval {
  String get label => switch (this) {
        BookingApproval.menunggu => 'Menunggu persetujuan',
        BookingApproval.disetujui => 'Disetujui',
        BookingApproval.ditolak => 'Ditolak',
      };
}

/// Data booking (FR-06, FR-07): user, camp, tipe tenda, tanggal, total
/// harga, dan status pembayaran (simulasi).
///
/// Nama destinasi/camp/tenda disalin ("snapshot") saat booking dibuat agar
/// riwayat booking tetap bisa dibaca walau admin kemudian mengubah atau
/// menghapus data camp/tenda aslinya.
class Booking {
  const Booking({
    required this.id,
    required this.userEmail,
    required this.destinationName,
    required this.campId,
    required this.campName,
    required this.tentTypeId,
    required this.tentName,
    required this.pricePerNight,
    required this.checkIn,
    required this.nights,
    required this.totalPrice,
    required this.createdAt,
    this.approval = BookingApproval.menunggu,
  });

  final String id;
  final String userEmail;

  final String destinationName;
  final String campId;
  final String campName;
  final String tentTypeId;
  final String tentName;
  final int pricePerNight;

  final DateTime checkIn;
  final int nights;
  final int totalPrice;

  final DateTime createdAt;
  final BookingApproval approval;

  /// Simulasi pembayaran: dianggap lunas begitu booking dibuat (FR-06).
  String get paymentStatusLabel => 'Lunas (simulasi)';

  Booking copyWith({BookingApproval? approval}) => Booking(
        id: id,
        userEmail: userEmail,
        destinationName: destinationName,
        campId: campId,
        campName: campName,
        tentTypeId: tentTypeId,
        tentName: tentName,
        pricePerNight: pricePerNight,
        checkIn: checkIn,
        nights: nights,
        totalPrice: totalPrice,
        createdAt: createdAt,
        approval: approval ?? this.approval,
      );

  static const _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String formatDate(DateTime d) =>
      '${d.day} ${_bulan[d.month - 1]} ${d.year}';

  String get checkInLabel => formatDate(checkIn);
  String get nightsLabel => nights == 1 ? '1 malam' : '$nights malam';

  static String formatRupiah(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return 'Rp $b';
  }

  String get totalPriceLabel => formatRupiah(totalPrice);
}

enum BookingApproval { menunggu, disetujui, ditolak }

extension BookingApprovalLabel on BookingApproval {
  String get label => switch (this) {
        BookingApproval.menunggu => 'Menunggu persetujuan',
        BookingApproval.disetujui => 'Disetujui',
        BookingApproval.ditolak => 'Ditolak',
      };
}

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
  String get paymentStatusLabel => 'Lunas';

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

  /// Tanggal checkout (eksklusif), dipakai untuk mengecek tumpang-tindih
  /// tanggal antar booking saat menghitung stok yang tersedia per tanggal.
  DateTime get checkOut => checkIn.add(Duration(days: nights));

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

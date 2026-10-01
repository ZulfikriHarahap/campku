/// Tipe tenda yang bisa dipilih di sebuah camp (FR-05, FR-09).
///
/// Field mengikuti "Data Utama" mini SRS: nama, harga, kapasitas (jumlah
/// orang), dan jumlah/stok yang tersedia.
class TentType {
  const TentType({
    required this.id,
    required this.campId,
    required this.name,
    required this.price,
    required this.capacity,
    required this.stock,
  });

  /// Kunci unik tipe tenda.
  final String id;

  /// Id camp tempat tipe tenda ini ditawarkan.
  final String campId;

  final String name;

  /// Harga sewa per malam, dalam rupiah.
  final int price;

  /// Kapasitas maksimum, dalam jumlah orang.
  final int capacity;

  /// Jumlah tenda yang tersedia untuk dibooking.
  final int stock;

  String get priceLabel => 'Rp ${_thousands(price)} / malam';
  String get capacityLabel => 'Muat $capacity orang';

  static String _thousands(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return b.toString();
  }
}

/// Data contoh: setiap camp punya 2 tipe tenda dengan harga & stok berbeda.
const List<TentType> kTentTypes = [
  TentType(id: 'tt_sibayak_raja_berneh_dome', campId: 'camp_sibayak_raja_berneh', name: 'Tenda Dome 2 Orang', price: 75000, capacity: 2, stock: 6),
  TentType(id: 'tt_sibayak_raja_berneh_family', campId: 'camp_sibayak_raja_berneh', name: 'Tenda Keluarga 4 Orang', price: 130000, capacity: 4, stock: 3),

  TentType(id: 'tt_sibayak_jaridan_dome', campId: 'camp_sibayak_jaridan', name: 'Tenda Dome 2 Orang', price: 70000, capacity: 2, stock: 5),
  TentType(id: 'tt_sibayak_jaridan_group', campId: 'camp_sibayak_jaridan', name: 'Tenda Rombongan 6 Orang', price: 180000, capacity: 6, stock: 2),

  TentType(id: 'tt_sibuatan_basecamp_dome', campId: 'camp_sibuatan_basecamp', name: 'Tenda Dome 2 Orang', price: 80000, capacity: 2, stock: 4),
  TentType(id: 'tt_sibuatan_basecamp_family', campId: 'camp_sibuatan_basecamp', name: 'Tenda Keluarga 4 Orang', price: 140000, capacity: 4, stock: 2),

  TentType(id: 'tt_sinabung_basecamp_dome', campId: 'camp_sinabung_basecamp', name: 'Tenda Dome 2 Orang', price: 75000, capacity: 2, stock: 5),
  TentType(id: 'tt_sinabung_basecamp_group', campId: 'camp_sinabung_basecamp', name: 'Tenda Rombongan 6 Orang', price: 190000, capacity: 6, stock: 2),

  TentType(id: 'tt_toba_tuktuk_dome', campId: 'camp_toba_tuktuk', name: 'Tenda Dome 2 Orang', price: 65000, capacity: 2, stock: 8),
  TentType(id: 'tt_toba_tuktuk_family', campId: 'camp_toba_tuktuk', name: 'Tenda Keluarga 4 Orang', price: 120000, capacity: 4, stock: 4),

  TentType(id: 'tt_toba_lumban_silintong_dome', campId: 'camp_toba_lumban_silintong', name: 'Tenda Dome 2 Orang', price: 65000, capacity: 2, stock: 6),
  TentType(id: 'tt_toba_lumban_silintong_family', campId: 'camp_toba_lumban_silintong', name: 'Tenda Keluarga 4 Orang', price: 125000, capacity: 4, stock: 3),

  TentType(id: 'tt_lau_kawar_tepi_dome', campId: 'camp_lau_kawar_tepi', name: 'Tenda Dome 2 Orang', price: 60000, capacity: 2, stock: 6),
  TentType(id: 'tt_lau_kawar_tepi_family', campId: 'camp_lau_kawar_tepi', name: 'Tenda Keluarga 4 Orang', price: 110000, capacity: 4, stock: 3),

  TentType(id: 'tt_sidihoni_bukit_dome', campId: 'camp_sidihoni_bukit', name: 'Tenda Dome 2 Orang', price: 60000, capacity: 2, stock: 4),
  TentType(id: 'tt_sidihoni_bukit_family', campId: 'camp_sidihoni_bukit', name: 'Tenda Keluarga 4 Orang', price: 110000, capacity: 4, stock: 2),

  TentType(id: 'tt_sipiso_piso_lembah_dome', campId: 'camp_sipiso_piso_lembah', name: 'Tenda Dome 2 Orang', price: 70000, capacity: 2, stock: 5),
  TentType(id: 'tt_sipiso_piso_lembah_family', campId: 'camp_sipiso_piso_lembah', name: 'Tenda Keluarga 4 Orang', price: 130000, capacity: 4, stock: 2),

  TentType(id: 'tt_efrata_pinggir_dome', campId: 'camp_efrata_pinggir', name: 'Tenda Dome 2 Orang', price: 55000, capacity: 2, stock: 4),
  TentType(id: 'tt_efrata_pinggir_family', campId: 'camp_efrata_pinggir', name: 'Tenda Keluarga 4 Orang', price: 100000, capacity: 4, stock: 2),

  TentType(id: 'tt_binanga_bolon_hutan_dome', campId: 'camp_binanga_bolon_hutan', name: 'Tenda Dome 2 Orang', price: 55000, capacity: 2, stock: 3),
  TentType(id: 'tt_binanga_bolon_hutan_family', campId: 'camp_binanga_bolon_hutan', name: 'Tenda Keluarga 4 Orang', price: 95000, capacity: 4, stock: 2),

  TentType(id: 'tt_bahorok_sungai_dome', campId: 'camp_bahorok_sungai', name: 'Tenda Dome 2 Orang', price: 70000, capacity: 2, stock: 5),
  TentType(id: 'tt_bahorok_sungai_family', campId: 'camp_bahorok_sungai', name: 'Tenda Keluarga 4 Orang', price: 125000, capacity: 4, stock: 3),

  TentType(id: 'tt_leuser_pos_utama_dome', campId: 'camp_leuser_pos_utama', name: 'Tenda Dome 2 Orang', price: 90000, capacity: 2, stock: 3),
  TentType(id: 'tt_leuser_pos_utama_group', campId: 'camp_leuser_pos_utama', name: 'Tenda Rombongan 6 Orang', price: 220000, capacity: 6, stock: 1),

  TentType(id: 'tt_mangrove_serdang_dermaga_dome', campId: 'camp_mangrove_serdang_dermaga', name: 'Tenda Dome 2 Orang', price: 60000, capacity: 2, stock: 4),
  TentType(id: 'tt_mangrove_serdang_dermaga_family', campId: 'camp_mangrove_serdang_dermaga', name: 'Tenda Keluarga 4 Orang', price: 105000, capacity: 4, stock: 2),

  TentType(id: 'tt_alas_start_arung_dome', campId: 'camp_alas_start_arung', name: 'Tenda Dome 2 Orang', price: 85000, capacity: 2, stock: 4),
  TentType(id: 'tt_alas_start_arung_group', campId: 'camp_alas_start_arung', name: 'Tenda Rombongan 6 Orang', price: 210000, capacity: 6, stock: 2),

  TentType(id: 'tt_wampu_tepian_dome', campId: 'camp_wampu_tepian', name: 'Tenda Dome 2 Orang', price: 75000, capacity: 2, stock: 4),
  TentType(id: 'tt_wampu_tepian_family', campId: 'camp_wampu_tepian', name: 'Tenda Keluarga 4 Orang', price: 130000, capacity: 4, stock: 2),

  TentType(id: 'tt_bah_bolon_batu_dome', campId: 'camp_bah_bolon_batu', name: 'Tenda Dome 2 Orang', price: 65000, capacity: 2, stock: 5),
  TentType(id: 'tt_bah_bolon_batu_family', campId: 'camp_bah_bolon_batu', name: 'Tenda Keluarga 4 Orang', price: 115000, capacity: 4, stock: 3),
];
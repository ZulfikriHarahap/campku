import 'package:campku/data/destinations_data.dart';

/// Camp yang tersedia di sebuah destinasi (FR-04).
///
/// Sesuai mini SRS, data utama camp hanya "nama camp" dan "destinasi
/// terkait". Info harga dan kapasitas ada di tingkat [TentType], bukan di
/// sini, karena satu camp bisa punya beberapa tipe tenda dengan harga
/// berbeda.
class Camp {
  const Camp({
    required this.id,
    required this.name,
    required this.destinationSlug,
  });

  /// Kunci unik camp, dipakai untuk relasi ke [TentType].
  final String id;
  final String name;

  /// Slug [Destination] tempat camp ini berada.
  final String destinationSlug;
}

/// Data contoh: setiap destinasi punya 1-2 camp.
const List<Camp> kCamps = [
  // ── Gunung ────────────────────────────────
  Camp(id: 'camp_sibayak_raja_berneh', name: 'Camp Raja Berneh', destinationSlug: 'sibayak'),
  Camp(id: 'camp_sibayak_jaridan', name: 'Camp Jaridan', destinationSlug: 'sibayak'),
  Camp(id: 'camp_sibuatan_basecamp', name: 'Basecamp Sibuatan', destinationSlug: 'sibuatan'),
  Camp(id: 'camp_sinabung_basecamp', name: 'Basecamp Sinabung', destinationSlug: 'sinabung'),

  // ── Danau ─────────────────────────────────
  Camp(id: 'camp_toba_tuktuk', name: 'Camp Tuk Tuk', destinationSlug: 'toba'),
  Camp(id: 'camp_toba_lumban_silintong', name: 'Camp Lumban Silintong', destinationSlug: 'toba'),
  Camp(id: 'camp_lau_kawar_tepi', name: 'Camp Tepi Lau Kawar', destinationSlug: 'lau_kawar'),
  Camp(id: 'camp_sidihoni_bukit', name: 'Camp Bukit Sidihoni', destinationSlug: 'sidihoni'),

  // ── Air Terjun ────────────────────────────
  Camp(id: 'camp_sipiso_piso_lembah', name: 'Camp Lembah Sipiso-piso', destinationSlug: 'sipiso_piso'),
  Camp(id: 'camp_efrata_pinggir', name: 'Camp Pinggir Efrata', destinationSlug: 'efrata'),
  Camp(id: 'camp_binanga_bolon_hutan', name: 'Camp Hutan Binanga Bolon', destinationSlug: 'binanga_bolon'),

  // ── Hutan ─────────────────────────────────
  Camp(id: 'camp_bahorok_sungai', name: 'Camp Tepi Sungai Bahorok', destinationSlug: 'bahorok'),
  Camp(id: 'camp_leuser_pos_utama', name: 'Camp Pos Utama Leuser', destinationSlug: 'leuser'),
  Camp(id: 'camp_mangrove_serdang_dermaga', name: 'Camp Dermaga Mangrove', destinationSlug: 'mangrove_serdang'),

  // ── Sungai ────────────────────────────────
  Camp(id: 'camp_alas_start_arung', name: 'Camp Titik Start Arung Jeram', destinationSlug: 'alas'),
  Camp(id: 'camp_wampu_tepian', name: 'Camp Tepian Wampu', destinationSlug: 'wampu'),
  Camp(id: 'camp_bah_bolon_batu', name: 'Camp Batu Bah Bolon', destinationSlug: 'bah_bolon'),
];
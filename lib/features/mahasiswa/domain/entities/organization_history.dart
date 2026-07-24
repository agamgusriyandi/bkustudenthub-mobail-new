class OrganizationHistory {
  final String id;
  final String namaOrganisasi;
  final String tipe;
  final String jabatan;
  final int periodeMulai;
  final int? periodeSelesai;
  final String deskripsiKegiatan;
  final String apresiasi;
  final String? dokumentasi;
  final String statusVerifikasi;
  final List<String> achievements;

  OrganizationHistory({
    required this.id,
    required this.namaOrganisasi,
    required this.tipe,
    required this.jabatan,
    required this.periodeMulai,
    this.periodeSelesai,
    required this.deskripsiKegiatan,
    required this.apresiasi,
    this.dokumentasi,
    required this.statusVerifikasi,
    required this.achievements,
  });
}

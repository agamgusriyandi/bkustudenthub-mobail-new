class OrmawaProposal {
  final String id;
  final String? ormawaId;
  final String? mahasiswaId;
  final String? fakultasId;
  final String title;
  final String code;
  final String status;
  final DateTime date;
  final double budget;
  final String? description;
  final String? landasanKegiatan;
  final String? bentukKegiatan;
  final String? mitra;
  final String? pjKegiatan;
  final String? jadwalPelaksanaan;
  final String? sasaranKegiatan;
  final String? indikatorKeberhasilan;
  final String? sumberDana;
  final String? latarBelakang;
  final String? tujuanKegiatan;
  final String? fileUrl;
  final String? catatan;

  OrmawaProposal({
    required this.id,
    this.ormawaId,
    this.mahasiswaId,
    this.fakultasId,
    required this.title,
    required this.code,
    required this.status,
    required this.date,
    this.budget = 0,
    this.description,
    this.landasanKegiatan,
    this.bentukKegiatan,
    this.mitra,
    this.pjKegiatan,
    this.jadwalPelaksanaan,
    this.sasaranKegiatan,
    this.indikatorKeberhasilan,
    this.sumberDana,
    this.latarBelakang,
    this.tujuanKegiatan,
    this.fileUrl,
    this.catatan,
  });
}

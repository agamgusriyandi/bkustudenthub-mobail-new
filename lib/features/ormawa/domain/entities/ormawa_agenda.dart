class OrmawaAgenda {
  final String id;
  final String title;
  final DateTime date;
  final DateTime endDate;
  final String status;
  final String description;
  final String location;

  final String? landasanKegiatan;
  final String? bentukKegiatan;
  final String? mitra;
  final String? latarBelakang;
  final String? tujuanKegiatan;
  final String? jadwalPelaksanaan;
  final String? sasaranKegiatan;
  final String? indikatorKeberhasilan;
  final String? sumberDana;
  final double? estimasiDana;
  final String? pjKegiatan;

  OrmawaAgenda({
    required this.id,
    required this.title,
    required this.date,
    required this.endDate,
    required this.status,
    required this.description,
    required this.location,
    this.landasanKegiatan,
    this.bentukKegiatan,
    this.mitra,
    this.latarBelakang,
    this.tujuanKegiatan,
    this.jadwalPelaksanaan,
    this.sasaranKegiatan,
    this.indikatorKeberhasilan,
    this.sumberDana,
    this.estimasiDana,
    this.pjKegiatan,
  });
}

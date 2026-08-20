class Achievement {
  final String id;
  final String title;
  final String organizer;
  final String level;
  final String rank;
  final DateTime date;
  final String status;
  final bool isSynced;
  final String? certificateUrl;

  final String? tipe;
  final String? danaDiajukan;
  final String? danaDisetujui;
  final String? catatanVerifikator;
  final String? cabang;
  final String? jumlahUnitPeserta;
  final String? kelompokPrestasi;
  final String? bentuk;
  final String? urlPeserta;
  final String? urlFotoUpp;
  final String? urlDokumenUndangan;
  final String? jenisRekognisi;
  final String? simkatmawaStatus;
  final String? keterangan;

  final String? filePath;
  final String? suratTugasPath;
  final String? kategori;

  final List<dynamic>? pembimbingDosen;
  final List<dynamic>? anggotaMahasiswa;

  Achievement({
    required this.id,
    required this.title,
    required this.organizer,
    required this.level,
    required this.rank,
    required this.date,
    this.status = 'Pending',
    this.isSynced = false,
    this.certificateUrl,
    this.filePath,
    this.suratTugasPath,
    this.kategori,
    this.tipe,
    this.danaDiajukan,
    this.danaDisetujui,
    this.catatanVerifikator,
    this.cabang,
    this.jumlahUnitPeserta,
    this.kelompokPrestasi,
    this.bentuk,
    this.urlPeserta,
    this.urlFotoUpp,
    this.urlDokumenUndangan,
    this.jenisRekognisi,
    this.simkatmawaStatus,
    this.keterangan,
    this.pembimbingDosen,
    this.anggotaMahasiswa,
  });
}

class TkClinicalReportStats {
  final int totalDiperiksa;
  final int layak;
  final int perluPerhatian;
  final int tidakLayak;

  TkClinicalReportStats({
    required this.totalDiperiksa,
    required this.layak,
    required this.perluPerhatian,
    required this.tidakLayak,
  });

  factory TkClinicalReportStats.fromJson(Map<String, dynamic> json) {
    return TkClinicalReportStats(
      totalDiperiksa: json['total_diperiksa'] ?? 0,
      layak: json['layak'] ?? 0,
      perluPerhatian: json['perlu_perhatian'] ?? 0,
      tidakLayak: json['tidak_layak'] ?? 0,
    );
  }
}

class TkClinicalReportRecord {
  final int id;
  final String namaMahasiswa;
  final String nim;
  final String prodi;
  final String fakultas;
  final DateTime tanggal;
  final String hasil;
  final String catatan;
  final String namaPemeriksa;

  // Detail Vital
  final double tinggiBadan;
  final double beratBadan;
  final int sistole;
  final int diastole;
  final int gulaDarah;
  final String butaWarna;
  final String golonganDarah;
  final double suhuTubuh;
  final int denyutNadi;
  final int spo2;
  final int skalaNyeri;

  // Tindakan & Obat
  final String alergiObat;
  final String kondisiPsikologis;
  final String konsumsiObat;
  final String tindakanDiberikan;
  final String obatDiberikan;
  final String rekomendasi;

  TkClinicalReportRecord({
    required this.id,
    required this.namaMahasiswa,
    required this.nim,
    required this.prodi,
    required this.fakultas,
    required this.tanggal,
    required this.hasil,
    required this.catatan,
    required this.namaPemeriksa,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.sistole,
    required this.diastole,
    required this.gulaDarah,
    required this.butaWarna,
    required this.golonganDarah,
    required this.suhuTubuh,
    required this.denyutNadi,
    required this.spo2,
    required this.skalaNyeri,
    required this.alergiObat,
    required this.kondisiPsikologis,
    required this.konsumsiObat,
    required this.tindakanDiberikan,
    required this.obatDiberikan,
    required this.rekomendasi,
  });

  factory TkClinicalReportRecord.fromJson(Map<String, dynamic> json) {
    final mhs = json['mahasiswa'] as Map<String, dynamic>?;
    final prodiObj =
        mhs != null
            ? (mhs['program_studi'] ?? mhs['ProgramStudi'])
                as Map<String, dynamic>?
            : null;
    final fakObj =
        mhs != null
            ? (mhs['fakultas'] ?? mhs['Fakultas']) as Map<String, dynamic>?
            : null;
    final tkObj = json['tenaga_kes'] ?? json['TenagaKes'];
    final tkMap = tkObj is Map<String, dynamic> ? tkObj : null;

    return TkClinicalReportRecord(
      id: json['id'] ?? 0,
      namaMahasiswa: mhs != null ? (mhs['nama'] ?? mhs['Nama'] ?? '—') : '—',
      nim: mhs != null ? (mhs['nim'] ?? mhs['NIM'] ?? '—') : '—',
      prodi:
          prodiObj != null
              ? (prodiObj['nama'] ?? prodiObj['Nama'] ?? '—')
              : '—',
      fakultas:
          fakObj != null ? (fakObj['nama'] ?? fakObj['Nama'] ?? '—') : '—',
      tanggal:
          json['tanggal'] != null
              ? DateTime.parse(json['tanggal'])
              : DateTime.now(),
      hasil: json['hasil'] ?? '—',
      catatan: json['catatan'] ?? '—',
      namaPemeriksa:
          tkMap != null ? (tkMap['nama'] ?? tkMap['Nama'] ?? '—') : '—',

      tinggiBadan: _parseDouble(json['tinggi_badan']),
      beratBadan: _parseDouble(json['berat_badan']),
      sistole: _parseInt(json['sistole']),
      diastole: _parseInt(json['diastole']),
      gulaDarah: _parseInt(json['gula_darah']),
      butaWarna: json['buta_warna']?.toString() ?? '—',
      golonganDarah: json['golongan_darah']?.toString() ?? '—',
      suhuTubuh: _parseDouble(json['suhu_tubuh']),
      denyutNadi: _parseInt(json['denyut_nadi']),
      spo2: _parseInt(json['spo2']),
      skalaNyeri: _parseInt(json['skala_nyeri']),

      alergiObat: json['alergi_obat'] ?? '—',
      kondisiPsikologis: json['kondisi_psikologis'] ?? '—',
      konsumsiObat: json['konsumsi_obat'] ?? '—',
      tindakanDiberikan: json['tindakan_diberikan'] ?? '—',
      obatDiberikan: json['obat_diberikan'] ?? '—',
      rekomendasi: json['rekomendasi'] ?? '—',
    );
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

class TkClinicalReportModel {
  final TkClinicalReportStats summary;
  final List<TkClinicalReportRecord> records;

  TkClinicalReportModel({required this.summary, required this.records});

  factory TkClinicalReportModel.fromJson(Map<String, dynamic> json) {
    var recordList = json['records'] as List? ?? [];
    List<TkClinicalReportRecord> parsedRecords =
        recordList.map((e) => TkClinicalReportRecord.fromJson(e)).toList();

    return TkClinicalReportModel(
      summary: TkClinicalReportStats.fromJson(json['summary'] ?? {}),
      records: parsedRecords,
    );
  }
}

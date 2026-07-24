import 'package:equatable/equatable.dart';

class MedicalRecord extends Equatable {
  final int id;
  final int mahasiswaId;
  final int? tenagaKesId;
  final DateTime tanggal;
  final String? jenisPemeriksaan;
  final double tinggiBadan;
  final double beratBadan;
  final double bmi;
  final int sistole;
  final int diastole;
  final int? gulaDarah;
  final String? butaWarna;
  final String? riwayatPenyakit;
  final String? golonganDarah;
  final double suhuTubuh;
  final int denyutNadi;
  final int spO2;
  final int? skalaNyeri;
  final String? alergiObat;
  final String? kondisiPsikologis;
  final String? konsumsiObat;
  final String? tindakanDiberikan;
  final String? obatDiberikan;
  final String? catatan;
  final String? hasil;
  final String? rekomendasi;
  final String statusKesehatan;
  final String? namaPemeriksa;

  const MedicalRecord({
    required this.id,
    required this.mahasiswaId,
    this.tenagaKesId,
    required this.tanggal,
    this.jenisPemeriksaan,
    required this.tinggiBadan,
    required this.beratBadan,
    required this.bmi,
    required this.sistole,
    required this.diastole,
    this.gulaDarah,
    this.butaWarna,
    this.riwayatPenyakit,
    this.golonganDarah,
    required this.suhuTubuh,
    required this.denyutNadi,
    required this.spO2,
    this.skalaNyeri,
    this.alergiObat,
    this.kondisiPsikologis,
    this.konsumsiObat,
    this.tindakanDiberikan,
    this.obatDiberikan,
    this.catatan,
    this.hasil,
    this.rekomendasi,
    required this.statusKesehatan,
    this.namaPemeriksa,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] ?? 0,
      mahasiswaId: json['mahasiswa_id'] ?? 0,
      tenagaKesId: json['tenaga_kes_id'],
      tanggal:
          json['tanggal'] != null
              ? DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now()
              : DateTime.now(),
      jenisPemeriksaan: json['jenis_pemeriksaan']?.toString(),
      tinggiBadan: _parseDouble(json['tinggi_badan']),
      beratBadan: _parseDouble(json['berat_badan']),
      bmi:
          json['bmi'] != null
              ? _parseDouble(json['bmi'])
              : _calculateBmi(
                _parseDouble(json['tinggi_badan']),
                _parseDouble(json['berat_badan']),
              ),
      sistole: _parseInt(json['sistole']),
      diastole: _parseInt(json['diastole']),
      gulaDarah:
          json['gula_darah'] != null ? _parseInt(json['gula_darah']) : null,
      butaWarna: json['buta_warna']?.toString(),
      riwayatPenyakit: json['riwayat_penyakit']?.toString(),
      golonganDarah: json['golongan_darah']?.toString(),
      suhuTubuh: _parseDouble(json['suhu_tubuh']),
      denyutNadi: _parseInt(json['denyut_nadi']),
      spO2: _parseInt(json['sp_o2'] ?? json['spo2']),
      skalaNyeri:
          json['skala_nyeri'] != null ? _parseInt(json['skala_nyeri']) : null,
      alergiObat: json['alergi_obat']?.toString(),
      kondisiPsikologis: json['kondisi_psikologis']?.toString(),
      konsumsiObat: json['konsumsi_obat']?.toString(),
      tindakanDiberikan: json['tindakan_diberikan']?.toString(),
      obatDiberikan: json['obat_diberikan']?.toString(),
      catatan: json['catatan']?.toString(),
      hasil: json['hasil']?.toString(),
      rekomendasi: json['rekomendasi']?.toString(),
      statusKesehatan: json['status_kesehatan']?.toString() ?? 'stabil',
      namaPemeriksa: json['nama_pemeriksa']?.toString(),
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

  static double _calculateBmi(double tinggi, double berat) {
    if (tinggi <= 0) return 0;
    final tinggiMeter = tinggi / 100;
    return berat / (tinggiMeter * tinggiMeter);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'tenaga_kes_id': tenagaKesId,
      'tanggal': tanggal.toIso8601String(),
      'jenis_pemeriksaan': jenisPemeriksaan,
      'tinggi_badan': tinggiBadan,
      'berat_badan': beratBadan,
      'bmi': bmi,
      'sistole': sistole,
      'diastole': diastole,
      'gula_darah': gulaDarah,
      'buta_warna': butaWarna,
      'riwayat_penyakit': riwayatPenyakit,
      'golongan_darah': golonganDarah,
      'suhu_tubuh': suhuTubuh,
      'denyut_nadi': denyutNadi,
      'sp_o2': spO2,
      'skala_nyeri': skalaNyeri,
      'alergi_obat': alergiObat,
      'kondisi_psikologis': kondisiPsikologis,
      'konsumsi_obat': konsumsiObat,
      'tindakan_diberikan': tindakanDiberikan,
      'obat_diberikan': obatDiberikan,
      'catatan': catatan,
      'hasil': hasil,
      'rekomendasi': rekomendasi,
      'status_kesehatan': statusKesehatan,
    };
  }

  String get tekananDarah => '$sistole/$diastole mmHg';

  String get bmiCategory {
    if (bmi < 18.5) return 'Kekurangan BB';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Kelebihan BB';
    return 'Obesitas';
  }

  String get statusCategory {
    if (hasil == 'Tidak Layak') return 'Tidak Layak';
    if (hasil == 'Perlu Perhatian') return 'Perlu Perhatian';
    return 'Layak Kegiatan';
  }

  @override
  List<Object?> get props => [
    id,
    mahasiswaId,
    tanggal,
    tinggiBadan,
    beratBadan,
    sistole,
    diastole,
    statusKesehatan,
  ];
}

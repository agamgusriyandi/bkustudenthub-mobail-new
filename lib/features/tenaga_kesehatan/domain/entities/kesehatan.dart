import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tenaga_kesehatan.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class Kesehatan extends Equatable {
  final String? alergiObat;
  final double? beratBadan;
  final int? bookingId;
  final String? butaWarna;
  final String? catatan;
  final String? createdAt;
  final int? denyutNadi;
  final int? diastole;
  final String? diperiksaOleh;
  final int? eventId;
  final String? fileUrl;
  final String? golonganDarah;
  final int? gulaDarah;
  final String? hasil;
  final int? id;
  final String? jenisPemeriksaan;
  final String? kondisiPsikologis;
  final String? konsumsiObat;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? nomorSurat;
  final String? obatDiberikan;
  final String? rekomendasi;
  final int? respirationRate;
  final String? riwayatPenyakit;
  final int? sistole;
  final int? skalaNyeri;
  final int? spo2;
  final String? statusKesehatan;
  final double? suhuTubuh;
  final String? sumber;
  final String? tanggal;
  final TenagaKesehatan? tenagaKes;
  final int? tenagaKesId;
  final String? tindakanDiberikan;
  final double? tinggiBadan;
  final String? updatedAt;

  const Kesehatan({
    this.alergiObat,
    this.beratBadan,
    this.bookingId,
    this.butaWarna,
    this.catatan,
    this.createdAt,
    this.denyutNadi,
    this.diastole,
    this.diperiksaOleh,
    this.eventId,
    this.fileUrl,
    this.golonganDarah,
    this.gulaDarah,
    this.hasil,
    this.id,
    this.jenisPemeriksaan,
    this.kondisiPsikologis,
    this.konsumsiObat,
    this.mahasiswa,
    this.mahasiswaId,
    this.nomorSurat,
    this.obatDiberikan,
    this.rekomendasi,
    this.respirationRate,
    this.riwayatPenyakit,
    this.sistole,
    this.skalaNyeri,
    this.spo2,
    this.statusKesehatan,
    this.suhuTubuh,
    this.sumber,
    this.tanggal,
    this.tenagaKes,
    this.tenagaKesId,
    this.tindakanDiberikan,
    this.tinggiBadan,
    this.updatedAt,
  });

  factory Kesehatan.fromJson(Map<String, dynamic> json) {
    return Kesehatan(
      alergiObat: json['alergi_obat'],
      beratBadan: json['berat_badan'],
      bookingId:
          json['booking_id'] != null
              ? int.tryParse(json['booking_id'].toString()) ??
                  json['booking_id']
              : null,
      butaWarna: json['buta_warna'],
      catatan: json['catatan'],
      createdAt: json['created_at'],
      denyutNadi:
          json['denyut_nadi'] != null
              ? int.tryParse(json['denyut_nadi'].toString()) ??
                  json['denyut_nadi']
              : null,
      diastole:
          json['diastole'] != null
              ? int.tryParse(json['diastole'].toString()) ?? json['diastole']
              : null,
      diperiksaOleh: json['diperiksa_oleh'],
      eventId:
          json['event_id'] != null
              ? int.tryParse(json['event_id'].toString()) ?? json['event_id']
              : null,
      fileUrl: json['file_url'],
      golonganDarah: json['golongan_darah'],
      gulaDarah:
          json['gula_darah'] != null
              ? int.tryParse(json['gula_darah'].toString()) ??
                  json['gula_darah']
              : null,
      hasil: json['hasil'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      jenisPemeriksaan: json['jenis_pemeriksaan'],
      kondisiPsikologis: json['kondisi_psikologis'],
      konsumsiObat: json['konsumsi_obat'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswa_id'] != null
              ? int.tryParse(json['mahasiswa_id'].toString()) ??
                  json['mahasiswa_id']
              : null,
      nomorSurat: json['nomor_surat'],
      obatDiberikan: json['obat_diberikan'],
      rekomendasi: json['rekomendasi'],
      respirationRate:
          json['respiration_rate'] != null
              ? int.tryParse(json['respiration_rate'].toString()) ??
                  json['respiration_rate']
              : null,
      riwayatPenyakit: json['riwayat_penyakit'],
      sistole:
          json['sistole'] != null
              ? int.tryParse(json['sistole'].toString()) ?? json['sistole']
              : null,
      skalaNyeri:
          json['skala_nyeri'] != null
              ? int.tryParse(json['skala_nyeri'].toString()) ??
                  json['skala_nyeri']
              : null,
      spo2:
          json['spo2'] != null
              ? int.tryParse(json['spo2'].toString()) ?? json['spo2']
              : null,
      statusKesehatan: json['status_kesehatan'],
      suhuTubuh: json['suhu_tubuh'],
      sumber: json['sumber'],
      tanggal: json['tanggal'],
      tenagaKes:
          json['tenaga_kes'] != null
              ? TenagaKesehatan.fromJson(json['tenaga_kes'])
              : null,
      tenagaKesId:
          json['tenaga_kes_id'] != null
              ? int.tryParse(json['tenaga_kes_id'].toString()) ??
                  json['tenaga_kes_id']
              : null,
      tindakanDiberikan: json['tindakan_diberikan'],
      tinggiBadan: json['tinggi_badan'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alergi_obat': alergiObat,
      'berat_badan': beratBadan,
      'booking_id': bookingId,
      'buta_warna': butaWarna,
      'catatan': catatan,
      'created_at': createdAt,
      'denyut_nadi': denyutNadi,
      'diastole': diastole,
      'diperiksa_oleh': diperiksaOleh,
      'event_id': eventId,
      'file_url': fileUrl,
      'golongan_darah': golonganDarah,
      'gula_darah': gulaDarah,
      'hasil': hasil,
      'id': id,
      'jenis_pemeriksaan': jenisPemeriksaan,
      'kondisi_psikologis': kondisiPsikologis,
      'konsumsi_obat': konsumsiObat,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswa_id': mahasiswaId,
      'nomor_surat': nomorSurat,
      'obat_diberikan': obatDiberikan,
      'rekomendasi': rekomendasi,
      'respiration_rate': respirationRate,
      'riwayat_penyakit': riwayatPenyakit,
      'sistole': sistole,
      'skala_nyeri': skalaNyeri,
      'spo2': spo2,
      'status_kesehatan': statusKesehatan,
      'suhu_tubuh': suhuTubuh,
      'sumber': sumber,
      'tanggal': tanggal,
      'tenaga_kes': tenagaKes?.toJson(),
      'tenaga_kes_id': tenagaKesId,
      'tindakan_diberikan': tindakanDiberikan,
      'tinggi_badan': tinggiBadan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    alergiObat,
    beratBadan,
    bookingId,
    butaWarna,
    catatan,
    createdAt,
    denyutNadi,
    diastole,
    diperiksaOleh,
    eventId,
    fileUrl,
    golonganDarah,
    gulaDarah,
    hasil,
    id,
    jenisPemeriksaan,
    kondisiPsikologis,
    konsumsiObat,
    mahasiswa,
    mahasiswaId,
    nomorSurat,
    obatDiberikan,
    rekomendasi,
    respirationRate,
    riwayatPenyakit,
    sistole,
    skalaNyeri,
    spo2,
    statusKesehatan,
    suhuTubuh,
    sumber,
    tanggal,
    tenagaKes,
    tenagaKesId,
    tindakanDiberikan,
    tinggiBadan,
    updatedAt,
  ];
}

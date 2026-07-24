import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspirasi.dart';
import 'package:bkuhub_mobile/core/domain/entities/user.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/dosen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/riwayat_organisasi.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/pkkmb_hasil.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/prestasi.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/konseling.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/pkkmb_progress.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/program_studi.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/pkkmb_banding.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/beasiswa_pendaftaran.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/pkkmb_sertifikat.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/pengajuan_surat.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/kesehatan.dart';

class Mahasiswa extends Equatable {
  final String? agama;
  final String? alamat;
  final String? alamatDomisili;
  final String? asalSekolah;
  final List<Aspirasi>? aspirasi;
  final List<BeasiswaPendaftaran>? beasiswa;
  final String? createdAt;
  final int? creditLimit;
  final String? desa;
  final String? desaDomisili;
  final Dosen? dosenPa;
  final int? dosenPaid;
  final String? dusun;
  final String? dusunDomisili;
  final String? emailKampus;
  final String? emailPersonal;
  final Fakultas? fakultas;
  final int? fakultasId;
  final String? fotoUrl;
  final String? gelarBelakang;
  final String? gelarDepan;
  final String? gelombang;
  final String? golonganDarah;
  final int? id;
  final double? ipk;
  final double? ipkTerakhir;
  final String? ipkasal;
  final String? isDisabilitas;
  final String? isTransfer;
  final String? jalurMasuk;
  final String? jenisKelamin;
  final String? jenisTinggal;
  final String? jenjang;
  final String? kategoriUkt;
  final String? kecamatan;
  final String? kecamatanDomisili;
  final List<Kesehatan>? kesehatan;
  final String? kewarganegaraan;
  final String? kodePos;
  final String? kodePosDomisili;
  final List<Konseling>? konseling;
  final String? kontakDarurat;
  final String? kota;
  final String? kotaDomisili;
  final String? lastSyncedAt;
  final String? nama;
  final String? namaAyah;
  final String? namaIbuKandung;
  final String? namaWali;
  final String? nik;
  final String? nim;
  final String? nimlama;
  final String? nirl;
  final String? nirm;
  final String? nisn;
  final String? noHp;
  final String? noIjazahSma;
  final String? nomorKk;
  final String? nomorKps;
  final String? npsn;
  final String? nupn;
  final String? pekerjaan;
  final String? pekerjaanAyah;
  final String? pekerjaanIbu;
  final List<PengajuanSurat>? pengajuanSurat;
  final User? pengguna;
  final int? penggunaId;
  final int? penghasilanOrtu;
  final PkkmbBanding? pkkmbBanding;
  final PkkmbHasil? pkkmbHasil;
  final List<PkkmbProgress>? pkkmbProgress;
  final PkkmbSertifikat? pkkmbSertifikat;
  final List<Prestasi>? prestasi;
  final String? prodiAsal;
  final ProgramStudi? programStudi;
  final int? programStudiId;
  final String? provinsi;
  final String? provinsiDomisili;
  final List<RiwayatOrganisasi>? riwayatOrganisasi;
  final String? rt;
  final String? rtdomisili;
  final String? rw;
  final String? rwdomisili;
  final int? semesterSekarang;
  final String? sevimaHash;
  final String? sistemKuliah;
  final String? sksasal;
  final String? statusAkademik;
  final String? statusAkun;
  final String? statusPernikahan;
  final int? tahunMasuk;
  final String? tanggalDaftar;
  final String? tanggalLahir;
  final String? telepon;
  final String? tempatLahir;
  final int? totalSks;
  final String? universitasAsal;
  final String? updatedAt;

  const Mahasiswa({
    this.agama,
    this.alamat,
    this.alamatDomisili,
    this.asalSekolah,
    this.aspirasi,
    this.beasiswa,
    this.createdAt,
    this.creditLimit,
    this.desa,
    this.desaDomisili,
    this.dosenPa,
    this.dosenPaid,
    this.dusun,
    this.dusunDomisili,
    this.emailKampus,
    this.emailPersonal,
    this.fakultas,
    this.fakultasId,
    this.fotoUrl,
    this.gelarBelakang,
    this.gelarDepan,
    this.gelombang,
    this.golonganDarah,
    this.id,
    this.ipk,
    this.ipkTerakhir,
    this.ipkasal,
    this.isDisabilitas,
    this.isTransfer,
    this.jalurMasuk,
    this.jenisKelamin,
    this.jenisTinggal,
    this.jenjang,
    this.kategoriUkt,
    this.kecamatan,
    this.kecamatanDomisili,
    this.kesehatan,
    this.kewarganegaraan,
    this.kodePos,
    this.kodePosDomisili,
    this.konseling,
    this.kontakDarurat,
    this.kota,
    this.kotaDomisili,
    this.lastSyncedAt,
    this.nama,
    this.namaAyah,
    this.namaIbuKandung,
    this.namaWali,
    this.nik,
    this.nim,
    this.nimlama,
    this.nirl,
    this.nirm,
    this.nisn,
    this.noHp,
    this.noIjazahSma,
    this.nomorKk,
    this.nomorKps,
    this.npsn,
    this.nupn,
    this.pekerjaan,
    this.pekerjaanAyah,
    this.pekerjaanIbu,
    this.pengajuanSurat,
    this.pengguna,
    this.penggunaId,
    this.penghasilanOrtu,
    this.pkkmbBanding,
    this.pkkmbHasil,
    this.pkkmbProgress,
    this.pkkmbSertifikat,
    this.prestasi,
    this.prodiAsal,
    this.programStudi,
    this.programStudiId,
    this.provinsi,
    this.provinsiDomisili,
    this.riwayatOrganisasi,
    this.rt,
    this.rtdomisili,
    this.rw,
    this.rwdomisili,
    this.semesterSekarang,
    this.sevimaHash,
    this.sistemKuliah,
    this.sksasal,
    this.statusAkademik,
    this.statusAkun,
    this.statusPernikahan,
    this.tahunMasuk,
    this.tanggalDaftar,
    this.tanggalLahir,
    this.telepon,
    this.tempatLahir,
    this.totalSks,
    this.universitasAsal,
    this.updatedAt,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      agama: json['agama'],
      alamat: json['alamat'],
      alamatDomisili: json['alamatDomisili'],
      asalSekolah: json['asalSekolah'],
      aspirasi:
          json['aspirasi'] != null
              ? (json['aspirasi'] as List)
                  .map((i) => Aspirasi.fromJson(i))
                  .toList()
              : null,
      beasiswa:
          json['beasiswa'] != null
              ? (json['beasiswa'] as List)
                  .map((i) => BeasiswaPendaftaran.fromJson(i))
                  .toList()
              : null,
      createdAt: json['created_at'],
      creditLimit:
          json['creditLimit'] != null
              ? int.tryParse(json['creditLimit'].toString()) ??
                  json['creditLimit']
              : null,
      desa: json['desa'],
      desaDomisili: json['desaDomisili'],
      dosenPa: json['dosenPA'] != null ? Dosen.fromJson(json['dosenPA']) : null,
      dosenPaid:
          json['dosenPAID'] != null
              ? int.tryParse(json['dosenPAID'].toString()) ?? json['dosenPAID']
              : null,
      dusun: json['dusun'],
      dusunDomisili: json['dusunDomisili'],
      emailKampus: json['emailKampus'],
      emailPersonal: json['emailPersonal'],
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultasID'] != null
              ? int.tryParse(json['fakultasID'].toString()) ??
                  json['fakultasID']
              : null,
      fotoUrl: json['fotoURL'],
      gelarBelakang: json['gelarBelakang'],
      gelarDepan: json['gelarDepan'],
      gelombang: json['gelombang'],
      golonganDarah: json['golonganDarah'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      ipk: json['ipk'],
      ipkTerakhir: json['ipkTerakhir'],
      ipkasal: json['ipkasal'],
      isDisabilitas: json['isDisabilitas'],
      isTransfer: json['isTransfer'],
      jalurMasuk: json['jalurMasuk'],
      jenisKelamin: json['jenisKelamin'],
      jenisTinggal: json['jenisTinggal'],
      jenjang: json['jenjang'],
      kategoriUkt: json['kategoriUKT'],
      kecamatan: json['kecamatan'],
      kecamatanDomisili: json['kecamatanDomisili'],
      kesehatan:
          json['kesehatan'] != null
              ? (json['kesehatan'] as List)
                  .map((i) => Kesehatan.fromJson(i))
                  .toList()
              : null,
      kewarganegaraan: json['kewarganegaraan'],
      kodePos: json['kodePos'],
      kodePosDomisili: json['kodePosDomisili'],
      konseling:
          json['konseling'] != null
              ? (json['konseling'] as List)
                  .map((i) => Konseling.fromJson(i))
                  .toList()
              : null,
      kontakDarurat: json['kontakDarurat'],
      kota: json['kota'],
      kotaDomisili: json['kotaDomisili'],
      lastSyncedAt: json['lastSyncedAt'],
      nama: json['nama'],
      namaAyah: json['namaAyah'],
      namaIbuKandung: json['namaIbuKandung'],
      namaWali: json['namaWali'],
      nik: json['nik'],
      nim: json['nim'],
      nimlama: json['nimlama'],
      nirl: json['nirl'],
      nirm: json['nirm'],
      nisn: json['nisn'],
      noHp: json['noHP'],
      noIjazahSma: json['noIjazahSMA'],
      nomorKk: json['nomorKK'],
      nomorKps: json['nomorKPS'],
      npsn: json['npsn'],
      nupn: json['nupn'],
      pekerjaan: json['pekerjaan'],
      pekerjaanAyah: json['pekerjaanAyah'],
      pekerjaanIbu: json['pekerjaanIbu'],
      pengajuanSurat:
          json['pengajuanSurat'] != null
              ? (json['pengajuanSurat'] as List)
                  .map((i) => PengajuanSurat.fromJson(i))
                  .toList()
              : null,
      pengguna:
          json['pengguna'] != null ? User.fromJson(json['pengguna']) : null,
      penggunaId:
          json['penggunaID'] != null
              ? int.tryParse(json['penggunaID'].toString()) ??
                  json['penggunaID']
              : null,
      penghasilanOrtu:
          json['penghasilanOrtu'] != null
              ? int.tryParse(json['penghasilanOrtu'].toString()) ??
                  json['penghasilanOrtu']
              : null,
      pkkmbBanding:
          json['pkkmbBanding'] != null
              ? PkkmbBanding.fromJson(json['pkkmbBanding'])
              : null,
      pkkmbHasil:
          json['pkkmbHasil'] != null
              ? PkkmbHasil.fromJson(json['pkkmbHasil'])
              : null,
      pkkmbProgress:
          json['pkkmbProgress'] != null
              ? (json['pkkmbProgress'] as List)
                  .map((i) => PkkmbProgress.fromJson(i))
                  .toList()
              : null,
      pkkmbSertifikat:
          json['pkkmbSertifikat'] != null
              ? PkkmbSertifikat.fromJson(json['pkkmbSertifikat'])
              : null,
      prestasi:
          json['prestasi'] != null
              ? (json['prestasi'] as List)
                  .map((i) => Prestasi.fromJson(i))
                  .toList()
              : null,
      prodiAsal: json['prodiAsal'],
      programStudi:
          json['programStudi'] != null
              ? ProgramStudi.fromJson(json['programStudi'])
              : null,
      programStudiId:
          json['programStudiID'] != null
              ? int.tryParse(json['programStudiID'].toString()) ??
                  json['programStudiID']
              : null,
      provinsi: json['provinsi'],
      provinsiDomisili: json['provinsiDomisili'],
      riwayatOrganisasi:
          json['riwayatOrganisasi'] != null
              ? (json['riwayatOrganisasi'] as List)
                  .map((i) => RiwayatOrganisasi.fromJson(i))
                  .toList()
              : null,
      rt: json['rt'],
      rtdomisili: json['rtdomisili'],
      rw: json['rw'],
      rwdomisili: json['rwdomisili'],
      semesterSekarang:
          json['semesterSekarang'] != null
              ? int.tryParse(json['semesterSekarang'].toString()) ??
                  json['semesterSekarang']
              : null,
      sevimaHash: json['sevimaHash'],
      sistemKuliah: json['sistemKuliah'],
      sksasal: json['sksasal'],
      statusAkademik: json['statusAkademik'],
      statusAkun: json['statusAkun'],
      statusPernikahan: json['statusPernikahan'],
      tahunMasuk:
          json['tahunMasuk'] != null
              ? int.tryParse(json['tahunMasuk'].toString()) ??
                  json['tahunMasuk']
              : null,
      tanggalDaftar: json['tanggalDaftar'],
      tanggalLahir: json['tanggalLahir'],
      telepon: json['telepon'],
      tempatLahir: json['tempatLahir'],
      totalSks:
          json['totalSKS'] != null
              ? int.tryParse(json['totalSKS'].toString()) ?? json['totalSKS']
              : null,
      universitasAsal: json['universitasAsal'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agama': agama,
      'alamat': alamat,
      'alamatDomisili': alamatDomisili,
      'asalSekolah': asalSekolah,
      'aspirasi': aspirasi?.map((i) => i.toJson()).toList(),
      'beasiswa': beasiswa?.map((i) => i.toJson()).toList(),
      'created_at': createdAt,
      'creditLimit': creditLimit,
      'desa': desa,
      'desaDomisili': desaDomisili,
      'dosenPA': dosenPa?.toJson(),
      'dosenPAID': dosenPaid,
      'dusun': dusun,
      'dusunDomisili': dusunDomisili,
      'emailKampus': emailKampus,
      'emailPersonal': emailPersonal,
      'fakultas': fakultas?.toJson(),
      'fakultasID': fakultasId,
      'fotoURL': fotoUrl,
      'gelarBelakang': gelarBelakang,
      'gelarDepan': gelarDepan,
      'gelombang': gelombang,
      'golonganDarah': golonganDarah,
      'id': id,
      'ipk': ipk,
      'ipkTerakhir': ipkTerakhir,
      'ipkasal': ipkasal,
      'isDisabilitas': isDisabilitas,
      'isTransfer': isTransfer,
      'jalurMasuk': jalurMasuk,
      'jenisKelamin': jenisKelamin,
      'jenisTinggal': jenisTinggal,
      'jenjang': jenjang,
      'kategoriUKT': kategoriUkt,
      'kecamatan': kecamatan,
      'kecamatanDomisili': kecamatanDomisili,
      'kesehatan': kesehatan?.map((i) => i.toJson()).toList(),
      'kewarganegaraan': kewarganegaraan,
      'kodePos': kodePos,
      'kodePosDomisili': kodePosDomisili,
      'konseling': konseling?.map((i) => i.toJson()).toList(),
      'kontakDarurat': kontakDarurat,
      'kota': kota,
      'kotaDomisili': kotaDomisili,
      'lastSyncedAt': lastSyncedAt,
      'nama': nama,
      'namaAyah': namaAyah,
      'namaIbuKandung': namaIbuKandung,
      'namaWali': namaWali,
      'nik': nik,
      'nim': nim,
      'nimlama': nimlama,
      'nirl': nirl,
      'nirm': nirm,
      'nisn': nisn,
      'noHP': noHp,
      'noIjazahSMA': noIjazahSma,
      'nomorKK': nomorKk,
      'nomorKPS': nomorKps,
      'npsn': npsn,
      'nupn': nupn,
      'pekerjaan': pekerjaan,
      'pekerjaanAyah': pekerjaanAyah,
      'pekerjaanIbu': pekerjaanIbu,
      'pengajuanSurat': pengajuanSurat?.map((i) => i.toJson()).toList(),
      'pengguna': pengguna?.toJson(),
      'penggunaID': penggunaId,
      'penghasilanOrtu': penghasilanOrtu,
      'pkkmbBanding': pkkmbBanding?.toJson(),
      'pkkmbHasil': pkkmbHasil?.toJson(),
      'pkkmbProgress': pkkmbProgress?.map((i) => i.toJson()).toList(),
      'pkkmbSertifikat': pkkmbSertifikat?.toJson(),
      'prestasi': prestasi?.map((i) => i.toJson()).toList(),
      'prodiAsal': prodiAsal,
      'programStudi': programStudi?.toJson(),
      'programStudiID': programStudiId,
      'provinsi': provinsi,
      'provinsiDomisili': provinsiDomisili,
      'riwayatOrganisasi': riwayatOrganisasi?.map((i) => i.toJson()).toList(),
      'rt': rt,
      'rtdomisili': rtdomisili,
      'rw': rw,
      'rwdomisili': rwdomisili,
      'semesterSekarang': semesterSekarang,
      'sevimaHash': sevimaHash,
      'sistemKuliah': sistemKuliah,
      'sksasal': sksasal,
      'statusAkademik': statusAkademik,
      'statusAkun': statusAkun,
      'statusPernikahan': statusPernikahan,
      'tahunMasuk': tahunMasuk,
      'tanggalDaftar': tanggalDaftar,
      'tanggalLahir': tanggalLahir,
      'telepon': telepon,
      'tempatLahir': tempatLahir,
      'totalSKS': totalSks,
      'universitasAsal': universitasAsal,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    agama,
    alamat,
    alamatDomisili,
    asalSekolah,
    aspirasi,
    beasiswa,
    createdAt,
    creditLimit,
    desa,
    desaDomisili,
    dosenPa,
    dosenPaid,
    dusun,
    dusunDomisili,
    emailKampus,
    emailPersonal,
    fakultas,
    fakultasId,
    fotoUrl,
    gelarBelakang,
    gelarDepan,
    gelombang,
    golonganDarah,
    id,
    ipk,
    ipkTerakhir,
    ipkasal,
    isDisabilitas,
    isTransfer,
    jalurMasuk,
    jenisKelamin,
    jenisTinggal,
    jenjang,
    kategoriUkt,
    kecamatan,
    kecamatanDomisili,
    kesehatan,
    kewarganegaraan,
    kodePos,
    kodePosDomisili,
    konseling,
    kontakDarurat,
    kota,
    kotaDomisili,
    lastSyncedAt,
    nama,
    namaAyah,
    namaIbuKandung,
    namaWali,
    nik,
    nim,
    nimlama,
    nirl,
    nirm,
    nisn,
    noHp,
    noIjazahSma,
    nomorKk,
    nomorKps,
    npsn,
    nupn,
    pekerjaan,
    pekerjaanAyah,
    pekerjaanIbu,
    pengajuanSurat,
    pengguna,
    penggunaId,
    penghasilanOrtu,
    pkkmbBanding,
    pkkmbHasil,
    pkkmbProgress,
    pkkmbSertifikat,
    prestasi,
    prodiAsal,
    programStudi,
    programStudiId,
    provinsi,
    provinsiDomisili,
    riwayatOrganisasi,
    rt,
    rtdomisili,
    rw,
    rwdomisili,
    semesterSekarang,
    sevimaHash,
    sistemKuliah,
    sksasal,
    statusAkademik,
    statusAkun,
    statusPernikahan,
    tahunMasuk,
    tanggalDaftar,
    tanggalLahir,
    telepon,
    tempatLahir,
    totalSks,
    universitasAsal,
    updatedAt,
  ];
}

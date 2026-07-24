import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/riwayat_organisasi.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/prestasi_mahasiswa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/prestasi_dosen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class Prestasi extends Equatable {
  final List<PrestasiMahasiswa>? anggotaMahasiswa;
  final String? bentuk;
  final String? buktiUrl;
  final String? cabang;
  final String? catatanVerifikator;
  final String? createdAt;
  final double? danaDiajukan;
  final double? danaDisetujui;
  final int? id;
  final String? jenisRekognisi;
  final int? jumlahUnitPeserta;
  final String? kategori;
  final String? kelompokPrestasi;
  final String? keterangan;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? namaKegiatan;
  final List<PrestasiDosen>? pembimbingDosen;
  final String? penyelenggara;
  final String? peringkat;
  final int? poin;
  final RiwayatOrganisasi? riwayatOrganisasi;
  final int? riwayatOrganisasiId;
  final String? simkatmawaId;
  final String? simkatmawaStatus;
  final String? status;
  final String? tanggal;
  final String? tingkat;
  final String? tipe;
  final String? updatedAt;
  final String? urlDokumenUndangan;
  final String? urlFotoUpp;
  final String? urlPeserta;
  final String? urlSertifikat;

  const Prestasi({
    this.anggotaMahasiswa,
    this.bentuk,
    this.buktiUrl,
    this.cabang,
    this.catatanVerifikator,
    this.createdAt,
    this.danaDiajukan,
    this.danaDisetujui,
    this.id,
    this.jenisRekognisi,
    this.jumlahUnitPeserta,
    this.kategori,
    this.kelompokPrestasi,
    this.keterangan,
    this.mahasiswa,
    this.mahasiswaId,
    this.namaKegiatan,
    this.pembimbingDosen,
    this.penyelenggara,
    this.peringkat,
    this.poin,
    this.riwayatOrganisasi,
    this.riwayatOrganisasiId,
    this.simkatmawaId,
    this.simkatmawaStatus,
    this.status,
    this.tanggal,
    this.tingkat,
    this.tipe,
    this.updatedAt,
    this.urlDokumenUndangan,
    this.urlFotoUpp,
    this.urlPeserta,
    this.urlSertifikat,
  });

  factory Prestasi.fromJson(Map<String, dynamic> json) {
    return Prestasi(
      anggotaMahasiswa:
          json['anggota_mahasiswa'] != null
              ? (json['anggota_mahasiswa'] as List)
                  .map((i) => PrestasiMahasiswa.fromJson(i))
                  .toList()
              : null,
      bentuk: json['bentuk'],
      buktiUrl: json['bukti_url'],
      cabang: json['cabang'],
      catatanVerifikator: json['catatan_verifikator'],
      createdAt: json['created_at'],
      danaDiajukan: json['dana_diajukan'],
      danaDisetujui: json['dana_disetujui'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      jenisRekognisi: json['jenis_rekognisi'],
      jumlahUnitPeserta:
          json['jumlah_unit_peserta'] != null
              ? int.tryParse(json['jumlah_unit_peserta'].toString()) ??
                  json['jumlah_unit_peserta']
              : null,
      kategori: json['kategori'],
      kelompokPrestasi: json['kelompok_prestasi'],
      keterangan: json['keterangan'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswa_id'] != null
              ? int.tryParse(json['mahasiswa_id'].toString()) ??
                  json['mahasiswa_id']
              : null,
      namaKegiatan: json['nama_kegiatan'],
      pembimbingDosen:
          json['pembimbing_dosen'] != null
              ? (json['pembimbing_dosen'] as List)
                  .map((i) => PrestasiDosen.fromJson(i))
                  .toList()
              : null,
      penyelenggara: json['penyelenggara'],
      peringkat: json['peringkat'],
      poin:
          json['poin'] != null
              ? int.tryParse(json['poin'].toString()) ?? json['poin']
              : null,
      riwayatOrganisasi:
          json['riwayat_organisasi'] != null
              ? RiwayatOrganisasi.fromJson(json['riwayat_organisasi'])
              : null,
      riwayatOrganisasiId:
          json['riwayat_organisasi_id'] != null
              ? int.tryParse(json['riwayat_organisasi_id'].toString()) ??
                  json['riwayat_organisasi_id']
              : null,
      simkatmawaId: json['simkatmawa_id'],
      simkatmawaStatus: json['simkatmawa_status'],
      status: json['status'],
      tanggal: json['tanggal'],
      tingkat: json['tingkat'],
      tipe: json['tipe'],
      updatedAt: json['updated_at'],
      urlDokumenUndangan: json['url_dokumen_undangan'],
      urlFotoUpp: json['url_foto_upp'],
      urlPeserta: json['url_peserta'],
      urlSertifikat: json['url_sertifikat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anggota_mahasiswa': anggotaMahasiswa?.map((i) => i.toJson()).toList(),
      'bentuk': bentuk,
      'bukti_url': buktiUrl,
      'cabang': cabang,
      'catatan_verifikator': catatanVerifikator,
      'created_at': createdAt,
      'dana_diajukan': danaDiajukan,
      'dana_disetujui': danaDisetujui,
      'id': id,
      'jenis_rekognisi': jenisRekognisi,
      'jumlah_unit_peserta': jumlahUnitPeserta,
      'kategori': kategori,
      'kelompok_prestasi': kelompokPrestasi,
      'keterangan': keterangan,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswa_id': mahasiswaId,
      'nama_kegiatan': namaKegiatan,
      'pembimbing_dosen': pembimbingDosen?.map((i) => i.toJson()).toList(),
      'penyelenggara': penyelenggara,
      'peringkat': peringkat,
      'poin': poin,
      'riwayat_organisasi': riwayatOrganisasi?.toJson(),
      'riwayat_organisasi_id': riwayatOrganisasiId,
      'simkatmawa_id': simkatmawaId,
      'simkatmawa_status': simkatmawaStatus,
      'status': status,
      'tanggal': tanggal,
      'tingkat': tingkat,
      'tipe': tipe,
      'updated_at': updatedAt,
      'url_dokumen_undangan': urlDokumenUndangan,
      'url_foto_upp': urlFotoUpp,
      'url_peserta': urlPeserta,
      'url_sertifikat': urlSertifikat,
    };
  }

  @override
  List<Object?> get props => [
    anggotaMahasiswa,
    bentuk,
    buktiUrl,
    cabang,
    catatanVerifikator,
    createdAt,
    danaDiajukan,
    danaDisetujui,
    id,
    jenisRekognisi,
    jumlahUnitPeserta,
    kategori,
    kelompokPrestasi,
    keterangan,
    mahasiswa,
    mahasiswaId,
    namaKegiatan,
    pembimbingDosen,
    penyelenggara,
    peringkat,
    poin,
    riwayatOrganisasi,
    riwayatOrganisasiId,
    simkatmawaId,
    simkatmawaStatus,
    status,
    tanggal,
    tingkat,
    tipe,
    updatedAt,
    urlDokumenUndangan,
    urlFotoUpp,
    urlPeserta,
    urlSertifikat,
  ];
}

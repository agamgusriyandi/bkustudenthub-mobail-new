import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/proposal_riwayat.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/laporan_pertanggungjawaban.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';

class Proposal extends Equatable {
  final Fakultas? fakultas;
  final int? fakultasId;
  final double? anggaran;
  final int? approvedDosenId;
  final int? approvedFakultasId;
  final String? bentukKegiatan;
  final String? catatan;
  final String? createdAt;
  final String? deskripsi;
  final String? fileUrl;
  final int? id;
  final String? indikatorKeberhasilan;
  final String? jadwalPelaksanaan;
  final String? jenis;
  final String? judul;
  final String? landasanKegiatan;
  final String? latarBelakang;
  final List<LaporanPertanggungjawaban>? lpj;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? mitra;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? pjKegiatan;
  final List<ProposalRiwayat>? riwayat;
  final String? sasaranKegiatan;
  final String? status;
  final String? sumberDana;
  final String? tanggalKegiatan;
  final String? tenggatLpj;
  final String? tujuanKegiatan;
  final String? updatedAt;

  const Proposal({
    this.fakultas,
    this.fakultasId,
    this.anggaran,
    this.approvedDosenId,
    this.approvedFakultasId,
    this.bentukKegiatan,
    this.catatan,
    this.createdAt,
    this.deskripsi,
    this.fileUrl,
    this.id,
    this.indikatorKeberhasilan,
    this.jadwalPelaksanaan,
    this.jenis,
    this.judul,
    this.landasanKegiatan,
    this.latarBelakang,
    this.lpj,
    this.mahasiswa,
    this.mahasiswaId,
    this.mitra,
    this.ormawa,
    this.ormawaId,
    this.pjKegiatan,
    this.riwayat,
    this.sasaranKegiatan,
    this.status,
    this.sumberDana,
    this.tanggalKegiatan,
    this.tenggatLpj,
    this.tujuanKegiatan,
    this.updatedAt,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      fakultas:
          json['Fakultas'] != null ? Fakultas.fromJson(json['Fakultas']) : null,
      fakultasId:
          json['FakultasID'] != null
              ? int.tryParse(json['FakultasID'].toString()) ??
                  json['FakultasID']
              : null,
      anggaran: json['anggaran'],
      approvedDosenId:
          json['approvedDosenID'] != null
              ? int.tryParse(json['approvedDosenID'].toString()) ??
                  json['approvedDosenID']
              : null,
      approvedFakultasId:
          json['approvedFakultasID'] != null
              ? int.tryParse(json['approvedFakultasID'].toString()) ??
                  json['approvedFakultasID']
              : null,
      bentukKegiatan: json['bentuk_kegiatan'],
      catatan: json['catatan'],
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      fileUrl: json['file_url'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      indikatorKeberhasilan: json['indikator_keberhasilan'],
      jadwalPelaksanaan: json['jadwal_pelaksanaan'],
      jenis: json['jenis'],
      judul: json['judul'],
      landasanKegiatan: json['landasan_kegiatan'],
      latarBelakang: json['latar_belakang'],
      lpj:
          json['lpj'] != null
              ? (json['lpj'] as List)
                  .map((i) => LaporanPertanggungjawaban.fromJson(i))
                  .toList()
              : null,
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      mitra: json['mitra'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      pjKegiatan: json['pj_kegiatan'],
      riwayat:
          json['riwayat'] != null
              ? (json['riwayat'] as List)
                  .map((i) => ProposalRiwayat.fromJson(i))
                  .toList()
              : null,
      sasaranKegiatan: json['sasaran_kegiatan'],
      status: json['status'],
      sumberDana: json['sumber_dana'],
      tanggalKegiatan: json['tanggalKegiatan'],
      tenggatLpj: json['tenggat_lpj'],
      tujuanKegiatan: json['tujuan_kegiatan'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Fakultas': fakultas?.toJson(),
      'FakultasID': fakultasId,
      'anggaran': anggaran,
      'approvedDosenID': approvedDosenId,
      'approvedFakultasID': approvedFakultasId,
      'bentuk_kegiatan': bentukKegiatan,
      'catatan': catatan,
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'file_url': fileUrl,
      'id': id,
      'indikator_keberhasilan': indikatorKeberhasilan,
      'jadwal_pelaksanaan': jadwalPelaksanaan,
      'jenis': jenis,
      'judul': judul,
      'landasan_kegiatan': landasanKegiatan,
      'latar_belakang': latarBelakang,
      'lpj': lpj?.map((i) => i.toJson()).toList(),
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'mitra': mitra,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'pj_kegiatan': pjKegiatan,
      'riwayat': riwayat?.map((i) => i.toJson()).toList(),
      'sasaran_kegiatan': sasaranKegiatan,
      'status': status,
      'sumber_dana': sumberDana,
      'tanggalKegiatan': tanggalKegiatan,
      'tenggat_lpj': tenggatLpj,
      'tujuan_kegiatan': tujuanKegiatan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    fakultas,
    fakultasId,
    anggaran,
    approvedDosenId,
    approvedFakultasId,
    bentukKegiatan,
    catatan,
    createdAt,
    deskripsi,
    fileUrl,
    id,
    indikatorKeberhasilan,
    jadwalPelaksanaan,
    jenis,
    judul,
    landasanKegiatan,
    latarBelakang,
    lpj,
    mahasiswa,
    mahasiswaId,
    mitra,
    ormawa,
    ormawaId,
    pjKegiatan,
    riwayat,
    sasaranKegiatan,
    status,
    sumberDana,
    tanggalKegiatan,
    tenggatLpj,
    tujuanKegiatan,
    updatedAt,
  ];
}

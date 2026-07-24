import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_kehadiran.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';

class OrmawaKegiatan extends Equatable {
  final String? bentukKegiatan;
  final String? createdAt;
  final String? deskripsi;
  final double? estimasiDana;
  final int? id;
  final String? indikatorKeberhasilan;
  final String? jadwalPelaksanaan;
  final String? judul;
  final List<OrmawaKehadiran>? kehadiran;
  final String? landasanKegiatan;
  final String? latarBelakang;
  final String? lokasi;
  final String? mitra;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? pjKegiatan;
  final String? sasaranKegiatan;
  final String? status;
  final String? sumberDana;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? tujuanKegiatan;
  final String? updatedAt;

  const OrmawaKegiatan({
    this.bentukKegiatan,
    this.createdAt,
    this.deskripsi,
    this.estimasiDana,
    this.id,
    this.indikatorKeberhasilan,
    this.jadwalPelaksanaan,
    this.judul,
    this.kehadiran,
    this.landasanKegiatan,
    this.latarBelakang,
    this.lokasi,
    this.mitra,
    this.ormawa,
    this.ormawaId,
    this.pjKegiatan,
    this.sasaranKegiatan,
    this.status,
    this.sumberDana,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.tujuanKegiatan,
    this.updatedAt,
  });

  factory OrmawaKegiatan.fromJson(Map<String, dynamic> json) {
    return OrmawaKegiatan(
      bentukKegiatan: json['bentuk_kegiatan'],
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      estimasiDana: json['estimasi_dana'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      indikatorKeberhasilan: json['indikator_keberhasilan'],
      jadwalPelaksanaan: json['jadwal_pelaksanaan'],
      judul: json['judul'],
      kehadiran:
          json['kehadiran'] != null
              ? (json['kehadiran'] as List)
                  .map((i) => OrmawaKehadiran.fromJson(i))
                  .toList()
              : null,
      landasanKegiatan: json['landasan_kegiatan'],
      latarBelakang: json['latar_belakang'],
      lokasi: json['lokasi'],
      mitra: json['mitra'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      pjKegiatan: json['pj_kegiatan'],
      sasaranKegiatan: json['sasaran_kegiatan'],
      status: json['status'],
      sumberDana: json['sumber_dana'],
      tanggalMulai: json['tanggalMulai'],
      tanggalSelesai: json['tanggalSelesai'],
      tujuanKegiatan: json['tujuan_kegiatan'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bentuk_kegiatan': bentukKegiatan,
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'estimasi_dana': estimasiDana,
      'id': id,
      'indikator_keberhasilan': indikatorKeberhasilan,
      'jadwal_pelaksanaan': jadwalPelaksanaan,
      'judul': judul,
      'kehadiran': kehadiran?.map((i) => i.toJson()).toList(),
      'landasan_kegiatan': landasanKegiatan,
      'latar_belakang': latarBelakang,
      'lokasi': lokasi,
      'mitra': mitra,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'pj_kegiatan': pjKegiatan,
      'sasaran_kegiatan': sasaranKegiatan,
      'status': status,
      'sumber_dana': sumberDana,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      'tujuan_kegiatan': tujuanKegiatan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    bentukKegiatan,
    createdAt,
    deskripsi,
    estimasiDana,
    id,
    indikatorKeberhasilan,
    jadwalPelaksanaan,
    judul,
    kehadiran,
    landasanKegiatan,
    latarBelakang,
    lokasi,
    mitra,
    ormawa,
    ormawaId,
    pjKegiatan,
    sasaranKegiatan,
    status,
    sumberDana,
    tanggalMulai,
    tanggalSelesai,
    tujuanKegiatan,
    updatedAt,
  ];
}

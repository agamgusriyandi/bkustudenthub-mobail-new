import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_anggota.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_notifikasi.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_pengumuman.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/kategori_ormawa.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_aspirasi.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_mutasi_saldo.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_kegiatan.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/program_studi.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_divisi.dart';

class Ormawa extends Equatable {
  final int? jumlahAnggota;
  final List<OrmawaAnggota>? anggota;
  final List<OrmawaAspirasi>? aspirasi;
  final String? createdAt;
  final String? deskripsi;
  final List<OrmawaDivisi>? divisi;
  final String? email;
  final Fakultas? fakultas;
  final int? fakultasId;
  final int? id;
  final String? instagram;
  final String? kategori;
  final KategoriOrmawa? kategoriDetail;
  final int? kategoriOrmawaId;
  final List<OrmawaKegiatan>? kegiatan;
  final String? logoUrl;
  final double? minIpk;
  final String? misi;
  final List<OrmawaMutasiSaldo>? mutasi;
  final String? nama;
  final List<OrmawaNotifikasi>? notifikasi;
  final bool? openRecruitment;
  final List<OrmawaPengumuman>? pengumuman;
  final String? phone;
  final int? poin;
  final ProgramStudi? programStudi;
  final int? programStudiId;
  final List<Proposal>? proposals;
  final String? recruitmentEnd;
  final String? recruitmentRequirements;
  final String? recruitmentStart;
  final String? rekening;
  final String? singkatan;
  final String? status;
  final int? tenggatLpjHari;
  final String? updatedAt;
  final String? visi;
  final String? website;

  const Ormawa({
    this.jumlahAnggota,
    this.anggota,
    this.aspirasi,
    this.createdAt,
    this.deskripsi,
    this.divisi,
    this.email,
    this.fakultas,
    this.fakultasId,
    this.id,
    this.instagram,
    this.kategori,
    this.kategoriDetail,
    this.kategoriOrmawaId,
    this.kegiatan,
    this.logoUrl,
    this.minIpk,
    this.misi,
    this.mutasi,
    this.nama,
    this.notifikasi,
    this.openRecruitment,
    this.pengumuman,
    this.phone,
    this.poin,
    this.programStudi,
    this.programStudiId,
    this.proposals,
    this.recruitmentEnd,
    this.recruitmentRequirements,
    this.recruitmentStart,
    this.rekening,
    this.singkatan,
    this.status,
    this.tenggatLpjHari,
    this.updatedAt,
    this.visi,
    this.website,
  });

  factory Ormawa.fromJson(Map<String, dynamic> json) {
    return Ormawa(
      jumlahAnggota:
          json['JumlahAnggota'] != null
              ? int.tryParse(json['JumlahAnggota'].toString()) ??
                  json['JumlahAnggota']
              : null,
      anggota:
          json['anggota'] != null
              ? (json['anggota'] as List)
                  .map((i) => OrmawaAnggota.fromJson(i))
                  .toList()
              : null,
      aspirasi:
          json['aspirasi'] != null
              ? (json['aspirasi'] as List)
                  .map((i) => OrmawaAspirasi.fromJson(i))
                  .toList()
              : null,
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      divisi:
          json['divisi'] != null
              ? (json['divisi'] as List)
                  .map((i) => OrmawaDivisi.fromJson(i))
                  .toList()
              : null,
      email: json['email'],
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      instagram: json['instagram'],
      kategori: json['kategori'],
      kategoriDetail:
          json['kategori_detail'] != null
              ? KategoriOrmawa.fromJson(json['kategori_detail'])
              : null,
      kategoriOrmawaId:
          json['kategori_ormawa_id'] != null
              ? int.tryParse(json['kategori_ormawa_id'].toString()) ??
                  json['kategori_ormawa_id']
              : null,
      kegiatan:
          json['kegiatan'] != null
              ? (json['kegiatan'] as List)
                  .map((i) => OrmawaKegiatan.fromJson(i))
                  .toList()
              : null,
      logoUrl: json['logoURL'],
      minIpk: json['min_ipk'],
      misi: json['misi'],
      mutasi:
          json['mutasi'] != null
              ? (json['mutasi'] as List)
                  .map((i) => OrmawaMutasiSaldo.fromJson(i))
                  .toList()
              : null,
      nama: json['nama'],
      notifikasi:
          json['notifikasi'] != null
              ? (json['notifikasi'] as List)
                  .map((i) => OrmawaNotifikasi.fromJson(i))
                  .toList()
              : null,
      openRecruitment: json['open_recruitment'],
      pengumuman:
          json['pengumuman'] != null
              ? (json['pengumuman'] as List)
                  .map((i) => OrmawaPengumuman.fromJson(i))
                  .toList()
              : null,
      phone: json['phone'],
      poin:
          json['poin'] != null
              ? int.tryParse(json['poin'].toString()) ?? json['poin']
              : null,
      programStudi:
          json['program_studi'] != null
              ? ProgramStudi.fromJson(json['program_studi'])
              : null,
      programStudiId:
          json['program_studi_id'] != null
              ? int.tryParse(json['program_studi_id'].toString()) ??
                  json['program_studi_id']
              : null,
      proposals:
          json['proposals'] != null
              ? (json['proposals'] as List)
                  .map((i) => Proposal.fromJson(i))
                  .toList()
              : null,
      recruitmentEnd: json['recruitment_end'],
      recruitmentRequirements: json['recruitment_requirements'],
      recruitmentStart: json['recruitment_start'],
      rekening: json['rekening'],
      singkatan: json['singkatan'],
      status: json['status'],
      tenggatLpjHari:
          json['tenggat_lpj_hari'] != null
              ? int.tryParse(json['tenggat_lpj_hari'].toString()) ??
                  json['tenggat_lpj_hari']
              : null,
      updatedAt: json['updated_at'],
      visi: json['visi'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'JumlahAnggota': jumlahAnggota,
      'anggota': anggota?.map((i) => i.toJson()).toList(),
      'aspirasi': aspirasi?.map((i) => i.toJson()).toList(),
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'divisi': divisi?.map((i) => i.toJson()).toList(),
      'email': email,
      'fakultas': fakultas?.toJson(),
      'fakultas_id': fakultasId,
      'id': id,
      'instagram': instagram,
      'kategori': kategori,
      'kategori_detail': kategoriDetail?.toJson(),
      'kategori_ormawa_id': kategoriOrmawaId,
      'kegiatan': kegiatan?.map((i) => i.toJson()).toList(),
      'logoURL': logoUrl,
      'min_ipk': minIpk,
      'misi': misi,
      'mutasi': mutasi?.map((i) => i.toJson()).toList(),
      'nama': nama,
      'notifikasi': notifikasi?.map((i) => i.toJson()).toList(),
      'open_recruitment': openRecruitment,
      'pengumuman': pengumuman?.map((i) => i.toJson()).toList(),
      'phone': phone,
      'poin': poin,
      'program_studi': programStudi?.toJson(),
      'program_studi_id': programStudiId,
      'proposals': proposals?.map((i) => i.toJson()).toList(),
      'recruitment_end': recruitmentEnd,
      'recruitment_requirements': recruitmentRequirements,
      'recruitment_start': recruitmentStart,
      'rekening': rekening,
      'singkatan': singkatan,
      'status': status,
      'tenggat_lpj_hari': tenggatLpjHari,
      'updated_at': updatedAt,
      'visi': visi,
      'website': website,
    };
  }

  @override
  List<Object?> get props => [
    jumlahAnggota,
    anggota,
    aspirasi,
    createdAt,
    deskripsi,
    divisi,
    email,
    fakultas,
    fakultasId,
    id,
    instagram,
    kategori,
    kategoriDetail,
    kategoriOrmawaId,
    kegiatan,
    logoUrl,
    minIpk,
    misi,
    mutasi,
    nama,
    notifikasi,
    openRecruitment,
    pengumuman,
    phone,
    poin,
    programStudi,
    programStudiId,
    proposals,
    recruitmentEnd,
    recruitmentRequirements,
    recruitmentStart,
    rekening,
    singkatan,
    status,
    tenggatLpjHari,
    updatedAt,
    visi,
    website,
  ];
}

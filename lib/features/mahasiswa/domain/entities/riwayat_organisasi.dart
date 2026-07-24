import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/prestasi.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class RiwayatOrganisasi extends Equatable {
  final String? apresiasi;
  final String? createdAt;
  final String? deskripsiKegiatan;
  final int? id;
  final String? jabatan;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? namaOrganisasi;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? periode;
  final int? periodeMulai;
  final int? periodeSelesai;
  final List<Prestasi>? prestasi;
  final String? status;
  final String? statusVerifikasi;
  final String? tipe;
  final String? updatedAt;

  const RiwayatOrganisasi({
    this.apresiasi,
    this.createdAt,
    this.deskripsiKegiatan,
    this.id,
    this.jabatan,
    this.mahasiswa,
    this.mahasiswaId,
    this.namaOrganisasi,
    this.ormawa,
    this.ormawaId,
    this.periode,
    this.periodeMulai,
    this.periodeSelesai,
    this.prestasi,
    this.status,
    this.statusVerifikasi,
    this.tipe,
    this.updatedAt,
  });

  factory RiwayatOrganisasi.fromJson(Map<String, dynamic> json) {
    return RiwayatOrganisasi(
      apresiasi: json['apresiasi'],
      createdAt: json['created_at'],
      deskripsiKegiatan: json['deskripsiKegiatan'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      jabatan: json['jabatan'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      namaOrganisasi: json['namaOrganisasi'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      periode: json['periode'],
      periodeMulai:
          json['periodeMulai'] != null
              ? int.tryParse(json['periodeMulai'].toString()) ??
                  json['periodeMulai']
              : null,
      periodeSelesai:
          json['periodeSelesai'] != null
              ? int.tryParse(json['periodeSelesai'].toString()) ??
                  json['periodeSelesai']
              : null,
      prestasi:
          json['prestasi'] != null
              ? (json['prestasi'] as List)
                  .map((i) => Prestasi.fromJson(i))
                  .toList()
              : null,
      status: json['status'],
      statusVerifikasi: json['statusVerifikasi'],
      tipe: json['tipe'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apresiasi': apresiasi,
      'created_at': createdAt,
      'deskripsiKegiatan': deskripsiKegiatan,
      'id': id,
      'jabatan': jabatan,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'namaOrganisasi': namaOrganisasi,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'periode': periode,
      'periodeMulai': periodeMulai,
      'periodeSelesai': periodeSelesai,
      'prestasi': prestasi?.map((i) => i.toJson()).toList(),
      'status': status,
      'statusVerifikasi': statusVerifikasi,
      'tipe': tipe,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    apresiasi,
    createdAt,
    deskripsiKegiatan,
    id,
    jabatan,
    mahasiswa,
    mahasiswaId,
    namaOrganisasi,
    ormawa,
    ormawaId,
    periode,
    periodeMulai,
    periodeSelesai,
    prestasi,
    status,
    statusVerifikasi,
    tipe,
    updatedAt,
  ];
}

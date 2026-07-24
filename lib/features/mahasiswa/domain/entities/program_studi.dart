import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/dosen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class ProgramStudi extends Equatable {
  final int? currentMahasiswa;
  final String? akreditasi;
  final String? createdAt;
  final List<Dosen>? dosen;
  final Fakultas? fakultas;
  final int? fakultasId;
  final int? id;
  final String? jenjang;
  final String? kepalaProdi;
  final String? kode;
  final List<Mahasiswa>? mahasiswa;
  final String? nama;
  final String? updatedAt;

  const ProgramStudi({
    this.currentMahasiswa,
    this.akreditasi,
    this.createdAt,
    this.dosen,
    this.fakultas,
    this.fakultasId,
    this.id,
    this.jenjang,
    this.kepalaProdi,
    this.kode,
    this.mahasiswa,
    this.nama,
    this.updatedAt,
  });

  factory ProgramStudi.fromJson(Map<String, dynamic> json) {
    return ProgramStudi(
      currentMahasiswa:
          json['CurrentMahasiswa'] != null
              ? int.tryParse(json['CurrentMahasiswa'].toString()) ??
                  json['CurrentMahasiswa']
              : null,
      akreditasi: json['akreditasi'],
      createdAt: json['created_at'],
      dosen:
          json['dosen'] != null
              ? (json['dosen'] as List).map((i) => Dosen.fromJson(i)).toList()
              : null,
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultasID'] != null
              ? int.tryParse(json['fakultasID'].toString()) ??
                  json['fakultasID']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      jenjang: json['jenjang'],
      kepalaProdi: json['kepalaProdi'],
      kode: json['kode'],
      mahasiswa:
          json['mahasiswa'] != null
              ? (json['mahasiswa'] as List)
                  .map((i) => Mahasiswa.fromJson(i))
                  .toList()
              : null,
      nama: json['nama'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CurrentMahasiswa': currentMahasiswa,
      'akreditasi': akreditasi,
      'created_at': createdAt,
      'dosen': dosen?.map((i) => i.toJson()).toList(),
      'fakultas': fakultas?.toJson(),
      'fakultasID': fakultasId,
      'id': id,
      'jenjang': jenjang,
      'kepalaProdi': kepalaProdi,
      'kode': kode,
      'mahasiswa': mahasiswa?.map((i) => i.toJson()).toList(),
      'nama': nama,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    currentMahasiswa,
    akreditasi,
    createdAt,
    dosen,
    fakultas,
    fakultasId,
    id,
    jenjang,
    kepalaProdi,
    kode,
    mahasiswa,
    nama,
    updatedAt,
  ];
}

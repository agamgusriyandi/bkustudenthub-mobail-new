import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class OrmawaAspirasi extends Equatable {
  final String? createdAt;
  final int? id;
  final String? isi;
  final String? judul;
  final String? kategori;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? status;
  final String? tanggapan;
  final String? updatedAt;

  const OrmawaAspirasi({
    this.createdAt,
    this.id,
    this.isi,
    this.judul,
    this.kategori,
    this.mahasiswa,
    this.mahasiswaId,
    this.ormawa,
    this.ormawaId,
    this.status,
    this.tanggapan,
    this.updatedAt,
  });

  factory OrmawaAspirasi.fromJson(Map<String, dynamic> json) {
    return OrmawaAspirasi(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isi: json['isi'],
      judul: json['judul'],
      kategori: json['kategori'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      status: json['status'],
      tanggapan: json['tanggapan'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'isi': isi,
      'judul': judul,
      'kategori': kategori,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'status': status,
      'tanggapan': tanggapan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    isi,
    judul,
    kategori,
    mahasiswa,
    mahasiswaId,
    ormawa,
    ormawaId,
    status,
    tanggapan,
    updatedAt,
  ];
}
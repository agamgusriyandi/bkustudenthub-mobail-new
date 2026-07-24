import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_kegiatan.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class OrmawaKehadiran extends Equatable {
  final String? createdAt;
  final int? id;
  final OrmawaKegiatan? kegiatan;
  final int? kegiatanId;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? status;
  final String? updatedAt;
  final String? waktuHadir;

  const OrmawaKehadiran({
    this.createdAt,
    this.id,
    this.kegiatan,
    this.kegiatanId,
    this.mahasiswa,
    this.mahasiswaId,
    this.status,
    this.updatedAt,
    this.waktuHadir,
  });

  factory OrmawaKehadiran.fromJson(Map<String, dynamic> json) {
    return OrmawaKehadiran(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      kegiatan:
          json['kegiatan'] != null
              ? OrmawaKegiatan.fromJson(json['kegiatan'])
              : null,
      kegiatanId:
          json['kegiatanID'] != null
              ? int.tryParse(json['kegiatanID'].toString()) ??
                  json['kegiatanID']
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
      status: json['status'],
      updatedAt: json['updated_at'],
      waktuHadir: json['waktuHadir'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'kegiatan': kegiatan?.toJson(),
      'kegiatanID': kegiatanId,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'status': status,
      'updated_at': updatedAt,
      'waktuHadir': waktuHadir,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    kegiatan,
    kegiatanId,
    mahasiswa,
    mahasiswaId,
    status,
    updatedAt,
    waktuHadir,
  ];
}

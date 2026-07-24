import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/pkkmb_kegiatan.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class PkkmbProgress extends Equatable {
  final String? createdAt;
  final int? id;
  final PkkmbKegiatan? kegiatan;
  final int? kegiatanId;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? status;
  final String? updatedAt;

  const PkkmbProgress({
    this.createdAt,
    this.id,
    this.kegiatan,
    this.kegiatanId,
    this.mahasiswa,
    this.mahasiswaId,
    this.status,
    this.updatedAt,
  });

  factory PkkmbProgress.fromJson(Map<String, dynamic> json) {
    return PkkmbProgress(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      kegiatan:
          json['kegiatan'] != null
              ? PkkmbKegiatan.fromJson(json['kegiatan'])
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
  ];
}

import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/dosen.dart';

class PrestasiDosen extends Equatable {
  final String? createdAt;
  final Dosen? dosen;
  final int? dosenId;
  final int? id;
  final String? namaDosen;
  final String? nidn;
  final String? peran;
  final int? prestasiId;
  final String? suratTugasUrl;
  final String? updatedAt;

  const PrestasiDosen({
    this.createdAt,
    this.dosen,
    this.dosenId,
    this.id,
    this.namaDosen,
    this.nidn,
    this.peran,
    this.prestasiId,
    this.suratTugasUrl,
    this.updatedAt,
  });

  factory PrestasiDosen.fromJson(Map<String, dynamic> json) {
    return PrestasiDosen(
      createdAt: json['created_at'],
      dosen: json['dosen'] != null ? Dosen.fromJson(json['dosen']) : null,
      dosenId:
          json['dosen_id'] != null
              ? int.tryParse(json['dosen_id'].toString()) ?? json['dosen_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      namaDosen: json['nama_dosen'],
      nidn: json['nidn'],
      peran: json['peran'],
      prestasiId:
          json['prestasi_id'] != null
              ? int.tryParse(json['prestasi_id'].toString()) ??
                  json['prestasi_id']
              : null,
      suratTugasUrl: json['surat_tugas_url'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'dosen': dosen?.toJson(),
      'dosen_id': dosenId,
      'id': id,
      'nama_dosen': namaDosen,
      'nidn': nidn,
      'peran': peran,
      'prestasi_id': prestasiId,
      'surat_tugas_url': suratTugasUrl,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    dosen,
    dosenId,
    id,
    namaDosen,
    nidn,
    peran,
    prestasiId,
    suratTugasUrl,
    updatedAt,
  ];
}

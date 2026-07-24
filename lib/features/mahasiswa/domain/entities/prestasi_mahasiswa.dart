import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class PrestasiMahasiswa extends Equatable {
  final String? createdAt;
  final int? id;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? peran;
  final int? prestasiId;
  final String? updatedAt;

  const PrestasiMahasiswa({
    this.createdAt,
    this.id,
    this.mahasiswa,
    this.mahasiswaId,
    this.peran,
    this.prestasiId,
    this.updatedAt,
  });

  factory PrestasiMahasiswa.fromJson(Map<String, dynamic> json) {
    return PrestasiMahasiswa(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswa_id'] != null
              ? int.tryParse(json['mahasiswa_id'].toString()) ??
                  json['mahasiswa_id']
              : null,
      peran: json['peran'],
      prestasiId:
          json['prestasi_id'] != null
              ? int.tryParse(json['prestasi_id'].toString()) ??
                  json['prestasi_id']
              : null,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswa_id': mahasiswaId,
      'peran': peran,
      'prestasi_id': prestasiId,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    mahasiswa,
    mahasiswaId,
    peran,
    prestasiId,
    updatedAt,
  ];
}

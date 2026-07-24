import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class PkkmbSertifikat extends Equatable {
  final String? createdAt;
  final String? fileUrl;
  final int? id;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? tanggalTerbit;
  final String? updatedAt;

  const PkkmbSertifikat({
    this.createdAt,
    this.fileUrl,
    this.id,
    this.mahasiswa,
    this.mahasiswaId,
    this.tanggalTerbit,
    this.updatedAt,
  });

  factory PkkmbSertifikat.fromJson(Map<String, dynamic> json) {
    return PkkmbSertifikat(
      createdAt: json['created_at'],
      fileUrl: json['fileURL'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
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
      tanggalTerbit: json['tanggalTerbit'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'fileURL': fileUrl,
      'id': id,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'tanggalTerbit': tanggalTerbit,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    fileUrl,
    id,
    mahasiswa,
    mahasiswaId,
    tanggalTerbit,
    updatedAt,
  ];
}

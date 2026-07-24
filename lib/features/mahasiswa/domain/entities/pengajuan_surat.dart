import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class PengajuanSurat extends Equatable {
  final String? catatan;
  final String? createdAt;
  final String? fileUrl;
  final int? id;
  final String? jenis;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? nomorSurat;
  final String? status;
  final String? updatedAt;

  const PengajuanSurat({
    this.catatan,
    this.createdAt,
    this.fileUrl,
    this.id,
    this.jenis,
    this.mahasiswa,
    this.mahasiswaId,
    this.nomorSurat,
    this.status,
    this.updatedAt,
  });

  factory PengajuanSurat.fromJson(Map<String, dynamic> json) {
    return PengajuanSurat(
      catatan: json['catatan'],
      createdAt: json['created_at'],
      fileUrl: json['fileURL'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      jenis: json['jenis'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      nomorSurat: json['nomorSurat'],
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catatan': catatan,
      'created_at': createdAt,
      'fileURL': fileUrl,
      'id': id,
      'jenis': jenis,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'nomorSurat': nomorSurat,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    catatan,
    createdAt,
    fileUrl,
    id,
    jenis,
    mahasiswa,
    mahasiswaId,
    nomorSurat,
    status,
    updatedAt,
  ];
}

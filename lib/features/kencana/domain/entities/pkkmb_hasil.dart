import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class PkkmbHasil extends Equatable {
  final String? createdAt;
  final int? id;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final double? nilai;
  final String? statusKelulusan;
  final String? updatedAt;

  const PkkmbHasil({
    this.createdAt,
    this.id,
    this.mahasiswa,
    this.mahasiswaId,
    this.nilai,
    this.statusKelulusan,
    this.updatedAt,
  });

  factory PkkmbHasil.fromJson(Map<String, dynamic> json) {
    return PkkmbHasil(
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
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      nilai: json['nilai'],
      statusKelulusan: json['statusKelulusan'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'nilai': nilai,
      'statusKelulusan': statusKelulusan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    mahasiswa,
    mahasiswaId,
    nilai,
    statusKelulusan,
    updatedAt,
  ];
}

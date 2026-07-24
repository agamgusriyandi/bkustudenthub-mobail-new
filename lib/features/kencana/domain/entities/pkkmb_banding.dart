import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class PkkmbBanding extends Equatable {
  final String? alasan;
  final String? createdAt;
  final int? id;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? status;
  final String? updatedAt;

  const PkkmbBanding({
    this.alasan,
    this.createdAt,
    this.id,
    this.mahasiswa,
    this.mahasiswaId,
    this.status,
    this.updatedAt,
  });

  factory PkkmbBanding.fromJson(Map<String, dynamic> json) {
    return PkkmbBanding(
      alasan: json['alasan'],
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
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alasan': alasan,
      'created_at': createdAt,
      'id': id,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    alasan,
    createdAt,
    id,
    mahasiswa,
    mahasiswaId,
    status,
    updatedAt,
  ];
}

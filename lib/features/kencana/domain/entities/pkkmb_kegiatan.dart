import 'package:equatable/equatable.dart';

class PkkmbKegiatan extends Equatable {
  final String? createdAt;
  final String? deskripsi;
  final int? id;
  final String? judul;
  final String? lokasi;
  final String? tanggal;
  final String? updatedAt;

  const PkkmbKegiatan({
    this.createdAt,
    this.deskripsi,
    this.id,
    this.judul,
    this.lokasi,
    this.tanggal,
    this.updatedAt,
  });

  factory PkkmbKegiatan.fromJson(Map<String, dynamic> json) {
    return PkkmbKegiatan(
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      judul: json['judul'],
      lokasi: json['lokasi'],
      tanggal: json['tanggal'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'id': id,
      'judul': judul,
      'lokasi': lokasi,
      'tanggal': tanggal,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    deskripsi,
    id,
    judul,
    lokasi,
    tanggal,
    updatedAt,
  ];
}

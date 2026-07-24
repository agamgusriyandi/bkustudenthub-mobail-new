import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/dosen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class Konseling extends Equatable {
  final String? catatan;
  final String? createdAt;
  final Dosen? dosen;
  final int? dosenId;
  final int? id;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? status;
  final String? tanggal;
  final String? topik;
  final String? updatedAt;

  const Konseling({
    this.catatan,
    this.createdAt,
    this.dosen,
    this.dosenId,
    this.id,
    this.mahasiswa,
    this.mahasiswaId,
    this.status,
    this.tanggal,
    this.topik,
    this.updatedAt,
  });

  factory Konseling.fromJson(Map<String, dynamic> json) {
    return Konseling(
      catatan: json['catatan'],
      createdAt: json['created_at'],
      dosen: json['dosen'] != null ? Dosen.fromJson(json['dosen']) : null,
      dosenId:
          json['dosenID'] != null
              ? int.tryParse(json['dosenID'].toString()) ?? json['dosenID']
              : null,
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
      tanggal: json['tanggal'],
      topik: json['topik'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catatan': catatan,
      'created_at': createdAt,
      'dosen': dosen?.toJson(),
      'dosenID': dosenId,
      'id': id,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'status': status,
      'tanggal': tanggal,
      'topik': topik,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    catatan,
    createdAt,
    dosen,
    dosenId,
    id,
    mahasiswa,
    mahasiswaId,
    status,
    tanggal,
    topik,
    updatedAt,
  ];
}

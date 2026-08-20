import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';

class OrmawaPengumuman extends Equatable {
  final String? createdAt;
  final int? id;
  final String? isi;
  final String? judul;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? tanggalMulai;
  final String? tanggalSelesai;
  final String? target;
  final String? updatedAt;

  const OrmawaPengumuman({
    this.createdAt,
    this.id,
    this.isi,
    this.judul,
    this.ormawa,
    this.ormawaId,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.target,
    this.updatedAt,
  });

  factory OrmawaPengumuman.fromJson(Map<String, dynamic> json) {
    return OrmawaPengumuman(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isi: json['isi'],
      judul: json['judul'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      tanggalMulai: json['tanggalMulai'],
      tanggalSelesai: json['tanggalSelesai'],
      target: json['target'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'isi': isi,
      'judul': judul,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'tanggalMulai': tanggalMulai,
      'tanggalSelesai': tanggalSelesai,
      'target': target,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    isi,
    judul,
    ormawa,
    ormawaId,
    tanggalMulai,
    tanggalSelesai,
    target,
    updatedAt,
  ];
}
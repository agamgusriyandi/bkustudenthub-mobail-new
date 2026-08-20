import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';

class OrmawaDivisi extends Equatable {
  final String? createdAt;
  final String? deskripsi;
  final int? id;
  final String? nama;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? updatedAt;

  const OrmawaDivisi({
    this.createdAt,
    this.deskripsi,
    this.id,
    this.nama,
    this.ormawa,
    this.ormawaId,
    this.updatedAt,
  });

  factory OrmawaDivisi.fromJson(Map<String, dynamic> json) {
    return OrmawaDivisi(
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      nama: json['nama'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'id': id,
      'nama': nama,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    deskripsi,
    id,
    nama,
    ormawa,
    ormawaId,
    updatedAt,
  ];
}
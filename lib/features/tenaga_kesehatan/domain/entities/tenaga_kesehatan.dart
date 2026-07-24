import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/core/domain/entities/user.dart';

class TenagaKesehatan extends Equatable {
  final String? createdAt;
  final String? email;
  final int? fakultasId;
  final String? fotoUrl;
  final int? id;
  final bool? isAktif;
  final String? lokasi;
  final String? nama;
  final String? noHp;
  final int? programStudiId;
  final String? scopeType;
  final String? spesialisasi;
  final String? updatedAt;
  final User? user;
  final int? userId;

  const TenagaKesehatan({
    this.createdAt,
    this.email,
    this.fakultasId,
    this.fotoUrl,
    this.id,
    this.isAktif,
    this.lokasi,
    this.nama,
    this.noHp,
    this.programStudiId,
    this.scopeType,
    this.spesialisasi,
    this.updatedAt,
    this.user,
    this.userId,
  });

  factory TenagaKesehatan.fromJson(Map<String, dynamic> json) {
    return TenagaKesehatan(
      createdAt: json['created_at'],
      email: json['email'],
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      fotoUrl: json['foto_url'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isAktif: json['is_aktif'],
      lokasi: json['lokasi'],
      nama: json['nama'],
      noHp: json['no_hp'],
      programStudiId:
          json['program_studi_id'] != null
              ? int.tryParse(json['program_studi_id'].toString()) ??
                  json['program_studi_id']
              : null,
      scopeType: json['scope_type'],
      spesialisasi: json['spesialisasi'],
      updatedAt: json['updated_at'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userId:
          json['user_id'] != null
              ? int.tryParse(json['user_id'].toString()) ?? json['user_id']
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'email': email,
      'fakultas_id': fakultasId,
      'foto_url': fotoUrl,
      'id': id,
      'is_aktif': isAktif,
      'lokasi': lokasi,
      'nama': nama,
      'no_hp': noHp,
      'program_studi_id': programStudiId,
      'scope_type': scopeType,
      'spesialisasi': spesialisasi,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'user_id': userId,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    email,
    fakultasId,
    fotoUrl,
    id,
    isAktif,
    lokasi,
    nama,
    noHp,
    programStudiId,
    scopeType,
    spesialisasi,
    updatedAt,
    user,
    userId,
  ];
}

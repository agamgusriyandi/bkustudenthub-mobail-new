import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/dosen.dart';

class User extends Equatable {
  final String? avatarUrl;
  final String? createdAt;
  final Dosen? dosen;
  final String? email;
  final int? fakultasId;
  final int? id;
  final String? namaLengkap;
  final String? noHp;
  final String? ormawaAssign;
  final int? ormawaId;
  final int? programStudiId;
  final String? role;
  final String? updatedAt;

  const User({
    this.avatarUrl,
    this.createdAt,
    this.dosen,
    this.email,
    this.fakultasId,
    this.id,
    this.namaLengkap,
    this.noHp,
    this.ormawaAssign,
    this.ormawaId,
    this.programStudiId,
    this.role,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'],
      dosen: json['dosen'] != null ? Dosen.fromJson(json['dosen']) : null,
      email: json['email'],
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      namaLengkap: json['nama_lengkap'],
      noHp: json['no_hp'],
      ormawaAssign: json['ormawa_assign'],
      ormawaId:
          json['ormawa_id'] != null
              ? int.tryParse(json['ormawa_id'].toString()) ?? json['ormawa_id']
              : null,
      programStudiId:
          json['program_studi_id'] != null
              ? int.tryParse(json['program_studi_id'].toString()) ??
                  json['program_studi_id']
              : null,
      role: json['role'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'dosen': dosen?.toJson(),
      'email': email,
      'fakultas_id': fakultasId,
      'id': id,
      'nama_lengkap': namaLengkap,
      'no_hp': noHp,
      'ormawa_assign': ormawaAssign,
      'ormawa_id': ormawaId,
      'program_studi_id': programStudiId,
      'role': role,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    avatarUrl,
    createdAt,
    dosen,
    email,
    fakultasId,
    id,
    namaLengkap,
    noHp,
    ormawaAssign,
    ormawaId,
    programStudiId,
    role,
    updatedAt,
  ];
}

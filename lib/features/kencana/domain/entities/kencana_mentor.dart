import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/core/domain/entities/user.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class KencanaMentor extends Equatable {
  final String? createdAt;
  final String? email;
  final Fakultas? fakultas;
  final int? fakultasId;
  final int? id;
  final String? jenisKelamin;
  final Mahasiswa? mahasiswa;
  final String? name;
  final String? phone;
  final String? scopeType;
  final String? status;
  final String? updatedAt;
  final User? user;
  final int? userId;

  const KencanaMentor({
    this.createdAt,
    this.email,
    this.fakultas,
    this.fakultasId,
    this.id,
    this.jenisKelamin,
    this.mahasiswa,
    this.name,
    this.phone,
    this.scopeType,
    this.status,
    this.updatedAt,
    this.user,
    this.userId,
  });

  factory KencanaMentor.fromJson(Map<String, dynamic> json) {
    return KencanaMentor(
      createdAt: json['created_at'],
      email: json['email'],
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      jenisKelamin: json['jenis_kelamin'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      name: json['name'],
      phone: json['phone'],
      scopeType: json['scope_type'],
      status: json['status'],
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
      'fakultas': fakultas?.toJson(),
      'fakultas_id': fakultasId,
      'id': id,
      'jenis_kelamin': jenisKelamin,
      'mahasiswa': mahasiswa?.toJson(),
      'name': name,
      'phone': phone,
      'scope_type': scopeType,
      'status': status,
      'updated_at': updatedAt,
      'user': user?.toJson(),
      'user_id': userId,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    email,
    fakultas,
    fakultasId,
    id,
    jenisKelamin,
    mahasiswa,
    name,
    phone,
    scopeType,
    status,
    updatedAt,
    user,
    userId,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';

class OrmawaNotifikasi extends Equatable {
  final String? createdAt;
  final int? id;
  final bool? isRead;
  final String? judul;
  final Ormawa? ormawa;
  final int? ormawaId;
  final String? pesan;
  final String? tipe;
  final String? updatedAt;

  const OrmawaNotifikasi({
    this.createdAt,
    this.id,
    this.isRead,
    this.judul,
    this.ormawa,
    this.ormawaId,
    this.pesan,
    this.tipe,
    this.updatedAt,
  });

  factory OrmawaNotifikasi.fromJson(Map<String, dynamic> json) {
    return OrmawaNotifikasi(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isRead: json['isRead'],
      judul: json['judul'],
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      pesan: json['pesan'],
      tipe: json['tipe'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'isRead': isRead,
      'judul': judul,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'pesan': pesan,
      'tipe': tipe,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    isRead,
    judul,
    ormawa,
    ormawaId,
    pesan,
    tipe,
    updatedAt,
  ];
}
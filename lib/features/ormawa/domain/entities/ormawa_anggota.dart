import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class OrmawaAnggota extends Equatable {
  final String? alasan;
  final String? createdAt;
  final String? customAnswers;
  final String? cvUrl;
  final String? divisi;
  final String? divisiPilihanDua;
  final int? id;
  final double? ipk;
  final String? joinedAt;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final Ormawa? ormawa;
  final int? ormawaId;
  final int? parentId;
  final String? rejectionReason;
  final String? reviewedAt;
  final int? reviewedBy;
  final String? role;
  final String? status;
  final String? updatedAt;

  const OrmawaAnggota({
    this.alasan,
    this.createdAt,
    this.customAnswers,
    this.cvUrl,
    this.divisi,
    this.divisiPilihanDua,
    this.id,
    this.ipk,
    this.joinedAt,
    this.mahasiswa,
    this.mahasiswaId,
    this.ormawa,
    this.ormawaId,
    this.parentId,
    this.rejectionReason,
    this.reviewedAt,
    this.reviewedBy,
    this.role,
    this.status,
    this.updatedAt,
  });

  factory OrmawaAnggota.fromJson(Map<String, dynamic> json) {
    return OrmawaAnggota(
      alasan: json['alasan'],
      createdAt: json['created_at'],
      customAnswers: json['custom_answers'],
      cvUrl: json['cv_url'],
      divisi: json['divisi'],
      divisiPilihanDua: json['divisi_pilihan_dua'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      ipk: json['ipk'],
      joinedAt: json['joinedAt'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswaID'] != null
              ? int.tryParse(json['mahasiswaID'].toString()) ??
                  json['mahasiswaID']
              : null,
      ormawa: json['ormawa'] != null ? Ormawa.fromJson(json['ormawa']) : null,
      ormawaId:
          json['ormawaID'] != null
              ? int.tryParse(json['ormawaID'].toString()) ?? json['ormawaID']
              : null,
      parentId:
          json['parentID'] != null
              ? int.tryParse(json['parentID'].toString()) ?? json['parentID']
              : null,
      rejectionReason: json['rejection_reason'],
      reviewedAt: json['reviewed_at'],
      reviewedBy:
          json['reviewed_by'] != null
              ? int.tryParse(json['reviewed_by'].toString()) ??
                  json['reviewed_by']
              : null,
      role: json['role'],
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alasan': alasan,
      'created_at': createdAt,
      'custom_answers': customAnswers,
      'cv_url': cvUrl,
      'divisi': divisi,
      'divisi_pilihan_dua': divisiPilihanDua,
      'id': id,
      'ipk': ipk,
      'joinedAt': joinedAt,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswaID': mahasiswaId,
      'ormawa': ormawa?.toJson(),
      'ormawaID': ormawaId,
      'parentID': parentId,
      'rejection_reason': rejectionReason,
      'reviewed_at': reviewedAt,
      'reviewed_by': reviewedBy,
      'role': role,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    alasan,
    createdAt,
    customAnswers,
    cvUrl,
    divisi,
    divisiPilihanDua,
    id,
    ipk,
    joinedAt,
    mahasiswa,
    mahasiswaId,
    ormawa,
    ormawaId,
    parentId,
    rejectionReason,
    reviewedAt,
    reviewedBy,
    role,
    status,
    updatedAt,
  ];
}

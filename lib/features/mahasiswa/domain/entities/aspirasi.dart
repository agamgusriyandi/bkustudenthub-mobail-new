import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class Aspirasi extends Equatable {
  final String? createdAt;
  final String? deadline;
  final int? id;
  final bool? isAnonim;
  final String? isi;
  final String? judul;
  final String? kategori;
  final String? lampiranUrl;
  final Mahasiswa? mahasiswa;
  final int? mahasiswaId;
  final String? prioritas;
  final String? respon;
  final String? status;
  final String? tujuan;
  final String? updatedAt;

  const Aspirasi({
    this.createdAt,
    this.deadline,
    this.id,
    this.isAnonim,
    this.isi,
    this.judul,
    this.kategori,
    this.lampiranUrl,
    this.mahasiswa,
    this.mahasiswaId,
    this.prioritas,
    this.respon,
    this.status,
    this.tujuan,
    this.updatedAt,
  });

  factory Aspirasi.fromJson(Map<String, dynamic> json) {
    return Aspirasi(
      createdAt: json['created_at'],
      deadline: json['deadline'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isAnonim: json['is_anonim'],
      isi: json['isi'],
      judul: json['judul'],
      kategori: json['kategori'],
      lampiranUrl: json['lampiran_url'],
      mahasiswa:
          json['mahasiswa'] != null
              ? Mahasiswa.fromJson(json['mahasiswa'])
              : null,
      mahasiswaId:
          json['mahasiswa_id'] != null
              ? int.tryParse(json['mahasiswa_id'].toString()) ??
                  json['mahasiswa_id']
              : null,
      prioritas: json['prioritas'],
      respon: json['respon'],
      status: json['status'],
      tujuan: json['tujuan'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'deadline': deadline,
      'id': id,
      'is_anonim': isAnonim,
      'isi': isi,
      'judul': judul,
      'kategori': kategori,
      'lampiran_url': lampiranUrl,
      'mahasiswa': mahasiswa?.toJson(),
      'mahasiswa_id': mahasiswaId,
      'prioritas': prioritas,
      'respon': respon,
      'status': status,
      'tujuan': tujuan,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    deadline,
    id,
    isAnonim,
    isi,
    judul,
    kategori,
    lampiranUrl,
    mahasiswa,
    mahasiswaId,
    prioritas,
    respon,
    status,
    tujuan,
    updatedAt,
  ];
}

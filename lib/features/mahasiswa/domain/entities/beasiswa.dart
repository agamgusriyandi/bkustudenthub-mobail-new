import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/beasiswa_pendaftaran.dart';

class Beasiswa extends Equatable {
  final double? anggaran;
  final String? createdAt;
  final String? customFields;
  final String? deadline;
  final String? deskripsi;
  final String? fileKtm;
  final String? fileSertifikat;
  final String? fileTranskrip;
  final int? id;
  final double? ipkMin;
  final String? kategori;
  final int? kuota;
  final String? nama;
  final double? nilaiBantuan;
  final List<BeasiswaPendaftaran>? pendaftaran;
  final String? penyelenggara;
  final String? persyaratan;
  final String? skema;
  final String? updatedAt;

  const Beasiswa({
    this.anggaran,
    this.createdAt,
    this.customFields,
    this.deadline,
    this.deskripsi,
    this.fileKtm,
    this.fileSertifikat,
    this.fileTranskrip,
    this.id,
    this.ipkMin,
    this.kategori,
    this.kuota,
    this.nama,
    this.nilaiBantuan,
    this.pendaftaran,
    this.penyelenggara,
    this.persyaratan,
    this.skema,
    this.updatedAt,
  });

  factory Beasiswa.fromJson(Map<String, dynamic> json) {
    return Beasiswa(
      anggaran: json['anggaran'],
      createdAt: json['created_at'],
      customFields: json['custom_fields'],
      deadline: json['deadline'],
      deskripsi: json['deskripsi'],
      fileKtm: json['file_ktm'],
      fileSertifikat: json['file_sertifikat'],
      fileTranskrip: json['file_transkrip'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      ipkMin: json['ipk_min'],
      kategori: json['kategori'],
      kuota:
          json['kuota'] != null
              ? int.tryParse(json['kuota'].toString()) ?? json['kuota']
              : null,
      nama: json['nama'],
      nilaiBantuan: json['nilai_bantuan'],
      pendaftaran:
          json['pendaftaran'] != null
              ? (json['pendaftaran'] as List)
                  .map((i) => BeasiswaPendaftaran.fromJson(i))
                  .toList()
              : null,
      penyelenggara: json['penyelenggara'],
      persyaratan: json['persyaratan'],
      skema: json['skema'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'anggaran': anggaran,
      'created_at': createdAt,
      'custom_fields': customFields,
      'deadline': deadline,
      'deskripsi': deskripsi,
      'file_ktm': fileKtm,
      'file_sertifikat': fileSertifikat,
      'file_transkrip': fileTranskrip,
      'id': id,
      'ipk_min': ipkMin,
      'kategori': kategori,
      'kuota': kuota,
      'nama': nama,
      'nilai_bantuan': nilaiBantuan,
      'pendaftaran': pendaftaran?.map((i) => i.toJson()).toList(),
      'penyelenggara': penyelenggara,
      'persyaratan': persyaratan,
      'skema': skema,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    anggaran,
    createdAt,
    customFields,
    deadline,
    deskripsi,
    fileKtm,
    fileSertifikat,
    fileTranskrip,
    id,
    ipkMin,
    kategori,
    kuota,
    nama,
    nilaiBantuan,
    pendaftaran,
    penyelenggara,
    persyaratan,
    skema,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/proposal.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/dosen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/program_studi.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class Fakultas extends Equatable {
  final String? createdAt;
  final String? dekan;
  final List<Dosen>? dosen;
  final String? email;
  final int? id;
  final String? kode;
  final List<Mahasiswa>? mahasiswa;
  final String? nama;
  final String? noHp;
  final List<ProgramStudi>? programStudi;
  final List<Proposal>? proposals;
  final String? updatedAt;

  const Fakultas({
    this.createdAt,
    this.dekan,
    this.dosen,
    this.email,
    this.id,
    this.kode,
    this.mahasiswa,
    this.nama,
    this.noHp,
    this.programStudi,
    this.proposals,
    this.updatedAt,
  });

  factory Fakultas.fromJson(Map<String, dynamic> json) {
    return Fakultas(
      createdAt: json['created_at'],
      dekan: json['dekan'],
      dosen:
          json['dosen'] != null
              ? (json['dosen'] as List).map((i) => Dosen.fromJson(i)).toList()
              : null,
      email: json['email'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      kode: json['kode'],
      mahasiswa:
          json['mahasiswa'] != null
              ? (json['mahasiswa'] as List)
                  .map((i) => Mahasiswa.fromJson(i))
                  .toList()
              : null,
      nama: json['nama'],
      noHp: json['noHP'],
      programStudi:
          json['programStudi'] != null
              ? (json['programStudi'] as List)
                  .map((i) => ProgramStudi.fromJson(i))
                  .toList()
              : null,
      proposals:
          json['proposals'] != null
              ? (json['proposals'] as List)
                  .map((i) => Proposal.fromJson(i))
                  .toList()
              : null,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'dekan': dekan,
      'dosen': dosen?.map((i) => i.toJson()).toList(),
      'email': email,
      'id': id,
      'kode': kode,
      'mahasiswa': mahasiswa?.map((i) => i.toJson()).toList(),
      'nama': nama,
      'noHP': noHp,
      'programStudi': programStudi?.map((i) => i.toJson()).toList(),
      'proposals': proposals?.map((i) => i.toJson()).toList(),
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    dekan,
    dosen,
    email,
    id,
    kode,
    mahasiswa,
    nama,
    noHp,
    programStudi,
    proposals,
    updatedAt,
  ];
}

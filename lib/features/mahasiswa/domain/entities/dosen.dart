import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/core/domain/entities/user.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/konseling.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/program_studi.dart';

class Dosen extends Equatable {
  final String? agama;
  final String? alamat;
  final String? createdAt;
  final String? email;
  final Fakultas? fakultas;
  final int? fakultasId;
  final int? id;
  final bool? isDpa;
  final String? jabatan;
  final String? jenisKelamin;
  final List<Konseling>? konseling;
  final List<Mahasiswa>? mahasiswaBimbingan;
  final String? nama;
  final String? nidn;
  final String? nik;
  final String? nip;
  final String? noHp;
  final User? pengguna;
  final int? penggunaId;
  final ProgramStudi? programStudi;
  final int? programStudiId;
  final String? statusAktif;
  final String? statusKepegawaian;
  final String? tanggalLahir;
  final String? tempatLahir;
  final String? updatedAt;

  const Dosen({
    this.agama,
    this.alamat,
    this.createdAt,
    this.email,
    this.fakultas,
    this.fakultasId,
    this.id,
    this.isDpa,
    this.jabatan,
    this.jenisKelamin,
    this.konseling,
    this.mahasiswaBimbingan,
    this.nama,
    this.nidn,
    this.nik,
    this.nip,
    this.noHp,
    this.pengguna,
    this.penggunaId,
    this.programStudi,
    this.programStudiId,
    this.statusAktif,
    this.statusKepegawaian,
    this.tanggalLahir,
    this.tempatLahir,
    this.updatedAt,
  });

  factory Dosen.fromJson(Map<String, dynamic> json) {
    return Dosen(
      agama: json['agama'],
      alamat: json['alamat'],
      createdAt: json['created_at'],
      email: json['email'],
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultasID'] != null
              ? int.tryParse(json['fakultasID'].toString()) ??
                  json['fakultasID']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isDpa: json['isDPA'],
      jabatan: json['jabatan'],
      jenisKelamin: json['jenisKelamin'],
      konseling:
          json['konseling'] != null
              ? (json['konseling'] as List)
                  .map((i) => Konseling.fromJson(i))
                  .toList()
              : null,
      mahasiswaBimbingan:
          json['mahasiswaBimbingan'] != null
              ? (json['mahasiswaBimbingan'] as List)
                  .map((i) => Mahasiswa.fromJson(i))
                  .toList()
              : null,
      nama: json['nama'],
      nidn: json['nidn'],
      nik: json['nik'],
      nip: json['nip'],
      noHp: json['noHP'],
      pengguna:
          json['pengguna'] != null ? User.fromJson(json['pengguna']) : null,
      penggunaId:
          json['pengguna_id'] != null
              ? int.tryParse(json['pengguna_id'].toString()) ??
                  json['pengguna_id']
              : null,
      programStudi:
          json['programStudi'] != null
              ? ProgramStudi.fromJson(json['programStudi'])
              : null,
      programStudiId:
          json['programStudiID'] != null
              ? int.tryParse(json['programStudiID'].toString()) ??
                  json['programStudiID']
              : null,
      statusAktif: json['statusAktif'],
      statusKepegawaian: json['statusKepegawaian'],
      tanggalLahir: json['tanggalLahir'],
      tempatLahir: json['tempatLahir'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agama': agama,
      'alamat': alamat,
      'created_at': createdAt,
      'email': email,
      'fakultas': fakultas?.toJson(),
      'fakultasID': fakultasId,
      'id': id,
      'isDPA': isDpa,
      'jabatan': jabatan,
      'jenisKelamin': jenisKelamin,
      'konseling': konseling?.map((i) => i.toJson()).toList(),
      'mahasiswaBimbingan': mahasiswaBimbingan?.map((i) => i.toJson()).toList(),
      'nama': nama,
      'nidn': nidn,
      'nik': nik,
      'nip': nip,
      'noHP': noHp,
      'pengguna': pengguna?.toJson(),
      'pengguna_id': penggunaId,
      'programStudi': programStudi?.toJson(),
      'programStudiID': programStudiId,
      'statusAktif': statusAktif,
      'statusKepegawaian': statusKepegawaian,
      'tanggalLahir': tanggalLahir,
      'tempatLahir': tempatLahir,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    agama,
    alamat,
    createdAt,
    email,
    fakultas,
    fakultasId,
    id,
    isDpa,
    jabatan,
    jenisKelamin,
    konseling,
    mahasiswaBimbingan,
    nama,
    nidn,
    nik,
    nip,
    noHp,
    pengguna,
    penggunaId,
    programStudi,
    programStudiId,
    statusAktif,
    statusKepegawaian,
    tanggalLahir,
    tempatLahir,
    updatedAt,
  ];
}

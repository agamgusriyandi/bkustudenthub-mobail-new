import 'package:equatable/equatable.dart';

class KategoriOrmawa extends Equatable {
  final String? createdAt;
  final String? deskripsi;
  final int? id;
  final bool? isSystem;
  final String? nama;
  final bool? terafiliasiFakultas;
  final String? updatedAt;
  final int? urutan;
  final bool? wajibProdi;

  const KategoriOrmawa({
    this.createdAt,
    this.deskripsi,
    this.id,
    this.isSystem,
    this.nama,
    this.terafiliasiFakultas,
    this.updatedAt,
    this.urutan,
    this.wajibProdi,
  });

  factory KategoriOrmawa.fromJson(Map<String, dynamic> json) {
    return KategoriOrmawa(
      createdAt: json['created_at'],
      deskripsi: json['deskripsi'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isSystem: json['is_system'],
      nama: json['nama'],
      terafiliasiFakultas: json['terafiliasi_fakultas'],
      updatedAt: json['updated_at'],
      urutan:
          json['urutan'] != null
              ? int.tryParse(json['urutan'].toString()) ?? json['urutan']
              : null,
      wajibProdi: json['wajib_prodi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'deskripsi': deskripsi,
      'id': id,
      'is_system': isSystem,
      'nama': nama,
      'terafiliasi_fakultas': terafiliasiFakultas,
      'updated_at': updatedAt,
      'urutan': urutan,
      'wajib_prodi': wajibProdi,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    deskripsi,
    id,
    isSystem,
    nama,
    terafiliasiFakultas,
    updatedAt,
    urutan,
    wajibProdi,
  ];
}

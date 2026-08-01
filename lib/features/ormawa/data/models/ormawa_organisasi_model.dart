import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';

class OrmawaOrganisasiModel extends OrmawaOrganisasi {
  OrmawaOrganisasiModel({
    required super.id,
    required super.nama,
    required super.deskripsi,
    super.logoUrl,
    super.visi,
    super.misi,
    super.alamat,
    super.email,
    super.website,
    super.instagram,
    super.tahunBerdiri,
    super.status,
    super.createdAt,
    super.updatedAt,
  });

  factory OrmawaOrganisasiModel.fromJson(Map<String, dynamic> json) {
    return OrmawaOrganisasiModel(
      id: json['ID'] ?? json['id'] ?? 0,
      nama: json['Nama'] ?? json['nama'] ?? '',
      deskripsi: json['Deskripsi'] ?? json['deskripsi'] ?? '',
      logoUrl: json['LogoURL'] ?? json['logo_url'] ?? json['logo'],
      visi: json['Visi'] ?? json['visi'],
      misi: json['Misi'] ?? json['misi'],
      alamat: json['Alamat'] ?? json['alamat'],
      email: json['Email'] ?? json['email'],
      website: json['Website'] ?? json['website'],
      instagram: json['Instagram'] ?? json['instagram'],
      tahunBerdiri: json['TahunBerdiri'] ?? json['tahun_berdiri'],
      status: json['Status'] ?? json['status'] ?? 'aktif',
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'Nama': nama,
        'Deskripsi': deskripsi,
        'Visi': visi,
        'Misi': misi,
        'Alamat': alamat,
        'Email': email,
        'Website': website,
        'Instagram': instagram,
        'TahunBerdiri': tahunBerdiri,
        'Status': status,
      };

  OrmawaOrganisasi toEntity() => OrmawaOrganisasi(
        id: id,
        nama: nama,
        deskripsi: deskripsi,
        logoUrl: logoUrl,
        visi: visi,
        misi: misi,
        alamat: alamat,
        email: email,
        website: website,
        instagram: instagram,
        tahunBerdiri: tahunBerdiri,
        status: status,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

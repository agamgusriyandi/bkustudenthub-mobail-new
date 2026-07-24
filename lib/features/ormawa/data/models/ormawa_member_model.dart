import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';

class OrmawaMemberModel extends OrmawaMember {
  OrmawaMemberModel({
    required super.id,
    required super.mahasiswaId,
    required super.name,
    required super.nim,
    required super.role,
    required super.division,
    required super.status,
    super.email,
    super.phone,
    super.joinedAt,
    super.fotoUrl,
    super.periode,
  });

  factory OrmawaMemberModel.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['Mahasiswa'] as Map<String, dynamic>?;
    return OrmawaMemberModel(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      mahasiswaId:
          (json['MahasiswaID'] ?? json['mahasiswaId'] ?? '').toString(),
      name: mahasiswa?['Nama'] ?? mahasiswa?['nama'] ?? json['name'] ?? '',
      nim: mahasiswa?['NIM'] ?? mahasiswa?['nim'] ?? json['nim'] ?? '',
      role: json['Role'] ?? json['role'] ?? '',
      division: json['Divisi'] ?? json['division'] ?? '',
      status: json['Status'] ?? json['status'] ?? 'Aktif',
      email:
          mahasiswa?['email_kampus'] ??
          mahasiswa?['EmailKampus'] ??
          json['email'] ??
          '',
      phone: mahasiswa?['no_hp'] ?? mahasiswa?['NoHP'] ?? json['phone'] ?? '',
      joinedAt: DateTime.tryParse(
        json['JoinedAt'] ?? json['joinedAt'] ?? json['joined_at'] ?? '',
      ),
      fotoUrl:
          mahasiswa?['FotoURL'] ??
          mahasiswa?['foto_url'] ??
          mahasiswa?['Foto'] ??
          json['fotoUrl'] ??
          '',
      periode: json['Periode'] ?? json['periode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'MahasiswaID': int.tryParse(mahasiswaId),
      'Role': role,
      'Divisi': division,
      'Status': status,
      'EmailKampus': email,
      'NoHP': phone,
      'JoinedAt': joinedAt?.toIso8601String(),
    };
  }
}

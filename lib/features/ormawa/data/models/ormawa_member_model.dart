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
    super.prodi,
  });

  factory OrmawaMemberModel.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['Mahasiswa'] as Map<String, dynamic>?;
    final programStudi = mahasiswa?['ProgramStudi'] as Map<String, dynamic>?;
    final pengguna = (mahasiswa?['Pengguna'] ??
        mahasiswa?['pengguna'] ??
        json['Pengguna'] ??
        json['pengguna']) as Map<String, dynamic>?;

    final rawFoto = mahasiswa?['FotoURL'] ??
        mahasiswa?['foto_url'] ??
        mahasiswa?['Foto'] ??
        mahasiswa?['foto'] ??
        pengguna?['avatar_url'] ??
        pengguna?['AvatarURL'] ??
        pengguna?['foto'] ??
        pengguna?['Foto'] ??
        json['avatar_url'] ??
        json['AvatarURL'] ??
        json['foto_url'] ??
        json['FotoURL'] ??
        json['fotoUrl'] ??
        json['foto'] ??
        '';

    final prodiName = programStudi?['Nama'] ??
        programStudi?['nama'] ??
        mahasiswa?['prodi'] ??
        mahasiswa?['Prodi'] ??
        json['prodi'] ??
        '';

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
      fotoUrl: rawFoto.toString(),
      periode: json['Periode'] ?? json['periode'] ?? '',
      prodi: prodiName.toString(),
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
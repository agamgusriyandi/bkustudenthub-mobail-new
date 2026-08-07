import 'package:equatable/equatable.dart';

class Patient extends Equatable {
  final int id;
  final String nama;
  final String nim;
  final String jenisKelamin;
  final String prodi;
  final String fakultas;
  final int semester;
  final String? noHP;
  final String? email;
  final String? emailKampus;
  final String? fotoURL;
  final String? golonganDarah;
  final String? alergiObat;

  const Patient({
    required this.id,
    required this.nama,
    required this.nim,
    required this.jenisKelamin,
    required this.prodi,
    required this.fakultas,
    required this.semester,
    this.noHP,
    this.email,
    this.emailKampus,
    this.fotoURL,
    this.golonganDarah,
    this.alergiObat,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    // Handle nested prodi and fakultas from backend
    final prodiData = json['program_studi'] ?? json['ProgramStudi'] ?? json;
    final fakData = json['fakultas'] ?? json['Fakultas'] ?? json;
    final userMap = json['user'] is Map ? json['user'] : null;
    final penggunaMap = json['pengguna'] is Map ? json['pengguna'] : null;
    final userSource = userMap ?? penggunaMap;

    return Patient(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['Nama'] ?? '',
      nim: json['nim'] ?? json['NIM'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? json['JenisKelamin'] ?? '',
      prodi: prodiData is Map ? (prodiData['nama'] ?? '') : (prodiData ?? ''),
      fakultas: fakData is Map ? (fakData['nama'] ?? '') : (fakData ?? ''),
      semester: json['semester_sekarang'] ?? json['SemesterSekarang'] ?? 1,
      noHP:
          json['no_hp'] ??
          json['NoHP'] ??
          (userSource != null
              ? (userSource['no_hp'] ?? userSource['phone'])
              : null),
      email:
          json['email_personal'] ??
          json['EmailPersonal'] ??
          (userSource != null ? userSource['email'] : null),
      emailKampus: json['email_kampus'] ?? json['EmailKampus'],
      fotoURL: () {
        final possibleUrls = [
          json['foto_url'],
          json['FotoURL'],
          json['avatar_url'],
          json['avatar'],
          json['foto'],
          if (userSource != null) ...[
            userSource['avatar_url'],
            userSource['avatar'],
            userSource['foto'],
            userSource['foto_url'],
          ],
        ];
        for (final url in possibleUrls) {
          if (url != null && url.toString().trim().isNotEmpty) {
            return url.toString();
          }
        }
        return null;
      }(),
      golonganDarah: json['golongan_darah'] ?? json['GolonganDarah'],
      alergiObat: json['alergi_obat'] ?? json['AlergiObat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'nim': nim,
      'jenis_kelamin': jenisKelamin,
      'prodi': prodi,
      'fakultas': fakultas,
      'semester': semester,
      'no_hp': noHP,
      'email': email,
    };
  }

  String get initials {
    if (nama.isEmpty) return 'M';
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  @override
  List<Object?> get props => [
    id,
    nama,
    nim,
    jenisKelamin,
    prodi,
    fakultas,
    semester,
    noHP,
    email,
  ];
}

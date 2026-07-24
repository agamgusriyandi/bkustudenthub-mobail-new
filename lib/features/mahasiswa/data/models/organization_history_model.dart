import '../../domain/entities/organization_history.dart';

class OrganizationHistoryModel extends OrganizationHistory {
  OrganizationHistoryModel({
    required super.id,
    required super.namaOrganisasi,
    required super.tipe,
    required super.jabatan,
    required super.periodeMulai,
    super.periodeSelesai,
    required super.deskripsiKegiatan,
    required super.apresiasi,
    super.dokumentasi,
    required super.statusVerifikasi,
    required super.achievements,
  });

  static int _parseInt(dynamic val, int defaultVal) {
    if (val == null) return defaultVal;
    if (val is int) return val;
    if (val is double) return val.toInt();
    final parsed = int.tryParse(val.toString());
    return parsed ?? defaultVal;
  }

  static int? _parseNullableInt(dynamic val) {
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  factory OrganizationHistoryModel.fromJson(Map<String, dynamic> json) {
    final List<String> parsedAchievements = [];
    if (json['Prestasi'] != null) {
      final List rawPrestasi = json['Prestasi'];
      for (var item in rawPrestasi) {
        if (item is Map && item['nama_kegiatan'] != null) {
          parsedAchievements.add(item['nama_kegiatan'].toString());
        }
      }
    }
    if (parsedAchievements.isEmpty &&
        json['apresiasi'] != null &&
        json['apresiasi'].toString().isNotEmpty) {
      parsedAchievements.add(json['apresiasi'].toString());
    }
    if (parsedAchievements.isEmpty) {
      parsedAchievements.add("Anggota aktif kepengurusan");
    }

    return OrganizationHistoryModel(
      id: (json['id'] ?? json['ID'] ?? '').toString(),
      namaOrganisasi: json['NamaOrganisasi'] ?? json['nama_organisasi'] ?? '',
      tipe: json['Tipe'] ?? json['tipe'] ?? '',
      jabatan: json['Jabatan'] ?? json['jabatan'] ?? '',
      periodeMulai: _parseInt(
        json['PeriodeMulai'] ?? json['periode_mulai'],
        2023,
      ),
      periodeSelesai: _parseNullableInt(
        json['PeriodeSelesai'] ?? json['periode_selesai'],
      ),
      deskripsiKegiatan:
          json['DeskripsiKegiatan'] ?? json['deskripsi_kegiatan'] ?? '',
      apresiasi: json['Apresiasi'] ?? json['apresiasi'] ?? '',
      dokumentasi: json['Dokumentasi'] ?? json['dokumentasi'],
      statusVerifikasi:
          json['StatusVerifikasi'] ??
          json['status_verifikasi'] ??
          json['status'] ??
          'Menunggu',
      achievements: parsedAchievements,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_organisasi': namaOrganisasi,
      'tipe': tipe,
      'jabatan': jabatan,
      'periode_mulai': periodeMulai,
      'periode_selesai': periodeSelesai,
      'deskripsi_kegiatan': deskripsiKegiatan,
      'apresiasi': apresiasi,
      'dokumentasi': dokumentasi,
    };
  }
}

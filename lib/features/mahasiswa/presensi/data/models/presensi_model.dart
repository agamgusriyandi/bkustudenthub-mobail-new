enum PresensiStatus { hadir, terlambat, sakit, izin, alpa, belum }

class PresensiModel {
  final int id;
  final String matkulName;
  final String jam;
  final String ruangan;
  final String dosen;
  final PresensiStatus status;
  final String? checkInTime;
  final bool canCheckIn;

  const PresensiModel({
    required this.id,
    required this.matkulName,
    required this.jam,
    required this.ruangan,
    required this.dosen,
    this.status = PresensiStatus.belum,
    this.checkInTime,
    this.canCheckIn = false,
  });

  factory PresensiModel.fromJson(Map<String, dynamic> json) {
    return PresensiModel(
      id: json['id'] ?? 0,
      matkulName: json['nama_matkul'] ?? json['matkul_name'] ?? '',
      jam: json['jam'] ?? '',
      ruangan: json['ruangan'] ?? '',
      dosen: json['dosen'] ?? '',
      status: _parseStatus(json['status']),
      checkInTime: json['check_in_time'],
      canCheckIn: json['can_check_in'] ?? false,
    );
  }

  static PresensiStatus _parseStatus(dynamic value) {
    if (value == null) return PresensiStatus.belum;
    switch (value.toString().toLowerCase()) {
      case 'hadir':
        return PresensiStatus.hadir;
      case 'terlambat':
        return PresensiStatus.terlambat;
      case 'sakit':
        return PresensiStatus.sakit;
      case 'izin':
        return PresensiStatus.izin;
      case 'alpa':
        return PresensiStatus.alpa;
      default:
        return PresensiStatus.belum;
    }
  }

  String get statusLabel {
    switch (status) {
      case PresensiStatus.hadir:
        return 'Hadir';
      case PresensiStatus.terlambat:
        return 'Terlambat';
      case PresensiStatus.sakit:
        return 'Sakit';
      case PresensiStatus.izin:
        return 'Izin';
      case PresensiStatus.alpa:
        return 'Alpa';
      case PresensiStatus.belum:
        return 'Belum';
    }
  }
}

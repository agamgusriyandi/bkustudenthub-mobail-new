import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_attendance.dart';

class OrmawaAttendanceModel extends OrmawaAttendance {
  OrmawaAttendanceModel({
    required super.mahasiswaId,
    super.mahasiswaName,
    super.nim,
    required super.waktuHadir,
    super.status,
  });

  factory OrmawaAttendanceModel.fromJson(Map<String, dynamic> json) {
    final mahasiswa = json['Mahasiswa'] as Map<String, dynamic>?;
    return OrmawaAttendanceModel(
      mahasiswaId:
          (json['MahasiswaID'] ?? json['mahasiswaId'] ?? '').toString(),
      mahasiswaName:
          mahasiswa?['Nama'] ??
          mahasiswa?['nama'] ??
          json['mahasiswaName'] ??
          '',
      nim: mahasiswa?['NIM'] ?? mahasiswa?['nim'] ?? json['nim'] ?? '',
      waktuHadir:
          DateTime.tryParse(
            json['WaktuHadir'] ??
                json['waktuHadir'] ??
                json['waktu_hadir'] ??
                '',
          ) ??
          DateTime.now(),
      status: json['Status'] ?? json['status'] ?? 'terdaftar',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MahasiswaID': int.tryParse(mahasiswaId),
      'WaktuHadir': waktuHadir.toIso8601String(),
    };
  }
}
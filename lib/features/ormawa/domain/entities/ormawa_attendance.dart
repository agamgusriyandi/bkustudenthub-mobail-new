class OrmawaAttendance {
  final String mahasiswaId;
  final String? mahasiswaName;
  final String? nim;
  final DateTime waktuHadir;
  final String status;

  OrmawaAttendance({
    required this.mahasiswaId,
    this.mahasiswaName,
    this.nim,
    required this.waktuHadir,
    this.status = 'terdaftar',
  });
}
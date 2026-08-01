class OrmawaAbsensiManagementModel {
  final int id;
  final String nama;
  final String? deskripsi;
  final String? lokasi;
  final DateTime tanggal;
  final DateTime? waktuMulai;
  final DateTime? waktuSelesai;
  final String status;
  final int jumlahHadir;
  final int jumlahTotal;

  OrmawaAbsensiManagementModel({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.lokasi,
    required this.tanggal,
    this.waktuMulai,
    this.waktuSelesai,
    this.status = 'aktif',
    this.jumlahHadir = 0,
    this.jumlahTotal = 0,
  });

  factory OrmawaAbsensiManagementModel.fromJson(Map<String, dynamic> json) {
    return OrmawaAbsensiManagementModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? json['Nama'] ?? '',
      deskripsi: json['deskripsi'] ?? json['Deskripsi'],
      lokasi: json['lokasi'] ?? json['Lokasi'],
      tanggal: DateTime.tryParse(json['tanggal'] ?? json['Tanggal'] ?? '') ?? DateTime.now(),
      waktuMulai: json['waktu_mulai'] != null ? DateTime.tryParse(json['waktu_mulai']) : null,
      waktuSelesai: json['waktu_selesai'] != null ? DateTime.tryParse(json['waktu_selesai']) : null,
      status: json['status'] ?? json['Status'] ?? 'aktif',
      jumlahHadir: json['jumlah_hadir'] ?? json['JumlahHadir'] ?? 0,
      jumlahTotal: json['jumlah_total'] ?? json['JumlahTotal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nama': nama,
    'deskripsi': deskripsi,
    'lokasi': lokasi,
    'tanggal': tanggal.toIso8601String(),
    'waktu_mulai': waktuMulai?.toIso8601String(),
    'waktu_selesai': waktuSelesai?.toIso8601String(),
    'status': status,
    'jumlah_hadir': jumlahHadir,
    'jumlah_total': jumlahTotal,
  };
}

class CampusEventSchedule {
  final String judul;
  final DateTime tanggal;
  final String kategori;
  final String lokasi;
  final String deskripsi;

  CampusEventSchedule({
    required this.judul,
    required this.tanggal,
    required this.kategori,
    this.lokasi = '',
    this.deskripsi = '',
  });

  factory CampusEventSchedule.fromJson(Map<String, dynamic> json) {
    return CampusEventSchedule(
      judul: json['judul'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      kategori: json['kategori'] ?? '',
      lokasi: json['lokasi'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
    );
  }
}

class PkkmbEvent {
  final String id;
  final String judul;
  final String deskripsi;
  final DateTime tanggal;
  final String lokasi;

  PkkmbEvent({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tanggal,
    required this.lokasi,
  });

  factory PkkmbEvent.fromJson(Map<String, dynamic> json) {
    return PkkmbEvent(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      judul: json['Judul'] ?? json['judul'] ?? '',
      deskripsi: json['Deskripsi'] ?? json['deskripsi'] ?? '',
      tanggal:
          DateTime.tryParse(json['Tanggal'] ?? json['tanggal'] ?? '') ??
          DateTime.now(),
      lokasi: json['Lokasi'] ?? json['lokasi'] ?? '',
    );
  }
}

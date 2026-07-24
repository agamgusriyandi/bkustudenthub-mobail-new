class CampusNews {
  final int id;
  final String judul;
  final String isi;
  final String gambarUrl;
  final String kategori;
  final DateTime tanggalPublish;

  const CampusNews({
    required this.id,
    required this.judul,
    required this.isi,
    required this.gambarUrl,
    required this.kategori,
    required this.tanggalPublish,
  });

  factory CampusNews.fromJson(Map<String, dynamic> json) {
    return CampusNews(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? json['Judul'] ?? '',
      isi: json['isi'] ?? json['isi_singkat'] ?? json['Isi'] ?? '',
      gambarUrl: json['gambar_url'] ?? json['GambarURL'] ?? '',
      kategori: json['kategori'] ?? json['Kategori'] ?? 'Info Terbaru',
      tanggalPublish:
          DateTime.tryParse(
            json['tanggal']?.toString() ??
                json['tanggal_publish']?.toString() ??
                json['TanggalPublish']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }
}

class Deadline {
  final String nama;
  final String tipe;
  final int sisaHari;
  final String link;

  const Deadline({
    required this.nama,
    required this.tipe,
    required this.sisaHari,
    required this.link,
  });

  factory Deadline.fromJson(Map<String, dynamic> json) {
    return Deadline(
      nama: '${json['nama'] ?? json['Nama'] ?? json['judul'] ?? ''}',
      tipe: '${json['tipe'] ?? json['Tipe'] ?? json['kategori'] ?? 'kampus'}',
      sisaHari: int.tryParse('${json['sisa_hari'] ?? json['SisaHari'] ?? 0}') ?? 0,
      link: '${json['link'] ?? json['Link'] ?? ''}',
    );
  }
}

class Activity {
  final String deskripsi;
  final String tipe;
  final String link;
  final DateTime createdAt;

  const Activity({
    required this.deskripsi,
    required this.tipe,
    required this.link,
    required this.createdAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      deskripsi:
          '${json['deskripsi'] ?? json['Deskripsi'] ?? json['judul'] ?? ''}',
      tipe: '${json['tipe'] ?? json['Tipe'] ?? json['kategori'] ?? 'info'}',
      link: '${json['link'] ?? json['Link'] ?? ''}',
      createdAt:
          DateTime.tryParse('${json['created_at'] ?? json['CreatedAt'] ?? ''}') ??
          DateTime.now(),
    );
  }
}

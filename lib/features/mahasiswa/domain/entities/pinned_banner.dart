class PinnedBanner {
  final int id;
  final String pesan;
  final String link;

  const PinnedBanner({
    required this.id,
    required this.pesan,
    required this.link,
  });

  factory PinnedBanner.fromJson(Map<String, dynamic> json) {
    return PinnedBanner(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      pesan: '${json['pesan'] ?? json['Pesan'] ?? ''}',
      link: '${json['link'] ?? json['Link'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'pesan': pesan, 'link': link};

  bool get aktif => pesan.trim().isNotEmpty;
}

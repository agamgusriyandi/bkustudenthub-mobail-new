class BeritaModel {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final String author;
  final DateTime publishedAt;
  final String? category;
  final String? excerpt;

  const BeritaModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
    this.category,
    this.excerpt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      author: json['author'] ?? json['penulis'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? json['created_at'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? json['kategori'],
      excerpt: json['excerpt'] ?? json['ringkasan'],
    );
  }

  String get formattedDate {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${publishedAt.day} ${months[publishedAt.month - 1]} ${publishedAt.year}';
  }
}

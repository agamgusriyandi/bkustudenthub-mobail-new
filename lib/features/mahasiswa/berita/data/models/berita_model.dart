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
    String parsedAuthor = 'Admin BKU';
    final penulis = json['Penulis'];
    if (penulis is Map<String, dynamic> && penulis['nama_lengkap'] != null && penulis['nama_lengkap'].toString().isNotEmpty) {
      parsedAuthor = penulis['nama_lengkap'].toString();
    } else {
      final fallbackAuthor = json['author'] ?? json['penulis'] ?? json['Penulis'];
      if (fallbackAuthor is String && fallbackAuthor.isNotEmpty) {
        parsedAuthor = fallbackAuthor;
      }
    }

    return BeritaModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['Judul'] ?? '',
      content: json['content'] ?? json['IsiKonten'] ?? json['Isi'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? json['GambarURL'] ?? '',
      author: parsedAuthor,
      publishedAt: DateTime.tryParse(json['published_at'] ?? json['created_at'] ?? json['TanggalPublish'] ?? '') ?? DateTime.now(),
      category: json['category'] ?? json['kategori'] ?? json['Kategori'],
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

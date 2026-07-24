class Aspiration {
  final String id;
  final String category;
  final String title;
  final String description;
  final DateTime date;
  final DateTime? updatedAt;
  final String status;
  final String? feedback;
  final String? imageUrl;
  final String? attachmentPath;
  final String tujuan;
  final bool isAnonim;

  Aspiration({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.date,
    this.updatedAt,
    required this.status,
    this.feedback,
    this.imageUrl,
    this.attachmentPath,
    this.tujuan = 'Fakultas',
    this.isAnonim = false,
  });
}

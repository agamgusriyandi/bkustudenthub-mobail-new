import '../../domain/entities/aspiration.dart';

class AspirationModel extends Aspiration {
  AspirationModel({
    required super.id,
    required super.category,
    required super.title,
    required super.description,
    required super.date,
    super.updatedAt,
    required super.status,
    super.feedback,
    super.imageUrl,
    super.attachmentPath,
    super.tujuan,
    super.isAnonim,
  });

  factory AspirationModel.fromJson(Map<String, dynamic> json) {
    return AspirationModel(
      id: json['id']?.toString() ?? '',
      category: json['kategori'] ?? '',
      title: json['judul'] ?? '',
      description: json['isi'] ?? '',
      date:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null || json['UpdatedAt'] != null
              ? DateTime.parse(json['updated_at'] ?? json['UpdatedAt'])
              : null,
      status: json['status'] ?? '',
      feedback: json['respon'],
      imageUrl: json['lampiran_url'] ?? json['file_url'],
      tujuan: json['tujuan'] ?? 'Fakultas',
      isAnonim: json['is_anonim'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'judul': title,
      'isi': description,
      'kategori': category,
      'is_anonim': isAnonim,
      'tujuan': tujuan,
    };
  }
}

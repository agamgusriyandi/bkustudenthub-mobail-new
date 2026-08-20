class KategoriOrmawaModel {
  final int id;

  KategoriOrmawaModel({required this.id});

  factory KategoriOrmawaModel.fromJson(Map<String, dynamic> json) {
    return KategoriOrmawaModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
class MahasiswaModel {
  final int id;

  MahasiswaModel({required this.id});

  factory MahasiswaModel.fromJson(Map<String, dynamic> json) {
    return MahasiswaModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

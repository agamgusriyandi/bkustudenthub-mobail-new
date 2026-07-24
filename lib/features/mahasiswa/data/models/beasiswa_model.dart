class BeasiswaModel {
  final int id;

  BeasiswaModel({required this.id});

  factory BeasiswaModel.fromJson(Map<String, dynamic> json) {
    return BeasiswaModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

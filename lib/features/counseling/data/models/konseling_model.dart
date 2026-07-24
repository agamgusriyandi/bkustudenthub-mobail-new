class KonselingModel {
  final int id;

  KonselingModel({required this.id});

  factory KonselingModel.fromJson(Map<String, dynamic> json) {
    return KonselingModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

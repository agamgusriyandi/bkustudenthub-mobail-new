class KencanaMaterialModel {
  final int id;

  KencanaMaterialModel({required this.id});

  factory KencanaMaterialModel.fromJson(Map<String, dynamic> json) {
    return KencanaMaterialModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class PrestasiModel {
  final int id;

  PrestasiModel({required this.id});

  factory PrestasiModel.fromJson(Map<String, dynamic> json) {
    return PrestasiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class PrestasiDosenModel {
  final int id;

  PrestasiDosenModel({required this.id});

  factory PrestasiDosenModel.fromJson(Map<String, dynamic> json) {
    return PrestasiDosenModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class FakultasModel {
  final int id;

  FakultasModel({required this.id});

  factory FakultasModel.fromJson(Map<String, dynamic> json) {
    return FakultasModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

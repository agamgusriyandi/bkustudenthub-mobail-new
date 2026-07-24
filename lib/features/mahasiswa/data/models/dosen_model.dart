class DosenModel {
  final int id;

  DosenModel({required this.id});

  factory DosenModel.fromJson(Map<String, dynamic> json) {
    return DosenModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class KesehatanModel {
  final int id;

  KesehatanModel({required this.id});

  factory KesehatanModel.fromJson(Map<String, dynamic> json) {
    return KesehatanModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

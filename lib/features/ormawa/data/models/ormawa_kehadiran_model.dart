class OrmawaKehadiranModel {
  final int id;

  OrmawaKehadiranModel({required this.id});

  factory OrmawaKehadiranModel.fromJson(Map<String, dynamic> json) {
    return OrmawaKehadiranModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

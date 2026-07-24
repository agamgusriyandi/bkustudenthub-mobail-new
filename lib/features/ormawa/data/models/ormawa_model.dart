class OrmawaModel {
  final int id;

  OrmawaModel({required this.id});

  factory OrmawaModel.fromJson(Map<String, dynamic> json) {
    return OrmawaModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

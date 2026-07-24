class KencanaSessionModel {
  final int id;

  KencanaSessionModel({required this.id});

  factory KencanaSessionModel.fromJson(Map<String, dynamic> json) {
    return KencanaSessionModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

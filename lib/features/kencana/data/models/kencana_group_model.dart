class KencanaGroupModel {
  final int id;

  KencanaGroupModel({required this.id});

  factory KencanaGroupModel.fromJson(Map<String, dynamic> json) {
    return KencanaGroupModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

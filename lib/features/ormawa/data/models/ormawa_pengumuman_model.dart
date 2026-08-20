class OrmawaPengumumanModel {
  final int id;

  OrmawaPengumumanModel({required this.id});

  factory OrmawaPengumumanModel.fromJson(Map<String, dynamic> json) {
    return OrmawaPengumumanModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
class OrmawaDivisiModel {
  final int id;

  OrmawaDivisiModel({required this.id});

  factory OrmawaDivisiModel.fromJson(Map<String, dynamic> json) {
    return OrmawaDivisiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
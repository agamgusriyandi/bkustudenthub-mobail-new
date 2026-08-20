class OrmawaKegiatanModel {
  final int id;

  OrmawaKegiatanModel({required this.id});

  factory OrmawaKegiatanModel.fromJson(Map<String, dynamic> json) {
    return OrmawaKegiatanModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
class PkkmbKegiatanModel {
  final int id;

  PkkmbKegiatanModel({required this.id});

  factory PkkmbKegiatanModel.fromJson(Map<String, dynamic> json) {
    return PkkmbKegiatanModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

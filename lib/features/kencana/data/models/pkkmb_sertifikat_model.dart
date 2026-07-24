class PkkmbSertifikatModel {
  final int id;

  PkkmbSertifikatModel({required this.id});

  factory PkkmbSertifikatModel.fromJson(Map<String, dynamic> json) {
    return PkkmbSertifikatModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

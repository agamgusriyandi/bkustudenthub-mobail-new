class PkkmbBandingModel {
  final int id;

  PkkmbBandingModel({required this.id});

  factory PkkmbBandingModel.fromJson(Map<String, dynamic> json) {
    return PkkmbBandingModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

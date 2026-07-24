class PkkmbHasilModel {
  final int id;

  PkkmbHasilModel({required this.id});

  factory PkkmbHasilModel.fromJson(Map<String, dynamic> json) {
    return PkkmbHasilModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

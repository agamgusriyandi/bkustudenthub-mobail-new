class KencanaRemedialModel {
  final int id;

  KencanaRemedialModel({required this.id});

  factory KencanaRemedialModel.fromJson(Map<String, dynamic> json) {
    return KencanaRemedialModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

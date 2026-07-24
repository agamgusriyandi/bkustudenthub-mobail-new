class KencanaStageModel {
  final int id;

  KencanaStageModel({required this.id});

  factory KencanaStageModel.fromJson(Map<String, dynamic> json) {
    return KencanaStageModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

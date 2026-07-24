class KencanaQuestionOptionModel {
  final int id;

  KencanaQuestionOptionModel({required this.id});

  factory KencanaQuestionOptionModel.fromJson(Map<String, dynamic> json) {
    return KencanaQuestionOptionModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

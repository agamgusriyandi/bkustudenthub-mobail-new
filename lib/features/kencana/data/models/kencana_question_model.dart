class KencanaQuestionModel {
  final int id;

  KencanaQuestionModel({required this.id});

  factory KencanaQuestionModel.fromJson(Map<String, dynamic> json) {
    return KencanaQuestionModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

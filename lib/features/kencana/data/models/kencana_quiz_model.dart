class KencanaQuizModel {
  final int id;

  KencanaQuizModel({required this.id});

  factory KencanaQuizModel.fromJson(Map<String, dynamic> json) {
    return KencanaQuizModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

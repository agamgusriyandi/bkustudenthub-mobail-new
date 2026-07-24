class KencanaMentorModel {
  final int id;

  KencanaMentorModel({required this.id});

  factory KencanaMentorModel.fromJson(Map<String, dynamic> json) {
    return KencanaMentorModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

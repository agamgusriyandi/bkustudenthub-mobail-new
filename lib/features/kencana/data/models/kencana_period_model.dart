class KencanaPeriodModel {
  final int id;

  KencanaPeriodModel({required this.id});

  factory KencanaPeriodModel.fromJson(Map<String, dynamic> json) {
    return KencanaPeriodModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

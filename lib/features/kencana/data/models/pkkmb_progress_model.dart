class PkkmbProgressModel {
  final int id;

  PkkmbProgressModel({required this.id});

  factory PkkmbProgressModel.fromJson(Map<String, dynamic> json) {
    return PkkmbProgressModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class AspirasiModel {
  final int id;

  AspirasiModel({required this.id});

  factory AspirasiModel.fromJson(Map<String, dynamic> json) {
    return AspirasiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class OrmawaAspirasiModel {
  final int id;

  OrmawaAspirasiModel({required this.id});

  factory OrmawaAspirasiModel.fromJson(Map<String, dynamic> json) {
    return OrmawaAspirasiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
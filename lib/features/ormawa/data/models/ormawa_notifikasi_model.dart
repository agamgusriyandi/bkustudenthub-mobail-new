class OrmawaNotifikasiModel {
  final int id;

  OrmawaNotifikasiModel({required this.id});

  factory OrmawaNotifikasiModel.fromJson(Map<String, dynamic> json) {
    return OrmawaNotifikasiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class TenagaKesehatanModel {
  final int id;

  TenagaKesehatanModel({required this.id});

  factory TenagaKesehatanModel.fromJson(Map<String, dynamic> json) {
    return TenagaKesehatanModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

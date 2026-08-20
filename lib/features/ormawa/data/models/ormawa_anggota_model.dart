class OrmawaAnggotaModel {
  final int id;

  OrmawaAnggotaModel({required this.id});

  factory OrmawaAnggotaModel.fromJson(Map<String, dynamic> json) {
    return OrmawaAnggotaModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
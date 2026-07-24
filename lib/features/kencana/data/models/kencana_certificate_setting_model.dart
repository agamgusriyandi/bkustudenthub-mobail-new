class KencanaCertificateSettingModel {
  final int id;

  KencanaCertificateSettingModel({required this.id});

  factory KencanaCertificateSettingModel.fromJson(Map<String, dynamic> json) {
    return KencanaCertificateSettingModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

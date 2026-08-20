class PengajuanSuratModel {
  final int id;

  PengajuanSuratModel({required this.id});

  factory PengajuanSuratModel.fromJson(Map<String, dynamic> json) {
    return PengajuanSuratModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
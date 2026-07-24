class LaporanPertanggungjawabanModel {
  final int id;

  LaporanPertanggungjawabanModel({required this.id});

  factory LaporanPertanggungjawabanModel.fromJson(Map<String, dynamic> json) {
    return LaporanPertanggungjawabanModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

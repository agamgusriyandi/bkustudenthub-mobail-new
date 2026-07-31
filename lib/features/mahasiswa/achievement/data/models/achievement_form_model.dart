class AchievementFormModel {
  final String namaPrestasi;
  final String tingkat;
  final DateTime tanggal;
  final String deskripsi;
  final String? sertifikatPath;

  const AchievementFormModel({
    required this.namaPrestasi,
    required this.tingkat,
    required this.tanggal,
    required this.deskripsi,
    this.sertifikatPath,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama_prestasi': namaPrestasi,
      'tingkat': tingkat,
      'tanggal': tanggal.toIso8601String(),
      'deskripsi': deskripsi,
    };
  }

  factory AchievementFormModel.fromJson(Map<String, dynamic> json) {
    return AchievementFormModel(
      namaPrestasi: json['nama_prestasi'] ?? '',
      tingkat: json['tingkat'] ?? '',
      tanggal: DateTime.tryParse(json['tanggal'] ?? '') ?? DateTime.now(),
      deskripsi: json['deskripsi'] ?? '',
      sertifikatPath: json['sertifikat_path'],
    );
  }
}

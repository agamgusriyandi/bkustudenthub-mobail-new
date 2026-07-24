class PrestasiMahasiswaModel {
  final int id;

  PrestasiMahasiswaModel({required this.id});

  factory PrestasiMahasiswaModel.fromJson(Map<String, dynamic> json) {
    return PrestasiMahasiswaModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

class RiwayatOrganisasiModel {
  final int id;

  RiwayatOrganisasiModel({required this.id});

  factory RiwayatOrganisasiModel.fromJson(Map<String, dynamic> json) {
    return RiwayatOrganisasiModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}
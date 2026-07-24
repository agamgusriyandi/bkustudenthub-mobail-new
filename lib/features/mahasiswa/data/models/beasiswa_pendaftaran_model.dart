class BeasiswaPendaftaranModel {
  final int id;

  BeasiswaPendaftaranModel({required this.id});

  factory BeasiswaPendaftaranModel.fromJson(Map<String, dynamic> json) {
    return BeasiswaPendaftaranModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

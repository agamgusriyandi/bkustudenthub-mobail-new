class OrmawaMutasiSaldoModel {
  final int id;

  OrmawaMutasiSaldoModel({required this.id});

  factory OrmawaMutasiSaldoModel.fromJson(Map<String, dynamic> json) {
    return OrmawaMutasiSaldoModel(id: json['id'] ?? 0);
  }

  Map<String, dynamic> toJson() => {'id': id};
}

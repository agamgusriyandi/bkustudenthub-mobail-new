import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';

class OrmawaDivisionModel extends OrmawaDivision {
  OrmawaDivisionModel({
    required super.id,
    required super.name,
    required super.description,
  });

  factory OrmawaDivisionModel.fromJson(Map<String, dynamic> json) {
    return OrmawaDivisionModel(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      name: json['Nama'] ?? json['nama'] ?? '',
      description: json['Deskripsi'] ?? json['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'ID': int.tryParse(id), 'Nama': name, 'Deskripsi': description};
  }
}
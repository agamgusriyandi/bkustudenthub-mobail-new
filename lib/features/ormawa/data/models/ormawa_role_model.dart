import 'dart:convert';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_role.dart';

class OrmawaRoleModel extends OrmawaRole {
  OrmawaRoleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.permissions,
  });

  factory OrmawaRoleModel.fromJson(Map<String, dynamic> json) {
    List<String> perms = [];
    final permissionsRaw =
        json['Permissions'] ??
        json['permissions'] ??
        json['Hak'] ??
        json['hak'];
    if (permissionsRaw is List) {
      perms = permissionsRaw.map((e) => e.toString()).toList();
    } else if (permissionsRaw is String) {
      try {
        final decoded = jsonDecode(permissionsRaw);
        if (decoded is List) {
          perms = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }
    return OrmawaRoleModel(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      name: json['Nama'] ?? json['nama'] ?? '',
      description: json['Deskripsi'] ?? json['deskripsi'] ?? '',
      permissions: perms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'Nama': name,
      'Deskripsi': description,
      'Permissions': permissions,
    };
  }
}

import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_group_member.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/fakultas.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_mentor.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_period.dart';

class KencanaGroup extends Equatable {
  final int? capacity;
  final String? code;
  final String? createdAt;
  final int? createdBy;
  final String? description;
  final Fakultas? fakultas;
  final int? fakultasId;
  final int? groupNumber;
  final int? id;
  final List<KencanaGroupMember>? members;
  final KencanaMentor? mentor;
  final int? mentorId;
  final String? name;
  final KencanaPeriod? period;
  final int? periodId;
  final String? scopeType;
  final String? status;
  final String? updatedAt;

  const KencanaGroup({
    this.capacity,
    this.code,
    this.createdAt,
    this.createdBy,
    this.description,
    this.fakultas,
    this.fakultasId,
    this.groupNumber,
    this.id,
    this.members,
    this.mentor,
    this.mentorId,
    this.name,
    this.period,
    this.periodId,
    this.scopeType,
    this.status,
    this.updatedAt,
  });

  factory KencanaGroup.fromJson(Map<String, dynamic> json) {
    return KencanaGroup(
      capacity:
          json['capacity'] != null
              ? int.tryParse(json['capacity'].toString()) ?? json['capacity']
              : null,
      code: json['code'],
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      description: json['description'],
      fakultas:
          json['fakultas'] != null ? Fakultas.fromJson(json['fakultas']) : null,
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      groupNumber:
          json['group_number'] != null
              ? int.tryParse(json['group_number'].toString()) ??
                  json['group_number']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      members:
          json['members'] != null
              ? (json['members'] as List)
                  .map((i) => KencanaGroupMember.fromJson(i))
                  .toList()
              : null,
      mentor:
          json['mentor'] != null
              ? KencanaMentor.fromJson(json['mentor'])
              : null,
      mentorId:
          json['mentor_id'] != null
              ? int.tryParse(json['mentor_id'].toString()) ?? json['mentor_id']
              : null,
      name: json['name'],
      period:
          json['period'] != null
              ? KencanaPeriod.fromJson(json['period'])
              : null,
      periodId:
          json['period_id'] != null
              ? int.tryParse(json['period_id'].toString()) ?? json['period_id']
              : null,
      scopeType: json['scope_type'],
      status: json['status'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capacity': capacity,
      'code': code,
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'fakultas': fakultas?.toJson(),
      'fakultas_id': fakultasId,
      'group_number': groupNumber,
      'id': id,
      'members': members?.map((i) => i.toJson()).toList(),
      'mentor': mentor?.toJson(),
      'mentor_id': mentorId,
      'name': name,
      'period': period?.toJson(),
      'period_id': periodId,
      'scope_type': scopeType,
      'status': status,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    capacity,
    code,
    createdAt,
    createdBy,
    description,
    fakultas,
    fakultasId,
    groupNumber,
    id,
    members,
    mentor,
    mentorId,
    name,
    period,
    periodId,
    scopeType,
    status,
    updatedAt,
  ];
}

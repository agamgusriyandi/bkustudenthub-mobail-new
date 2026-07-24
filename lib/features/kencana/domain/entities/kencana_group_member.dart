import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_group.dart';

class KencanaGroupMember extends Equatable {
  final int? addedBy;
  final String? createdAt;
  final KencanaGroup? group;
  final int? groupId;
  final int? id;
  final String? joinedAt;
  final int? periodId;
  final String? status;
  final Mahasiswa? student;
  final int? studentId;
  final String? updatedAt;

  const KencanaGroupMember({
    this.addedBy,
    this.createdAt,
    this.group,
    this.groupId,
    this.id,
    this.joinedAt,
    this.periodId,
    this.status,
    this.student,
    this.studentId,
    this.updatedAt,
  });

  factory KencanaGroupMember.fromJson(Map<String, dynamic> json) {
    return KencanaGroupMember(
      addedBy:
          json['added_by'] != null
              ? int.tryParse(json['added_by'].toString()) ?? json['added_by']
              : null,
      createdAt: json['created_at'],
      group:
          json['group'] != null ? KencanaGroup.fromJson(json['group']) : null,
      groupId:
          json['group_id'] != null
              ? int.tryParse(json['group_id'].toString()) ?? json['group_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      joinedAt: json['joined_at'],
      periodId:
          json['period_id'] != null
              ? int.tryParse(json['period_id'].toString()) ?? json['period_id']
              : null,
      status: json['status'],
      student:
          json['student'] != null ? Mahasiswa.fromJson(json['student']) : null,
      studentId:
          json['student_id'] != null
              ? int.tryParse(json['student_id'].toString()) ??
                  json['student_id']
              : null,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'added_by': addedBy,
      'created_at': createdAt,
      'group': group?.toJson(),
      'group_id': groupId,
      'id': id,
      'joined_at': joinedAt,
      'period_id': periodId,
      'status': status,
      'student': student?.toJson(),
      'student_id': studentId,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    addedBy,
    createdAt,
    group,
    groupId,
    id,
    joinedAt,
    periodId,
    status,
    student,
    studentId,
    updatedAt,
  ];
}

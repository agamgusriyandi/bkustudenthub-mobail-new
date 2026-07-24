import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mahasiswa.dart';

class KencanaRemedial extends Equatable {
  final String? closedAt;
  final String? component;
  final String? createdAt;
  final int? createdBy;
  final int? id;
  final String? openedAt;
  final int? periodId;
  final String? reason;
  final String? status;
  final Mahasiswa? student;
  final int? studentId;
  final String? type;
  final String? updatedAt;

  const KencanaRemedial({
    this.closedAt,
    this.component,
    this.createdAt,
    this.createdBy,
    this.id,
    this.openedAt,
    this.periodId,
    this.reason,
    this.status,
    this.student,
    this.studentId,
    this.type,
    this.updatedAt,
  });

  factory KencanaRemedial.fromJson(Map<String, dynamic> json) {
    return KencanaRemedial(
      closedAt: json['closed_at'],
      component: json['component'],
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      openedAt: json['opened_at'],
      periodId:
          json['period_id'] != null
              ? int.tryParse(json['period_id'].toString()) ?? json['period_id']
              : null,
      reason: json['reason'],
      status: json['status'],
      student:
          json['student'] != null ? Mahasiswa.fromJson(json['student']) : null,
      studentId:
          json['student_id'] != null
              ? int.tryParse(json['student_id'].toString()) ??
                  json['student_id']
              : null,
      type: json['type'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'closed_at': closedAt,
      'component': component,
      'created_at': createdAt,
      'created_by': createdBy,
      'id': id,
      'opened_at': openedAt,
      'period_id': periodId,
      'reason': reason,
      'status': status,
      'student': student?.toJson(),
      'student_id': studentId,
      'type': type,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    closedAt,
    component,
    createdAt,
    createdBy,
    id,
    openedAt,
    periodId,
    reason,
    status,
    student,
    studentId,
    type,
    updatedAt,
  ];
}

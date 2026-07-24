import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_stage.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_assignment.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_quiz.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_material.dart';

class KencanaSession extends Equatable {
  final List<KencanaAssignment>? assignments;
  final String? createdAt;
  final int? createdBy;
  final String? description;
  final String? endDate;
  final int? id;
  final bool? isPublished;
  final bool? isRequired;
  final List<KencanaMaterial>? materials;
  final int? orderNumber;
  final String? qrExpiresAt;
  final String? qrToken;
  final List<KencanaQuiz>? quizzes;
  final KencanaStage? stage;
  final int? stageId;
  final String? startDate;
  final String? status;
  final String? title;
  final String? updatedAt;

  const KencanaSession({
    this.assignments,
    this.createdAt,
    this.createdBy,
    this.description,
    this.endDate,
    this.id,
    this.isPublished,
    this.isRequired,
    this.materials,
    this.orderNumber,
    this.qrExpiresAt,
    this.qrToken,
    this.quizzes,
    this.stage,
    this.stageId,
    this.startDate,
    this.status,
    this.title,
    this.updatedAt,
  });

  factory KencanaSession.fromJson(Map<String, dynamic> json) {
    return KencanaSession(
      assignments:
          json['assignments'] != null
              ? (json['assignments'] as List)
                  .map((i) => KencanaAssignment.fromJson(i))
                  .toList()
              : null,
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      description: json['description'],
      endDate: json['end_date'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isPublished: json['is_published'],
      isRequired: json['is_required'],
      materials:
          json['materials'] != null
              ? (json['materials'] as List)
                  .map((i) => KencanaMaterial.fromJson(i))
                  .toList()
              : null,
      orderNumber:
          json['order_number'] != null
              ? int.tryParse(json['order_number'].toString()) ??
                  json['order_number']
              : null,
      qrExpiresAt: json['qr_expires_at'],
      qrToken: json['qr_token'],
      quizzes:
          json['quizzes'] != null
              ? (json['quizzes'] as List)
                  .map((i) => KencanaQuiz.fromJson(i))
                  .toList()
              : null,
      stage:
          json['stage'] != null ? KencanaStage.fromJson(json['stage']) : null,
      stageId:
          json['stage_id'] != null
              ? int.tryParse(json['stage_id'].toString()) ?? json['stage_id']
              : null,
      startDate: json['start_date'],
      status: json['status'],
      title: json['title'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignments': assignments?.map((i) => i.toJson()).toList(),
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'end_date': endDate,
      'id': id,
      'is_published': isPublished,
      'is_required': isRequired,
      'materials': materials?.map((i) => i.toJson()).toList(),
      'order_number': orderNumber,
      'qr_expires_at': qrExpiresAt,
      'qr_token': qrToken,
      'quizzes': quizzes?.map((i) => i.toJson()).toList(),
      'stage': stage?.toJson(),
      'stage_id': stageId,
      'start_date': startDate,
      'status': status,
      'title': title,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    assignments,
    createdAt,
    createdBy,
    description,
    endDate,
    id,
    isPublished,
    isRequired,
    materials,
    orderNumber,
    qrExpiresAt,
    qrToken,
    quizzes,
    stage,
    stageId,
    startDate,
    status,
    title,
    updatedAt,
  ];
}

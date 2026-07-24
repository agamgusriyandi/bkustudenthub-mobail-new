import 'package:equatable/equatable.dart';

class KencanaAssignment extends Equatable {
  final String? allowedFileTypes;
  final String? createdAt;
  final int? createdBy;
  final String? description;
  final String? dueDate;
  final int? fakultasId;
  final int? id;
  final bool? isRequired;
  final String? openAt;
  final int? sessionId;
  final String? status;
  final String? submissionType;
  final String? title;
  final String? updatedAt;

  const KencanaAssignment({
    this.allowedFileTypes,
    this.createdAt,
    this.createdBy,
    this.description,
    this.dueDate,
    this.fakultasId,
    this.id,
    this.isRequired,
    this.openAt,
    this.sessionId,
    this.status,
    this.submissionType,
    this.title,
    this.updatedAt,
  });

  factory KencanaAssignment.fromJson(Map<String, dynamic> json) {
    return KencanaAssignment(
      allowedFileTypes: json['allowed_file_types'],
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      description: json['description'],
      dueDate: json['due_date'],
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isRequired: json['is_required'],
      openAt: json['open_at'],
      sessionId:
          json['session_id'] != null
              ? int.tryParse(json['session_id'].toString()) ??
                  json['session_id']
              : null,
      status: json['status'],
      submissionType: json['submission_type'],
      title: json['title'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allowed_file_types': allowedFileTypes,
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'due_date': dueDate,
      'fakultas_id': fakultasId,
      'id': id,
      'is_required': isRequired,
      'open_at': openAt,
      'session_id': sessionId,
      'status': status,
      'submission_type': submissionType,
      'title': title,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    allowedFileTypes,
    createdAt,
    createdBy,
    description,
    dueDate,
    fakultasId,
    id,
    isRequired,
    openAt,
    sessionId,
    status,
    submissionType,
    title,
    updatedAt,
  ];
}

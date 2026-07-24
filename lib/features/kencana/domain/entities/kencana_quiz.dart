import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_question.dart';

class KencanaQuiz extends Equatable {
  final String? closeAt;
  final String? createdAt;
  final int? createdBy;
  final String? description;
  final int? durationMinutes;
  final int? fakultasId;
  final int? id;
  final String? instruction;
  final bool? isRequired;
  final int? maxAttempts;
  final String? openAt;
  final List<KencanaQuestion>? questions;
  final int? sessionId;
  final bool? showScore;
  final String? status;
  final String? title;
  final String? updatedAt;

  const KencanaQuiz({
    this.closeAt,
    this.createdAt,
    this.createdBy,
    this.description,
    this.durationMinutes,
    this.fakultasId,
    this.id,
    this.instruction,
    this.isRequired,
    this.maxAttempts,
    this.openAt,
    this.questions,
    this.sessionId,
    this.showScore,
    this.status,
    this.title,
    this.updatedAt,
  });

  factory KencanaQuiz.fromJson(Map<String, dynamic> json) {
    return KencanaQuiz(
      closeAt: json['close_at'],
      createdAt: json['created_at'],
      createdBy:
          json['created_by'] != null
              ? int.tryParse(json['created_by'].toString()) ??
                  json['created_by']
              : null,
      description: json['description'],
      durationMinutes:
          json['duration_minutes'] != null
              ? int.tryParse(json['duration_minutes'].toString()) ??
                  json['duration_minutes']
              : null,
      fakultasId:
          json['fakultas_id'] != null
              ? int.tryParse(json['fakultas_id'].toString()) ??
                  json['fakultas_id']
              : null,
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      instruction: json['instruction'],
      isRequired: json['is_required'],
      maxAttempts:
          json['max_attempts'] != null
              ? int.tryParse(json['max_attempts'].toString()) ??
                  json['max_attempts']
              : null,
      openAt: json['open_at'],
      questions:
          json['questions'] != null
              ? (json['questions'] as List)
                  .map((i) => KencanaQuestion.fromJson(i))
                  .toList()
              : null,
      sessionId:
          json['session_id'] != null
              ? int.tryParse(json['session_id'].toString()) ??
                  json['session_id']
              : null,
      showScore: json['show_score'],
      status: json['status'],
      title: json['title'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'close_at': closeAt,
      'created_at': createdAt,
      'created_by': createdBy,
      'description': description,
      'duration_minutes': durationMinutes,
      'fakultas_id': fakultasId,
      'id': id,
      'instruction': instruction,
      'is_required': isRequired,
      'max_attempts': maxAttempts,
      'open_at': openAt,
      'questions': questions?.map((i) => i.toJson()).toList(),
      'session_id': sessionId,
      'show_score': showScore,
      'status': status,
      'title': title,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    closeAt,
    createdAt,
    createdBy,
    description,
    durationMinutes,
    fakultasId,
    id,
    instruction,
    isRequired,
    maxAttempts,
    openAt,
    questions,
    sessionId,
    showScore,
    status,
    title,
    updatedAt,
  ];
}

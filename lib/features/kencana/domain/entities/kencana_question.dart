import 'package:equatable/equatable.dart';
import 'package:bkuhub_mobile/features/kencana/domain/entities/kencana_question_option.dart';

class KencanaQuestion extends Equatable {
  final String? createdAt;
  final int? id;
  final List<KencanaQuestionOption>? options;
  final int? orderNumber;
  final String? questionText;
  final String? questionType;
  final int? quizId;
  final double? score;
  final String? updatedAt;

  const KencanaQuestion({
    this.createdAt,
    this.id,
    this.options,
    this.orderNumber,
    this.questionText,
    this.questionType,
    this.quizId,
    this.score,
    this.updatedAt,
  });

  factory KencanaQuestion.fromJson(Map<String, dynamic> json) {
    return KencanaQuestion(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      options:
          json['options'] != null
              ? (json['options'] as List)
                  .map((i) => KencanaQuestionOption.fromJson(i))
                  .toList()
              : null,
      orderNumber:
          json['order_number'] != null
              ? int.tryParse(json['order_number'].toString()) ??
                  json['order_number']
              : null,
      questionText: json['question_text'],
      questionType: json['question_type'],
      quizId:
          json['quiz_id'] != null
              ? int.tryParse(json['quiz_id'].toString()) ?? json['quiz_id']
              : null,
      score: json['score'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'options': options?.map((i) => i.toJson()).toList(),
      'order_number': orderNumber,
      'question_text': questionText,
      'question_type': questionType,
      'quiz_id': quizId,
      'score': score,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    options,
    orderNumber,
    questionText,
    questionType,
    quizId,
    score,
    updatedAt,
  ];
}

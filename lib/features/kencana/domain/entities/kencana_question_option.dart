import 'package:equatable/equatable.dart';

class KencanaQuestionOption extends Equatable {
  final String? createdAt;
  final int? id;
  final bool? isCorrect;
  final String? optionText;
  final int? orderNumber;
  final int? questionId;
  final String? updatedAt;

  const KencanaQuestionOption({
    this.createdAt,
    this.id,
    this.isCorrect,
    this.optionText,
    this.orderNumber,
    this.questionId,
    this.updatedAt,
  });

  factory KencanaQuestionOption.fromJson(Map<String, dynamic> json) {
    return KencanaQuestionOption(
      createdAt: json['created_at'],
      id:
          json['id'] != null
              ? int.tryParse(json['id'].toString()) ?? json['id']
              : null,
      isCorrect: json['is_correct'],
      optionText: json['option_text'],
      orderNumber:
          json['order_number'] != null
              ? int.tryParse(json['order_number'].toString()) ??
                  json['order_number']
              : null,
      questionId:
          json['question_id'] != null
              ? int.tryParse(json['question_id'].toString()) ??
                  json['question_id']
              : null,
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created_at': createdAt,
      'id': id,
      'is_correct': isCorrect,
      'option_text': optionText,
      'order_number': orderNumber,
      'question_id': questionId,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
    createdAt,
    id,
    isCorrect,
    optionText,
    orderNumber,
    questionId,
    updatedAt,
  ];
}

import 'package:equatable/equatable.dart';

class CounselingSession extends Equatable {
  final String id;
  final String studentName;
  final String studentId;
  final DateTime dateTime;
  final String status;
  final String reason;
  final String? meetLink;

  const CounselingSession({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.dateTime,
    required this.status,
    required this.reason,
    this.meetLink,
  });

  @override
  List<Object?> get props => [
    id,
    studentName,
    studentId,
    dateTime,
    status,
    reason,
    meetLink,
  ];
}

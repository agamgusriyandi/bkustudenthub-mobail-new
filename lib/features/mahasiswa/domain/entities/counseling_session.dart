class CounselingSession {
  final String id;
  final String psychologistId;
  final String psychologistName;
  final String topic;
  final DateTime date;
  final String time;
  final String? location;
  final String status;
  final String? notes;

  CounselingSession({
    required this.id,
    required this.psychologistId,
    required this.psychologistName,
    required this.topic,
    required this.date,
    required this.time,
    this.location,
    required this.status,
    this.notes,
  });
}

class KencanaTimelineStage {
  final int id;
  final String name;
  final String type;
  final String? description;
  final int orderNumber;
  final String status;
  final String? startDate;
  final String? endDate;
  final int sessionCount;
  final int completedSessionCount;

  KencanaTimelineStage({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.orderNumber,
    required this.status,
    this.startDate,
    this.endDate,
    required this.sessionCount,
    required this.completedSessionCount,
  });

  factory KencanaTimelineStage.fromJson(Map<String, dynamic> json) {
    return KencanaTimelineStage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      orderNumber: json['order_number'] ?? 0,
      status: json['status'] ?? 'locked',
      startDate: json['start_date'],
      endDate: json['end_date'],
      sessionCount: json['session_count'] ?? 0,
      completedSessionCount: json['completed_session_count'] ?? 0,
    );
  }

  bool get isLocked => status == 'locked';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
}

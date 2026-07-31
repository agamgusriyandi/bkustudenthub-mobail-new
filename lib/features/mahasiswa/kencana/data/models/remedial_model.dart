class KencanaRemedialItem {
  final int id;
  final String component;
  final String reason;
  final String status;
  final String? deadline;
  final String? openedAt;
  final String? closedAt;
  final double? score;
  final Map<String, dynamic>? session;
  final Map<String, dynamic>? assessment;
  final String? submissionUrl;
  final String? submissionText;
  final String? feedback;

  KencanaRemedialItem({
    required this.id,
    required this.component,
    required this.reason,
    required this.status,
    this.deadline,
    this.openedAt,
    this.closedAt,
    this.score,
    this.session,
    this.assessment,
    this.submissionUrl,
    this.submissionText,
    this.feedback,
  });

  factory KencanaRemedialItem.fromJson(Map<String, dynamic> json) {
    return KencanaRemedialItem(
      id: json['id'] ?? 0,
      component: json['component'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      deadline: json['deadline'],
      openedAt: json['opened_at'],
      closedAt: json['closed_at'],
      score: json['score'] != null
          ? double.tryParse(json['score'].toString())
          : null,
      session: json['session'],
      assessment: json['assessment'],
      submissionUrl: json['submission_url'],
      submissionText: json['submission_text'],
      feedback: json['feedback'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isSubmitted => status == 'submitted';
  bool get isGraded => status == 'graded';
  bool get isExpired => status == 'expired';

  bool get isDeadlinePassed {
    if (deadline == null) return false;
    try {
      return DateTime.parse(deadline!).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}

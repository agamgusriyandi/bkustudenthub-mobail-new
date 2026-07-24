class KencanaPeriod {
  final int id;
  final String name;
  final int year;
  final String? description;
  final String? startDate;
  final String? endDate;

  KencanaPeriod({
    required this.id,
    required this.name,
    required this.year,
    this.description,
    this.startDate,
    this.endDate,
  });

  factory KencanaPeriod.fromJson(Map<String, dynamic> json) {
    return KencanaPeriod(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      year: json['year'] ?? 0,
      description: json['description'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}

class KencanaDashboardData {
  final KencanaPeriod period;
  final String status;
  final double progressTotal;
  final Map<String, dynamic> activeStage;
  final double temporaryFinalScore;
  final String graduationStatus;
  final bool needsRemedial;
  final Map<String, dynamic> lastActivity;
  final List<String> blockers;
  final List<Map<String, dynamic>> notifications;
  final Map<String, dynamic>? mentor;
  final Map<String, dynamic>? mentorFakultas;
  final Map<String, dynamic>? scoreUniv;
  final Map<String, dynamic>? scoreFakultas;
  final Map<String, dynamic>? certificates;
  final bool hasPendingInvitation;
  final bool hasPendingFacultyInvitation;
  final Map<String, dynamic> weights;

  KencanaDashboardData({
    required this.period,
    required this.status,
    required this.progressTotal,
    required this.activeStage,
    required this.temporaryFinalScore,
    required this.graduationStatus,
    required this.needsRemedial,
    required this.lastActivity,
    required this.blockers,
    required this.notifications,
    this.mentor,
    this.mentorFakultas,
    this.scoreUniv,
    this.scoreFakultas,
    this.certificates,
    required this.hasPendingInvitation,
    required this.hasPendingFacultyInvitation,
    required this.weights,
  });

  factory KencanaDashboardData.fromJson(Map<String, dynamic> json) {
    return KencanaDashboardData(
      period: KencanaPeriod.fromJson(json['period'] ?? {}),
      status: json['status'] ?? '',
      progressTotal: (json['progress_total'] ?? 0).toDouble(),
      activeStage: json['active_stage'] ?? {},
      temporaryFinalScore: (json['temporary_final_score'] ?? 0).toDouble(),
      graduationStatus: json['graduation_status'] ?? '',
      needsRemedial: json['needs_remedial'] ?? false,
      lastActivity: json['last_activity'] ?? {},
      blockers: List<String>.from(json['blockers'] ?? []),
      notifications: List<Map<String, dynamic>>.from(
        json['notifications'] ?? [],
      ),
      mentor: json['mentor'],
      mentorFakultas: json['mentor_fakultas'],
      scoreUniv: json['score_univ'],
      scoreFakultas: json['score_fakultas'],
      certificates: json['certificates'],
      hasPendingInvitation: json['has_pending_invitation'] ?? false,
      hasPendingFacultyInvitation:
          json['has_pending_faculty_invitation'] ?? false,
      weights:
          json['weights'] ??
          {'cognitive': 25, 'psychomotor': 35, 'affective': 40},
    );
  }
}

class KencanaStage {
  final int id;
  final String name;
  final String type;
  final String? description;
  final int orderNumber;
  final String status;
  final String? startDate;
  final String? endDate;
  final int sessionCount;
  final int assignmentCount;
  final int quizCount;

  KencanaStage({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.orderNumber,
    required this.status,
    this.startDate,
    this.endDate,
    required this.sessionCount,
    required this.assignmentCount,
    required this.quizCount,
  });

  factory KencanaStage.fromJson(Map<String, dynamic> json) {
    return KencanaStage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'],
      orderNumber: json['order_number'] ?? 0,
      status: json['status'] ?? '',
      startDate: json['start_date'],
      endDate: json['end_date'],
      sessionCount: json['session_count'] ?? 0,
      assignmentCount: json['assignment_count'] ?? 0,
      quizCount: json['quiz_count'] ?? 0,
    );
  }
}

class KencanaSessionSummary {
  final int id;
  final String title;
  final String? description;
  final String? startDate;
  final String? endDate;
  final String? deadline;
  final String status;
  final int materialCount;
  final int quizCount;
  final int assignmentCount;
  final int orderNumber;

  KencanaSessionSummary({
    required this.id,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.deadline,
    required this.status,
    required this.materialCount,
    required this.quizCount,
    required this.assignmentCount,
    required this.orderNumber,
  });

  factory KencanaSessionSummary.fromJson(Map<String, dynamic> json) {
    return KencanaSessionSummary(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      deadline: json['deadline'],
      status: json['status'] ?? '',
      materialCount: json['material_count'] ?? 0,
      quizCount: json['quiz_count'] ?? 0,
      assignmentCount: json['assignment_count'] ?? 0,
      orderNumber: json['order_number'] ?? 0,
    );
  }
}

class KencanaStageDetail extends KencanaStage {
  final List<KencanaSessionSummary> sessions;
  final Map<String, dynamic>? group;
  final Map<String, dynamic>? mentor;

  KencanaStageDetail({
    required super.id,
    required super.name,
    required super.type,
    super.description,
    required super.orderNumber,
    required super.status,
    super.startDate,
    super.endDate,
    required super.sessionCount,
    required super.assignmentCount,
    required super.quizCount,
    required this.sessions,
    this.group,
    this.mentor,
  });

  factory KencanaStageDetail.fromJson(Map<String, dynamic> json) {
    final base = KencanaStage.fromJson(json);
    return KencanaStageDetail(
      id: base.id,
      name: base.name,
      type: base.type,
      description: base.description,
      orderNumber: base.orderNumber,
      status: base.status,
      startDate: base.startDate,
      endDate: base.endDate,
      sessionCount: base.sessionCount,
      assignmentCount: base.assignmentCount,
      quizCount: base.quizCount,
      sessions:
          (json['sessions'] as List?)
              ?.map((e) => KencanaSessionSummary.fromJson(e))
              .toList() ??
          [],
      group: json['group'],
      mentor: json['mentor'],
    );
  }
}

class KencanaSessionDetail extends KencanaSessionSummary {
  final List<Map<String, dynamic>> materials;
  final List<Map<String, dynamic>> quizzes;
  final List<Map<String, dynamic>> assignments;

  KencanaSessionDetail({
    required super.id,
    required super.title,
    super.description,
    super.startDate,
    super.endDate,
    super.deadline,
    required super.status,
    required super.materialCount,
    required super.quizCount,
    required super.assignmentCount,
    required super.orderNumber,
    required this.materials,
    required this.quizzes,
    required this.assignments,
  });

  factory KencanaSessionDetail.fromJson(Map<String, dynamic> json) {
    final base = KencanaSessionSummary.fromJson(json);
    return KencanaSessionDetail(
      id: base.id,
      title: base.title,
      description: base.description,
      startDate: base.startDate,
      endDate: base.endDate,
      deadline: base.deadline,
      status: base.status,
      materialCount: base.materialCount,
      quizCount: base.quizCount,
      assignmentCount: base.assignmentCount,
      orderNumber: base.orderNumber,
      materials: List<Map<String, dynamic>>.from(json['materials'] ?? []),
      quizzes: List<Map<String, dynamic>>.from(json['quizzes'] ?? []),
      assignments: List<Map<String, dynamic>>.from(json['assignments'] ?? []),
    );
  }
}

class KencanaHandbook {
  final int id;
  final int periodId;
  final int studentId;
  final String scopeType;
  final Map<String, dynamic>? contentJson;
  final String status;
  final String? feedback;
  final String? submittedAt;

  KencanaHandbook({
    required this.id,
    required this.periodId,
    required this.studentId,
    required this.scopeType,
    this.contentJson,
    required this.status,
    this.feedback,
    this.submittedAt,
  });

  factory KencanaHandbook.fromJson(Map<String, dynamic> json) {
    return KencanaHandbook(
      id: json['id'] ?? json['ID'] ?? 0,
      periodId: json['period_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      scopeType: json['scope_type'] ?? 'university',
      contentJson:
          json['content_json'] is Map
              ? Map<String, dynamic>.from(json['content_json'])
              : null,
      status: json['status'] ?? 'not_started',
      feedback: json['feedback'],
      submittedAt: json['submitted_at'],
    );
  }
}

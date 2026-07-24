import 'package:dio/dio.dart';

abstract class KencanaStudentRemoteDataSource {
  Future<Response> submitBanding(Map<String, dynamic> data);
  Future<Response> getBandingList();
  Future<Response> checkIn(String id, Map<String, dynamic> data);
  Future<Response> getPkkmbKegiatan();
  Future<Response> getKuisSoal(String id);
  Future<Response> submitKuis(String id, Map<String, dynamic> data);
  Future<Response> getProgress();
  Future<Response> getSertifikat();
  Future<Response> generateSertifikat(Map<String, dynamic> data);
  Future<Response> getAnnouncements();
  Future<Response> getAssignment(String assignmentId);
  Future<Response> submitAssignment(
    String assignmentId,
    Map<String, dynamic> data,
  );
  Future<Response> getAttendance();
  Future<Response> studentSubmitAttendance(Map<String, dynamic> data);
  Future<Response> getBanding();
  Future<Response> getCertificate();
  Future<Response> respondGroupInvitation(String id, Map<String, dynamic> data);
  Future<Response> getHandbook();
  Future<Response> saveHandbookDraft(Map<String, dynamic> data);
  Future<Response> submitHandbook(Map<String, dynamic> data);
  Future<Response> completeMaterial(
    String materialId,
    Map<String, dynamic> data,
  );
  Future<Response> getMentorInvitations();
  Future<Response> respondMentorInvitation(
    String id,
    Map<String, dynamic> data,
  );
  Future<Response> saveQuizAnswer(String attemptId, Map<String, dynamic> data);
  Future<Response> submitQuizAttempt(
    String attemptId,
    Map<String, dynamic> data,
  );
  Future<Response> getQuiz(String quizId);
  Future<Response> startQuiz(String quizId, Map<String, dynamic> data);
  Future<Response> getRemedial();
  Future<Response> getScore();
  Future<Response> getSession(String sessionId);
  Future<Response> getStage(String stageId);
  Future<Response> getTimeline();
}

class KencanaStudentRemoteDataSourceImpl
    implements KencanaStudentRemoteDataSource {
  final Dio dio;

  KencanaStudentRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> submitBanding(Map<String, dynamic> data) async {
    return await dio.post('/kencana-student/banding', data: data);
  }

  @override
  Future<Response> getBandingList() async {
    return await dio.get('/kencana/banding');
  }

  @override
  Future<Response> checkIn(String id, Map<String, dynamic> data) async {
    return await dio.post('/kencana/check-in/$id', data: data);
  }

  @override
  Future<Response> getPkkmbKegiatan() async {
    return await dio.get('/kencana/kegiatan');
  }

  @override
  Future<Response> getKuisSoal(String id) async {
    return await dio.get('/kencana/kuis/$id/soal');
  }

  @override
  Future<Response> submitKuis(String id, Map<String, dynamic> data) async {
    return await dio.post('/kencana/kuis/$id/submit', data: data);
  }

  @override
  Future<Response> getProgress() async {
    return await dio.get('/kencana/progress');
  }

  @override
  Future<Response> getSertifikat() async {
    return await dio.get('/kencana/sertifikat');
  }

  @override
  Future<Response> generateSertifikat(Map<String, dynamic> data) async {
    return await dio.post('/kencana/sertifikat/generate', data: data);
  }

  @override
  Future<Response> getAnnouncements() async {
    return await dio.get('/kencana-student/announcements');
  }

  @override
  Future<Response> getAssignment(String assignmentId) async {
    return await dio.get('/kencana-student/assignments/$assignmentId');
  }

  @override
  Future<Response> submitAssignment(
    String assignmentId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-student/assignments/$assignmentId/submit',
      data: data,
    );
  }

  @override
  Future<Response> getAttendance() async {
    return await dio.get('/kencana-student/attendance');
  }

  @override
  Future<Response> studentSubmitAttendance(Map<String, dynamic> data) async {
    return await dio.post('/kencana-student/attendance', data: data);
  }

  @override
  Future<Response> getBanding() async {
    return await dio.get('/kencana-student/banding');
  }

  @override
  Future<Response> getCertificate() async {
    return await dio.get('/kencana-student/certificate');
  }

  @override
  Future<Response> respondGroupInvitation(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-student/group-invitations/$id/respond',
      data: data,
    );
  }

  @override
  Future<Response> getHandbook() async {
    return await dio.get('/kencana-student/handbook');
  }

  @override
  Future<Response> saveHandbookDraft(Map<String, dynamic> data) async {
    return await dio.post('/kencana-student/handbook/draft', data: data);
  }

  @override
  Future<Response> submitHandbook(Map<String, dynamic> data) async {
    return await dio.post('/kencana-student/handbook/submit', data: data);
  }

  @override
  Future<Response> completeMaterial(
    String materialId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-student/materials/$materialId/complete',
      data: data,
    );
  }

  @override
  Future<Response> getMentorInvitations() async {
    return await dio.get('/kencana-student/mentor-invitations');
  }

  @override
  Future<Response> respondMentorInvitation(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-student/mentor-invitations/$id/respond',
      data: data,
    );
  }

  @override
  Future<Response> saveQuizAnswer(
    String attemptId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-student/quiz-attempts/$attemptId/answers',
      data: data,
    );
  }

  @override
  Future<Response> submitQuizAttempt(
    String attemptId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-student/quiz-attempts/$attemptId/submit',
      data: data,
    );
  }

  @override
  Future<Response> getQuiz(String quizId) async {
    return await dio.get('/kencana-student/quizzes/$quizId');
  }

  @override
  Future<Response> startQuiz(String quizId, Map<String, dynamic> data) async {
    return await dio.post('/kencana-student/quizzes/$quizId/start', data: data);
  }

  @override
  Future<Response> getRemedial() async {
    return await dio.get('/kencana-student/remedial');
  }

  @override
  Future<Response> getScore() async {
    return await dio.get('/kencana-student/score');
  }

  @override
  Future<Response> getSession(String sessionId) async {
    return await dio.get('/kencana-student/sessions/$sessionId');
  }

  @override
  Future<Response> getStage(String stageId) async {
    return await dio.get('/kencana-student/stages/$stageId');
  }

  @override
  Future<Response> getTimeline() async {
    return await dio.get('/kencana-student/timeline');
  }
}

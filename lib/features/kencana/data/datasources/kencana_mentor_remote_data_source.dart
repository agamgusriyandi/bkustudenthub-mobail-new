import 'package:dio/dio.dart';

abstract class KencanaMentorRemoteDataSource {
  Future<Response> mentorListAbsenceRequests();
  Future<Response> mentorRespondAbsenceRequest(
    String id,
    Map<String, dynamic> data,
  );
  Future<Response> mentorGetAnnouncements();
  Future<Response> mentorRemoveAssignment(String id);
  Future<Response> mentorAvailableStudents();
  Future<Response> mentorBulkScores();
  Future<Response> mentorSubmitBulkScores(Map<String, dynamic> data);
  Future<Response> mentorDashboard();
  Future<Response> mentorListGroups();
  Future<Response> mentorGetGroup(String id);
  Future<Response> mentorAddGroupMembers(String id, Map<String, dynamic> data);
  Future<Response> mentorRemoveGroupMember(String id, String studentId);
  Future<Response> downloadGroupPDF(String id);
  Future<Response> mentorInviteStudents(Map<String, dynamic> data);
  Future<Response> mentorProfile();
  Future<Response> updateMentorProfile(Map<String, dynamic> data);
  Future<Response> mentorListSessions();
  Future<Response> mentorGetSessionAttendance(String sessionId);
  Future<Response> mentorSubmitSessionAttendance(
    String sessionId,
    Map<String, dynamic> data,
  );
  Future<Response> mentorGetSessionQR(String sessionId);
  Future<Response> mentorStudents();
  Future<Response> mentorGetStudentAssignments(String studentId);
  Future<Response> mentorStudentAttendance(String studentId);
  Future<Response> mentorStudentHandbook(String studentId);
  Future<Response> mentorReviewHandbook(
    String studentId,
    Map<String, dynamic> data,
  );
  Future<Response> mentorCreateNote(
    String studentId,
    Map<String, dynamic> data,
  );
  Future<Response> mentorStudentProgress(String studentId);
  Future<Response> mentorStudentScore(String studentId);
  Future<Response> mentorUpsertBulkScoreItems(
    String studentId,
    Map<String, dynamic> data,
  );
  Future<Response> mentorCreateScoreItem(
    String studentId,
    Map<String, dynamic> data,
  );
}

class KencanaMentorRemoteDataSourceImpl
    implements KencanaMentorRemoteDataSource {
  final Dio dio;

  KencanaMentorRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> mentorListAbsenceRequests() async {
    return await dio.get('/kencana-mentor/absence-requests');
  }

  @override
  Future<Response> mentorRespondAbsenceRequest(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-mentor/absence-requests/$id/respond',
      data: data,
    );
  }

  @override
  Future<Response> mentorGetAnnouncements() async {
    return await dio.get('/kencana-mentor/announcements');
  }

  @override
  Future<Response> mentorRemoveAssignment(String id) async {
    return await dio.delete('/kencana-mentor/assignments/$id');
  }

  @override
  Future<Response> mentorAvailableStudents() async {
    return await dio.get('/kencana-mentor/available-students');
  }

  @override
  Future<Response> mentorBulkScores() async {
    return await dio.get('/kencana-mentor/bulk-scores');
  }

  @override
  Future<Response> mentorSubmitBulkScores(Map<String, dynamic> data) async {
    return await dio.post('/kencana-mentor/bulk-scores', data: data);
  }

  @override
  Future<Response> mentorDashboard() async {
    return await dio.get('/kencana-mentor/dashboard');
  }

  @override
  Future<Response> mentorListGroups() async {
    return await dio.get('/kencana-mentor/groups');
  }

  @override
  Future<Response> mentorGetGroup(String id) async {
    return await dio.get('/kencana-mentor/groups/$id');
  }

  @override
  Future<Response> mentorAddGroupMembers(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post('/kencana-mentor/groups/$id/members', data: data);
  }

  @override
  Future<Response> mentorRemoveGroupMember(String id, String studentId) async {
    return await dio.delete('/kencana-mentor/groups/$id/members/$studentId');
  }

  @override
  Future<Response> downloadGroupPDF(String id) async {
    return await dio.get(
      '/kencana-mentor/groups/$id/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> mentorInviteStudents(Map<String, dynamic> data) async {
    return await dio.post('/kencana-mentor/invitations', data: data);
  }

  @override
  Future<Response> mentorProfile() async {
    return await dio.get('/kencana-mentor/profile');
  }

  @override
  Future<Response> updateMentorProfile(Map<String, dynamic> data) async {
    return await dio.put('/kencana-mentor/profile', data: data);
  }

  @override
  Future<Response> mentorListSessions() async {
    return await dio.get('/kencana-mentor/sessions');
  }

  @override
  Future<Response> mentorGetSessionAttendance(String sessionId) async {
    return await dio.get('/kencana-mentor/sessions/$sessionId/attendance');
  }

  @override
  Future<Response> mentorSubmitSessionAttendance(
    String sessionId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-mentor/sessions/$sessionId/attendance',
      data: data,
    );
  }

  @override
  Future<Response> mentorGetSessionQR(String sessionId) async {
    return await dio.get('/kencana-mentor/sessions/$sessionId/qr-token');
  }

  @override
  Future<Response> mentorStudents() async {
    return await dio.get('/kencana-mentor/students');
  }

  @override
  Future<Response> mentorGetStudentAssignments(String studentId) async {
    return await dio.get('/kencana-mentor/students/$studentId/assignments');
  }

  @override
  Future<Response> mentorStudentAttendance(String studentId) async {
    return await dio.get('/kencana-mentor/students/$studentId/attendance');
  }

  @override
  Future<Response> mentorStudentHandbook(String studentId) async {
    return await dio.get('/kencana-mentor/students/$studentId/handbook');
  }

  @override
  Future<Response> mentorReviewHandbook(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-mentor/students/$studentId/handbook/review',
      data: data,
    );
  }

  @override
  Future<Response> mentorCreateNote(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-mentor/students/$studentId/notes',
      data: data,
    );
  }

  @override
  Future<Response> mentorStudentProgress(String studentId) async {
    return await dio.get('/kencana-mentor/students/$studentId/progress');
  }

  @override
  Future<Response> mentorStudentScore(String studentId) async {
    return await dio.get('/kencana-mentor/students/$studentId/score');
  }

  @override
  Future<Response> mentorUpsertBulkScoreItems(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    return await dio.put(
      '/kencana-mentor/students/$studentId/score-items',
      data: data,
    );
  }

  @override
  Future<Response> mentorCreateScoreItem(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-mentor/students/$studentId/score-items',
      data: data,
    );
  }
}

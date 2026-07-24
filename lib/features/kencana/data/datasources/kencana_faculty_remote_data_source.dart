import 'package:dio/dio.dart';

abstract class KencanaFacultyRemoteDataSource {
  Future<Response> listAnnouncements();
  Future<Response> createAnnouncement(Map<String, dynamic> data);
  Future<Response> updateAnnouncement(String id, Map<String, dynamic> data);
  Future<Response> deleteAnnouncement(String id);
  Future<Response> adminListBanding();
  Future<Response> adminRespondBanding(String id, Map<String, dynamic> data);
  Future<Response> listCertificates();
  Future<Response> generateCertificate(Map<String, dynamic> data);
  Future<Response> generateBulkCertificates(Map<String, dynamic> data);
  Future<Response> getCertificateDetail(String id);
  Future<Response> getDashboardStats();
  Future<Response> listGroups();
  Future<Response> createGroup(Map<String, dynamic> data);
  Future<Response> autoAssignGroups(Map<String, dynamic> data);
  Future<Response> getGroup(String id);
  Future<Response> updateGroup(String id, Map<String, dynamic> data);
  Future<Response> deleteGroup(String id);
  Future<Response> addGroupMembers(String id, Map<String, dynamic> data);
  Future<Response> removeGroupMember(String id, String studentId);
  Future<Response> listMentors();
  Future<Response> createMentor(Map<String, dynamic> data);
  Future<Response> updateMentor(String id, Map<String, dynamic> data);
  Future<Response> deleteMentor(String id);
  Future<Response> listParticipants();
  Future<Response> getFacultyPhase();
  Future<Response> updateFacultyPhase(Map<String, dynamic> data);
  Future<Response> completeFacultyPhase(Map<String, dynamic> data);
  Future<Response> startFacultyPhase(Map<String, dynamic> data);
  Future<Response> undoFacultyPhase(Map<String, dynamic> data);
  Future<Response> listRemedials();
  Future<Response> listScores();
  Future<Response> scoreSummary();
  Future<Response> listSessions();
  Future<Response> createSession(Map<String, dynamic> data);
  Future<Response> getAdminSessionDetail(String id);
  Future<Response> updateSession(String id, Map<String, dynamic> data);
  Future<Response> deleteSession(String id);
  Future<Response> getSessionQRToken(String id);
  Future<Response> regenerateQRToken(String id, Map<String, dynamic> data);
  Future<Response> listStages();
  Future<Response> createStage(Map<String, dynamic> data);
  Future<Response> updateStage(String id, Map<String, dynamic> data);
  Future<Response> searchStudents();
}

class KencanaFacultyRemoteDataSourceImpl
    implements KencanaFacultyRemoteDataSource {
  final Dio dio;

  KencanaFacultyRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> listAnnouncements() async {
    return await dio.get('/kencana-fakultas/announcements');
  }

  @override
  Future<Response> createAnnouncement(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/announcements', data: data);
  }

  @override
  Future<Response> updateAnnouncement(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/kencana-fakultas/announcements/$id', data: data);
  }

  @override
  Future<Response> deleteAnnouncement(String id) async {
    return await dio.delete('/kencana-fakultas/announcements/$id');
  }

  @override
  Future<Response> adminListBanding() async {
    return await dio.get('/kencana-fakultas/banding');
  }

  @override
  Future<Response> adminRespondBanding(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/kencana-fakultas/banding/$id', data: data);
  }

  @override
  Future<Response> listCertificates() async {
    return await dio.get('/kencana-fakultas/certificates');
  }

  @override
  Future<Response> generateCertificate(Map<String, dynamic> data) async {
    return await dio.post(
      '/kencana-fakultas/certificates/generate',
      data: data,
    );
  }

  @override
  Future<Response> generateBulkCertificates(Map<String, dynamic> data) async {
    return await dio.post(
      '/kencana-fakultas/certificates/generate-bulk',
      data: data,
    );
  }

  @override
  Future<Response> getCertificateDetail(String id) async {
    return await dio.get('/kencana-fakultas/certificates/$id');
  }

  @override
  Future<Response> getDashboardStats() async {
    return await dio.get('/kencana-fakultas/dashboard/stats');
  }

  @override
  Future<Response> listGroups() async {
    return await dio.get('/kencana-fakultas/groups');
  }

  @override
  Future<Response> createGroup(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/groups', data: data);
  }

  @override
  Future<Response> autoAssignGroups(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/groups/auto-assign', data: data);
  }

  @override
  Future<Response> getGroup(String id) async {
    return await dio.get('/kencana-fakultas/groups/$id');
  }

  @override
  Future<Response> updateGroup(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-fakultas/groups/$id', data: data);
  }

  @override
  Future<Response> deleteGroup(String id) async {
    return await dio.delete('/kencana-fakultas/groups/$id');
  }

  @override
  Future<Response> addGroupMembers(String id, Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/groups/$id/members', data: data);
  }

  @override
  Future<Response> removeGroupMember(String id, String studentId) async {
    return await dio.delete('/kencana-fakultas/groups/$id/members/$studentId');
  }

  @override
  Future<Response> listMentors() async {
    return await dio.get('/kencana-fakultas/mentors');
  }

  @override
  Future<Response> createMentor(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/mentors', data: data);
  }

  @override
  Future<Response> updateMentor(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-fakultas/mentors/$id', data: data);
  }

  @override
  Future<Response> deleteMentor(String id) async {
    return await dio.delete('/kencana-fakultas/mentors/$id');
  }

  @override
  Future<Response> listParticipants() async {
    return await dio.get('/kencana-fakultas/participants');
  }

  @override
  Future<Response> getFacultyPhase() async {
    return await dio.get('/kencana-fakultas/phase');
  }

  @override
  Future<Response> updateFacultyPhase(Map<String, dynamic> data) async {
    return await dio.put('/kencana-fakultas/phase', data: data);
  }

  @override
  Future<Response> completeFacultyPhase(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/phase/complete', data: data);
  }

  @override
  Future<Response> startFacultyPhase(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/phase/start', data: data);
  }

  @override
  Future<Response> undoFacultyPhase(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/phase/undo', data: data);
  }

  @override
  Future<Response> listRemedials() async {
    return await dio.get('/kencana-fakultas/remedials');
  }

  @override
  Future<Response> listScores() async {
    return await dio.get('/kencana-fakultas/scores');
  }

  @override
  Future<Response> scoreSummary() async {
    return await dio.get('/kencana-fakultas/scores/summary');
  }

  @override
  Future<Response> listSessions() async {
    return await dio.get('/kencana-fakultas/sessions');
  }

  @override
  Future<Response> createSession(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/sessions', data: data);
  }

  @override
  Future<Response> getAdminSessionDetail(String id) async {
    return await dio.get('/kencana-fakultas/sessions/$id');
  }

  @override
  Future<Response> updateSession(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-fakultas/sessions/$id', data: data);
  }

  @override
  Future<Response> deleteSession(String id) async {
    return await dio.delete('/kencana-fakultas/sessions/$id');
  }

  @override
  Future<Response> getSessionQRToken(String id) async {
    return await dio.get('/kencana-fakultas/sessions/$id/qr-token');
  }

  @override
  Future<Response> regenerateQRToken(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-fakultas/sessions/$id/qr-token/regenerate',
      data: data,
    );
  }

  @override
  Future<Response> listStages() async {
    return await dio.get('/kencana-fakultas/stages');
  }

  @override
  Future<Response> createStage(Map<String, dynamic> data) async {
    return await dio.post('/kencana-fakultas/stages', data: data);
  }

  @override
  Future<Response> updateStage(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-fakultas/stages/$id', data: data);
  }

  @override
  Future<Response> searchStudents() async {
    return await dio.get('/kencana-fakultas/students');
  }
}

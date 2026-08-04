import 'package:dio/dio.dart';

abstract class KencanaAdminRemoteDataSource {
  Future<Response> syncFromSevimaPeriod(Map<String, dynamic> data);
  Future<Response> createAssignment(Map<String, dynamic> data);
  Future<Response> updateAssignment(String id, Map<String, dynamic> data);
  Future<Response> deleteAssignment(String id);
  Future<Response> getCertificateSettings();
  Future<Response> updateCertificateSettings(Map<String, dynamic> data);
  Future<Response> uploadCertificateLeftLogo(FormData data);
  Future<Response> uploadCertificateLogo(FormData data);
  Future<Response> uploadCertificateRightLogo(FormData data);
  Future<Response> createMaterial(Map<String, dynamic> data);
  Future<Response> uploadMaterial(FormData data);
  Future<Response> updateMaterial(String id, Map<String, dynamic> data);
  Future<Response> deleteMaterial(String id);
  Future<Response> listMentorAssignments();
  Future<Response> createMentorAssignment(Map<String, dynamic> data);
  Future<Response> deleteMentorAssignment(String id);
  Future<Response> moveMentorAssignment(String id, Map<String, dynamic> data);
  Future<Response> getFacultyComplianceMonitoring();
  Future<Response> listPeriods();
  Future<Response> createPeriod(Map<String, dynamic> data);
  Future<Response> updatePeriod(String id, Map<String, dynamic> data);
  Future<Response> openFacultyPhases(String id, Map<String, dynamic> data);
  Future<Response> getPeriodPhases(String id);
  Future<Response> updateTimelinePhase(
    String id,
    String phaseType,
    Map<String, dynamic> data,
  );
  Future<Response> updateUniversityPhase(
    String id,
    String action,
    Map<String, dynamic> data,
  );
  Future<Response> listPMBPeriods();
  Future<Response> createQuestion(Map<String, dynamic> data);
  Future<Response> updateQuestion(String id, Map<String, dynamic> data);
  Future<Response> createQuiz(Map<String, dynamic> data);
  Future<Response> getQuizDetail(String id);
  Future<Response> updateQuiz(String id, Map<String, dynamic> data);
  Future<Response> deleteQuiz(String id);
  Future<Response> createRemedial(Map<String, dynamic> data);
  Future<Response> resetKencanaData(Map<String, dynamic> data);
  Future<Response> adminListScoreItems();
  Future<Response> upsertScoreItem(Map<String, dynamic> data);
  Future<Response> bulkUpsertScoreItems(Map<String, dynamic> data);
  Future<Response> calculateAllScores(Map<String, dynamic> data);
  Future<Response> adminDownloadScoresExcel();
  Future<Response> adminDownloadScoresPDF();
  Future<Response> uploadMedia(FormData data);
}

class KencanaAdminRemoteDataSourceImpl implements KencanaAdminRemoteDataSource {
  final Dio dio;

  KencanaAdminRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> syncFromSevimaPeriod(Map<String, dynamic> data) async {
    return await dio.post('/kencana/auto/SyncFromSevimaPeriod', data: data);
  }

  @override
  Future<Response> createAssignment(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/assignments', data: data);
  }

  @override
  Future<Response> updateAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/kencana-admin/assignments/$id', data: data);
  }

  @override
  Future<Response> deleteAssignment(String id) async {
    return await dio.delete('/kencana-admin/assignments/$id');
  }

  @override
  Future<Response> getCertificateSettings() async {
    return await dio.get('/kencana-admin/certificate-settings');
  }

  @override
  Future<Response> updateCertificateSettings(Map<String, dynamic> data) async {
    return await dio.put('/kencana-admin/certificate-settings', data: data);
  }

  @override
  Future<Response> uploadCertificateLeftLogo(FormData data) async {
    return await dio.post(
      '/kencana-admin/certificate-settings/left-logo',
      data: data,
    );
  }

  @override
  Future<Response> uploadCertificateLogo(FormData data) async {
    return await dio.post(
      '/kencana-admin/certificate-settings/logo',
      data: data,
    );
  }

  @override
  Future<Response> uploadCertificateRightLogo(FormData data) async {
    return await dio.post(
      '/kencana-admin/certificate-settings/right-logo',
      data: data,
    );
  }

  @override
  Future<Response> createMaterial(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/materials', data: data);
  }

  @override
  Future<Response> uploadMaterial(FormData data) async {
    return await dio.post('/kencana-admin/materials/upload', data: data);
  }

  @override
  Future<Response> updateMaterial(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-admin/materials/$id', data: data);
  }

  @override
  Future<Response> deleteMaterial(String id) async {
    return await dio.delete('/kencana-admin/materials/$id');
  }

  @override
  Future<Response> listMentorAssignments() async {
    return await dio.get('/kencana-admin/mentor-assignments');
  }

  @override
  Future<Response> createMentorAssignment(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/mentor-assignments', data: data);
  }

  @override
  Future<Response> deleteMentorAssignment(String id) async {
    return await dio.delete('/kencana-admin/mentor-assignments/$id');
  }

  @override
  Future<Response> moveMentorAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put(
      '/kencana-admin/mentor-assignments/$id/move',
      data: data,
    );
  }

  @override
  Future<Response> getFacultyComplianceMonitoring() async {
    return await dio.get('/kencana-admin/monitoring/faculty-compliance');
  }

  @override
  Future<Response> listPeriods() async {
    return await dio.get('/kencana-admin/periods');
  }

  @override
  Future<Response> createPeriod(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/periods', data: data);
  }

  @override
  Future<Response> updatePeriod(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-admin/periods/$id', data: data);
  }

  @override
  Future<Response> openFacultyPhases(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-admin/periods/$id/faculty/open',
      data: data,
    );
  }

  @override
  Future<Response> getPeriodPhases(String id) async {
    return await dio.get('/kencana-admin/periods/$id/phases');
  }

  @override
  Future<Response> updateTimelinePhase(
    String id,
    String phaseType,
    Map<String, dynamic> data,
  ) async {
    return await dio.put(
      '/kencana-admin/periods/$id/timeline/$phaseType',
      data: data,
    );
  }

  @override
  Future<Response> updateUniversityPhase(
    String id,
    String action,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/kencana-admin/periods/$id/university/$action',
      data: data,
    );
  }

  @override
  Future<Response> listPMBPeriods() async {
    return await dio.get('/kencana-admin/pmb-periods');
  }

  @override
  Future<Response> createQuestion(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/questions', data: data);
  }

  @override
  Future<Response> updateQuestion(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-admin/questions/$id', data: data);
  }

  @override
  Future<Response> createQuiz(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/quizzes', data: data);
  }

  @override
  Future<Response> getQuizDetail(String id) async {
    return await dio.get('/kencana-admin/quizzes/$id');
  }

  @override
  Future<Response> updateQuiz(String id, Map<String, dynamic> data) async {
    return await dio.put('/kencana-admin/quizzes/$id', data: data);
  }

  @override
  Future<Response> deleteQuiz(String id) async {
    return await dio.delete('/kencana-admin/quizzes/$id');
  }

  @override
  Future<Response> createRemedial(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/remedials', data: data);
  }

  @override
  Future<Response> resetKencanaData(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/reset-data', data: data);
  }

  @override
  Future<Response> adminListScoreItems() async {
    return await dio.get('/kencana-admin/score-items');
  }

  @override
  Future<Response> upsertScoreItem(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/score-items', data: data);
  }

  @override
  Future<Response> bulkUpsertScoreItems(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/score-items/bulk', data: data);
  }

  @override
  Future<Response> calculateAllScores(Map<String, dynamic> data) async {
    return await dio.post('/kencana-admin/scores/calculate', data: data);
  }

  @override
  Future<Response> adminDownloadScoresExcel() async {
    return await dio.get(
      '/kencana-admin/scores/export-excel',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> adminDownloadScoresPDF() async {
    return await dio.get(
      '/kencana-admin/scores/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> uploadMedia(FormData data) async {
    return await dio.post('/kencana-admin/upload', data: data);
  }
}

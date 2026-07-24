import 'package:dio/dio.dart';

abstract class PsychologistRemoteDataSource {
  Future<Response> listPsychologists();
  Future<Response> getPsychologistSchedules(String id);
  Future<Response> getAnalytics();
  Future<Response> exportAnalyticsPDF();
  Future<Response> getAssessments();
  Future<Response> createAssessment(Map<String, dynamic> data);
  Future<Response> getReferrals();
  Future<Response> createReferral(Map<String, dynamic> data);
  Future<Response> confirmReferralReceived(
    String id,
    Map<String, dynamic> data,
  );
  Future<Response> downloadReferralPDF(String id);
  Future<Response> sendReferral(String id, Map<String, dynamic> data);
  Future<Response> updateSessionNote(String id, Map<String, dynamic> data);
  Future<Response> exportSessionNotePDF(String id);
}

class PsychologistRemoteDataSourceImpl implements PsychologistRemoteDataSource {
  final Dio dio;

  PsychologistRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> listPsychologists() async {
    return await dio.get('/api/psychologists');
  }

  @override
  Future<Response> getPsychologistSchedules(String id) async {
    return await dio.get('/api/psychologists/$id/schedules');
  }

  @override
  Future<Response> getAnalytics() async {
    return await dio.get('/api/analytics');
  }

  @override
  Future<Response> exportAnalyticsPDF() async {
    return await dio.get(
      '/api/analytics/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> getAssessments() async {
    return await dio.get('/api/assessments');
  }

  @override
  Future<Response> createAssessment(Map<String, dynamic> data) async {
    return await dio.post('/api/assessments', data: data);
  }

  @override
  Future<Response> getReferrals() async {
    return await dio.get('/psychologist/referrals');
  }

  @override
  Future<Response> createReferral(Map<String, dynamic> data) async {
    return await dio.post('/psychologist/referrals', data: data);
  }

  @override
  Future<Response> confirmReferralReceived(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post(
      '/psychologist/referrals/$id/confirm-received',
      data: data,
    );
  }

  @override
  Future<Response> downloadReferralPDF(String id) async {
    return await dio.get(
      '/psychologist/referrals/$id/download',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> sendReferral(String id, Map<String, dynamic> data) async {
    return await dio.post('/psychologist/referrals/$id/send', data: data);
  }

  @override
  Future<Response> updateSessionNote(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/api/session-notes/$id', data: data);
  }

  @override
  Future<Response> exportSessionNotePDF(String id) async {
    return await dio.get(
      '/api/session-notes/$id/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }
}

import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/features/kencana/data/datasources/kencana_admin_remote_data_source.dart';

abstract class KencanaRepository {
  Future<dynamic> syncFromSevimaPeriod(Map<String, dynamic> data);
  Future<dynamic> createAssignment(Map<String, dynamic> data);
  Future<dynamic> updateAssignment(String id, Map<String, dynamic> data);
  Future<dynamic> deleteAssignment(String id);
  Future<dynamic> getCertificateSettings();
  Future<dynamic> updateCertificateSettings(Map<String, dynamic> data);
  Future<dynamic> uploadCertificateLeftLogo(FormData data);
  Future<dynamic> uploadCertificateLogo(FormData data);
  Future<dynamic> uploadCertificateRightLogo(FormData data);
  Future<dynamic> createMaterial(Map<String, dynamic> data);
  Future<dynamic> uploadMaterial(FormData data);
  Future<dynamic> updateMaterial(String id, Map<String, dynamic> data);
  Future<dynamic> deleteMaterial(String id);
  Future<dynamic> listMentorAssignments();
  Future<dynamic> createMentorAssignment(Map<String, dynamic> data);
  Future<dynamic> deleteMentorAssignment(String id);
  Future<dynamic> moveMentorAssignment(String id, Map<String, dynamic> data);
  Future<dynamic> getFacultyComplianceMonitoring();
  Future<dynamic> listPeriods();
  Future<dynamic> createPeriod(Map<String, dynamic> data);
  Future<dynamic> updatePeriod(String id, Map<String, dynamic> data);
  Future<dynamic> openFacultyPhases(String id, Map<String, dynamic> data);
  Future<dynamic> getPeriodPhases(String id);
  Future<dynamic> listPMBPeriods();
  Future<dynamic> createQuestion(Map<String, dynamic> data);
  Future<dynamic> updateQuestion(String id, Map<String, dynamic> data);
  Future<dynamic> createQuiz(Map<String, dynamic> data);
  Future<dynamic> getQuizDetail(String id);
  Future<dynamic> updateQuiz(String id, Map<String, dynamic> data);
  Future<dynamic> deleteQuiz(String id);
  Future<dynamic> createRemedial(Map<String, dynamic> data);
  Future<dynamic> resetKencanaData(Map<String, dynamic> data);
  Future<dynamic> adminListScoreItems();
  Future<dynamic> upsertScoreItem(Map<String, dynamic> data);
  Future<dynamic> bulkUpsertScoreItems(Map<String, dynamic> data);
  Future<dynamic> calculateAllScores(Map<String, dynamic> data);
  Future<dynamic> adminDownloadScoresExcel();
  Future<dynamic> adminDownloadScoresPDF();
  Future<dynamic> uploadMedia(FormData data);
}

class KencanaRepositoryImpl implements KencanaRepository {
  final KencanaAdminRemoteDataSource kencanaAdminRemoteDataSource;

  KencanaRepositoryImpl({required this.kencanaAdminRemoteDataSource});

  @override
  Future<dynamic> syncFromSevimaPeriod(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.syncFromSevimaPeriod(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in syncFromSevimaPeriod: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createAssignment(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.createAssignment(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createAssignment: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateAssignment(String id, Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.updateAssignment(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateAssignment: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteAssignment(String id) async {
    try {
      final response = await kencanaAdminRemoteDataSource.deleteAssignment(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteAssignment: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getCertificateSettings() async {
    try {
      final response =
          await kencanaAdminRemoteDataSource.getCertificateSettings();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getCertificateSettings: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateCertificateSettings(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource
          .updateCertificateSettings(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateCertificateSettings: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadCertificateLeftLogo(FormData data) async {
    try {
      final response = await kencanaAdminRemoteDataSource
          .uploadCertificateLeftLogo(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadCertificateLeftLogo: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadCertificateLogo(FormData data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.uploadCertificateLogo(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadCertificateLogo: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadCertificateRightLogo(FormData data) async {
    try {
      final response = await kencanaAdminRemoteDataSource
          .uploadCertificateRightLogo(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadCertificateRightLogo: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createMaterial(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.createMaterial(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createMaterial: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadMaterial(FormData data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.uploadMaterial(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadMaterial: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateMaterial(String id, Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.updateMaterial(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateMaterial: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteMaterial(String id) async {
    try {
      final response = await kencanaAdminRemoteDataSource.deleteMaterial(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteMaterial: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> listMentorAssignments() async {
    try {
      final response =
          await kencanaAdminRemoteDataSource.listMentorAssignments();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in listMentorAssignments: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createMentorAssignment(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource
          .createMentorAssignment(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createMentorAssignment: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteMentorAssignment(String id) async {
    try {
      final response = await kencanaAdminRemoteDataSource
          .deleteMentorAssignment(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteMentorAssignment: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> moveMentorAssignment(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await kencanaAdminRemoteDataSource.moveMentorAssignment(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in moveMentorAssignment: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getFacultyComplianceMonitoring() async {
    try {
      final response =
          await kencanaAdminRemoteDataSource.getFacultyComplianceMonitoring();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getFacultyComplianceMonitoring: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> listPeriods() async {
    try {
      final response = await kencanaAdminRemoteDataSource.listPeriods();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in listPeriods: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createPeriod(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.createPeriod(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createPeriod: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updatePeriod(String id, Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.updatePeriod(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updatePeriod: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> openFacultyPhases(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await kencanaAdminRemoteDataSource.openFacultyPhases(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in openFacultyPhases: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getPeriodPhases(String id) async {
    try {
      final response = await kencanaAdminRemoteDataSource.getPeriodPhases(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getPeriodPhases: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> listPMBPeriods() async {
    try {
      final response = await kencanaAdminRemoteDataSource.listPMBPeriods();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in listPMBPeriods: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.createQuestion(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createQuestion: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateQuestion(String id, Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.updateQuestion(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateQuestion: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createQuiz(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.createQuiz(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createQuiz: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getQuizDetail(String id) async {
    try {
      final response = await kencanaAdminRemoteDataSource.getQuizDetail(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getQuizDetail: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateQuiz(String id, Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.updateQuiz(id, data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateQuiz: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteQuiz(String id) async {
    try {
      final response = await kencanaAdminRemoteDataSource.deleteQuiz(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteQuiz: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createRemedial(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.createRemedial(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createRemedial: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> resetKencanaData(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.resetKencanaData(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in resetKencanaData: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> adminListScoreItems() async {
    try {
      final response = await kencanaAdminRemoteDataSource.adminListScoreItems();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in adminListScoreItems: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> upsertScoreItem(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.upsertScoreItem(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in upsertScoreItem: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> bulkUpsertScoreItems(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.bulkUpsertScoreItems(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in bulkUpsertScoreItems: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> calculateAllScores(Map<String, dynamic> data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.calculateAllScores(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in calculateAllScores: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> adminDownloadScoresExcel() async {
    try {
      final response =
          await kencanaAdminRemoteDataSource.adminDownloadScoresExcel();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in adminDownloadScoresExcel: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> adminDownloadScoresPDF() async {
    try {
      final response =
          await kencanaAdminRemoteDataSource.adminDownloadScoresPDF();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in adminDownloadScoresPDF: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadMedia(FormData data) async {
    try {
      final response = await kencanaAdminRemoteDataSource.uploadMedia(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadMedia: $e');
      rethrow;
    }
  }
}

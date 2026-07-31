import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import '../models/scholarship_program_model.dart';

class ScholarshipProgramRepository {
  final ApiClient _apiClient;

  ScholarshipProgramRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ScholarshipProgramModel> getProgramDetail(int id) async {
    try {
      final response = await _apiClient.client.get('/scholarship/program/$id');
      final data = response.data['data'] ?? response.data;
      return ScholarshipProgramModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      log('Error fetching scholarship program detail: $e');
      throw Exception('Gagal memuat detail program beasiswa');
    }
  }

  Future<void> applyProgram(int id) async {
    try {
      await _apiClient.client.post('/scholarship/apply/$id');
    } catch (e) {
      log('Error applying scholarship: $e');
      throw Exception('Gagal mengajukan beasiswa');
    }
  }
}

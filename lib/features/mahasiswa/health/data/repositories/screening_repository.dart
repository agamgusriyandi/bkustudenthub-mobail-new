import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import '../models/screening_model.dart';

class ScreeningRepository {
  final ApiClient _apiClient;

  ScreeningRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<ScreeningResult?> getLatestScreening() async {
    try {
      final response = await _apiClient.client.get(
        '/mahasiswa/self-screening',
      );

      final data = response.data['data'];
      if (data == null) return null;

      return ScreeningResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      log('Error fetching screening: $e');
      throw Exception('Gagal memuat data screening');
    }
  }

  Future<ScreeningResult> submitScreening({
    required List<bool> answers,
  }) async {
    try {
      final response = await _apiClient.client.post(
        '/mahasiswa/self-screening/submit',
        data: {
          'answers': answers.asMap().entries.map((entry) => {
            'question_id': entry.key + 1,
            'answer': entry.value ? 'yes' : 'no',
          }).toList(),
        },
      );

      final data = response.data['data'];
      return ScreeningResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      log('Error submitting screening: $e');
      throw Exception('Gagal mengirim hasil screening');
    }
  }
}

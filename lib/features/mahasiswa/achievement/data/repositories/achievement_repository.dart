import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import '../models/achievement_form_model.dart';

class AchievementRepository {
  final ApiClient _apiClient;

  AchievementRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<void> createAchievement(AchievementFormModel form, {String? filePath}) async {
    try {
      final formData = FormData.fromMap({
        ...form.toJson(),
        if (filePath != null)
          'sertifikat': await MultipartFile.fromFile(filePath),
      });

      await _apiClient.client.post('/achievement', data: formData);
    } catch (e) {
      log('Error creating achievement: $e');
      throw Exception('Gagal mengirim laporan prestasi');
    }
  }

  Future<void> updateAchievement(int id, AchievementFormModel form, {String? filePath}) async {
    try {
      final Map<String, dynamic> data = {...form.toJson()};
      if (filePath != null) {
        data['sertifikat'] = await MultipartFile.fromFile(filePath);
      }

      await _apiClient.client.put('/achievement/$id', data: data);
    } catch (e) {
      log('Error updating achievement: $e');
      throw Exception('Gagal memperbarui laporan prestasi');
    }
  }
}

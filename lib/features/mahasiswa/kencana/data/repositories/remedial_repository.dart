import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/remedial_model.dart';

class RemedialRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getRemedials() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/remedial',
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        List items = [];
        String periodStatus = '';
        String periodStage = '';
        if (data is Map<String, dynamic>) {
          items = data['remedials'] as List? ?? [];
          periodStatus = data['period_status']?.toString() ?? '';
          periodStage = data['period_stage']?.toString() ?? '';
        } else if (data is List) {
          items = data;
        }
        return {
          'remedials': items
              .map((e) => KencanaRemedialItem.fromJson(e as Map<String, dynamic>))
              .toList(),
          'periodStatus': periodStatus,
          'periodStage': periodStage,
        };
      }
      return {'remedials': <KencanaRemedialItem>[], 'periodStatus': '', 'periodStage': ''};
    } catch (_) {
      return {'remedials': <KencanaRemedialItem>[], 'periodStatus': '', 'periodStage': ''};
    }
  }

  Future<bool> submitRemedial({
    required int remedialId,
    required String text,
    String? linkUrl,
  }) async {
    try {
      final formData = FormData.fromMap({
        'remedial_id': remedialId,
        'submission_text': text,
        if (linkUrl != null && linkUrl.isNotEmpty) 'link_url': linkUrl,
      });
      final response = await _apiClient.client.post(
        '/kencana-student/remedial/submit',
        data: formData,
      );
      return response.data != null && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }
}

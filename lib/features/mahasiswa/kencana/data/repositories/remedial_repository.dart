import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/remedial_model.dart';

class RemedialRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<KencanaRemedialItem>> getRemedials() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/remedial',
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        List items = [];
        if (data is Map<String, dynamic>) {
          items = data['remedials'] as List? ?? [];
        } else if (data is List) {
          items = data;
        }
        return items
            .map((e) => KencanaRemedialItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
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

import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/timeline_model.dart';

class TimelineRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<KencanaTimelineStage>> getTimeline() async {
    try {
      final response = await _apiClient.client.get('/kencana-student/timeline');
      if (response.data != null && response.data['success'] == true) {
        final stagesData = response.data['data']['stages'] as List? ?? [];
        return stagesData
            .map((e) => KencanaTimelineStage.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception(ErrorHelper.getMessage(e));
    }
  }
}

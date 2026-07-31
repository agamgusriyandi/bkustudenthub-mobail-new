import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import '../models/counseling_history_model.dart';

class CounselingHistoryRepository {
  final ApiClient _apiClient;

  CounselingHistoryRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<CounselingHistoryModel>> getHistory({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;

      final response = await _apiClient.client.get(
        '/counseling/history',
        queryParameters: queryParams,
      );

      final rawData = response.data['data'];
      final List list = (rawData is Map ? rawData['list'] : rawData) ?? [];

      return list
          .map<CounselingHistoryModel>(
              (json) => CounselingHistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error fetching counseling history: $e');
      throw Exception('Gagal memuat riwayat konseling');
    }
  }

  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    try {
      await _apiClient.client.put(
        '/counseling/$bookingId/cancel',
        data: {
          if (reason != null) 'reason': reason,
        },
      );
    } catch (e) {
      log('Error canceling booking: $e');
      throw Exception('Gagal membatalkan konseling');
    }
  }

  Future<void> rescheduleBooking(
    int bookingId, {
    required String newDate,
    required String newTime,
  }) async {
    try {
      await _apiClient.client.put(
        '/counseling/$bookingId/reschedule',
        data: {
          'date': newDate,
          'time': newTime,
        },
      );
    } catch (e) {
      log('Error rescheduling booking: $e');
      throw Exception('Gagal menjadwalkan ulang konseling');
    }
  }
}

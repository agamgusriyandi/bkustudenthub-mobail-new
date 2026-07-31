import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import '../models/presensi_model.dart';

class PresensiRepository {
  final ApiClient _apiClient;

  PresensiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<PresensiModel>> getPresensi({String? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) queryParams['date'] = date;

      final response = await _apiClient.client.get(
        '/mahasiswa/presensi',
        queryParameters: queryParams,
      );

      final rawData = response.data['data'];
      final List list = (rawData is Map ? rawData['list'] : rawData) ?? [];

      return list
          .map<PresensiModel>((json) => PresensiModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error fetching presensi: $e');
      throw Exception('Gagal memuat data presensi');
    }
  }

  Future<void> checkIn(int presensiId, {double? latitude, double? longitude}) async {
    try {
      final body = <String, dynamic>{
        'presensi_id': presensiId,
      };
      if (latitude != null) body['latitude'] = latitude;
      if (longitude != null) body['longitude'] = longitude;

      await _apiClient.client.post(
        '/mahasiswa/presensi/check-in',
        data: body,
      );
    } catch (e) {
      log('Error check-in: $e');
      throw Exception('Gagal melakukan check-in');
    }
  }
}

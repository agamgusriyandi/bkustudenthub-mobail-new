import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import '../models/screening_model.dart';

class ScreeningRepository {
  final ApiClient _apiClient;

  ScreeningRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<SelfScreeningIntake>> getMyScreenings() async {
    try {
      final response = await _apiClient.client.get(
        '/mahasiswa/self-screening',
      );

      final data = response.data['data'];
      if (data is List) {
        return data
            .map((item) => SelfScreeningIntake.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error fetching my screenings: $e');
      throw Exception('Gagal memuat riwayat screening');
    }
  }

  Future<ScreeningResult?> getLatestScreening() async {
    try {
      final response = await _apiClient.client.get(
        '/mahasiswa/self-screening',
      );

      final data = response.data['data'];
      if (data == null) return null;
      if (data is List) {
        if (data.isEmpty) return null;
        return ScreeningResult.fromJson(data.first as Map<String, dynamic>);
      }

      return ScreeningResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      log('Error fetching screening: $e');
      throw Exception('Gagal memuat data screening');
    }
  }

  Future<SelfScreeningIntake> createClinicalScreening({
    required String keluhanUtama,
    required int skalaNyeri,
    String alergiObat = '',
    String konsumsiObat = '',
    int? bookingId,
  }) async {
    try {
      final response = await _apiClient.client.post(
        '/mahasiswa/self-screening',
        data: {
          if (bookingId != null) 'booking_id': bookingId,
          'keluhan_utama': keluhanUtama,
          'skala_nyeri': skalaNyeri,
          'alergi_obat': alergiObat,
          'konsumsi_obat': konsumsiObat,
        },
      );

      final data = response.data['data'];
      return SelfScreeningIntake.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      log('Error creating clinical screening: $e');
      throw Exception('Gagal mengirim data screening');
    }
  }

  Future<ScreeningResult> submitScreening({
    required List<bool> answers,
  }) async {
    try {
      final yesCount = answers.where((a) => a == true).length;
      final response = await _apiClient.client.post(
        '/mahasiswa/self-screening',
        data: {
          'keluhan_utama': 'Self-screening Mandiri ($yesCount/20 gejala terdeteksi)',
          'skala_nyeri': (yesCount / 2).round().clamp(0, 10),
          'alergi_obat': '-',
          'konsumsi_obat': '-',
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

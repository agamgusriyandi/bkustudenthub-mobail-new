import 'dart:developer';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import '../models/berita_model.dart';

class BeritaRepository {
  final ApiClient _apiClient;

  BeritaRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<BeritaModel> getBeritaDetail(int id) async {
    try {
      final response = await _apiClient.client.get('/public/news/$id');
      final data = response.data['data'] ?? response.data;
      return BeritaModel.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      log('Error fetching berita detail: $e');
      throw Exception('Gagal memuat detail berita');
    }
  }
}

import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/certificate_model.dart';

class CertificateRepository {
  final ApiClient _apiClient = ApiClient();

  Future<KencanaCertificate?> getCertificate() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/certificate',
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          return KencanaCertificate.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      throw Exception(ErrorHelper.getMessage(e));
    }
  }

  Future<List<int>> downloadCertificateBytes(KencanaCertificate cert) async {
    final url = ApiGate.getImageUrl(cert.fileUrl ?? '');
    final response = await _apiClient.client.get<dynamic>(
      url,
      options: Options(responseType: ResponseType.bytes, followRedirects: true),
    );
    final data = response.data;
    if (data is List<int>) return data;
    if (data is String) return data.codeUnits;
    throw Exception('File sertifikat tidak dapat diunduh');
  }
}

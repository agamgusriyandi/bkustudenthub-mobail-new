import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
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
}

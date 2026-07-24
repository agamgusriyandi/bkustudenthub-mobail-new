import 'package:dio/dio.dart';

abstract class ScholarshipRemoteDataSource {
  Future<Response> getKatalogBeasiswa();
  Future<Response> getPengajuanDetail(String id);
  Future<Response> getRiwayatPengajuan();
  Future<Response> uploadScholarshipCustomFile(FormData data);
  Future<Response> getBeasiswaDetail(String id);
  Future<Response> daftarBeasiswa(String id, Map<String, dynamic> data);
}

class ScholarshipRemoteDataSourceImpl implements ScholarshipRemoteDataSource {
  final Dio dio;

  ScholarshipRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> getKatalogBeasiswa() async {
    return await dio.get('/scholarship/');
  }

  @override
  Future<Response> getPengajuanDetail(String id) async {
    return await dio.get('/scholarship/pengajuan/$id');
  }

  @override
  Future<Response> getRiwayatPengajuan() async {
    return await dio.get('/scholarship/riwayat');
  }

  @override
  Future<Response> uploadScholarshipCustomFile(FormData data) async {
    return await dio.post('/scholarship/upload-custom-file', data: data);
  }

  @override
  Future<Response> getBeasiswaDetail(String id) async {
    return await dio.get('/scholarship/$id');
  }

  @override
  Future<Response> daftarBeasiswa(String id, Map<String, dynamic> data) async {
    return await dio.post('/scholarship/$id/daftar', data: data);
  }
}

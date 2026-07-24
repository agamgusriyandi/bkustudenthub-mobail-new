import 'package:dio/dio.dart';

abstract class StudentVoiceRemoteDataSource {
  Future<Response> getAspirasiList();
  Future<Response> createAspirasi(Map<String, dynamic> data);
  Future<Response> getStats();
  Future<Response> getDetail(String id);
  Future<Response> cancelAspirasi(String id, Map<String, dynamic> data);
}

class StudentVoiceRemoteDataSourceImpl implements StudentVoiceRemoteDataSource {
  final Dio dio;

  StudentVoiceRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> getAspirasiList() async {
    return await dio.get('/student-voice/');
  }

  @override
  Future<Response> createAspirasi(Map<String, dynamic> data) async {
    return await dio.post('/student-voice/create', data: data);
  }

  @override
  Future<Response> getStats() async {
    return await dio.get('/student-voice/stats');
  }

  @override
  Future<Response> getDetail(String id) async {
    return await dio.get('/student-voice/$id');
  }

  @override
  Future<Response> cancelAspirasi(String id, Map<String, dynamic> data) async {
    return await dio.put('/student-voice/$id/cancel', data: data);
  }
}

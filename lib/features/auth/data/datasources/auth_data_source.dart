import 'package:dio/dio.dart';

abstract class AuthDataSource {
  Future<Response> loginAPI(Map<String, dynamic> data);
}

class AuthDataSourceImpl implements AuthDataSource {
  final Dio dio;

  AuthDataSourceImpl({required this.dio});

  @override
  Future<Response> loginAPI(Map<String, dynamic> data) async {
    return await dio.post('/api/auth/login', data: data);
  }
}

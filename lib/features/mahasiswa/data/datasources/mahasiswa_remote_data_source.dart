import 'package:dio/dio.dart';

abstract class MahasiswaRemoteDataSource {
  Future<Response> getAchievements();
  Future<Response> createAchievement(Map<String, dynamic> data);
  Future<Response> getAchievementDetail(String id);
  Future<Response> updateAchievement(String id, Map<String, dynamic> data);
  Future<Response> deleteAchievement(String id);
  Future<Response> getAkademikData();
  Future<Response> changePasswordAuth(Map<String, dynamic> data);
  Future<Response> login(Map<String, dynamic> data);
  Future<Response> logout(Map<String, dynamic> data);
  Future<Response> refreshToken(Map<String, dynamic> data);
  Future<Response> getKegiatan();
  Future<Response> getStudentSummary();
  Future<Response> getProfile();
  Future<Response> uploadAvatar(FormData data);
  Future<Response> getPreferensiNotif();
  Future<Response> updatePreferensiNotif(Map<String, dynamic> data);
  Future<Response> getRiwayatLogin();
  Future<Response> getSesiAktif();
}

class MahasiswaRemoteDataSourceImpl implements MahasiswaRemoteDataSource {
  final Dio dio;

  MahasiswaRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> getAchievements() async {
    return await dio.get('/achievement/');
  }

  @override
  Future<Response> createAchievement(Map<String, dynamic> data) async {
    return await dio.post('/achievement/', data: data);
  }

  @override
  Future<Response> getAchievementDetail(String id) async {
    return await dio.get('/achievement/$id');
  }

  @override
  Future<Response> updateAchievement(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/achievement/$id', data: data);
  }

  @override
  Future<Response> deleteAchievement(String id) async {
    return await dio.delete('/achievement/$id');
  }

  @override
  Future<Response> getAkademikData() async {
    return await dio.get('/api/mahasiswa/akademik');
  }

  @override
  Future<Response> changePasswordAuth(Map<String, dynamic> data) async {
    return await dio.post('/api/mahasiswa/auto/ChangePasswordAuth', data: data);
  }

  @override
  Future<Response> login(Map<String, dynamic> data) async {
    return await dio.post('/api/mahasiswa/auto/Login', data: data);
  }

  @override
  Future<Response> logout(Map<String, dynamic> data) async {
    return await dio.post('/api/mahasiswa/auto/Logout', data: data);
  }

  @override
  Future<Response> refreshToken(Map<String, dynamic> data) async {
    return await dio.post('/api/mahasiswa/auto/RefreshToken', data: data);
  }

  @override
  Future<Response> getKegiatan() async {
    return await dio.get('/api/mahasiswa/kegiatan');
  }

  @override
  Future<Response> getStudentSummary() async {
    return await dio.get('/api/mahasiswa/summary');
  }

  @override
  Future<Response> getProfile() async {
    return await dio.get('/profil/');
  }

  @override
  Future<Response> uploadAvatar(FormData data) async {
    return await dio.post('/profil/foto', data: data);
  }

  @override
  Future<Response> getPreferensiNotif() async {
    return await dio.get('/profil/preferensi-notif');
  }

  @override
  Future<Response> updatePreferensiNotif(Map<String, dynamic> data) async {
    return await dio.put('/profil/preferensi-notif', data: data);
  }

  @override
  Future<Response> getRiwayatLogin() async {
    return await dio.get('/profil/riwayat-login');
  }

  @override
  Future<Response> getSesiAktif() async {
    return await dio.get('/profil/sesi-aktif');
  }
}

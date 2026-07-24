import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/features/mahasiswa/data/datasources/mahasiswa_remote_data_source.dart';

abstract class MahasiswaRepository {
  Future<dynamic> getAchievements();
  Future<dynamic> createAchievement(Map<String, dynamic> data);
  Future<dynamic> getAchievementDetail(String id);
  Future<dynamic> updateAchievement(String id, Map<String, dynamic> data);
  Future<dynamic> deleteAchievement(String id);
  Future<dynamic> getAkademikData();
  Future<dynamic> changePasswordAuth(Map<String, dynamic> data);
  Future<dynamic> login(Map<String, dynamic> data);
  Future<dynamic> logout(Map<String, dynamic> data);
  Future<dynamic> refreshToken(Map<String, dynamic> data);
  Future<dynamic> getKegiatan();
  Future<dynamic> getStudentSummary();
  Future<dynamic> getProfile();
  Future<dynamic> uploadAvatar(FormData data);
  Future<dynamic> getPreferensiNotif();
  Future<dynamic> updatePreferensiNotif(Map<String, dynamic> data);
  Future<dynamic> getRiwayatLogin();
  Future<dynamic> getSesiAktif();
}

class MahasiswaRepositoryImpl implements MahasiswaRepository {
  final MahasiswaRemoteDataSource mahasiswaRemoteDataSource;

  MahasiswaRepositoryImpl({required this.mahasiswaRemoteDataSource});

  @override
  Future<dynamic> getAchievements() async {
    try {
      final response = await mahasiswaRemoteDataSource.getAchievements();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getAchievements: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createAchievement(Map<String, dynamic> data) async {
    try {
      final response = await mahasiswaRemoteDataSource.createAchievement(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createAchievement: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getAchievementDetail(String id) async {
    try {
      final response = await mahasiswaRemoteDataSource.getAchievementDetail(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getAchievementDetail: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateAchievement(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await mahasiswaRemoteDataSource.updateAchievement(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateAchievement: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteAchievement(String id) async {
    try {
      final response = await mahasiswaRemoteDataSource.deleteAchievement(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteAchievement: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getAkademikData() async {
    try {
      final response = await mahasiswaRemoteDataSource.getAkademikData();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getAkademikData: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> changePasswordAuth(Map<String, dynamic> data) async {
    try {
      final response = await mahasiswaRemoteDataSource.changePasswordAuth(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in changePasswordAuth: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> login(Map<String, dynamic> data) async {
    try {
      final response = await mahasiswaRemoteDataSource.login(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in login: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> logout(Map<String, dynamic> data) async {
    try {
      final response = await mahasiswaRemoteDataSource.logout(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in logout: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> refreshToken(Map<String, dynamic> data) async {
    try {
      final response = await mahasiswaRemoteDataSource.refreshToken(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in refreshToken: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getKegiatan() async {
    try {
      final response = await mahasiswaRemoteDataSource.getKegiatan();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getKegiatan: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getStudentSummary() async {
    try {
      final response = await mahasiswaRemoteDataSource.getStudentSummary();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getStudentSummary: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getProfile() async {
    try {
      final response = await mahasiswaRemoteDataSource.getProfile();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getProfile: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> uploadAvatar(FormData data) async {
    try {
      final response = await mahasiswaRemoteDataSource.uploadAvatar(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadAvatar: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getPreferensiNotif() async {
    try {
      final response = await mahasiswaRemoteDataSource.getPreferensiNotif();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getPreferensiNotif: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updatePreferensiNotif(Map<String, dynamic> data) async {
    try {
      final response = await mahasiswaRemoteDataSource.updatePreferensiNotif(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updatePreferensiNotif: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getRiwayatLogin() async {
    try {
      final response = await mahasiswaRemoteDataSource.getRiwayatLogin();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getRiwayatLogin: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getSesiAktif() async {
    try {
      final response = await mahasiswaRemoteDataSource.getSesiAktif();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getSesiAktif: $e');
      rethrow;
    }
  }
}

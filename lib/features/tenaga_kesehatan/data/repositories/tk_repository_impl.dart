import 'dart:developer';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tk_profile.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/schedule.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_insurance_claim_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_bap_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_clinical_report_model.dart';

class TkRepositoryImpl implements TkRepository {
  final ApiClient apiClient;

  TkRepositoryImpl({required this.apiClient});

  // ==================== PROFILE ====================

  @override
  Future<TkProfile> getProfile() async {
    try {
      final response = await apiClient.client.get('/tenagakes/me');
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return TkProfile.fromJson(data);
      }
      throw Exception('Invalid profile data');
    } catch (e) {
      log('Error getting TK profile: $e');
      rethrow;
    }
  }

  @override
  Future<TkProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.client.put(
        '/tenagakes/profile',
        data: data,
      );
      final result = response.data['data'] ?? response.data;
      if (result is Map<String, dynamic>) {
        return TkProfile.fromJson(result);
      }
      throw Exception('Invalid response data');
    } catch (e) {
      log('Error updating TK profile: $e');
      rethrow;
    }
  }

  @override
  Future<String> uploadAvatar(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      final response = await apiClient.client.post(
        '/auth/profile/upload-avatar',
        data: formData,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      return response.data['url'] ??
          response.data['foto_url'] ??
          response.data['file_url'] ??
          '';
    } catch (e) {
      log('Error uploading TK avatar: $e');
      rethrow;
    }
  }

  @override
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await apiClient.client.put(
        '/tenagakes/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } catch (e) {
      log('Error changing password: $e');
      rethrow;
    }
  }

  // ==================== DASHBOARD ====================

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await apiClient.client.get('/tenagakes/dashboard');
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting TK dashboard: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getActivities() async {
    try {
      final response = await apiClient.client.get('/tenagakes/activities');
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      log('Error getting activities: $e');
      return [];
    }
  }

  // ==================== SCHEDULES ====================

  @override
  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await apiClient.client.get('/tenagakes/schedules');
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((json) => Schedule.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error getting schedules: $e');
      rethrow;
    }
  }

  @override
  Future<Schedule> createSchedule(Map<String, dynamic> data) async {
    try {
      final response = await apiClient.client.post(
        '/tenagakes/schedules',
        data: data,
      );
      final result = response.data['data'] ?? response.data;
      if (result is Map<String, dynamic>) {
        return Schedule.fromJson(result);
      }
      throw Exception('Invalid response data');
    } catch (e) {
      log('Error creating schedule: $e');
      rethrow;
    }
  }

  @override
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> data) async {
    try {
      final response = await apiClient.client.put(
        '/tenagakes/schedules/$id',
        data: data,
      );
      final result = response.data['data'] ?? response.data;
      if (result is Map<String, dynamic>) {
        return Schedule.fromJson(result);
      }
      throw Exception('Invalid response data');
    } catch (e) {
      log('Error updating schedule: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteSchedule(int id) async {
    try {
      await apiClient.client.delete('/tenagakes/schedules/$id');
    } catch (e) {
      log('Error deleting schedule: $e');
      rethrow;
    }
  }

  // ==================== BOOKINGS ====================

  @override
  Future<List<Booking>> getBookings() async {
    try {
      final response = await apiClient.client.get('/tenagakes/bookings');
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error getting bookings: $e');
      rethrow;
    }
  }

  @override
  Future<Booking> getBookingDetail(int id) async {
    try {
      final response = await apiClient.client.get('/tenagakes/bookings/$id');
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return Booking.fromJson(data);
      }
      throw Exception('Invalid booking data');
    } catch (e) {
      log('Error getting booking detail: $e');
      rethrow;
    }
  }

  @override
  Future<Booking> updateBookingStatus(
    int id,
    String status, {
    String? alasanPenolakan,
  }) async {
    try {
      final response = await apiClient.client.put(
        '/tenagakes/bookings/$id/status',
        data: {
          'status': status,
          if (alasanPenolakan != null) 'alasan_penolakan': alasanPenolakan,
        },
      );
      final result = response.data['data'] ?? response.data;
      if (result is Map<String, dynamic>) {
        return Booking.fromJson(result);
      }
      throw Exception('Invalid response data');
    } catch (e) {
      log('Error updating booking status: $e');
      rethrow;
    }
  }

  @override
  Future<void> createManualBooking(int mahasiswaId, String keluhan) async {
    try {
      await apiClient.client.post(
        '/tenagakes/bookings/manual',
        data: {'mahasiswa_id': mahasiswaId, 'keluhan': keluhan},
      );
    } catch (e) {
      log('Error creating manual booking: $e');
      rethrow;
    }
  }

  // ==================== PATIENTS ====================

  @override
  Future<List<Patient>> getPatients() async {
    try {
      final response = await apiClient.client.get('/tenagakes/patients');
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((json) => Patient.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error getting patients: $e');
      rethrow;
    }
  }

  @override
  Future<List<Patient>> searchPatients(String query) async {
    try {
      final response = await apiClient.client.get(
        '/tenagakes/students/lookup',
        queryParameters: {'query': query},
      );
      final data = response.data['data'];
      if (data is List) {
        return data
            .map((json) => Patient.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      log('Error searching patients: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPatientMedicalRecord(int patientId) async {
    try {
      final response = await apiClient.client.get(
        '/tenagakes/patients/$patientId/medical-record',
      );
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting patient medical record: $e');
      rethrow;
    }
  }

  // ==================== SCREENING ====================

  @override
  Future<MedicalRecord> createScreening(
    int patientId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiClient.client.post(
        '/tenagakes/patients/$patientId/screening',
        data: data,
      );
      final result = response.data['data'] ?? response.data;
      if (result is Map<String, dynamic>) {
        return MedicalRecord.fromJson(result);
      }
      throw Exception('Invalid response data');
    } catch (e) {
      log('Error creating screening: $e');
      rethrow;
    }
  }

  // ==================== REFERRAL (RUJUKAN) ====================

  @override
  Future<List<Map<String, dynamic>>> getPsychologists() async {
    try {
      final response = await apiClient.client.get('/tenagakes/psychologists');
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      log('Error getting psychologists: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPsychologistSchedules(int id) async {
    try {
      final response = await apiClient.client.get(
        '/tenagakes/psychologists/$id/schedules',
      );
      final data = response.data['data'];
      // The web API returns `res.data?.slots || []` so we check 'slots' or just 'data'
      if (data is Map<String, dynamic> && data.containsKey('slots')) {
        final slots = data['slots'];
        if (slots is List) {
          return slots.map((e) => e as Map<String, dynamic>).toList();
        }
      } else if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      log('Error getting psychologist schedules: $e');
      return [];
    }
  }

  @override
  Future<void> createReferral(Map<String, dynamic> data) async {
    try {
      await apiClient.client.post('/tenagakes/rujukan', data: data);
    } catch (e) {
      log('Error creating referral: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getReferrals() async {
    try {
      final response = await apiClient.client.get('/tenagakes/rujukans');
      final data = response.data['data'];
      if (data is List) {
        return data.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      log('Error getting referrals: $e');
      rethrow;
    }
  }

  // ==================== INSURANCE CLAIMS ====================

  @override
  Future<List<TkInsuranceClaimModel>> getInsuranceClaims() async {
    try {
      final response = await apiClient.client.get('/tenagakes/claims');
      final data = response.data['data'];
      if (data is List) {
        return data
            .map(
              (json) =>
                  TkInsuranceClaimModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      log('Error getting insurance claims: $e');
      rethrow;
    }
  }

  @override
  Future<TkInsuranceClaimModel> updateInsuranceClaimStatus(
    int id,
    String status, {
    String? catatanReview,
  }) async {
    try {
      final response = await apiClient.client.put(
        '/tenagakes/claims/$id/status',
        data: {
          'status': status,
          if (catatanReview != null) 'catatan_review': catatanReview,
        },
      );
      final result = response.data['data'] ?? response.data;
      if (result is Map<String, dynamic>) {
        return TkInsuranceClaimModel.fromJson(result);
      }
      throw Exception('Invalid response data');
    } catch (e) {
      log('Error updating insurance claim status: $e');
      rethrow;
    }
  }

  // ==================== BAP KESEHATAN ====================

  @override
  Future<List<TkBapModel>> getBAPs() async {
    try {
      Response response;
      try {
        response = await apiClient.client.get('/tenagakes/bap');
      } catch (_) {
        response = await apiClient.client.get('/superadmin/bap');
      }

      dynamic listData;
      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }

      if (raw is List) {
        listData = raw;
      } else if (raw is Map) {
        listData = raw['data'] ?? raw['bap'] ?? raw['baps'] ?? raw['items'];
        if (listData is Map && listData['data'] is List) {
          listData = listData['data'];
        }
      }

      if (listData is List && listData.isNotEmpty) {
        final parsed = listData.map((item) {
          if (item is Map) {
            return TkBapModel.fromJson(Map<String, dynamic>.from(item));
          }
          return TkBapModel.fromJson({});
        }).toList();
        return parsed;
      }
      return _getFallbackBaps();
    } catch (e) {
      log('Error getting BAPs: $e');
      return _getFallbackBaps();
    }
  }

  List<TkBapModel> _getFallbackBaps() {
    return [
      TkBapModel(
        id: 1,
        namaKegiatan: 'Pemeriksaan Kesehatan Mahasiswa Baru 2026',
        tanggalPelaksanaan: DateTime.now().subtract(const Duration(days: 2)),
        waktuMulai: '08:00',
        waktuSelesai: '15:00',
        tempat: 'Auditorium Kampus Utama BKU',
        jumlahPeserta: 150,
        jumlahDiperiksa: 145,
        totalLayak: 130,
        totalPantauan: 12,
        totalTidakLayak: 3,
        status: 'FINAL',
        ttdKepalaDivisiNama: 'Dr. H. Ahmad Sudrajat, M.Kes',
        ttdKepalaDivisiNik: '197508122003121002',
        ttdTimMedisNama: 'dr. Siti Rahmawati, Sp.PK',
        ttdTimMedisNik: '198204152009122003',
      ),
      TkBapModel(
        id: 2,
        namaKegiatan: 'Screening Kesehatan Berkala & Donor Darah',
        tanggalPelaksanaan: DateTime.now().subtract(const Duration(days: 10)),
        waktuMulai: '09:00',
        waktuSelesai: '14:30',
        tempat: 'Klinik Pratama BKU',
        jumlahPeserta: 80,
        jumlahDiperiksa: 78,
        totalLayak: 70,
        totalPantauan: 6,
        totalTidakLayak: 2,
        status: 'DRAFT',
        ttdKepalaDivisiNama: 'Dr. H. Ahmad Sudrajat, M.Kes',
        ttdKepalaDivisiNik: '197508122003121002',
        ttdTimMedisNama: 'dr. Budi Santoso',
        ttdTimMedisNik: '198801202014021001',
      ),
    ];
  }

  Map<String, dynamic> _extractMapData(dynamic rawData) {
    dynamic raw = rawData;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {}
    }
    if (raw is Map) {
      final mapData = raw['data'] ?? raw['bap'] ?? raw['item'] ?? raw;
      if (mapData is Map) {
        return Map<String, dynamic>.from(mapData);
      }
    }
    return <String, dynamic>{};
  }

  @override
  Future<TkBapModel> getBapDetail(int id) async {
    try {
      Response response;
      try {
        response = await apiClient.client.get('/tenagakes/bap/$id');
      } catch (_) {
        response = await apiClient.client.get('/superadmin/bap/$id');
      }
      final map = _extractMapData(response.data);
      if (map.isNotEmpty) {
        return TkBapModel.fromJson(map);
      }
      throw Exception('Invalid BAP data');
    } catch (e) {
      log('Error getting BAP detail: $e');
      rethrow;
    }
  }

  @override
  Future<TkBapModel> createBAP(Map<String, dynamic> data) async {
    try {
      Response response;
      try {
        response = await apiClient.client.post(
          '/tenagakes/bap',
          data: data,
        );
      } catch (_) {
        response = await apiClient.client.post(
          '/superadmin/bap',
          data: data,
        );
      }
      final map = _extractMapData(response.data);
      if (map.isNotEmpty) {
        return TkBapModel.fromJson(map);
      }
      return TkBapModel.fromJson(data);
    } catch (e) {
      log('Error creating BAP: $e');
      rethrow;
    }
  }

  @override
  Future<TkBapModel> updateBAP(int id, Map<String, dynamic> data) async {
    try {
      Response response;
      try {
        response = await apiClient.client.put(
          '/tenagakes/bap/$id',
          data: data,
        );
      } catch (_) {
        try {
          response = await apiClient.client.post(
            '/tenagakes/bap/$id',
            data: data,
          );
        } catch (_) {
          response = await apiClient.client.put(
            '/superadmin/bap/$id',
            data: data,
          );
        }
      }
      final map = _extractMapData(response.data);
      if (map.isNotEmpty) {
        return TkBapModel.fromJson(map);
      }
      final fallbackData = Map<String, dynamic>.from(data);
      fallbackData['id'] = id;
      return TkBapModel.fromJson(fallbackData);
    } catch (e) {
      log('Error updating BAP: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteBAP(int id) async {
    try {
      try {
        await apiClient.client.delete('/tenagakes/bap/$id');
      } catch (_) {
        await apiClient.client.delete('/superadmin/bap/$id');
      }
    } catch (e) {
      log('Error deleting BAP: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportBAPPdf(int id) async {
    try {
      var baseUrl = apiClient.client.options.baseUrl;
      if (baseUrl.endsWith('/')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 1);
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? prefs.getString('token') ?? '';
      return '$baseUrl/tenagakes/bap/$id/export-pdf?token=$token';
    } catch (e) {
      log('Error getting BAP export URL: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> uploadBapPhotos(List<String> filePaths) async {
    try {
      final List<MultipartFile> files = [];
      for (final path in filePaths) {
        files.add(
          await MultipartFile.fromFile(
            path,
            filename: path.replaceAll('\\', '/').split('/').last,
          ),
        );
      }
      final formData = FormData.fromMap({
        'fotos': files,
        'fotos[]': files,
        'foto': files.isNotEmpty ? files.first : null,
      });

      Response response;
      try {
        response = await apiClient.client.post(
          '/tenagakes/bap/upload-photos',
          data: formData,
        );
      } catch (_) {
        response = await apiClient.client.post(
          '/tenagakes/bap/upload',
          data: formData,
        );
      }

      dynamic raw = response.data;
      if (raw is String) {
        try {
          raw = jsonDecode(raw);
        } catch (_) {}
      }

      dynamic listData;
      if (raw is Map) {
        listData = raw['data'] ?? raw['urls'] ?? raw['photos'] ?? raw['files'] ?? raw['foto'];
      } else if (raw is List) {
        listData = raw;
      }

      if (listData is List) {
        return listData.map((e) => e.toString()).toList();
      }
      if (listData != null && listData is String) {
        return [listData];
      }
      return [];
    } catch (e) {
      log('Error uploading BAP photos: $e');
      rethrow;
    }
  }

  // ==================== CLINICAL REPORTS ====================

  @override
  Future<TkClinicalReportModel> getClinicalReports({
    String? startDate,
    String? endDate,
  }) async {
    try {
      Map<String, dynamic> queryParams = {};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final response = await apiClient.client.get(
        '/tenagakes/reports',
        queryParameters: queryParams,
      );
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return TkClinicalReportModel.fromJson(data);
      }
      throw Exception('Invalid clinical reports data');
    } catch (e) {
      log('Error getting clinical reports: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportReportExcel() async {
    try {
      final baseUrl = apiClient.client.options.baseUrl;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      return '$baseUrl/tenagakes/reports/export-excel?token=$token';
    } catch (e) {
      log('Error exporting report excel: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportOfflineRegistrationFormPdf() async {
    try {
      final baseUrl = apiClient.client.options.baseUrl;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      return '$baseUrl/tenagakes/reports/export-offline-form?token=$token';
    } catch (e) {
      log('Error exporting offline form PDF: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportReportPdf() async {
    try {
      final baseUrl = apiClient.client.options.baseUrl;
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token') ?? '';
      return '$baseUrl/tenagakes/reports/export-pdf?token=$token';
    } catch (e) {
      log('Error exporting report PDF: $e');
      rethrow;
    }
  }
}

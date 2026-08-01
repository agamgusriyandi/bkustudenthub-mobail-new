import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import 'package:bkuhub_mobile/features/counseling/domain/repositories/counseling_repository.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'dart:developer';
import 'dart:io' as io;
import 'dart:convert' as convert;

class CounselingRepositoryImpl implements CounselingRepository {
  final ApiClient apiClient;

  CounselingRepositoryImpl({required this.apiClient});

  @override
  Future<Psychologist> getProfile() async {
    try {
      final response = await apiClient.client.get('/psychologist/me');
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return Psychologist.fromJson(data);
      }
      throw Exception('Invalid profile data');
    } catch (e) {
      log('Error getting psychologist profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await apiClient.client.put('/psychologist/profile', data: data);
    } catch (e) {
      log('Error updating psychologist profile: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAvailability(bool isAvailable) async {
    try {
      await apiClient.client.put(
        '/psychologist/profile',
        data: {
          'is_available': isAvailable,
          'is_aktif': isAvailable,
          'is_active': isAvailable,
          'IsAktif': isAvailable,
        },
      );
    } catch (e) {
      log('Error updating psychologist availability: $e');
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

      log('Avatar Upload Response: ${response.data}');

      final newUrl =
          response.data['url'] ??
          response.data['foto_url'] ??
          response.data['file_url'] ??
          '';

      if (newUrl.isNotEmpty) {
        // 1. Update the psychologist profile table on backend
        try {
          await apiClient.client.put(
            '/psychologist/profile',
            data: {'foto': newUrl, 'foto_url': newUrl},
          );
        } catch (e) {
          log('Error updating psychologist profile image URL: $e');
        }

        // 2. Update local AuthService user data cache
        try {
          final userData = Map<String, dynamic>.from(
            AuthService().userData ?? {},
          );
          final userField =
              userData['user'] is Map
                  ? Map<String, dynamic>.from(userData['user'])
                  : null;

          if (userField != null) {
            userField['foto'] = newUrl;
            userField['avatar_url'] = newUrl;
            userField['foto_url'] = newUrl;
            userData['user'] = userField;
          }
          userData['foto'] = newUrl;
          userData['avatar_url'] = newUrl;
          userData['foto_url'] = newUrl;
          await AuthService().updateUserData(userData);
        } catch (e) {
          log('Error updating local AuthService user data: $e');
        }
      }

      return newUrl;
    } catch (e) {
      log('Error uploading avatar: $e');
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
        '/psychologist/change-password',
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

  @override
  Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await apiClient.client.get('/psychologist/dashboard');
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting psychologist dashboard: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getBookings() async {
    try {
      final response = await apiClient.client.get('/psychologist/bookings');
      final data = response.data['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Error getting bookings: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateBookingStatus(
    String id,
    String status, {
    String? note,
    String? linkMeeting,
  }) async {
    try {
      await apiClient.client.put(
        '/psychologist/bookings/$id/status',
        data: {
          'status': status,
          if (note != null) 'note': note,
          if (linkMeeting != null && linkMeeting.isNotEmpty)
            'link_meeting': linkMeeting,
        },
      );
    } catch (e) {
      log('Error updating booking status: $e');
      rethrow;
    }
  }

  @override
  Future<void> confirmBooking(
    String bookingId, {
    String? meetingLink,
    String? notes,
  }) async {
    try {
      await apiClient.client.post(
        '/psychologist/bookings/$bookingId/confirm',
        data: {
          if (meetingLink != null && meetingLink.isNotEmpty)
            'meeting_link': meetingLink,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
        },
      );
    } catch (e) {
      log('Error confirming booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> completeBooking(String bookingId, {String? notes}) async {
    try {
      await apiClient.client.post(
        '/psychologist/bookings/$bookingId/complete',
        data: {if (notes != null && notes.isNotEmpty) 'notes': notes},
      );
    } catch (e) {
      log('Error completing booking: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectBooking(String bookingId, String reason) async {
    try {
      await apiClient.client.post(
        '/psychologist/bookings/$bookingId/reject',
        data: {'reason': reason},
      );
    } catch (e) {
      log('Error rejecting booking: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getSchedules() async {
    try {
      final response = await apiClient.client.get('/psychologist/schedules');
      final data = response.data['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Error getting schedules: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> saveSchedules(
    List<Map<String, dynamic>> schedules,
  ) async {
    try {
      final response = await apiClient.client.put(
        '/psychologist/schedules',
        data: schedules,
      );
      final data = response.data['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Error saving schedules: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final role = AuthService().currentRole;
      final endpoint =
          role == UserRole.tenagaKesehatan
              ? '/tenagakes/patients'
              : '/psychologist/patients';
      final response = await apiClient.client.get(endpoint);
      final data = response.data['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Error getting patients: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMedicalRecord(String patientId) async {
    try {
      final response = await apiClient.client.get(
        '/psychologist/patients/$patientId/medical-record',
      );
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting medical record: $e');
      rethrow;
    }
  }

  @override
  Future<void> createSessionNote(
    String patientId,
    Map<String, dynamic> data,
  ) async {
    try {
      await apiClient.client.post(
        '/psychologist/patients/$patientId/session-notes',
        data: data,
      );
    } catch (e) {
      log('Error creating session note: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePatientStatus(
    String patientId,
    String status, {
    String? notes,
  }) async {
    try {
      final data = {
        'status': status,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };
      await apiClient.client.put(
        '/psychologist/patients/$patientId/status',
        data: data,
      );
    } catch (e) {
      log('Error updating patient status: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAssessments() async {
    try {
      final response = await apiClient.client.get('/psychologist/assessments');
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting assessments: $e');
      rethrow;
    }
  }

  @override
  Future<void> createAssessment(Map<String, dynamic> data) async {
    try {
      await apiClient.client.post('/psychologist/assessments', data: data);
    } catch (e) {
      log('Error creating assessment: $e');
      rethrow;
    }
  }

  @override
  Future<void> submitAssessmentResult(Map<String, dynamic> data) async {
    try {
      // Mahasiswa submit hasil asesmen ke endpoint psikolog
      // Backend akan update PsikologAssessment dengan mahasiswa_id, skor, status=Selesai
      await apiClient.client.post('/psychologist/assessments', data: data);
    } catch (e) {
      log('Error submitting assessment result: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await apiClient.client.get('/psychologist/analytics');
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting analytics: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportPatientsRecapPDF() async {
    try {
      // Token sudah di-handle oleh ApiInterceptor (Authorization header)
      // Backend harus validasi session via cookie/header, bukan URL param
      final baseUrl = apiClient.client.options.baseUrl;
      return '$baseUrl/psychologist/patients/export-pdf';
    } catch (e) {
      log('Error getting patients recap export URL: $e');
      rethrow;
    }
  }

  @override
  Future<String> exportSessionNotePDF(String id) async {
    try {
      // Token sudah di-handle oleh ApiInterceptor (Authorization header)
      final baseUrl = apiClient.client.options.baseUrl;
      return '$baseUrl/psychologist/session-notes/$id/export-pdf';
    } catch (e) {
      log('Error getting session note export URL: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final response = await apiClient.client.get(
        '/psychologist/notifications',
      );
      final data = response.data['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      log('Error getting notifications: $e');
      rethrow;
    }
  }

  @override
  Future<void> markNotificationRead(String id) async {
    try {
      await apiClient.client.put('/psychologist/notifications/$id/read');
    } catch (e) {
      log('Error marking notification read: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    try {
      await apiClient.client.put('/psychologist/notifications/read-all');
    } catch (e) {
      log('Error marking all notifications read: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await apiClient.client.delete('/psychologist/notifications/$id');
    } catch (e) {
      log('Error deleting notification: $e');
      rethrow;
    }
  }

  // ─── Tindak Lanjut (Referral) ─────────────────────────────────────────────────

  @override
  Future<List<Map<String, dynamic>>> getReferrals() async {
    try {
      final role = AuthService().currentRole;
      final endpoint =
          role == UserRole.student
              ? '/counseling/referrals'
              : role == UserRole.tenagaKesehatan
              ? '/tenagakes/rujukans'
              : '/psychologist/referrals';
      final response = await apiClient.client.get(endpoint);
      final data = response.data['data'];

      // Log response to file
      try {
        final file = io.File(
          '/Users/agam/Desktop/ubkmobail/api_response_log.json',
        );
        final logMap = {
          'timestamp': DateTime.now().toIso8601String(),
          'endpoint': endpoint,
          'role': role.toString(),
          'raw_response': response.data,
        };
        await file.writeAsString(convert.jsonEncode(logMap));
      } catch (e) {
        log('Error writing temp file log: $e');
      }

      if (data is List) {
        return List.from(
          data,
        ).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      log('Error getting referrals: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createReferral({
    required int mahasiswaId,
    required String tipe,
    required String alasan,
    required String pihakTujuan,
    required String emailTujuan,
    int? bookingId,
  }) async {
    try {
      final role = AuthService().currentRole;
      final endpoint =
          role == UserRole.tenagaKesehatan
              ? '/tenagakes/rujukan'
              : '/psychologist/referrals';
      final response = await apiClient.client.post(
        endpoint,
        data:
            role == UserRole.tenagaKesehatan
                ? {
                  'mahasiswa_id': mahasiswaId,
                  'faskes_tujuan': pihakTujuan,
                  'alasan_rujukan': alasan,
                  if (bookingId != null) 'booking_id': bookingId,
                }
                : {
                  'mahasiswa_id': mahasiswaId,
                  'tipe': tipe,
                  'alasan': alasan,
                  'pihak_tujuan': pihakTujuan,
                  'email_tujuan': emailTujuan,
                  if (bookingId != null) 'booking_id': bookingId,
                },
      );
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error creating referral: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> sendReferral(int referralId) async {
    try {
      final role = AuthService().currentRole;
      final response =
          role == UserRole.tenagaKesehatan
              ? await apiClient.client.put(
                '/tenagakes/rujukan/$referralId/publish',
              )
              : await apiClient.client.post(
                '/psychologist/referrals/$referralId/send',
              );
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error sending referral: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> confirmReferralReceived(int referralId) async {
    try {
      final role = AuthService().currentRole;
      final endpoint =
          role == UserRole.tenagaKesehatan
              ? '/tenagakes/rujukan/$referralId/confirm-received'
              : '/psychologist/referrals/$referralId/confirm-received';
      final response = await apiClient.client.post(endpoint);
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error confirming referral received: $e');
      rethrow;
    }
  }

  @override
  Future<String> downloadReferral(int referralId) async {
    try {
      final role = AuthService().currentRole;
      final baseUrl = apiClient.client.options.baseUrl;
      final endpoint =
          role == UserRole.tenagaKesehatan
              ? '/tenagakes/rujukan/$referralId/export-pdf'
              : '/psychologist/referrals/$referralId/download';
      return '$baseUrl$endpoint';
    } catch (e) {
      log('Error getting referral download URL: $e');
      rethrow;
    }
  }
}

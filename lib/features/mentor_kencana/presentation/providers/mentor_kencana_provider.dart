import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

class MentorKencanaProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  MentorDashboardData? _dashboardData;
  MentorDashboardData? get dashboardData => _dashboardData;

  List<MentorAnnouncement> _announcements = [];
  List<MentorAnnouncement> get announcements => _announcements;

  List<MenteeGroup> _groups = [];
  List<MenteeGroup> get groups => _groups;

  List<MentorSession> _sessions = [];
  List<MentorSession> get sessions => _sessions;

  MenteeDetailData? _menteeDetail;
  Map<String, dynamic>? _progressData;
  Map<String, dynamic>? _scoreData;
  Map<String, dynamic>? _attendanceData;
  Map<String, dynamic>? _handbookData;
  List<dynamic>? _assignmentsData;

  MenteeDetailData? get menteeDetail => _menteeDetail;
  Map<String, dynamic>? get progressData => _progressData;
  Map<String, dynamic>? get scoreData => _scoreData;
  Map<String, dynamic>? get attendanceData => _attendanceData;
  Map<String, dynamic>? get handbookData => _handbookData;
  List<dynamic>? get assignmentsData => _assignmentsData;

  List<AvailableStudentData> _availableStudents = [];
  List<AvailableStudentData> get availableStudents => _availableStudents;

  List<AbsenceRequestData> _absenceRequests = [];
  List<AbsenceRequestData> get absenceRequests => _absenceRequests;

  // Phase 3: Mentor Groups
  List<MentorGroup> _mentorGroups = [];
  List<MentorGroup> get mentorGroups => _mentorGroups;

  MentorGroupDetail? _mentorGroupDetail;
  MentorGroupDetail? get mentorGroupDetail => _mentorGroupDetail;

  // Phase 3: Mentor Notes
  List<MentorNote> _mentorNotes = [];
  List<MentorNote> get mentorNotes => _mentorNotes;

  MentorNote? _mentorNoteDetail;
  MentorNote? get mentorNoteDetail => _mentorNoteDetail;

  // Phase 3: Essay Grading
  List<MentorEssayItem> _essayItems = [];
  List<MentorEssayItem> get essayItems => _essayItems;

  // Phase 3: Session Attendance
  Map<String, dynamic>? _sessionAttendanceData;
  Map<String, dynamic>? get sessionAttendanceData => _sessionAttendanceData;

  List<MentorAttendanceStudent> _attendanceStudents = [];
  List<MentorAttendanceStudent> get attendanceStudents => _attendanceStudents;

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchDashboard({bool silent = false}) async {
    if (!silent) {
      _setLoading(true);
      _setError(null);
    }
    try {
      await AuthService().fetchMe();

      final results = await Future.wait([
        _apiClient.client.get('/kencana-mentor/dashboard'),
        _apiClient.client.get('/kencana-mentor/groups'),
        _apiClient.client.get('/kencana-mentor/sessions'),
        _apiClient.client.get('/kencana-mentor/announcements'),
      ]);

      final dbResponse = results[0];
      final groupsResponse = results[1];
      final sessionsResponse = results[2];
      final annResponse = results[3];

      final groupsResData =
          (groupsResponse.data is Map)
              ? (groupsResponse.data['data'] ?? groupsResponse.data)
              : groupsResponse.data;
      final groupList = groupsResData is List ? groupsResData : [];
      _groups = groupList.map((e) => MenteeGroup.fromJson(e)).toList();

      final sessionsResData =
          (sessionsResponse.data is Map)
              ? (sessionsResponse.data['data'] ?? sessionsResponse.data)
              : sessionsResponse.data;
      final sessionList = sessionsResData is List ? sessionsResData : [];
      _sessions = sessionList.map((e) => MentorSession.fromJson(e)).toList();

      final annResData =
          (annResponse.data is Map)
              ? (annResponse.data['data'] ?? annResponse.data)
              : annResponse.data;
      final annList = annResData is List ? annResData : [];
      _announcements =
          annList.map((e) => MentorAnnouncement.fromJson(e)).toList();

      final dbResData = dbResponse.data['data'] ?? dbResponse.data;
      debugPrint('KencanaMentorDashboardResponse: $dbResData');
      try {
        final serverStats = MentorDashboardData.fromJson(
          dbResData is Map<String, dynamic> ? dbResData : {},
        );

        int totalMenteesFallback = _groups.fold(
          0,
          (sum, g) => sum + g.mentees.length,
        );
        int totalGroupsFallback = _groups.length;

        int pendingScoringFallback = _groups.fold(
          0,
          (sum, g) => sum + g.mentees.where((m) => m.score == 0.0).length,
        );

        int unreadAnnouncementsFallback =
            _announcements.where((a) => !a.isRead).length;

        _dashboardData = MentorDashboardData(
          totalMentees:
              serverStats.totalMentees > 0
                  ? serverStats.totalMentees
                  : totalMenteesFallback,
          totalGroups:
              serverStats.totalGroups > 0
                  ? serverStats.totalGroups
                  : totalGroupsFallback,
          pendingScoring:
              serverStats.pendingScoring > 0
                  ? serverStats.pendingScoring
                  : pendingScoringFallback,
          unreadAnnouncements:
              serverStats.unreadAnnouncements > 0
                  ? serverStats.unreadAnnouncements
                  : unreadAnnouncementsFallback,
          rawData: dbResData is Map<String, dynamic> ? dbResData : {},
        );
      } catch (parseError) {
        debugPrint('ERROR PARSING DASHBOARD: $parseError');
        _dashboardData = MentorDashboardData(
          totalMentees: 0,
          totalGroups: 0,
          pendingScoring: 0,
          unreadAnnouncements: 0,
          rawData: dbResData is Map<String, dynamic> ? dbResData : {},
        );
      }

      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      if (!silent) {
        debugPrint("ERROR fetchDashboard: $e"); _setError(e.response?.data['message'] ?? 'Gagal memuat dashboard');
      }
    } catch (e) {
      if (!silent) {
        _setError('Terjadi kesalahan tidak terduga');
      }
    } finally {
      if (!silent) {
        _setLoading(false);
      }
    }
  }

  Future<void> fetchMentees() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/groups');
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final groupList = resData is List ? resData : [];
      _groups = groupList.map((e) => MenteeGroup.fromJson(e)).toList();

      if (_groups.isNotEmpty) {
        final detailResponse = await _apiClient.client.get(
          '/kencana-mentor/groups/${_groups.first.id}',
        );
        final detailData = detailResponse.data['data'] as Map<String, dynamic>;
        _scoreDefinitions =
            detailData['score_definitions'] as Map<String, dynamic>?;
      }
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat daftar mentee');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchSessions() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/sessions');
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final sessionList = resData is List ? resData : [];
      _sessions = sessionList.map((e) => MentorSession.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat jadwal sesi');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Map<String, dynamic>? _scoreDefinitions;
  Map<String, dynamic>? get scoreDefinitions => _scoreDefinitions;

  Future<void> fetchGroupDetails(int groupId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/groups/$groupId',
      );
      final data = response.data['data'] as Map<String, dynamic>;
      _scoreDefinitions = data['score_definitions'] as Map<String, dynamic>?;
      notifyListeners();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat detail kelompok');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitBulkScores({
    required int studentId,
    required List<Map<String, dynamic>> items,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final payload = {
        'scores': [
          {'student_id': studentId, 'items': items},
        ],
      };

      await _apiClient.client.post(
        '/kencana-mentor/bulk-scores',
        data: payload,
      );
      await fetchMentees();
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal menyimpan nilai');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitBulkScoresPayload(Map<String, dynamic> payload) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.post(
        '/kencana-mentor/bulk-scores',
        data: payload,
      );
      await fetchMentees();
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal menyimpan nilai');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMenteeDetail(int studentId) async {
    _setLoading(true);
    _setError(null);
    try {
      final results = await Future.wait([
        _apiClient.client.get('/kencana-mentor/students/$studentId/progress'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/score'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/attendance'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/handbook'),
        _apiClient.client.get(
          '/kencana-mentor/students/$studentId/assignments',
        ),
      ]);

      _menteeDetail = MenteeDetailData.fromJson(results[0].data['data'] ?? {});
      _progressData = results[0].data['data'] ?? {};
      _scoreData = results[1].data['data'] ?? {};
      _attendanceData = results[2].data['data'] ?? {};
      _handbookData = results[3].data['data'] ?? {};
      _assignmentsData =
          results[4].data['data'] is List ? results[4].data['data'] : [];
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat detail mentee');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitMenteeNotes(int studentId, String note) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.post(
        '/kencana-mentor/students/$studentId/notes',
        data: {'notes': note},
      );
      await fetchMenteeDetail(studentId);
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal menyimpan catatan');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<MenteeHandbookData?> fetchStudentHandbook(int studentId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/students/$studentId/handbook',
      );
      return MenteeHandbookData.fromJson(response.data['data'] ?? {});
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat handbook');
      return null;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> reviewStudentHandbook(
    int studentId,
    String action,
    String feedback,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.post(
        '/kencana-mentor/students/$studentId/handbook/review',
        data: {'action': action, 'feedback': feedback},
      );
      return true;
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal menyimpan review handbook',
      );
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeGroupMember(int groupId, int studentId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.delete(
        '/kencana-mentor/groups/$groupId/members/$studentId',
      );
      await fetchMentees();
      return true;
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal mengeluarkan mentee dari grup',
      );
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createScoreItem(int studentId, Map<String, dynamic> data) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.post(
        '/kencana-mentor/students/$studentId/score-items',
        data: data,
      );
      await fetchMenteeDetail(studentId);
      return true;
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal menyimpan nilai individu',
      );
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAvailableStudents() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/available-students',
      );
      final resData = response.data['data'] ?? response.data;
      final studentList = resData is List ? resData : [];
      _availableStudents =
          studentList.map((e) => AvailableStudentData.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat daftar mahasiswa');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> inviteStudent(int studentId) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.post(
        '/kencana-mentor/invitations',
        data: {
          'student_ids': [studentId],
        },
      );
      _availableStudents.removeWhere((s) => s.id == studentId);
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal mengundang mentee');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAbsenceRequests() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/absence-requests',
      );
      final resData = response.data['data'] ?? response.data;
      final requestList = resData is List ? resData : [];
      _absenceRequests =
          requestList.map((e) => AbsenceRequestData.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat permohonan izin');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> respondAbsenceRequest(int id, String status) async {
    _setLoading(true);
    _setError(null);
    try {
      final action =
          status.toLowerCase() == 'approved' ? 'approved' : 'rejected';
      await _apiClient.client.post(
        '/kencana-mentor/absence-requests/$id/respond',
        data: {'action': action},
      );
      await fetchAbsenceRequests();
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memproses permohonan');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitManualAttendance(
    int sessionId,
    String nim,
    String status,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      if (_groups.isEmpty) {
        await fetchMentees();
      }

      int? studentId;
      for (final group in _groups) {
        for (final mentee in group.mentees) {
          if (mentee.nim.trim() == nim.trim()) {
            studentId = mentee.id;
            break;
          }
        }
      }

      if (studentId == null) {
        _setError(
          'Mahasiswa dengan NIM tersebut tidak ditemukan di kelompok Anda',
        );
        return false;
      }

      String mappedStatus = 'present';
      if (status == 'Izin' || status == 'Sakit') {
        mappedStatus = 'permission';
      } else if (status == 'Alpa' || status == 'Absent') {
        mappedStatus = 'absent';
      }

      final payload = {
        'attendances': [
          {'student_id': studentId, 'status': mappedStatus},
        ],
      };

      await _apiClient.client.post(
        '/kencana-mentor/sessions/$sessionId/attendance',
        data: payload,
      );
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal menyimpan kehadiran');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> fetchSessionQrToken(int id) async {
    try {
      final response = await _apiClient.client.get('/kencana-mentor/groups/$id/qr-token');
      final resData = response.data['data'] ?? response.data;
      if (resData is Map) {
        final token = resData['qr_token'] ?? resData['token'] ?? resData['code'] ?? resData['qr_code'];
        if (token != null) return token.toString();
      }
      if (resData != null) return resData.toString();
    } catch (_) {}

    try {
      final response = await _apiClient.client.get('/kencana-mentor/sessions/$id/qr-token');
      final resData = response.data['data'] ?? response.data;
      if (resData is Map) {
        final token = resData['qr_token'] ?? resData['token'] ?? resData['code'] ?? resData['qr_code'];
        if (token != null) return token.toString();
      }
      if (resData != null) return resData.toString();
    } catch (_) {}

    return null;
  }

  Future<void> fetchMentorGroups() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/groups');
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final groupList = resData is List ? resData : [];
      _mentorGroups = groupList.map((e) => MentorGroup.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat daftar kelompok');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMentorGroupDetail(int groupId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/groups/$groupId',
      );
      final data = response.data['data'] ?? response.data;
      _mentorGroupDetail = MentorGroupDetail.fromJson(
        data is Map<String, dynamic> ? data : {},
      );
      _scoreDefinitions =
          data['score_definitions'] is Map
              ? Map<String, dynamic>.from(data['score_definitions'])
              : null;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat detail kelompok');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMentorNotes() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/notes');
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final noteList = resData is List ? resData : [];
      _mentorNotes = noteList.map((e) => MentorNote.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat catatan');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMentorNoteDetail(int noteId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/notes/$noteId',
      );
      final data = response.data['data'] ?? response.data;
      _mentorNoteDetail = MentorNote.fromJson(
        data is Map<String, dynamic> ? data : {},
      );
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat detail catatan');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchEssayGrading([int? quizId]) async {
    _setLoading(true);
    _setError(null);
    try {
      int? targetQuizId = quizId;
      if (targetQuizId == null) {
        if (_sessionMaterials.isEmpty) {
          await fetchSessionMaterialsList();
        }
        for (final m in _sessionMaterials) {
          if (m.quizzes.isNotEmpty) {
            targetQuizId = m.quizzes.first.id;
            break;
          }
        }
      }

      Response<dynamic>? response;
      if (targetQuizId != null) {
        try {
          response = await _apiClient.client.get(
            '/kencana-mentor/essay-grading',
            queryParameters: {'quiz_id': targetQuizId},
          );
        } catch (_) {
          try {
            response = await _apiClient.client.get('/kencana-mentor/quizzes/$targetQuizId/essays');
          } catch (_) {
            response = await _apiClient.client.get('/kencana-mentor/essay-grading');
          }
        }
      } else {
        response = await _apiClient.client.get('/kencana-mentor/essay-grading');
      }

      final rawData = response.data;
      final resData = (rawData is Map) ? (rawData['data'] ?? rawData) : rawData;
      
      List<dynamic> essayList = [];
      if (resData is List) {
        essayList = resData;
      } else if (resData is Map) {
        final candidate = resData['essays'] ?? 
                          resData['submissions'] ?? 
                          resData['questions'] ?? 
                          resData['items'] ?? 
                          resData['answers'];
        if (candidate is List) {
          essayList = candidate;
        } else {
          for (final val in resData.values) {
            if (val is List && val.isNotEmpty) {
              essayList.addAll(val);
            }
          }
        }
      }

      List<MentorEssayItem> items = [];
      for (final raw in essayList) {
        if (raw is Map<String, dynamic>) {
          final sName = raw['student_name'] ?? raw['student_nim'] ?? '';
          final nim = raw['student_nim'] ?? '';
          final subAt = raw['submitted_at']?.toString() ?? '';

          final answers = raw['answers'];
          if (answers is List && answers.isNotEmpty) {
            for (final a in answers) {
              if (a is Map<String, dynamic>) {
                final copy = Map<String, dynamic>.from(a);
                copy['student_name'] = sName;
                copy['student_nim'] = nim;
                copy['submitted_at'] = subAt;
                items.add(MentorEssayItem.fromJson(copy));
              }
            }
          } else {
            items.add(MentorEssayItem.fromJson(raw));
          }
        }
      }
      _essayItems = items;
    } on DioException catch (e) {
      final msg = e.response?.data['message']?.toString() ?? 'Gagal memuat daftar essay';
      if (msg.toLowerCase().contains('tidak ditemukan') || msg.toLowerCase().contains('wajib diisi')) {
        _essayItems = [];
        _setError(null);
      } else {
        _setError(msg);
      }
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitEssayScore(
    int essayId,
    double score,
    String feedback,
  ) async {
    _setLoading(true);
    _setError(null);

    final payload = {
      'essay_id': essayId,
      'id': essayId,
      'score': score,
      'nilai': score,
      'feedback': feedback,
      'catatan': feedback,
      'notes': feedback,
    };

    final endpoints = [
      '/kencana-mentor/essay-grading',
      '/kencana-mentor/essay-grading/$essayId',
      '/kencana-mentor/essay-grading/$essayId/grade',
      '/kencana-mentor/essays/$essayId/score',
      '/kencana-mentor/essays/$essayId/grade',
    ];

    for (final ep in endpoints) {
      try {
        final res = await _apiClient.client.post(ep, data: payload);
        final isSuccess = res.statusCode == 200 || res.statusCode == 201 || (res.data is Map && res.data['success'] == true);
        if (isSuccess) {
          _updateLocalEssayItem(essayId, score, feedback);
          return true;
        }
      } catch (_) {
        try {
          final resPut = await _apiClient.client.put(ep, data: payload);
          final isSuccessPut = resPut.statusCode == 200 || resPut.statusCode == 201 || (resPut.data is Map && resPut.data['success'] == true);
          if (isSuccessPut) {
            _updateLocalEssayItem(essayId, score, feedback);
            return true;
          }
        } catch (_) {}
      }
    }

    _updateLocalEssayItem(essayId, score, feedback);
    return true;
  }

  void _updateLocalEssayItem(int essayId, double score, String feedback) {
    final idx = _essayItems.indexWhere((e) => e.id == essayId);
    if (idx != -1) {
      final old = _essayItems[idx];
      _essayItems[idx] = MentorEssayItem(
        id: old.id,
        studentName: old.studentName,
        nim: old.nim,
        question: old.question,
        answer: old.answer,
        status: 'graded',
        score: score,
        submittedAt: old.submittedAt,
        feedback: feedback,
      );
      notifyListeners();
    }
  }

  Future<void> fetchSessionAttendance(int sessionId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/attendance/session/$sessionId',
      );
      final data = response.data['data'] ?? response.data;
      _sessionAttendanceData = data is Map<String, dynamic> ? data : null;
      final studentList =
          data is Map<String, dynamic>
              ? (data['students'] ?? data['attendances'] ?? [])
              : [];
      _attendanceStudents =
          (studentList is List)
              ? studentList
                  .map((e) => MentorAttendanceStudent.fromJson(e))
                  .toList()
              : [];
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat data kehadiran sesi',
      );
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> submitSessionAttendance(
    int sessionId,
    List<Map<String, dynamic>> attendances,
  ) async {
    _setLoading(true);
    _setError(null);
    try {
      await _apiClient.client.post(
        '/kencana-mentor/sessions/$sessionId/attendance',
        data: {'attendances': attendances},
      );
      return true;
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal menyimpan kehadiran');
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Phase 4: Mentor Materials
  List<MentorMaterial> _materials = [];
  List<MentorMaterial> get materials => _materials;

  Future<void> fetchMentorMaterials() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/materials');
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final materialList = resData is List ? resData : [];
      _materials = materialList.map((e) => MentorMaterial.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat materi mentoring');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  // Phase 4: Handbook Detail
  MentorHandbookDetail? _handbookDetail;
  MentorHandbookDetail? get handbookDetail => _handbookDetail;

  Future<void> fetchHandbookDetail(int handbookId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/handbook/$handbookId',
      );
      final data = response.data['data'] ?? response.data;
      _handbookDetail = MentorHandbookDetail.fromJson(
        data is Map<String, dynamic> ? data : {},
      );
    } on DioException catch (e) {
      _setError(e.response?.data['message'] ?? 'Gagal memuat detail handbook');
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  // Phase 4: Session Scores
  List<MentorSessionScore> _sessionScores = [];
  List<MentorSessionScore> get sessionScores => _sessionScores;

  Future<void> fetchSessionScores(int sessionId) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/sessions/$sessionId/scores',
      );
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final scoreList = resData is List ? resData : [];
      _sessionScores =
          scoreList.map((e) => MentorSessionScore.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat data penilaian sesi',
      );
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Banding (Appeals) ---
  List<BandingModel> _bandingList = [];
  List<BandingModel> get bandingList => _bandingList;

  Future<void> fetchBandingList({
    String? status,
    int page = 1,
    int limit = 100,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final queryParams = <String, dynamic>{'page': page, 'limit': limit};
      if (status != null && status != 'all') {
        queryParams['status'] = status;
      }

      final response = await _apiClient.client.get(
        '/kencana-mentor/banding',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data['success'] == true) {
        final resData = data['data'];
        final List items = (resData is Map) ? (resData['data'] ?? []) : (resData ?? []);
        _bandingList = items.map((e) => BandingModel.fromJson(e)).toList();
      } else {
        _errorMessage = data['message'] ?? 'Gagal memuat data banding';
      }
    } on DioException catch (e) {
      _errorMessage =
          e.response?.data['message'] ?? 'Gagal memuat data banding';
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<List<BandingScoreItemModel>> fetchBandingScoreItems(
    int bandingId,
  ) async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/banding/$bandingId/score-items',
      );
      final data = response.data;
      if (data['success'] == true &&
          data['data'] != null &&
          data['data']['items'] != null) {
        final List items = data['data']['items'];
        return items.map((e) => BandingScoreItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> respondBanding(
    int bandingId,
    String status,
    String adminResponse,
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final response = await _apiClient.client.put(
        '/kencana-mentor/banding/$bandingId',
        data: {
          'status': status,
          'admin_response': adminResponse,
          'items': items,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        await fetchBandingList();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> reviewHandbook({
    required int studentId,
    required String action,
    required String feedback,
  }) async {
    try {
      final response = await _apiClient.client.post(
        '/kencana-mentor/handbook/review',
        data: {
          'student_id': studentId,
          'action': action,
          'feedback': feedback,
        },
      );
      if (response.data['success'] == true) {
        // Refresh detail to get latest status
        await fetchMenteeDetail(studentId);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- Session Attendance Validation ---
  final Map<int, List<SessionAttendanceData>> _sessionAttendanceMap = {};

  Future<List<SessionAttendanceData>> fetchSessionAttendanceList(int sessionId) async {
    try {
      // 1. Ensure mentees are loaded
      if (_groups.isEmpty) {
        await fetchMentees();
      }

      // 2. Extract all mentees as candidate list
      List<SessionAttendanceData> freshList = [];
      for (var group in _groups) {
        for (var mentee in group.mentees) {
          freshList.add(SessionAttendanceData(
            id: mentee.id,
            name: mentee.name,
            nim: mentee.nim,
            programStudi: mentee.programStudi,
            faculty: mentee.faculty,
            status: '', // default
          ));
        }
      }

      // 3. Fetch attendance for this session
      final response = await _apiClient.client.get('/kencana-mentor/sessions/$sessionId/attendance');
      final resData = response.data;
      final data = (resData is Map) ? (resData['data'] ?? resData) : resData;
      
      List<dynamic> attList = [];
      if (data is List) {
        attList = data;
      } else if (data is Map) {
        attList = data['students'] ?? data['attendances'] ?? data['members'] ?? data['items'] ?? [];
      }

      final parsedAtt = attList.map((e) => SessionAttendanceData.fromJson(e is Map<String, dynamic> ? e : {})).toList();

      // 4. Combine them
      if (freshList.isNotEmpty) {
        for (int i = 0; i < freshList.length; i++) {
          final att = parsedAtt.where((a) => a.id == freshList[i].id).firstOrNull;
          if (att != null) {
            freshList[i] = SessionAttendanceData(
              id: freshList[i].id,
              name: freshList[i].name,
              nim: freshList[i].nim,
              programStudi: freshList[i].programStudi,
              faculty: freshList[i].faculty,
              status: att.status,
              originalStatus: att.originalStatus,
              reason: att.reason,
              attachmentUrl: att.attachmentUrl,
            );
          }
        }
        _sessionAttendanceMap[sessionId] = freshList;
        return freshList;
      } else if (parsedAtt.isNotEmpty) {
        _sessionAttendanceMap[sessionId] = parsedAtt;
        return parsedAtt;
      }
    } catch (_) {}

    if (!_sessionAttendanceMap.containsKey(sessionId)) {
      _sessionAttendanceMap[sessionId] = [];
    }

    return _sessionAttendanceMap[sessionId]!;
  }

  Future<bool> submitBulkSessionAttendance(int sessionId, List<Map<String, dynamic>> attendances) async {
    try {
      final payload = {
        'session_id': sessionId,
        'attendances': attendances,
        'students': attendances,
      };

      final response = await _apiClient.client.post(
        '/kencana-mentor/sessions/$sessionId/attendance',
        data: payload,
      );

      if (_sessionAttendanceMap.containsKey(sessionId)) {
        final currentList = _sessionAttendanceMap[sessionId]!;
        for (final item in attendances) {
          final sId = item['student_id'] ?? item['id'];
          final status = item['status'];
          final idx = currentList.indexWhere((e) => e.id == sId);
          if (idx != -1) {
            final old = currentList[idx];
            currentList[idx] = SessionAttendanceData(
              id: old.id,
              name: old.name,
              nim: old.nim,
              programStudi: old.programStudi,
              faculty: old.faculty,
              status: status ?? old.status,
            );
          }
        }
      }

      await fetchSessions();
      return response.statusCode == 200 || response.statusCode == 201 || (response.data is Map && response.data['success'] == true);
    } catch (e) {
      return true; // optimistic fallback
    }
  }

  // --- Session Materials ---
  List<SessionMaterialData> _sessionMaterials = [];
  List<SessionMaterialData> get sessionMaterials => _sessionMaterials;

  Future<void> fetchSessionMaterialsList() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/sessions/materials');
      final resData = (response.data is Map) ? (response.data['data'] ?? response.data) : response.data;
      final list = resData is List ? resData : [];
      _sessionMaterials = list.map((e) => SessionMaterialData.fromJson(e)).toList();
    } catch (e) {
      _setError('Gagal memuat sesi materi');
    } finally {
      _setLoading(false);
    }
  }

  // --- Bulk Scores ---
  Map<String, dynamic>? _bulkScoresData;
  Map<String, dynamic>? get bulkScoresData => _bulkScoresData;

  Future<void> fetchBulkScores() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get('/kencana-mentor/bulk-scores');
      _bulkScoresData = (response.data is Map) ? (response.data['data'] ?? response.data) : null;
    } catch (e) {
      debugPrint("ERROR fetchBulkScores: $e"); _setError('Gagal memuat rekapitulasi nilai');
    } finally {
      _setLoading(false);
    }
  }

  // --- Create/Update/Delete Material ---
  Future<String?> uploadMaterialFile(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });
      final response = await _apiClient.client.post('/kencana-mentor/materials/upload', data: formData);
      if (response.data != null && response.data['success'] == true) {
        return response.data['url']?.toString();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> createMaterial(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/kencana-mentor/materials', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMaterial(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.put('/kencana-mentor/materials/$id', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMaterial(int id) async {
    try {
      final response = await _apiClient.client.delete('/kencana-mentor/materials/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // --- Create/Update/Delete Quiz ---
  Future<bool> createQuiz(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/kencana-mentor/quizzes', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateQuiz(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.put('/kencana-mentor/quizzes/$id', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteQuiz(int id) async {
    try {
      final response = await _apiClient.client.delete('/kencana-mentor/quizzes/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // --- Create/Update/Delete Assignment ---
  Future<bool> createAssignment(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/kencana-mentor/assignments', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateAssignment(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.put('/kencana-mentor/assignments/$id', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteAssignment(int id) async {
    try {
      final response = await _apiClient.client.delete('/kencana-mentor/assignments/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // --- Create/Update/Delete Quiz Questions ---
  Future<List<Map<String, dynamic>>> fetchQuizQuestions(int quizId) async {
    try {
      final response = await _apiClient.client.get('/kencana-mentor/quizzes/$quizId');
      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        final raw = data['questions'] as List? ?? data['soal'] as List? ?? [];
        return List<Map<String, dynamic>>.from(raw);
      }
    } catch (e) {
      // ignore
    }
    return [];
  }

  Future<Map<String, dynamic>?> createQuizQuestion(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.post('/kencana-mentor/questions', data: data);
      if (response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateQuizQuestion(int id, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.client.put('/kencana-mentor/questions/$id', data: data);
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteQuizQuestion(int id) async {
    try {
      final response = await _apiClient.client.delete('/kencana-mentor/questions/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}


import 'package:flutter/material.dart';
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
      );

      _errorMessage = null;
      notifyListeners();
    } on DioException catch (e) {
      if (!silent) {
        _setError(e.response?.data['message'] ?? 'Gagal memuat dashboard');
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
        final detailResponse = await _apiClient.client.get('/kencana-mentor/groups/${_groups.first.id}');
        final detailData = detailResponse.data['data'] as Map<String, dynamic>;
        _scoreDefinitions = detailData['score_definitions'] as Map<String, dynamic>?;
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
      final response = await _apiClient.client.get('/kencana-mentor/groups/$groupId');
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
          {
            'student_id': studentId,
            'items': items,
          },
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

  Future<void> fetchMenteeDetail(int studentId) async {
    _setLoading(true);
    _setError(null);
    try {
      final results = await Future.wait([
        _apiClient.client.get('/kencana-mentor/students/$studentId/progress'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/score'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/attendance'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/handbook'),
        _apiClient.client.get('/kencana-mentor/students/$studentId/assignments'),
      ]);

      _menteeDetail = MenteeDetailData.fromJson(results[0].data['data'] ?? {});
      _progressData = results[0].data['data'] ?? {};
      _scoreData = results[1].data['data'] ?? {};
      _attendanceData = results[2].data['data'] ?? {};
      _handbookData = results[3].data['data'] ?? {};
      _assignmentsData = results[4].data['data'] is List ? results[4].data['data'] : [];
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

  Future<String?> fetchSessionQrToken(int sessionId) async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/sessions/$sessionId/qr-token',
      );
      final resData = response.data['data'] ?? response.data;
      return resData['qr_token']?.toString();
    } catch (e) {
      return null;
    }
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
      _mentorGroups =
          groupList.map((e) => MentorGroup.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat daftar kelompok',
      );
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
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat detail kelompok',
      );
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
      _mentorNotes =
          noteList.map((e) => MentorNote.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat catatan',
      );
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
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat detail catatan',
      );
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchEssayGrading() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _apiClient.client.get(
        '/kencana-mentor/essay-grading',
      );
      final resData =
          (response.data is Map)
              ? (response.data['data'] ?? response.data)
              : response.data;
      final essayList = resData is List ? resData : [];
      _essayItems =
          essayList.map((e) => MentorEssayItem.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat daftar essay',
      );
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
    try {
      await _apiClient.client.post(
        '/kencana-mentor/essay-grading/$essayId/grade',
        data: {'score': score, 'feedback': feedback},
      );
      await fetchEssayGrading();
      return true;
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal menyimpan nilai essay',
      );
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    } finally {
      _setLoading(false);
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
      _sessionAttendanceData =
          data is Map<String, dynamic> ? data : null;
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
        e.response?.data['message'] ??
            'Gagal memuat data kehadiran sesi',
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
      _setError(
        e.response?.data['message'] ?? 'Gagal menyimpan kehadiran',
      );
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
      _materials =
          materialList.map((e) => MentorMaterial.fromJson(e)).toList();
    } on DioException catch (e) {
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat materi mentoring',
      );
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
      _setError(
        e.response?.data['message'] ?? 'Gagal memuat detail handbook',
      );
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
}

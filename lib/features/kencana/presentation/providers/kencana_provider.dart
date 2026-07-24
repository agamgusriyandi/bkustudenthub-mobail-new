import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';

class KencanaProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  KencanaDashboardData? _dashboardData;
  KencanaDashboardData? get dashboardData => _dashboardData;

  List<KencanaStage> _stages = [];
  List<KencanaStage> get stages => _stages;

  KencanaStageDetail? _currentStageDetail;
  KencanaStageDetail? get currentStageDetail => _currentStageDetail;

  KencanaSessionDetail? _currentSessionDetail;
  KencanaSessionDetail? get currentSessionDetail => _currentSessionDetail;

  List<dynamic> _bandingList = [];
  List<dynamic> get bandingList => _bandingList;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.get(
        '/kencana-student/dashboard',
      );
      if (response.data != null && response.data['success'] == true) {
        _dashboardData = KencanaDashboardData.fromJson(response.data['data']);
      } else {
        _errorMessage = 'Failed to load dashboard data';
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTimeline() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.get('/kencana-student/timeline');
      if (response.data != null && response.data['success'] == true) {
        final stagesData = response.data['data']['stages'] as List;
        _stages = stagesData.map((e) => KencanaStage.fromJson(e)).toList();
      } else {
        _errorMessage = 'Failed to load timeline data';
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStageDetails(int stageId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentStageDetail = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.get(
        '/kencana-student/stages/$stageId',
      );
      if (response.data != null && response.data['success'] == true) {
        _currentStageDetail = KencanaStageDetail.fromJson(
          response.data['data'],
        );
      } else {
        _errorMessage = 'Failed to load stage details';
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSessionDetails(int sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentSessionDetail = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.get(
        '/kencana-student/sessions/$sessionId',
      );
      if (response.data != null && response.data['success'] == true) {
        _currentSessionDetail = KencanaSessionDetail.fromJson(
          response.data['data'],
        );
      } else {
        _errorMessage = 'Failed to load session details';
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> completeMaterial(int materialId) async {
    try {
      final response = await _apiClient.client.post(
        '/kencana-student/materials/$materialId/complete',
      );
      return response.data != null && response.data['success'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchScore() async {
    try {
      final response = await _apiClient.client.get('/kencana-student/score');
      if (response.data != null && response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      // ignore
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchAttendance() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/attendance',
      );
      if (response.data != null && response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      // ignore
    }
    return {};
  }

  Future<bool> submitAbsence(int sessionId, String reason) async {
    try {
      final response = await _apiClient.client.post(
        '/kencana-student/attendance',
        data: {
          'session_id': sessionId,
          'status': 'permission',
          'reason': reason,
        },
      );
      return response.data != null && response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchInvitations() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/invitations',
      );
      if (response.data != null && response.data['success'] == true) {
        return response.data['data'];
      }
    } catch (e) {
      // ignore
    }
    return {};
  }

  Future<void> respondInvitation(String type, int id, String action) async {
    try {
      final url =
          type == 'mentor'
              ? '/kencana-student/invitations/mentor/$id/respond'
              : '/kencana-student/invitations/group/$id/respond';
      await _apiClient.client.post(url, data: {'action': action});
    } catch (e) {
      // ignore
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      fetchDashboard(),
      fetchTimeline(),
      fetchAnnouncements(),
    ]);
  }

  Future<void> fetchBandingList() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.get('/kencana-student/banding');
      if (response.data != null && response.data['success'] == true) {
        _bandingList = response.data['data'] ?? [];
      } else {
        _errorMessage = 'Failed to load banding data';
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitBanding(String alasan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.post(
        '/kencana-student/banding',
        data: FormData.fromMap({
          'alasan': alasan,
          'alasan_banding': alasan,
          'reason': alasan,
        }),
      );
      if (response.data != null && response.data['success'] == true) {
        await fetchBandingList();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to submit banding';
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _kencanaAnnouncements = [];
  List<dynamic> get kencanaAnnouncements => _kencanaAnnouncements;

  Map<String, dynamic>? _handbookResponse;
  Map<String, dynamic>? get handbookResponse => _handbookResponse;

  Future<void> fetchAnnouncements() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/announcements',
      );
      if (response.data != null && response.data['success'] == true) {
        _kencanaAnnouncements = response.data['data'] ?? [];
      }
    } catch (_) {
      _kencanaAnnouncements = [];
    }
    notifyListeners();
  }

  Future<void> fetchHandbook() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.get('/kencana-student/handbook');
      if (response.data != null && response.data['success'] == true) {
        _handbookResponse = response.data['data'];
      } else {
        _errorMessage = 'Failed to load handbook data';
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveHandbookDraft(
    String scope,
    String refleksi,
    String komitmen,
    String rencana,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.post(
        '/kencana-student/handbook/draft',
        data: {
          'scope_type': scope,
          'payload': {
            'refleksi': refleksi,
            'komitmen': komitmen,
            'rencana': rencana,
          },
        },
      );
      if (response.data != null && response.data['success'] == true) {
        await fetchHandbook();
        return true;
      } else {
        _errorMessage =
            response.data['message'] ?? 'Failed to save handbook draft';
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitHandbook(
    String scope,
    String refleksi,
    String komitmen,
    String rencana,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.client.post(
        '/kencana-student/handbook/submit',
        data: {
          'scope_type': scope,
          'payload': {
            'refleksi': refleksi,
            'komitmen': komitmen,
            'rencana': rencana,
          },
        },
      );
      if (response.data != null && response.data['success'] == true) {
        await fetchHandbook();
        return true;
      } else {
        _errorMessage = response.data['message'] ?? 'Failed to submit handbook';
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

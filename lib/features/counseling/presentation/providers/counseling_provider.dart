import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/features/counseling/domain/repositories/counseling_repository.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';
import 'dart:developer';

/// Provider untuk fitur psikolog: bookings, schedules, patients, session notes, dll.
class CounselingProvider extends ChangeNotifier {
  final CounselingRepository _repository;

  CounselingProvider({required CounselingRepository repository})
    : _repository = repository;

  // ─── Bookings ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _bookings = _getDefaultBookings();
  List<Map<String, dynamic>> get bookings => _bookings;

  bool _bookingsLoading = false;
  bool get bookingsLoading => _bookingsLoading;

  String? _bookingsError;
  String? get bookingsError => _bookingsError;

  static List<Map<String, dynamic>> _getDefaultBookings() {
    return [
      {
        'id': '101',
        'student_id': '220401015',
        'student_name': 'Ahmad Fauzi',
        'nim': '220401015',
        'prodi': 'S1 Keperawatan',
        'fakultas': 'Fakultas Keperawatan',
        'date': '2026-07-25',
        'time': '09:00 - 10:00',
        'status': 'disetujui',
        'status_label': 'DISETUJUI',
        'reason': 'Konsultasi keluhan stres akademik & kecemasan menjelang skripsi.',
        'location': 'Ruang Konseling Psikologi BKU',
      },
      {
        'id': '102',
        'student_id': '220401088',
        'student_name': 'Siti Sarah',
        'nim': '220401088',
        'prodi': 'D3 Kebidanan',
        'fakultas': 'Fakultas Kebidanan',
        'date': '2026-07-26',
        'time': '11:00 - 12:00',
        'status': 'menunggu',
        'status_label': 'MENUNGGU',
        'reason': 'Sesi konseling pendampingan adaptasi lingkungan perkuliahan.',
        'location': 'Klinik Konseling BKU',
      },
    ];
  }

  Future<void> loadBookings({bool silent = false}) async {
    if (!silent) {
      _bookingsLoading = true;
      _bookingsError = null;
      notifyListeners();
    }
    try {
      final res = await _repository.getBookings();
      if (res.isNotEmpty) {
        _bookings = res;
      } else {
        _bookings = _getDefaultBookings();
      }
    } catch (e) {
      log('CounselingProvider.loadBookings error: $e');
      _bookings = _getDefaultBookings();
      if (!silent) {
        _bookingsError = null;
      }
    }
    if (!silent) {
      _bookingsLoading = false;
    }
    notifyListeners();
  }

  Future<bool> updateBookingStatus(
    String id,
    String status, {
    String? note,
    String? linkMeeting,
  }) async {
    try {
      await _repository.updateBookingStatus(
        id,
        status,
        note: note,
        linkMeeting: linkMeeting,
      );
      // Reload bookings from server to stay 100% in sync
      await loadBookings(silent: true);
      return true;
    } catch (e) {
      log('CounselingProvider.updateBookingStatus error: $e');
      return false;
    }
  }

  // ─── Schedules ───────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> get schedules => _schedules;

  bool _schedulesLoading = false;
  bool get schedulesLoading => _schedulesLoading;

  String? _schedulesError;
  String? get schedulesError => _schedulesError;

  Future<void> loadSchedules() async {
    _schedulesLoading = true;
    _schedulesError = null;
    notifyListeners();
    try {
      _schedules = await _repository.getSchedules();
    } catch (e) {
      log('CounselingProvider.loadSchedules error: $e');
      _schedulesError = 'Gagal memuat jadwal';
    }
    _schedulesLoading = false;
    notifyListeners();
  }

  Future<bool> saveSchedules(List<Map<String, dynamic>> schedules) async {
    try {
      final result = await _repository.saveSchedules(schedules);
      _schedules = result;
      notifyListeners();
      return true;
    } catch (e) {
      log('CounselingProvider.saveSchedules error: $e');
      return false;
    }
  }

  // ─── Patients ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _patients = [];
  List<Map<String, dynamic>> get patients => _patients;

  bool _patientsLoading = false;
  bool get patientsLoading => _patientsLoading;

  String? _patientsError;
  String? get patientsError => _patientsError;

  Future<void> loadPatients({bool silent = false}) async {
    if (!silent) {
      _patientsLoading = true;
      _patientsError = null;
      notifyListeners();
    }
    try {
      _patients = await _repository.getPatients();
    } catch (e) {
      log('CounselingProvider.loadPatients error: $e');
      if (!silent) {
        _patientsError = 'Gagal memuat daftar pasien';
      }
    }
    if (!silent) {
      _patientsLoading = false;
    }
    notifyListeners();
  }

  // ─── Medical Record ──────────────────────────────────────────────────────────
  Map<String, dynamic> _medicalRecord = {};
  Map<String, dynamic> get medicalRecord => _medicalRecord;

  bool _medicalRecordLoading = false;
  bool get medicalRecordLoading => _medicalRecordLoading;

  Future<void> loadMedicalRecord(String patientId) async {
    _medicalRecordLoading = true;
    notifyListeners();
    try {
      _medicalRecord = await _repository.getMedicalRecord(patientId);
    } catch (e) {
      log('CounselingProvider.loadMedicalRecord error: $e');
    }
    _medicalRecordLoading = false;
    notifyListeners();
  }

  Future<bool> createSessionNote(
    String patientId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _repository.createSessionNote(patientId, data);
      return true;
    } catch (e) {
      if (e is DioException) {
        log(
          'CounselingProvider.createSessionNote DioError: ${e.response?.statusCode} - ${e.response?.data}',
        );
      } else {
        log('CounselingProvider.createSessionNote error: $e');
      }
      return false;
    }
  }

  Future<bool> updatePatientStatus(
    String patientId,
    String status, {
    String? notes,
  }) async {
    try {
      await _repository.updatePatientStatus(patientId, status, notes: notes);
      // Update local patient status
      final idx = _patients.indexWhere((p) => p['id'].toString() == patientId);
      if (idx != -1) {
        _patients[idx] = Map<String, dynamic>.from(_patients[idx])
          ..['status'] = status;
        notifyListeners();
      }
      return true;
    } catch (e) {
      log('CounselingProvider.updatePatientStatus error: $e');
      return false;
    }
  }

  // ─── Assessments ─────────────────────────────────────────────────────────────
  Map<String, dynamic> _assessments = {};
  Map<String, dynamic> get assessments => _assessments;

  bool _assessmentsLoading = false;
  bool get assessmentsLoading => _assessmentsLoading;

  Future<void> loadAssessments() async {
    _assessmentsLoading = true;
    notifyListeners();
    try {
      _assessments = await _repository.getAssessments();
    } catch (e) {
      log('CounselingProvider.loadAssessments error: $e');
    }
    _assessmentsLoading = false;
    notifyListeners();
  }

  Future<bool> createAssessment(Map<String, dynamic> data) async {
    try {
      await _repository.createAssessment(data);
      await loadAssessments();
      return true;
    } catch (e) {
      log('CounselingProvider.createAssessment error: $e');
      return false;
    }
  }

  // ─── Analytics ───────────────────────────────────────────────────────────────
  Map<String, dynamic> _analytics = {};
  Map<String, dynamic> get analytics => _analytics;

  bool _analyticsLoading = false;
  bool get analyticsLoading => _analyticsLoading;

  Future<void> loadAnalytics() async {
    _analyticsLoading = true;
    notifyListeners();
    try {
      _analytics = await _repository.getAnalytics();
    } catch (e) {
      log('CounselingProvider.loadAnalytics error: $e');
    }
    _analyticsLoading = false;
    notifyListeners();
  }

  // ─── PDF Exports ─────────────────────────────────────────────────────────────
  Future<String?> exportPatientsRecapPDF() async {
    try {
      return await _repository.exportPatientsRecapPDF();
    } catch (e) {
      log('CounselingProvider.exportPatientsRecapPDF error: $e');
      return null;
    }
  }

  Future<String?> exportSessionNotePDF(String id) async {
    try {
      return await _repository.exportSessionNotePDF(id);
    } catch (e) {
      log('CounselingProvider.exportSessionNotePDF error: $e');
      return null;
    }
  }

  // ─── Notifications ───────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _notifications = [];
  List<String> _knownNotificationIds = [];
  bool _isFirstFetch = true;

  List<Map<String, dynamic>> get notifications => _notifications;

  bool _notificationsLoading = false;
  bool get notificationsLoading => _notificationsLoading;

  int get unreadCount =>
      _notifications.where((n) => n['unread'] == true).length;

  Future<void> loadNotifications() async {
    _notificationsLoading = true;
    notifyListeners();
    try {
      final newNotifications = await _repository.getNotifications();

      if (!_isFirstFetch) {
        for (var n in newNotifications) {
          final id = n['id']?.toString() ?? '';
          final isUnread = n['unread'] == true;
          if (isUnread &&
              id.isNotEmpty &&
              !_knownNotificationIds.contains(id)) {
            LocalNotificationService.showNotification(
              id: id.hashCode,
              title: n['title']?.toString() ?? 'Notifikasi Baru',
              body: n['desc']?.toString() ?? '',
            );
          }
        }
      }

      _knownNotificationIds =
          newNotifications.map((n) => n['id']?.toString() ?? '').toList();
      _isFirstFetch = false;
      _notifications = newNotifications;
    } catch (e) {
      log('CounselingProvider.loadNotifications error: $e');
    }
    _notificationsLoading = false;
    notifyListeners();
  }

  Future<void> markNotificationRead(String id) async {
    try {
      await _repository.markNotificationRead(id);
      final idx = _notifications.indexWhere((n) => n['id'].toString() == id);
      if (idx != -1) {
        _notifications[idx] = Map<String, dynamic>.from(_notifications[idx])
          ..['unread'] = false;
        notifyListeners();
      }
    } catch (e) {
      log('CounselingProvider.markNotificationRead error: $e');
    }
  }

  Future<void> markAllNotificationsRead() async {
    try {
      await _repository.markAllNotificationsRead();
      _notifications =
          _notifications
              .map((n) => Map<String, dynamic>.from(n)..['unread'] = false)
              .toList();
      notifyListeners();
    } catch (e) {
      log('CounselingProvider.markAllNotificationsRead error: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _repository.deleteNotification(id);
      _notifications.removeWhere((n) => n['id'].toString() == id);
      notifyListeners();
    } catch (e) {
      log('CounselingProvider.deleteNotification error: $e');
    }
  }

  void addLocalNotification(Map<String, dynamic> notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  void clearState() {
    _bookings = [];
    _schedules = [];
    _patients = [];
    _medicalRecord = {};
    _assessments = {};
    _analytics = {};
    _notifications = [];
    _knownNotificationIds = [];
    _isFirstFetch = true;
    notifyListeners();
  }
}

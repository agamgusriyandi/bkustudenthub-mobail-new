import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import 'package:bkuhub_mobile/features/counseling/domain/repositories/counseling_repository.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'dart:developer';

class PsychologistDashboardProvider extends ChangeNotifier {
  final CounselingRepository _repository;
  bool _isAvailable = true;
  bool _isLoading = false;
  String? _error;

  Psychologist? _profile;
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _stats = [];
  List<Map<String, dynamic>> _recentActivities = [];

  // Cache breaker for avatar
  int avatarVersion = 0;
  Map<String, dynamic> _currentSession = {};
  int _waitingCount = 0;
  int _confirmedCount = 0;
  int _reportsCount = 0;
  int _assessmentsCount = 0;
  int _completedToday = 0;
  int _newToday = 0;
  int _completedThisMonth = 0;
  int _rejectedCount = 0;

  PsychologistDashboardProvider({required CounselingRepository repository})
    : _repository = repository;

  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUpdating => _isUpdating;

  // Add loading state for availability toggle
  bool _isUpdating = false;
  bool get isUpdatingAvailability => _isUpdating;

  Psychologist? get profile => _profile;
  List<Map<String, dynamic>> get upcomingBookings => _upcomingBookings;
  List<Map<String, dynamic>> get stats => _stats;
  List<Map<String, dynamic>> get recentActivities => _recentActivities;
  Map<String, dynamic> get currentSession => _currentSession;
  int get waitingCount => _waitingCount;
  int get confirmedCount => _confirmedCount;
  int get reportsCount => _reportsCount;
  int get assessmentsCount => _assessmentsCount;
  int get completedToday => _completedToday;
  int get newToday => _newToday;
  int get completedThisMonth => _completedThisMonth;
  int get rejectedCount => _rejectedCount;

  Future<void> toggleAvailability() async {
    if (_isUpdating) return;

    // Optimistic update - update UI immediately
    final newStatus = !_isAvailable;
    _isAvailable = newStatus;
    _isUpdating = true;
    notifyListeners();

    try {
      // Persist to backend
      await _repository.updateAvailability(newStatus);

      // Update local profile object availability state
      if (_profile != null) {
        _profile = Psychologist(
          id: _profile!.id,
          name: _profile!.name,
          nidn: _profile!.nidn,
          specialization: _profile!.specialization,
          profileImageUrl: _profile!.profileImageUrl,
          isAvailable: newStatus,
          email: _profile!.email,
          phone: _profile!.phone,
          bio: _profile!.bio,
          location: _profile!.location,
          languages: _profile!.languages,
          fee: _profile!.fee,
        );
      }
      _error = null;
    } catch (e) {
      log('Error toggling availability: $e');
    }

    _isUpdating = false;
    notifyListeners();
  }

  Future<void> loadDashboardData({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _repository.getProfile(),
        _repository.getDashboard(),
      ]);

      _profile = results[0] as Psychologist;
      final dashboard = results[1] as Map<String, dynamic>;

      _stats = List<Map<String, dynamic>>.from(dashboard['stats'] ?? []);
      _upcomingBookings =
          List<Map<String, dynamic>>.from(dashboard['bookings'] ?? []).where((
            b,
          ) {
            final status = (b['status'] ?? '').toString().toLowerCase();
            return status == 'dikonfirmasi' ||
                status == 'confirmed' ||
                status == 'menunggu' ||
                status == 'pending';
          }).toList();
      _currentSession = dashboard['current_session'] ?? {};
      _recentActivities = List<Map<String, dynamic>>.from(
        dashboard['recent_activities'] ?? [],
      );
      _waitingCount = dashboard['waiting_count'] ?? 0;
      _confirmedCount = dashboard['confirmed_count'] ?? 0;
      _reportsCount = dashboard['reports_count'] ?? 0;
      _assessmentsCount = dashboard['assessments_count'] ?? 0;
      _completedToday = dashboard['completed_today'] ?? 0;
      _newToday = dashboard['new_today'] ?? 0;
      _completedThisMonth = dashboard['completed_this_month'] ?? 0;
      _rejectedCount =
          dashboard['rejected_count'] ??
          dashboard['cancelled_count'] ??
          dashboard['canceled_count'] ??
          dashboard['rejected'] ??
          dashboard['cancelled'] ??
          0;

      // Dynamic fallback from stats array
      if (_stats.isNotEmpty) {
        for (final stat in _stats) {
          final String statusStr =
              (stat['status'] ?? stat['label'] ?? '').toString().toLowerCase();
          final int countVal =
              int.tryParse(
                (stat['count'] ?? stat['value'] ?? '0').toString(),
              ) ??
              0;
          if (statusStr.contains('menunggu') || statusStr.contains('pending')) {
            _waitingCount = countVal;
          } else if (statusStr.contains('konfirmasi') ||
              statusStr.contains('confirmed') ||
              statusStr.contains('setuju')) {
            _confirmedCount = countVal;
          } else if (statusStr.contains('selesai') ||
              statusStr.contains('complete') ||
              statusStr.contains('tuntas')) {
            _completedThisMonth = countVal;
          } else if (statusStr.contains('tolak') ||
              statusStr.contains('cancel') ||
              statusStr.contains('batal')) {
            _rejectedCount = countVal;
          }
        }
      }

      _isAvailable = _profile?.isAvailable ?? true;
      _error = null;
    } catch (e) {
      log('Error loading psychologist dashboard: $e');
      if (!silent) {
        _error = 'Gagal memuat data dashboard';
      }
    }

    if (!silent) {
      _isLoading = false;
    }
    notifyListeners();
  }

  void refresh() {
    loadDashboardData();
  }

  // Computed getters for dashboard screen compatibility
  int get upcomingAppointments => _confirmedCount;

  // Profile update methods
  Future<void> updateProfileData(Map<String, dynamic> data) async {
    try {
      await _repository.updateProfile(data);
      await loadDashboardData();
    } catch (e) {
      log('Error updating psychologist profile: $e');
      rethrow;
    }
  }

  Future<void> uploadProfileAvatar(String imagePath) async {
    try {
      final newUrl = await _repository.uploadAvatar(imagePath);
      avatarVersion++;

      if (newUrl.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final photoUrlWithTimestamp =
            newUrl.contains('?')
                ? '$newUrl&v=$timestamp'
                : '$newUrl?v=$timestamp';

        final userData = Map<String, dynamic>.from(
          AuthService().userData ?? {},
        );
        userData['foto_url'] = photoUrlWithTimestamp;
        userData['avatar_url'] = photoUrlWithTimestamp;
        userData['foto'] = photoUrlWithTimestamp;

        if (userData['user'] is Map) {
          final userMap = Map<String, dynamic>.from(userData['user']);
          userMap['foto'] = photoUrlWithTimestamp;
          userMap['avatar'] = photoUrlWithTimestamp;
          userMap['avatar_url'] = photoUrlWithTimestamp;
          userData['user'] = userMap;
        }

        await AuthService().updateUserData(userData);
      }

      await loadDashboardData(); // Refresh profile to get the new avatar
    } catch (e) {
      log('Error uploading avatar: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await _repository.changePassword(
        oldPassword,
        newPassword,
        confirmPassword,
      );
    } catch (e) {
      log('Error changing password: $e');
      rethrow;
    }
  }
}

import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/permission_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_notification.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_attendance.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_finance.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_lpj.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_aspiration.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_role.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_repository.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';

class OrmawaProvider extends ChangeNotifier {
  final OrmawaRepository _repository;
  final AuthService _authService = AuthService();

  OrmawaRepository get repository => _repository;

  OrmawaProvider(this._repository);

  // Organization Info - populated from API
  String _orgName = '';
  String _academicYear = '';

  // Getters with fallback values
  String get orgName =>
      _orgName.isNotEmpty ? _orgName : (_authService.ormawaName ?? 'Ormawa');
  String get academicYear => _academicYear;

  // Stats
  int _totalMembers = 0;
  double _balance = 0;
  int _activeProposalsCount = 0;
  int _upcomingAgendasCount = 0;

  // Gamifikasi
  int _gamifikasiPoin = 0;
  int _gamifikasiPeringkat = 0;
  int _totalOrmawa = 0;
  List<Map<String, dynamic>> _gamifikasiHistory = [];
  List<Map<String, dynamic>> _gamifikasiLeaderboard = [];
  List<Map<String, dynamic>> _gamifikasiRules = [];

  List<OrmawaProposal> _proposals = [];
  List<OrmawaAgenda> _agendas = [];
  List<OrmawaMember> _members = [];
  List<OrmawaFinance> _financeList = [];
  List<OrmawaLPJ> _lpjs = [];
  List<OrmawaAttendance> _attendanceList = [];
  List<OrmawaAspiration> _aspirations = [];
  List<OrmawaAnnouncement> _announcements = [];
  List<OrmawaRole> _roles = [];
  List<OrmawaDivision> _divisions = [];
  List<OrmawaOrganisasi> _organisasiList = [];
  List<Map<String, dynamic>> _absensiManagementList = [];

  List<OrmawaNotification> _notifications = [];
  List<String> _knownNotificationIds = [];
  bool _isFirstFetch = true;

  List<OrmawaNotification> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  List<String> _availablePeriods = [];
  String _selectedPeriod = 'aktif';

  List<String> get availablePeriods => _availablePeriods;
  String get selectedPeriod => _selectedPeriod;

  bool _isLoading = false;

  // Getters
  int get totalMembers => _totalMembers;
  double get balance {
    if (_financeList.isEmpty) return _balance;
    double totalMasuk = 0;
    double totalKeluar = 0;
    for (var t in _financeList) {
      if (t.type == 'pemasukan') {
        totalMasuk += t.nominal;
      } else {
        totalKeluar += t.nominal;
      }
    }
    return totalMasuk - totalKeluar;
  }

  int get activeProposalsCount => _activeProposalsCount;
  int get upcomingAgendasCount => _upcomingAgendasCount;
  int get gamifikasiPoin => _gamifikasiPoin;
  int get gamifikasiPeringkat => _gamifikasiPeringkat;
  int get totalOrmawa => _totalOrmawa;
  List<Map<String, dynamic>> get gamifikasiHistory => _gamifikasiHistory;
  List<Map<String, dynamic>> get gamifikasiLeaderboard => _gamifikasiLeaderboard;
  List<Map<String, dynamic>> get gamifikasiRules => _gamifikasiRules;

  int get approvalRate {
    if (_proposals.isEmpty) return 0;
    final approved =
        _proposals
            .where(
              (p) =>
                  p.status.toLowerCase().contains('disetujui') ||
                  p.status.toLowerCase() == 'selesai',
            )
            .length;
    return ((approved / _proposals.length) * 100).round();
  }

  List<OrmawaProposal> get proposals => _proposals;
  List<OrmawaAgenda> get agendas => _agendas;
  List<OrmawaMember> get members {
    final list = List<OrmawaMember>.from(_members);
    final current = currentMember;
    if (current != null &&
        !list.any((m) => m.mahasiswaId == current.mahasiswaId)) {
      list.add(current);
    }
    return list;
  }

  List<OrmawaFinance> get financeList => _financeList;
  List<OrmawaLPJ> get lpjs => _lpjs;
  List<OrmawaAttendance> get attendanceList => _attendanceList;
  List<OrmawaAspiration> get aspirations => _aspirations;
  List<OrmawaAnnouncement> get announcements => _announcements;
  List<OrmawaRole> get roles => _roles;
  List<OrmawaDivision> get divisions => _divisions;
  List<OrmawaOrganisasi> get organisasiList => _organisasiList;
  List<Map<String, dynamic>> get absensiManagementList => _absensiManagementList;

  bool get isLoading => _isLoading;

  String? get ormawaId =>
      _authService.userData?['user']?['ormawa_id']?.toString() ??
      _authService.userData?['ormawa_id']?.toString();
  String? get mahasiswaId =>
      _authService.userData?['mahasiswa']?['ID']?.toString() ??
      _authService.userData?['mahasiswa']?['id']?.toString() ??
      _authService.userData?['mahasiswa_id']?.toString();
  String? get fakultasId =>
      _authService.userData?['mahasiswa']?['fakultas_id']?.toString() ??
      _authService.userData?['user']?['fakultas_id']?.toString() ??
      _authService.userData?['fakultas_id']?.toString();

  OrmawaMember? get currentMember {
    final mId = mahasiswaId;
    if (mId == null) return null;
    try {
      return _members.firstWhere((m) => m.mahasiswaId == mId);
    } catch (e) {
      final userData = _authService.userData;
      if (userData != null) {
        final mahasiswa = userData['mahasiswa'] ?? userData['user'] ?? userData;
        final roleStr = userData['role']?.toString() ?? 'Pengurus';
        return OrmawaMember(
          id: 'me',
          mahasiswaId: mId,
          name:
              mahasiswa['Nama'] ??
              mahasiswa['nama'] ??
              userData['name'] ??
              'Saya',
          nim: mahasiswa['NIM'] ?? mahasiswa['nim'] ?? userData['nim'] ?? '',
          role:
              roleStr
                  .split('_')
                  .map((word) => word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
                  .join(' '),
          division: '',
          status: 'Aktif',
          fotoUrl:
              mahasiswa['FotoURL'] ??
              mahasiswa['foto_url'] ??
              mahasiswa['foto'] ??
              mahasiswa['avatar_url'] ??
              '',
          joinedAt: DateTime.now(),
          email:
              mahasiswa['email_kampus'] ??
              mahasiswa['EmailKampus'] ??
              userData['email'] ??
              '',
          phone:
              mahasiswa['no_hp'] ??
              mahasiswa['NoHP'] ??
              userData['phone'] ??
              '',
        );
      }
      return null;
    }
  }

  /// Check if current user has specific permission
  /// Uses PermissionService as source of truth (permissions from login response)
  bool hasPermission(String permission) {
    // Use PermissionService for permission check
    // This ensures consistency with Web admin settings
    final member = currentMember;

    // Ketua/Ketua Umum always has all permissions
    if (member != null) {
      if (member.role.toUpperCase() == 'KETUA UMUM' ||
          member.role.toUpperCase() == 'KETUA') {
        return true;
      }
    }

    // Always allow attendance permissions for any Ormawa user
    if (permission == 'view_attendance' ||
        permission == 'submit_attendance' ||
        permission == 'edit_attendance') {
      if (AuthService().currentRole == UserRole.ormawa) {
        return true;
      }
    }

    // Delegate to PermissionService
    return PermissionService().hasPermission(permission);
  }

  /// Check if current user has ALL of the specified permissions
  bool hasAllPermissions(List<String> permissions) {
    return PermissionService().hasAllPermissions(permissions);
  }

  /// Check if current user has ANY of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return PermissionService().hasAnyPermission(permissions);
  }

  /// Get current permissions list from PermissionService
  List<String> get currentPermissions => PermissionService().permissions;

  /// Sync permissions from backend
  /// Call this on app resume to get fresh permissions
  Future<void> syncPermissions() async {
    await PermissionService().syncPermissions();
    notifyListeners();
  }

  // Logic Bridge Methods
  Future<void> refreshData() async {
    final ormawaId = this.ormawaId;
    if (ormawaId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch independent data in parallel for better performance
      final results = await Future.wait([
        _repository.getStats(ormawaId), // Stats
        _repository.getGamifikasiSummary(), // Gamification
        _repository.getActiveAcademicYear(), // Academic year
        _repository.getProposals(ormawaId), // Proposals
        _repository.getAgendas(ormawaId), // Agendas
        _repository.getMembersData(
          ormawaId,
          periode: _selectedPeriod,
        ), // Members
        _repository.getFinance(ormawaId), // Finance
        _repository.getLPJs(ormawaId), // LPJs
        _repository.getAspirations(ormawaId), // Aspirations
        _repository.getAnnouncements(ormawaId), // Announcements
        _repository.getRoles(), // Roles
        _repository.getDivisions(ormawaId: ormawaId), // Divisions
        _repository.getNotifications(ormawaId), // Notifications
        _repository.getOrmawaSettings(ormawaId), // Settings
        _repository.getGamifikasiHistory(), // 14
        _repository.getGamifikasiLeaderboard(), // 15
        _repository.getGamifikasiRules(), // 16
      ]);

      // Parse results - order matches Future.wait() order
      final stats = results[0] as Map<String, dynamic>;
      final gamSummary = results[1] as Map<String, dynamic>;
      final activeYear = results[2] as String?;
      final proposals = results[3] as List<OrmawaProposal>;
      final agendas = results[4] as List<OrmawaAgenda>;
      final membersData = results[5] as Map<String, dynamic>;
      final finance = results[6] as List<OrmawaFinance>;
      final lpjs = results[7] as List<OrmawaLPJ>;
      final aspirations = results[8] as List<OrmawaAspiration>;
      final announcements = results[9] as List<OrmawaAnnouncement>;
      final roles = results[10] as List<OrmawaRole>;
      final divisions = results[11] as List<OrmawaDivision>;
      final notifications = results[12] as List<OrmawaNotification>;
      final ormawaSettings = results[13] as Map<String, dynamic>;
      final gHistory = results[14] as List<Map<String, dynamic>>;
      final gLeaderboard = results[15] as List<Map<String, dynamic>>;
      final gRules = results[16] as List<Map<String, dynamic>>;

      // Update stats
      _totalMembers = (stats['totalMembers'] as num?)?.toInt() ?? 0;
      _balance = (stats['totalKas'] as num?)?.toDouble() ?? 0;
      _activeProposalsCount = (stats['totalProposals'] as num?)?.toInt() ?? 0;
      _upcomingAgendasCount = (stats['totalEvents'] as num?)?.toInt() ?? 0;

      // Update gamification
      _gamifikasiPoin = (gamSummary['poin'] as num?)?.toInt() ?? 0;
      _gamifikasiPeringkat = (gamSummary['peringkat'] as num?)?.toInt() ?? 0;
      _totalOrmawa = (gamSummary['total_ormawa'] as num?)?.toInt() ?? 0;
      _gamifikasiHistory = gHistory;
      _gamifikasiLeaderboard = gLeaderboard;
      _gamifikasiRules = gRules;

      // Update academic year
      if (activeYear != null && activeYear.isNotEmpty) {
        _academicYear = activeYear;
      }

      // Update lists
      _proposals = proposals;
      _agendas = agendas;
      _members = membersData['members'] as List<OrmawaMember>;
      _availablePeriods = membersData['periods'] as List<String>;
      _financeList = finance;
      _lpjs = lpjs;
      _aspirations = aspirations;
      _announcements = announcements;
      _roles = roles;
      _divisions = divisions;
      _ormawaSettings = ormawaSettings;
      _orgName = _ormawaSettings['nama'] ?? _ormawaSettings['Nama'] ?? '';

      // Handle notifications
      if (!_isFirstFetch) {
        for (var n in notifications) {
          if (!n.isRead && !_knownNotificationIds.contains(n.id)) {
            LocalNotificationService.showNotification(
              id: n.id.hashCode,
              title: n.title,
              body: n.message,
            );
          }
        }
      }
      _knownNotificationIds = notifications.map((n) => n.id).toList();
      _isFirstFetch = false;
      _notifications = notifications;
    } catch (_) {
      // ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProposal(OrmawaProposal proposal) async {
    await _repository.addProposal(proposal);
    await refreshData();
  }

  Future<void> updateProposal(OrmawaProposal proposal) async {
    await _repository.updateProposal(proposal);
    await refreshData();
  }

  Future<void> deleteProposal(String id) async {
    try {
      await _repository.deleteProposal(id);
      await refreshData();
    } catch (_) {
      // ignore
    }
  }

  // Members Management
  Future<void> setMemberPeriod(String periode) async {
    _selectedPeriod = periode;
    await refreshData();
  }

  Future<void> regenerateMembers() async {
    try {
      _isLoading = true;
      notifyListeners();

      final ormawaId = this.ormawaId;
      if (ormawaId != null) {
        await _repository.regenerateMembers(ormawaId);
        _selectedPeriod = 'aktif';
        await refreshData();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      return await _repository.getStudents();
    } catch (e) {
      return [];
    }
  }

  Future<void> addMember(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ormawaId = _authService.userData?['user']?['ormawa_id']?.toString();
      if (ormawaId != null) {
        await _repository.addMember(ormawaId, data);
        await refreshData();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.updateMember(id, data);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.deleteMember(id);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agendas Management
  Future<void> addAgenda(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();

      final ormawaId = this.ormawaId;
      if (ormawaId != null) {
        await _repository.addAgenda(ormawaId, data);
        await refreshData();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAgenda(String id, Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.updateAgenda(id, data);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAgenda(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.deleteAgenda(id);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateOrgName(String newName) {
    _orgName = newName;
    notifyListeners();
  }

  // Attendance Methods
  Future<void> fetchAttendance(String eventId) async {
    try {
      _isLoading = true;
      notifyListeners();
      _attendanceList = await _repository.getAttendance(eventId);
    } catch (_) {
      // ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitAttendance(
    String eventId,
    String mhsId,
    String status,
  ) async {
    try {
      await _repository.submitAttendance(eventId, mhsId, status);
      await fetchAttendance(eventId);
    } catch (e) {
      rethrow;
    }
  }

  // FINANCE METHODS
  Future<void> getFinance() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _financeList = await _repository.getFinance(id);
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> addFinance(Map<String, dynamic> data) async {
    try {
      final id = ormawaId;
      if (id == null) throw Exception('Ormawa ID not found');
      await _repository.addFinance(id, data);
      await getFinance();
    } catch (e) {
      rethrow;
    }
  }

  // LPJ METHODS
  Future<void> getLPJs() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _lpjs = await _repository.getLPJs(id);
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> addLPJ(Map<String, dynamic> data) async {
    try {
      await _repository.addLPJ(data);
      await getLPJs();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLPJ(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateLPJ(id, data);
      await getLPJs();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteLPJ(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.deleteLPJ(id);
      await getLPJs();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getAspirations() async {
    try {
      if (ormawaId == null) return;
      _aspirations = await _repository.getAspirations(ormawaId!);
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> respondToAspiration(String id, Map<String, dynamic> data) async {
    try {
      await _repository.respondToAspiration(id, data);
      await getAspirations();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getAnnouncements() async {
    try {
      if (ormawaId == null) return;
      _announcements = await _repository.getAnnouncements(ormawaId!);
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    try {
      await _repository.createAnnouncement(data);
      await getAnnouncements();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateAnnouncement(id, data);
      await getAnnouncements();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnnouncement(String id) async {
    try {
      await _repository.deleteAnnouncement(id);
      await getAnnouncements();
    } catch (e) {
      rethrow;
    }
  }

  // ROLES & DIVISIONS
  Future<void> createRole(Map<String, dynamic> data) async {
    await _repository.createRole(data);
    await refreshData();
  }

  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    await _repository.updateRole(id, data);
    await refreshData();
  }

  Future<void> deleteRole(String id) async {
    await _repository.deleteRole(id);
    await refreshData();
  }

  Future<void> createDivision(Map<String, dynamic> data) async {
    await _repository.createDivision(data);
    await refreshData();
  }

  Future<void> createDivisionInline(String name) async {
    try {
      final ormawaId = this.ormawaId;
      if (ormawaId != null) {
        await _repository.createDivisionInline(ormawaId, name);
        await refreshData();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteDivision(String id) async {
    await _repository.deleteDivision(id);
    await refreshData();
  }

  Future<void> fetchNotifications() async {
    final oId = ormawaId;
    if (oId == null) return;

    final newNotifications = await _repository.getNotifications(oId);
    if (!_isFirstFetch) {
      for (var n in newNotifications) {
        if (!n.isRead && !_knownNotificationIds.contains(n.id)) {
          LocalNotificationService.showNotification(
            id: n.id.hashCode,
            title: n.title,
            body: n.message,
          );
        }
      }
    }
    _knownNotificationIds = newNotifications.map((n) => n.id).toList();
    _isFirstFetch = false;
    _notifications = newNotifications;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await _repository.markNotificationAsRead(id);
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final n = _notifications[index];
      _notifications[index] = OrmawaNotification(
        id: n.id,
        ormawaId: n.ormawaId,
        type: n.type,
        title: n.title,
        message: n.message,
        isRead: true,
        createdAt: n.createdAt,
      );
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final oId = ormawaId;
    if (oId == null) return;

    _notifications =
        _notifications
            .map(
              (n) => OrmawaNotification(
                id: n.id,
                ormawaId: n.ormawaId,
                type: n.type,
                title: n.title,
                message: n.message,
                isRead: true,
                createdAt: n.createdAt,
              ),
            )
            .toList();
    notifyListeners();

    try {
      await _repository.markAllNotificationsAsRead(oId);
    } catch (_) {
      // ignore
    }
  }

  Future<void> removeNotification(String id) async {
    await _repository.deleteNotification(id);
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  // RECRUITMENT / OPEN RECRUITMENT
  Map<String, dynamic> _recruitmentSettings = {};
  List<Map<String, dynamic>> _recruitmentApplicants = [];
  List<Map<String, dynamic>> _recruitmentFormFields = [];

  Map<String, dynamic> get recruitmentSettings => _recruitmentSettings;
  List<Map<String, dynamic>> get recruitmentApplicants =>
      _recruitmentApplicants;
  List<Map<String, dynamic>> get recruitmentFormFields =>
      _recruitmentFormFields;

  Future<void> getRecruitmentSettings() async {
    if (ormawaId == null) return;
    try {
      _recruitmentSettings = await _repository.getRecruitmentSettings(
        ormawaId!,
      );
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> updateRecruitmentSettings(Map<String, dynamic> data) async {
    if (ormawaId == null) return;
    try {
      await _repository.updateRecruitmentSettings(ormawaId!, data);
      await getRecruitmentSettings();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getRecruitmentApplicants() async {
    if (ormawaId == null) {
      return;
    }
    try {
      _recruitmentApplicants = await _repository.getRecruitmentApplicants(
        ormawaId!,
      );
      try {
        _recruitmentFormFields = await _repository.getRecruitmentFormFields(
          ormawaId!,
        );
      } catch (err) {
        // Silenced: non-critical form fields error
      }
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> reviewRecruitmentApplicant(
    String applicantId,
    String status,
  ) async {
    try {
      await _repository.reviewRecruitmentApplicant(applicantId, status);
      await getRecruitmentApplicants();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getRecruitmentFormFields() async {
    if (ormawaId == null) return;
    try {
      _recruitmentFormFields = await _repository.getRecruitmentFormFields(
        ormawaId!,
      );
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> saveRecruitmentFormFields(
    List<Map<String, dynamic>> fields,
  ) async {
    if (ormawaId == null) return;
    try {
      await _repository.saveRecruitmentFormFields(ormawaId!, fields);
      await getRecruitmentFormFields();
    } catch (e) {
      rethrow;
    }
  }

  // SETTINGS / PREFERENCES
  Map<String, dynamic> _ormawaSettings = {};

  Map<String, dynamic> get ormawaSettings => _ormawaSettings;

  bool get notifApproval => _ormawaSettings['notifApproval'] ?? true;
  bool get notifFinance => _ormawaSettings['notifFinance'] ?? true;
  bool get notifAspiration => _ormawaSettings['notifAspiration'] ?? false;

  Future<void> getOrmawaSettings() async {
    if (ormawaId == null) return;
    try {
      final settings = await _repository.getOrmawaSettings(ormawaId!);
      _ormawaSettings = Map<String, dynamic>.from(settings);
      final prefs = await SharedPreferences.getInstance();
      _ormawaSettings['notifApproval'] =
          prefs.getBool('ormawa_notif_approval_$ormawaId') ?? true;
      _ormawaSettings['notifFinance'] =
          prefs.getBool('ormawa_notif_finance_$ormawaId') ?? true;
      _ormawaSettings['notifAspiration'] =
          prefs.getBool('ormawa_notif_aspiration_$ormawaId') ?? false;
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  Future<void> updateNotificationPreferences({
    bool? notifApproval,
    bool? notifFinance,
    bool? notifAspiration,
  }) async {
    if (ormawaId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (notifApproval != null) {
        await prefs.setBool('ormawa_notif_approval_$ormawaId', notifApproval);
        _ormawaSettings['notifApproval'] = notifApproval;
      }
      if (notifFinance != null) {
        await prefs.setBool('ormawa_notif_finance_$ormawaId', notifFinance);
        _ormawaSettings['notifFinance'] = notifFinance;
      }
      if (notifAspiration != null) {
        await prefs.setBool(
          'ormawa_notif_aspiration_$ormawaId',
          notifAspiration,
        );
        _ormawaSettings['notifAspiration'] = notifAspiration;
      }
      notifyListeners();
    } catch (_) {
      // ignore
    }
  }

  // ORGANISASI METHODS
  Future<void> fetchOrganisasi() async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await _repository.getOrganisasiList();
      _organisasiList = result;
    } catch (_) {
      // ignore
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrganisasi(Map<String, dynamic> data) async {
    try {
      await _repository.createOrganisasi(data);
      await fetchOrganisasi();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrganisasi(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateOrganisasi(id, data);
      await fetchOrganisasi();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrganisasi(String id) async {
    try {
      await _repository.deleteOrganisasi(id);
      await fetchOrganisasi();
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadFile(String filePath) async {
    try {
      _isLoading = true;
      notifyListeners();
      final url = await _repository.uploadFile(filePath);
      return url;
    } catch (e) {
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Attendance Management Methods
  Future<void> fetchAbsensiManagement() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _absensiManagementList = await _repository.getAbsensiManagement(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> createAbsensiManagement(Map<String, dynamic> data) async {
    try {
      await _repository.createAbsensiManagement(data);
      await fetchAbsensiManagement();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getAbsensiManagementDetail(String id) async {
    try {
      return await _repository.getAbsensiManagementDetail(id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateAbsensiManagement(String id, Map<String, dynamic> data) async {
    try {
      await _repository.updateAbsensiManagement(id, data);
      await fetchAbsensiManagement();
    } catch (e) {
      rethrow;
    }
  }
}
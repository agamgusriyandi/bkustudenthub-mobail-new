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
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_financial_setting.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_repository.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';

class OrmawaProvider extends ChangeNotifier {
  final OrmawaRepository _repository;
  final AuthService _authService = AuthService();

  OrmawaRepository get repository => _repository;

  OrmawaProvider(this._repository);

  String _orgName = '';
  String _academicYear = '';

  String get orgName {
    final s = _ormawaSettings['singkatan'] ?? _ormawaSettings['Singkatan'];
    if (s != null && s.toString().trim().isNotEmpty) return s.toString().trim();
    if (_orgName.isNotEmpty) return _orgName;
    final n = _ormawaSettings['nama'] ?? _ormawaSettings['Nama'];
    if (n != null && n.toString().trim().isNotEmpty) return n.toString().trim();
    return _authService.ormawaName ?? 'Ormawa';
  }
  String get academicYear => _academicYear;

  int _totalMembers = 0;
  double _balance = 0;
  int _activeProposalsCount = 0;
  int _upcomingAgendasCount = 0;

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
  Map<String, dynamic>? _budgetStatus;
  Map<String, dynamic> _bankAccount = {'nama_bank': '', 'no_rekening': '', 'nama_rekening': ''};
  List<Map<String, dynamic>> _iurans = [];
  List<Map<String, dynamic>> _myInvoices = [];
  List<Map<String, dynamic>> _iuranMembers = [];
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

  OrmawaFinancialSetting? _financialSetting;
  List<OrmawaFinancialSetting> _allFinancialSettings = [];
  List<OrmawaFinancialAuditLog> _auditLogs = [];
  bool _isLoadingPagu = false;

  OrmawaFinancialSetting? get financialSetting => _financialSetting;
  List<OrmawaFinancialSetting> get allFinancialSettings => _allFinancialSettings;
  List<OrmawaFinancialAuditLog> get auditLogs => _auditLogs;
  bool get isLoadingPagu => _isLoadingPagu;

  List<OrmawaNotification> get notifications => _notifications;
  int get unreadNotificationsCount =>
      _notifications.where((n) => !n.isRead).length;

  List<String> _availablePeriods = [];
  String _selectedPeriod = 'aktif';

  List<String> get availablePeriods => _availablePeriods;
  String get selectedPeriod => _selectedPeriod;

  bool _isLoading = false;
  bool _isRefreshingData = false;
  bool get isFirstFetch => _isFirstFetch;
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
  Map<String, dynamic>? get budgetStatus => _budgetStatus;
  Map<String, dynamic> get bankAccount => _bankAccount;
  List<Map<String, dynamic>> get iurans => _iurans;
  List<Map<String, dynamic>> get myInvoices => _myInvoices;
  List<Map<String, dynamic>> get iuranMembers => _iuranMembers;
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
                  .map((word) => word.isEmpty ? '' : '${word[0]}${word.substring(1).toLowerCase()}')
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

  String get userSubRole {
    final member = currentMember;
    if (member != null && member.role.trim().isNotEmpty && member.role.trim().toLowerCase() != 'ormawa') {
      return member.role.trim();
    }
    final userData = AuthService().userData;
    if (userData != null) {
      final userObj = userData['user'] ?? userData;
      final raw = userObj['role_display'] ?? userObj['roleDisplay'] ?? userObj['jabatan'] ?? userObj['Role'];
      if (raw != null && raw.toString().trim().isNotEmpty && raw.toString().trim().toLowerCase() != 'ormawa') {
        return raw.toString().trim();
      }
    }
    return 'Pengurus';
  }

  bool hasPermission(String permission) {
    if (permission.contains(',')) {
      final perms = permission.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      return perms.any((p) => hasPermission(p));
    }

    final p = permission.toLowerCase().trim();

    if (p == 'notifications.view' ||
        p == 'core.notifications.view' ||
        p == 'profile.view' ||
        p == 'core.profile.view' ||
        p == 'view_notifications' ||
        p == 'view_profile') {
      return true;
    }

    final permService = PermissionService();
    if (permService.hasPermissions) {
      if (permService.hasPermission(permission)) {
        return true;
      }
    }

    final member = currentMember;
    final r = (member?.role ?? userSubRole).toLowerCase().trim();

    if (r.contains('ketua') || r.contains('pembina') || r.contains('penasihat') || r.contains('admin')) {
      return true;
    }

    if (r.contains('wakil')) {
      if (!p.contains('delete') && !p.contains('pagu.manage') && !p.contains('settings.manage')) {
        return true;
      }
      return false;
    }

    if (r.contains('bendahara')) {
      if (p.contains('finance') ||
          p.contains('keuangan') ||
          p.contains('kas') ||
          p.contains('pagu') ||
          p.contains('lpj') ||
          p.contains('event') ||
          p.contains('calendar') ||
          p.contains('jadwal')) {
        return true;
      }
      return false;
    }

    if (r.contains('sekretaris')) {
      if (p.contains('proposal') ||
          p.contains('lpj') ||
          p.contains('event') ||
          p.contains('calendar') ||
          p.contains('jadwal') ||
          p.contains('attendance') ||
          p.contains('absensi') ||
          p.contains('member') ||
          p.contains('anggota') ||
          p.contains('staff') ||
          p.contains('staf') ||
          p.contains('structure') ||
          p.contains('struktur') ||
          p.contains('recruitment') ||
          p.contains('rekrutmen') ||
          p.contains('announcement') ||
          p.contains('pengumuman') ||
          p.contains('aspiration') ||
          p.contains('aspirasi')) {
        return true;
      }
      return false;
    }

    if (r.contains('kadiv') || r.contains('kepala') || r.contains('koordinator')) {
      if (p.contains('proposal') ||
          p.contains('event') ||
          p.contains('calendar') ||
          p.contains('jadwal') ||
          p.contains('attendance') ||
          p.contains('absensi') ||
          p.contains('aspiration') ||
          p.contains('aspirasi')) {
        return true;
      }
      return false;
    }

    if (r.contains('staf') || r.contains('staff') || r == 'anggota' || r.contains('anggota') || r == 'member') {
      if (p.contains('event') ||
          p.contains('calendar') ||
          p.contains('jadwal') ||
          p.contains('attendance') ||
          p.contains('absensi') ||
          p.contains('aspiration') ||
          p.contains('aspirasi')) {
        return true;
      }
      return false;
    }

    return false;
  }

  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((p) => hasPermission(p));
  }

  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((p) => hasPermission(p));
  }

  List<String> get currentPermissions => PermissionService().permissions;

  Future<void> syncPermissions() async {
    await PermissionService().syncPermissions();
    notifyListeners();
  }

  Future<void> refreshData() async {
    final ormawaId = this.ormawaId;
    if (ormawaId == null) return;
    if (_isRefreshingData) return;
    _isRefreshingData = true;

    if (_isFirstFetch && _members.isEmpty && _proposals.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _repository.getStats(ormawaId),
        _repository.getGamifikasiSummary(),
        _repository.getActiveAcademicYear(),
        _repository.getProposals(ormawaId),
        _repository.getAgendas(ormawaId),
        _repository.getMembersData(
          ormawaId,
          periode: _selectedPeriod,
        ),
        _repository.getFinance(ormawaId),
        _repository.getLPJs(ormawaId),
        _repository.getAspirations(ormawaId),
        _repository.getAnnouncements(ormawaId),
        _repository.getRoles(),
        _repository.getDivisions(ormawaId: ormawaId),
        _repository.getNotifications(ormawaId),
        _repository.getOrmawaSettings(ormawaId),
        _repository.getGamifikasiHistory(),
        _repository.getGamifikasiLeaderboard(),
        _repository.getGamifikasiRules(),
      ]);

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

      _totalMembers = (stats['totalMembers'] as num?)?.toInt() ?? 0;
      _balance = (stats['totalKas'] as num?)?.toDouble() ?? 0;
      _activeProposalsCount = (stats['totalProposals'] as num?)?.toInt() ?? 0;
      _upcomingAgendasCount = (stats['totalEvents'] as num?)?.toInt() ?? 0;

      _gamifikasiPoin = (gamSummary['poin'] as num?)?.toInt() ?? 0;
      _gamifikasiPeringkat = (gamSummary['peringkat'] as num?)?.toInt() ?? 0;
      _totalOrmawa = (gamSummary['total_ormawa'] as num?)?.toInt() ?? 0;
      _gamifikasiHistory = gHistory;
      _gamifikasiLeaderboard = gLeaderboard;
      _gamifikasiRules = gRules;

      if (activeYear != null && activeYear.isNotEmpty) {
        _academicYear = activeYear;
      }

      _proposals = List<OrmawaProposal>.from(proposals);
      _agendas = List<OrmawaAgenda>.from(agendas);
      _members = List<OrmawaMember>.from(membersData['members'] as List<OrmawaMember>);
      _availablePeriods = List<String>.from(membersData['periods'] as List<String>);
      _financeList = List<OrmawaFinance>.from(finance);
      _lpjs = List<OrmawaLPJ>.from(lpjs);
      _aspirations = List<OrmawaAspiration>.from(aspirations);
      _announcements = List<OrmawaAnnouncement>.from(announcements);
      _roles = roles;
      _divisions = divisions;
      _ormawaSettings = ormawaSettings;
      _orgName = _ormawaSettings['singkatan'] ??
          _ormawaSettings['Singkatan'] ??
          _ormawaSettings['nama'] ??
          _ormawaSettings['Nama'] ??
          '';

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
    } finally {
      _isLoading = false;
      _isRefreshingData = false;
      notifyListeners();
    }
  }

  Future<void> addProposal(OrmawaProposal proposal) async {
    await _repository.addProposal(proposal);
    await refreshData();
  }

  Future<void> createProposal(Map<String, dynamic> data) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.createProposal(data);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProposal(dynamic proposalOrId, [Map<String, dynamic>? data]) async {
    try {
      _isLoading = true;
      notifyListeners();
      if (proposalOrId is OrmawaProposal) {
        await _repository.updateProposal(proposalOrId);
      } else if (proposalOrId is String && data != null) {
        await _repository.updateProposalData(proposalOrId, data);
      }
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resubmitProposal(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.resubmitProposal(id);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteProposal(String id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.deleteProposal(id);
      await refreshData();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Future<void> fetchAttendance(String eventId) async {
    try {
      _attendanceList = await _repository.getAttendance(eventId);
    } catch (_) {
    } finally {
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

  Future<void> getFinance() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _financeList = await _repository.getFinance(id);
      notifyListeners();
    } catch (_) {
      
    }
  }

  Future<void> addFinance(Map<String, dynamic> data) async {
    try {
      final id = ormawaId;
      if (id == null) throw Exception('Ormawa ID not found');
      await _repository.addFinance(id, data);
      await getFinance();
      await fetchBudgetStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFinance(String transactionId) async {
    try {
      await _repository.deleteFinance(transactionId);
      await getFinance();
      await fetchBudgetStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchBudgetStatus() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _budgetStatus = await _repository.getBudgetStatus(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<String> generateReportNumber() async {
    try {
      final id = ormawaId;
      if (id == null) return '001/LAP-ORMAWA/X/2026';
      return await _repository.generateReportNumber(id);
    } catch (_) {
      return '001/LAP-ORMAWA/X/2026';
    }
  }

  Future<void> fetchBankAccount() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _bankAccount = await _repository.getBankAccount(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updateBankAccount(Map<String, dynamic> data) async {
    try {
      final id = ormawaId;
      if (id == null) throw Exception('Ormawa ID not found');
      await _repository.updateBankAccount(id, data);
      await fetchBankAccount();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchIurans() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _iurans = await _repository.getIurans(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> createIuran(Map<String, dynamic> data) async {
    try {
      final id = ormawaId;
      if (id == null) throw Exception('Ormawa ID not found');
      await _repository.createIuran(id, data);
      await fetchIurans();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchIuranMembers(String iuranId) async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _iuranMembers = await _repository.getIuranMembers(iuranId, id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> verifyIuranPayment(String detailId, Map<String, dynamic> data, [String? iuranId]) async {
    try {
      final id = ormawaId;
      if (id == null) throw Exception('Ormawa ID not found');
      await _repository.verifyIuranPayment(detailId, id, data);
      if (iuranId != null) {
        await fetchIuranMembers(iuranId);
      }
      await fetchIurans();
      await getFinance();
      await fetchBudgetStatus();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMyInvoices() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _myInvoices = await _repository.getMyIurans(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> payMyIuran(String detailId, String proofUrl) async {
    try {
      final id = ormawaId;
      if (id == null) throw Exception('Ormawa ID not found');
      await _repository.payMyIuran(detailId, id, {'bukti_transfer': proofUrl});
      await fetchIurans();
      await fetchMyInvoices();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getLPJs() async {
    try {
      final id = ormawaId;
      if (id == null) return;
      _lpjs = await _repository.getLPJs(id);
      notifyListeners();
    } catch (_) {
      
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
      
    }
  }

  Future<void> removeNotification(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    try {
      await _repository.deleteNotification(id);
    } catch (_) {
      
    }
  }

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
    } catch (_) {}
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
      } catch (_) {}
      try {
        _recruitmentSettings = await _repository.getRecruitmentSettings(
          ormawaId!,
        );
      } catch (_) {}
      notifyListeners();
    } catch (_) {}
  }

  Future<void> reviewRecruitmentApplicant(
    String applicantId,
    String status, {
    String? role,
    String? divisi,
    String? rejectionReason,
  }) async {
    try {
      await _repository.reviewRecruitmentApplicant(
        applicantId,
        status,
        role: role,
        divisi: divisi,
        rejectionReason: rejectionReason,
      );
      await getRecruitmentApplicants();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> bulkReviewApplicants(
    List<String> applicantIds,
    String status, {
    String? rejectionReason,
  }) async {
    for (final id in applicantIds) {
      try {
        final applicant = _recruitmentApplicants.firstWhere(
          (a) => (a['ID'] ?? a['id'])?.toString() == id,
          orElse: () => {},
        );
        final divisi = applicant['Divisi']?.toString() ?? applicant['divisi']?.toString() ?? 'Umum';
        await _repository.reviewRecruitmentApplicant(
          id,
          status,
          role: 'Anggota',
          divisi: divisi,
          rejectionReason: rejectionReason,
        );
      } catch (_) {}
    }
    await getRecruitmentApplicants();
  }

  Future<void> getRecruitmentFormFields() async {
    if (ormawaId == null) return;
    try {
      _recruitmentFormFields = await _repository.getRecruitmentFormFields(
        ormawaId!,
      );
      notifyListeners();
    } catch (_) {}
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

  Map<String, dynamic> _ormawaSettings = {};

  Map<String, dynamic> get ormawaSettings => _ormawaSettings;

  bool get notifApproval => _ormawaSettings['notifApproval'] ?? true;
  bool get notifFinance => _ormawaSettings['notifFinance'] ?? true;
  bool get notifAspiration => _ormawaSettings['notifAspiration'] ?? false;

  int get profileCompleteness {
    final fields = [
      _ormawaSettings['Nama'] ?? _ormawaSettings['nama'],
      _ormawaSettings['Singkatan'] ?? _ormawaSettings['singkatan'],
      _ormawaSettings['Deskripsi'] ?? _ormawaSettings['deskripsi'],
      _ormawaSettings['Visi'] ?? _ormawaSettings['visi'],
      _ormawaSettings['Misi'] ?? _ormawaSettings['misi'],
      _ormawaSettings['LogoURL'] ?? _ormawaSettings['logo_url'] ?? _ormawaSettings['Logo'],
      _ormawaSettings['Email'] ?? _ormawaSettings['email'],
      _ormawaSettings['Phone'] ?? _ormawaSettings['phone'] ?? _ormawaSettings['Kontak'],
      _ormawaSettings['Instagram'] ?? _ormawaSettings['instagram'],
      _ormawaSettings['NoRekening'] ?? _ormawaSettings['no_rekening'] ?? _ormawaSettings['Rekening'] ?? _ormawaSettings['rekening'],
    ];
    final filled = fields.where((f) => f != null && f.toString().trim().isNotEmpty).length;
    return ((filled / fields.length) * 100).round();
  }

  int get contactChannelsCount {
    final channels = [
      _ormawaSettings['Email'] ?? _ormawaSettings['email'],
      _ormawaSettings['Phone'] ?? _ormawaSettings['phone'] ?? _ormawaSettings['Kontak'],
      _ormawaSettings['Instagram'] ?? _ormawaSettings['instagram'],
      _ormawaSettings['Website'] ?? _ormawaSettings['website'],
    ];
    return channels.where((c) => c != null && c.toString().trim().isNotEmpty).length;
  }

  bool get hasBankAccount {
    final rek = _ormawaSettings['NoRekening'] ?? _ormawaSettings['no_rekening'] ?? _ormawaSettings['Rekening'] ?? _ormawaSettings['rekening'];
    return rek != null && rek.toString().trim().isNotEmpty;
  }

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
    }
  }

  Future<void> updateOrmawaSettings(Map<String, dynamic> data) async {
    if (ormawaId == null) return;
    try {
      _isLoading = true;
      notifyListeners();
      await _repository.updateOrmawaSettings(ormawaId!, data);
      _ormawaSettings.addAll(data);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
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
      
    }
  }

  Future<void> fetchOrganisasi() async {
    try {
      _isLoading = true;
      notifyListeners();
      final result = await _repository.getOrganisasiList();
      _organisasiList = result;
    } catch (_) {
      
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

  Future<void> fetchFinancialSettings({String? targetOrmawaId, String? periode}) async {
    try {
      _isLoadingPagu = true;
      notifyListeners();

      final oid = targetOrmawaId ?? ormawaId;
      final settings = await _repository.getFinancialSettings(
        ormawaId: oid,
        periode: periode,
      );

      _allFinancialSettings = settings;
      if (settings.isNotEmpty) {
        if (oid != null && oid.isNotEmpty) {
          _financialSetting = settings.firstWhere(
            (s) => s.ormawaId.toString() == oid,
            orElse: () => settings.first,
          );
        } else {
          _financialSetting = settings.first;
        }

        if (_financialSetting != null) {
          await fetchFinancialAuditLogs(_financialSetting!.ormawaId.toString());
        }
      } else {
        _financialSetting = null;
        _auditLogs = [];
      }
    } catch (_) {
    } finally {
      _isLoadingPagu = false;
      notifyListeners();
    }
  }

  void selectFinancialOrmawa(OrmawaFinancialSetting setting) {
    _financialSetting = setting;
    fetchFinancialAuditLogs(setting.ormawaId.toString());
    notifyListeners();
  }

  Future<void> fetchFinancialAuditLogs(String targetOrmawaId) async {
    try {
      final logs = await _repository.getFinancialAuditLogs(targetOrmawaId);
      _auditLogs = logs;
      notifyListeners();
    } catch (_) {
      _auditLogs = [];
      notifyListeners();
    }
  }

  Future<void> updateFinancialSetting(Map<String, dynamic> data) async {
    try {
      _isLoadingPagu = true;
      notifyListeners();

      await _repository.updateFinancialSetting(data);
      await fetchFinancialSettings(targetOrmawaId: data['ormawa_id']?.toString());
    } catch (e) {
      rethrow;
    } finally {
      _isLoadingPagu = false;
      notifyListeners();
    }
  }
}
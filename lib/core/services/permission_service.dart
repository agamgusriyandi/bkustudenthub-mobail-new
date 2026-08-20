import 'package:dio/dio.dart';
import '../network/api_client.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

/// PermissionService - Centralized permission management for Ormawa
///
/// This service ensures that permissions set by Admin in Web
/// are properly reflected in Mobile.
///
/// Source of truth: permissions from login response (/auth/login)
/// which are computed from database by backend (getUserPermissions)
///
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final Dio _dio = ApiClient().client;

  List<String> _permissions = [];
  bool _isSyncing = false;

  /// List of all available permissions in Ormawa module
  static const List<String> allPermissions = [
    // Dashboard
    'view_dashboard',
    'view_notifications',

    // Proposal
    'view_proposal',
    'create_proposal',
    'edit_proposal',
    'delete_proposal',

    // LPJ
    'view_lpj',
    'create_lpj',
    'edit_lpj',
    'upload_lpj_doc',
    'delete_lpj',

    // Finance
    'view_finance',
    'create_finance',
    'delete_finance',

    // Calendar/Agenda
    'view_calendar',
    'create_calendar',
    'edit_calendar',
    'delete_calendar',

    // Attendance
    'view_attendance',
    'submit_attendance',
    'edit_attendance',

    // Members
    'view_members',
    'create_members',
    'edit_members',

    // Structure
    'view_structure',
    'manage_structure',
    'view_staff',
    'manage_staff',

    // Aspirations
    'view_aspirations',
    'respond_aspirations',

    // Announcements
    'view_announcements',
    'create_announcements',
    'edit_announcements',
    'delete_announcements',

    // Settings
    'view_settings',
  ];

  /// Get all cached permissions
  List<String> get permissions => List.unmodifiable(_permissions);

  /// Check if permissions are loaded
  bool get hasPermissions => _permissions.isNotEmpty;

  /// Set permissions (called after login)
  void setPermissions(List<String> permissions) {
    _permissions = List.from(permissions);
  }

  /// Clear permissions (called on logout)
  void clear() {
    _permissions = [];
  }

  /// Sync permissions from backend
  /// Call this on app resume to get fresh permissions
  Future<bool> syncPermissions() async {
    // Skip if user is not logged in
    if (AuthService().token == null ||
        AuthService().currentRole == UserRole.guest) {
      return false;
    }

    if (_isSyncing) {
      return false;
    }

    _isSyncing = true;

    try {

      final response = await _dio.get('/auth/me');

      if (response.data['status'] == 'success' ||
          response.data['success'] == true) {
        final userData =
            response.data['data']?['user'] ?? response.data['user'];
        final perms = userData?['permissions'];

        if (perms is List) {
          _permissions = perms.map((e) => e.toString()).toList();
          _isSyncing = false;
          return true;
        }
      }

      _isSyncing = false;
      return false;
    } on DioException {
      _isSyncing = false;
      return false;
    } catch (e) {
      _isSyncing = false;
      return false;
    }
  }

  static const Map<String, List<String>> _legacyToDomainMap = {
    'view_dashboard': ['ormawa.core.view', 'ormawa.dashboard.view', 'core.dashboard.view'],
    'view_notifications': ['core.notifications.view', 'notifications.view'],
    'view_members': ['ormawa.members.view', 'ormawa.members.manage'],
    'create_members': ['ormawa.members.create', 'ormawa.members.manage', 'ormawa.organisasi.manage'],
    'edit_members': ['ormawa.members.update', 'ormawa.members.manage', 'ormawa.organisasi.manage'],
    'delete_members': ['ormawa.members.delete', 'ormawa.members.manage', 'ormawa.organisasi.manage'],
    'view_staff': ['ormawa.staff.view', 'ormawa.staff.manage'],
    'manage_staff': [
      'ormawa.staff.create',
      'ormawa.staff.update',
      'ormawa.staff.delete',
      'ormawa.staff.manage',
      'ormawa.organisasi.manage',
    ],
    'view_recruitment': [
      'ormawa.recruitment.view',
      'ormawa.recruitment.create',
      'ormawa.recruitment.manage',
      'ormawa.rekrutmen.manage',
    ],
    'manage_recruitment': [
      'ormawa.recruitment.view',
      'ormawa.recruitment.create',
      'ormawa.recruitment.update',
      'ormawa.recruitment.delete',
      'ormawa.recruitment.manage',
      'ormawa.rekrutmen.manage',
    ],
    'view_structure': ['ormawa.structure.view', 'ormawa.structure.manage'],
    'manage_structure': ['ormawa.structure.manage', 'ormawa.structure.update', 'ormawa.organisasi.manage'],
    'view_proposal': ['ormawa.proposals.view', 'ormawa.proposal-pipeline.view', 'ormawa.proposals.manage'],
    'create_proposal': ['ormawa.proposals.create', 'ormawa.proposals.manage'],
    'edit_proposal': ['ormawa.proposals.update', 'ormawa.proposals.manage'],
    'delete_proposal': ['ormawa.proposals.delete', 'ormawa.proposals.manage'],
    'view_lpj': ['ormawa.lpj.view', 'ormawa.lpj-pipeline.view', 'ormawa.lpj.manage'],
    'create_lpj': ['ormawa.lpj.create', 'ormawa.lpj.manage'],
    'edit_lpj': ['ormawa.lpj.update', 'ormawa.lpj.manage'],
    'upload_lpj_doc': ['ormawa.lpj.update', 'ormawa.lpj.manage', 'ormawa.lpj.create'],
    'delete_lpj': ['ormawa.lpj.delete', 'ormawa.lpj.manage'],
    'view_calendar': ['ormawa.events.view', 'ormawa.events.manage'],
    'create_calendar': ['ormawa.events.create', 'ormawa.events.manage'],
    'edit_calendar': ['ormawa.events.update', 'ormawa.events.manage'],
    'delete_calendar': ['ormawa.events.delete', 'ormawa.events.manage'],
    'view_attendance': ['ormawa.attendance.view', 'ormawa.attendance.manage'],
    'submit_attendance': ['ormawa.attendance.manage', 'ormawa.attendance.create'],
    'edit_attendance': ['ormawa.attendance.manage', 'ormawa.attendance.update'],
    'view_finance': ['ormawa.finance.view', 'ormawa.finance.manage'],
    'create_finance': ['ormawa.finance.create', 'ormawa.finance.manage'],
    'delete_finance': ['ormawa.finance.delete', 'ormawa.finance.manage'],
    'view_pagu': ['ormawa.pagu.view', 'ormawa.pagu.manage'],
    'manage_pagu': ['ormawa.pagu.manage', 'ormawa.pagu.update', 'ormawa.organisasi.manage'],
    'view_aspirations': ['ormawa.aspirations.view', 'ormawa.aspiration.view'],
    'respond_aspirations': ['ormawa.aspirations.update', 'ormawa.aspiration.update', 'ormawa.aspiration.manage'],
    'view_announcements': ['ormawa.announcements.view', 'ormawa.announcements.manage'],
    'create_announcements': ['ormawa.announcements.create', 'ormawa.announcements.manage'],
    'edit_announcements': ['ormawa.announcements.update', 'ormawa.announcements.manage'],
    'delete_announcements': ['ormawa.announcements.delete', 'ormawa.announcements.manage'],
    'view_settings': ['ormawa.settings.view', 'ormawa.settings.manage'],
    'manage_settings': ['ormawa.settings.manage', 'ormawa.settings.update', 'ormawa.organisasi.manage'],
    'view_rbac': ['ormawa.rbac.view', 'ormawa.rbac.manage'],
    'manage_rbac': [
      'ormawa.rbac.manage',
      'ormawa.rbac.create',
      'ormawa.rbac.update',
      'ormawa.rbac.delete',
    ],
    'view_gamifikasi': ['ormawa.gamifikasi.view', 'ormawa.gamifikasi.manage'],
  };

  bool hasPermission(String permission) {
    if (_permissions.isEmpty) {
      return false;
    }
    if (_permissions.contains('*') || _permissions.contains('superadmin.dashboard.view')) {
      return true;
    }

    if (permission.contains(',')) {
      final list = permission.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty);
      return list.any((p) => hasPermission(p));
    }

    final trimmed = permission.trim();
    if (_permissions.contains(trimmed)) return true;

    final mapped = _legacyToDomainMap[trimmed];
    if (mapped != null) {
      for (final p in mapped) {
        if (_permissions.contains(p)) return true;
      }
    }

    for (final entry in _legacyToDomainMap.entries) {
      if (entry.value.contains(trimmed) && _permissions.contains(entry.key)) {
        return true;
      }
    }

    return false;
  }

  /// Check if current user has ALL of the specified permissions
  bool hasAllPermissions(List<String> requiredPerms) {
    if (_permissions.isEmpty) return false;
    if (_permissions.contains('*')) return true;
    return requiredPerms.every((p) => hasPermission(p));
  }

  /// Check if current user has ANY of the specified permissions
  bool hasAnyPermission(List<String> anyPerms) {
    if (_permissions.isEmpty) return false;
    if (_permissions.contains('*')) return true;
    return anyPerms.any((p) => hasPermission(p));
  }

  /// Get permissions grouped by category
  Map<String, List<String>> get permissionsByCategory {
    return {
      'Dashboard': ['view_dashboard', 'view_notifications'],
      'Proposal': [
        'view_proposal',
        'create_proposal',
        'edit_proposal',
        'delete_proposal',
      ],
      'LPJ': [
        'view_lpj',
        'create_lpj',
        'edit_lpj',
        'upload_lpj_doc',
        'delete_lpj',
      ],
      'Keuangan': ['view_finance', 'create_finance', 'delete_finance'],
      'Kalender': [
        'view_calendar',
        'create_calendar',
        'edit_calendar',
        'delete_calendar',
      ],
      'Absensi': ['view_attendance', 'submit_attendance', 'edit_attendance'],
      'Anggota': ['view_members', 'create_members', 'edit_members'],
      'Struktur': [
        'view_structure',
        'manage_structure',
        'view_staff',
        'manage_staff',
      ],
      'Aspirasi': ['view_aspirations', 'respond_aspirations'],
      'Pengumuman': [
        'view_announcements',
        'create_announcements',
        'edit_announcements',
        'delete_announcements',
      ],
      'Pengaturan': ['view_settings'],
    };
  }

  /// Get human-readable label for permission
  String getPermissionLabel(String permission) {
    final labels = {
      'view_dashboard': 'Lihat Dashboard',
      'view_notifications': 'Lihat Notifikasi',
      'view_proposal': 'Lihat Proposal',
      'create_proposal': 'Buat Proposal',
      'edit_proposal': 'Edit Proposal',
      'delete_proposal': 'Hapus Proposal',
      'view_lpj': 'Lihat LPJ',
      'create_lpj': 'Buat LPJ',
      'edit_lpj': 'Edit LPJ',
      'upload_lpj_doc': 'Upload Dokumen LPJ',
      'delete_lpj': 'Hapus LPJ',
      'view_finance': 'Lihat Keuangan',
      'create_finance': 'Catat Transaksi',
      'delete_finance': 'Hapus Transaksi',
      'view_calendar': 'Lihat Kalender',
      'create_calendar': 'Buat Agenda',
      'edit_calendar': 'Edit Agenda',
      'delete_calendar': 'Hapus Agenda',
      'view_attendance': 'Lihat Absensi',
      'submit_attendance': 'Submit Absensi',
      'edit_attendance': 'Edit Absensi',
      'view_members': 'Lihat Anggota',
      'create_members': 'Tambah Anggota',
      'edit_members': 'Edit Anggota',
      'view_structure': 'Lihat Struktur',
      'manage_structure': 'Kelola Struktur',
      'view_staff': 'Lihat Staff',
      'manage_staff': 'Kelola Staff',
      'view_aspirations': 'Lihat Aspirasi',
      'respond_aspirations': 'Tanggapi Aspirasi',
      'view_announcements': 'Lihat Pengumuman',
      'create_announcements': 'Buat Pengumuman',
      'edit_announcements': 'Edit Pengumuman',
      'delete_announcements': 'Hapus Pengumuman',
      'view_settings': 'Lihat Pengaturan',
    };
    return labels[permission] ?? permission;
  }
}
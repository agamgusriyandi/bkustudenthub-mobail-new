import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'permission_service.dart';
import 'notification_service.dart';
import 'package:bkuhub_mobile/core/services/biometric_service.dart';
import 'package:bkuhub_mobile/core/services/secure_storage_service.dart';
import '../../core/error/error_handler.dart';

enum UserRole {
  student,
  ormawa,
  psychologist,
  tenagaKesehatan,
  mentorKencana,
  guest,
}

class LoginResult {
  final bool success;
  final bool requiresRoleSelection;
  final String? tempToken;
  final List<dynamic>? roles;
  final String? message;

  LoginResult({
    required this.success,
    this.requiresRoleSelection = false,
    this.tempToken,
    this.roles,
    this.message,
  });
}

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserRole _currentRole = UserRole.guest;
  UserRole get currentRole => _currentRole;

  String? _token;
  Map<String, dynamic>? _userData;
  String? _studentAvatarUrl;
  String? get studentAvatarUrl => _studentAvatarUrl;

  Future<LoginResult> login(String identifier, String password) async {
    try {
      final response = await ApiClient().client.post(
        '/auth/login',
        data: {'identifier': identifier, 'password': password},
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];

        // Check if multi-role selection is required
        bool requiresRole =
            data['requires_role_selection'] == true ||
            response.data['requires_role_selection'] == true;
        var rolesList = data['roles'] ?? response.data['roles'];

        final isMultiRole =
            rolesList != null && rolesList is List && rolesList.length > 1;

        // Set _userData early so that if select-role fallback is used, we still have user data (like avatar)
        _userData = data;

        if (requiresRole || isMultiRole) {
          // Map roles safely to ensure the UI has the required fields
          final List<Map<String, dynamic>> parsedRoles = [];
          if (rolesList is List) {
            for (final r in rolesList) {
              if (r is Map) {
                final map = Map<String, dynamic>.from(r);

                // Extract NIM if present to make the key unique for double degrees
                final nim = _extractNim(map);
                var roleKey =
                    map['role']?.toString() ?? map['id']?.toString() ?? '';
                if (nim != null && nim.isNotEmpty && !roleKey.contains(nim)) {
                  roleKey = '$roleKey-$nim';
                }

                // Format label to include NIM if present, e.g. "Mahasiswa (201FK04002)"
                var label =
                    map['label']?.toString() ?? map['name']?.toString() ?? '';
                if (label.isEmpty) {
                  label =
                      roleKey.contains('-') ? roleKey.split('-')[0] : roleKey;
                  // Capitalize first letter
                  if (label.isNotEmpty) {
                    label = label[0] + label.substring(1);
                  }
                }
                if (nim != null && nim.isNotEmpty && !label.contains(nim)) {
                  label = '$label ($nim)';
                }

                // Format description dynamically if empty
                var desc =
                    map['description']?.toString() ??
                    map['desc']?.toString() ??
                    '';
                if (desc.isEmpty) {
                  final prodiVal =
                      map['prodi']?.toString() ??
                      map['ProgramStudi']?.toString() ??
                      map['program_studi']?.toString() ??
                      '';
                  final kampusVal =
                      map['kampus']?.toString() ??
                      map['Kampus']?.toString() ??
                      '';
                  if (prodiVal.isNotEmpty && kampusVal.isNotEmpty) {
                    desc = 'Prodi $prodiVal ($kampusVal)';
                  } else if (prodiVal.isNotEmpty) {
                    desc = 'Prodi $prodiVal';
                  } else if (kampusVal.isNotEmpty) {
                    desc = kampusVal;
                  }
                }

                // Differentiate icons and colors based on role keys if not explicitly provided
                var iconName = map['icon']?.toString() ?? '';
                var colorStr = map['color']?.toString() ?? '';

                final rKeyLower = roleKey.toLowerCase();
                if (iconName.isEmpty || iconName == 'user') {
                  if (rKeyLower.contains('student') ||
                      rKeyLower.contains('mahasiswa')) {
                    iconName = 'graduation-cap';
                    colorStr =
                        colorStr.isEmpty ? '#002068' : colorStr; // BKU Blue
                  } else if (rKeyLower.contains('mentor')) {
                    iconName = 'users';
                    colorStr = colorStr.isEmpty ? '#10B981' : colorStr; // Green
                  } else if (rKeyLower.contains('health') ||
                      rKeyLower.contains('nakes') ||
                      rKeyLower.contains('tk') ||
                      rKeyLower.contains('kesehatan')) {
                    iconName = 'heart-pulse';
                    colorStr = colorStr.isEmpty ? '#EF4444' : colorStr; // Red
                  } else if (rKeyLower.contains('psikolog') ||
                      rKeyLower.contains('psychologist') ||
                      rKeyLower.contains('brain')) {
                    iconName = 'brain';
                    colorStr =
                        colorStr.isEmpty ? '#8B5CF6' : colorStr; // Purple
                  } else if (rKeyLower.contains('ormawa')) {
                    iconName = 'building-2';
                    colorStr = colorStr.isEmpty ? '#F59E0B' : colorStr; // Amber
                  } else {
                    iconName = 'user';
                    colorStr = colorStr.isEmpty ? '#2563EB' : colorStr; // Blue
                  }
                } else {
                  colorStr = colorStr.isEmpty ? '#2563EB' : colorStr;
                }

                map['role'] = roleKey;
                map['label'] = label;
                map['description'] = desc;
                map['icon'] = iconName;
                map['color'] = colorStr;
                parsedRoles.add(map);
              } else if (r != null) {
                parsedRoles.add({
                  'role': r.toString(),
                  'label': r.toString(),
                  'description': '',
                  'icon': 'user',
                  'color': '#2563EB',
                });
              }
            }
          }

          return LoginResult(
            success: true,
            requiresRoleSelection: true,
            tempToken:
                data['temp_token'] ??
                response.data['temp_token'] ??
                data['access_token'],
            roles: parsedRoles.isNotEmpty ? parsedRoles : rolesList,
          );
        }

        _token = data['access_token'];
        _userData =
            data; // Store entire data object including user and mRahasiswa

        // Initialize PermissionService with permissions from login response
        final userObj = _userData!['user'] ?? _userData!;
        final perms = userObj['permissions'];
        if (perms is List) {
          PermissionService().setPermissions(
            perms.map((e) => e.toString()).toList(),
          );
        }

        final roleStr =
            userObj['role']?.toString().toLowerCase().trim() ?? 'guest';
        if (roleStr.contains('mahasiswa') || roleStr.contains('student')) {
          _currentRole = UserRole.student;
        } else if (roleStr.contains('ormawa')) {
          _currentRole = UserRole.ormawa;
        } else if (roleStr.contains('psikolog') ||
            roleStr.contains('psychologist')) {
          _currentRole = UserRole.psychologist;
        } else if (roleStr.contains('tenaga_kesehatan') ||
            roleStr.contains('tenagakes') ||
            roleStr.contains('nakes') ||
            roleStr.contains('tk')) {
          _currentRole = UserRole.tenagaKesehatan;
        } else if (roleStr.contains('mentor') ||
            roleStr.contains('mentor_kencana')) {
          _currentRole = UserRole.mentorKencana;
        } else {
          _currentRole = UserRole.guest;
        }

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);
        await prefs.setString('user_data', jsonEncode(_userData));
        await prefs.setString('user_role', roleStr);
        await SecureStorageService().setToken(_token!);
        await SecureStorageService().setUserData(jsonEncode(_userData));
        _loadCachedStudentAvatar(prefs);

        return LoginResult(success: true);
      }
      return LoginResult(success: false, message: response.data['message']);
    } on DioException {
      rethrow;
    } catch (e) {
      return LoginResult(success: false, message: ErrorHandler.getMessage(e));
    }
  }

  Future<bool> loginSelectRole(String tempToken, String selectedRole) async {
    String roleToSend = selectedRole;
    String? chosenNim;

    if (selectedRole.contains('-')) {
      final parts = selectedRole.split('-');
      roleToSend = parts[0];
      chosenNim = parts[1];
    } else {
      // Check if selectedRole itself is a NIM
      final regex = RegExp(
        r'^([A-Z]{1,3}\d{5,8}|\d{10})$',
        caseSensitive: false,
      );
      if (regex.hasMatch(selectedRole)) {
        chosenNim = selectedRole;
        roleToSend = 'student'; // Fallback role for raw student NIMs
      }
    }

    try {
      final payload = <String, dynamic>{
        'temp_token': tempToken,
        'selected_role': roleToSend,
      };
      if (chosenNim != null) {
        payload['selected_nim'] = chosenNim;
      }

      final response = await ApiClient().client.post(
        '/auth/login/select-role',
        data: payload,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        _token = data['access_token'];
        _userData =
            data; // Store entire data object including user and mahasiswa

        // Forcefully overwrite chosen NIM in local _userData cache if present
        if (chosenNim != null && _userData != null) {
          _userData = Map<String, dynamic>.from(_userData!);
          if (_userData!['mahasiswa'] == null) {
            _userData!['mahasiswa'] = {};
          }
          if (_userData!['mahasiswa'] is Map) {
            final mahasiswaMap = Map<String, dynamic>.from(
              _userData!['mahasiswa'],
            );
            mahasiswaMap['nim'] = chosenNim;
            mahasiswaMap['NIM'] = chosenNim;
            _userData!['mahasiswa'] = mahasiswaMap;
          }
          _userData!['nim'] = chosenNim;
          _userData!['NIM'] = chosenNim;
        }

        // Initialize PermissionService with permissions from login response
        final userObj = _userData!['user'] ?? _userData!;
        final perms = userObj['permissions'];
        if (perms is List) {
          PermissionService().setPermissions(
            perms.map((e) => e.toString()).toList(),
          );
        }

        final roleStr =
            userObj['role']?.toString().toLowerCase().trim() ?? 'guest';
        if (roleStr.contains('mahasiswa') || roleStr.contains('student')) {
          _currentRole = UserRole.student;
        } else if (roleStr.contains('ormawa')) {
          _currentRole = UserRole.ormawa;
        } else if (roleStr.contains('psikolog') ||
            roleStr.contains('psychologist')) {
          _currentRole = UserRole.psychologist;
        } else if (roleStr.contains('tenaga_kesehatan') ||
            roleStr.contains('tenagakes') ||
            roleStr.contains('nakes') ||
            roleStr.contains('tk')) {
          _currentRole = UserRole.tenagaKesehatan;
        } else if (roleStr.contains('mentor') ||
            roleStr.contains('mentor_kencana')) {
          _currentRole = UserRole.mentorKencana;
        } else {
          _currentRole = UserRole.guest;
        }

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);
        await prefs.setString('user_data', jsonEncode(_userData));
        await prefs.setString('user_role', roleStr);
        await SecureStorageService().setToken(_token!);
        await SecureStorageService().setUserData(jsonEncode(_userData));
        _loadCachedStudentAvatar(prefs);

        return true;
      }
      return false;
    } on DioException catch (e) {
      if (e.response != null) {
      }
      rethrow;
    } catch (_) {
      rethrow;
    }
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    final userDataStr = prefs.getString('user_data');
    if (userDataStr != null) {
      _userData = jsonDecode(userDataStr);
      _loadCachedStudentAvatar(prefs);

      // _userData contains: { access_token, user: { id, email, role, ... } }
      // or in some cases the raw user object
      String? roleStr = prefs.getString('user_role')?.toLowerCase();
      if (roleStr == null || roleStr.trim().isEmpty) {
        if (_userData!['user'] != null && _userData!['user']['role'] != null) {
          roleStr = _userData!['user']['role']?.toString().toLowerCase();
        } else if (_userData!['role'] != null) {
          roleStr = _userData!['role']?.toString().toLowerCase();
        }

        // Also try 'data' wrapper (some responses wrap it)
        if (roleStr == null && _userData!['data'] != null) {
          final data = _userData!['data'];
          if (data['user'] != null && data['user']['role'] != null) {
            roleStr = data['user']['role']?.toString().toLowerCase();
          } else if (data['role'] != null) {
            roleStr = data['role']?.toString().toLowerCase();
          }
        }
      }

      roleStr ??= 'guest';

      // Initialize PermissionService with permissions from stored user data
      final userData = _userData!['user'] ?? _userData!;
      final perms = userData['permissions'];
      if (perms is List) {
        PermissionService().setPermissions(
          perms.map((e) => e.toString()).toList(),
        );
      }

      if (roleStr.contains('mahasiswa') || roleStr.contains('student')) {
        _currentRole = UserRole.student;
      } else if (roleStr.contains('ormawa')) {
        _currentRole = UserRole.ormawa;
      } else if (roleStr.contains('psikolog') ||
          roleStr.contains('psychologist')) {
        _currentRole = UserRole.psychologist;
      } else if (roleStr.contains('tenaga_kesehatan') ||
          roleStr.contains('tenagakes') ||
          roleStr.contains('nakes') ||
          roleStr.contains('tk')) {
        _currentRole = UserRole.tenagaKesehatan;
      } else if (roleStr.contains('mentor') ||
          roleStr.contains('mentor_kencana')) {
        _currentRole = UserRole.mentorKencana;
      } else {
        _currentRole = UserRole.guest;
      }
    } else {
      // If user_data is null, ensure state is reset completely
      _currentRole = UserRole.guest;
      _token = null;
      _userData = null;
    }
  }

  Future<void> logout() async {
    _currentRole = UserRole.guest;
    _token = null;
    _userData = null;
    // Clear permissions from PermissionService
    PermissionService().clear();
    // Clear notification state to prevent "jebol" notifications between accounts
    NotificationService().clearState();

    // Clear biometric credentials to prevent ghost login
    final bioService = BiometricService();
    await bioService.clearCredentials();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await SecureStorageService().deleteToken();
    await SecureStorageService().deleteUserData();
  }

  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      final response = await ApiClient().client.put(
        '/profil/change-password',
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
      return {
        'success': response.data['success'] == true,
        'message': response.data['message'] ?? 'Berhasil mengubah kata sandi',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message':
            e.response?.data['message'] ??
            'Gagal mengubah kata sandi. Periksa koneksi Anda.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan sistem'};
    }
  }

  Future<bool> requestOtp(String emailOrNim) async {
    try {
      final response = await ApiClient().client.post(
        '/auth/forgot-password',
        data: {'identifier': emailOrNim},
      );
      if (response.data is Map && response.data['success'] == false) {
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> verifyOtp(String emailOrNim, String otp) async {
    try {
      final response = await ApiClient().client.post(
        '/auth/verify-otp',
        data: {'identifier': emailOrNim, 'otp': otp},
      );
      if (response.data is Map && response.data['status'] == 'success') {
        return response.data['data']['reset_token'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> resetPassword(
    String resetToken,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await ApiClient().client.post(
        '/auth/reset-password',
        data: {
          'reset_token': resetToken,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      if (response.data is Map && response.data['status'] == 'success') {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String? get token => _token;
  Map<String, dynamic>? get userData => _userData;

  Future<void> updateUserData(Map<String, dynamic> data) async {
    _userData = data;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(data));
    _loadCachedStudentAvatar(prefs);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> fetchMe() async {
    try {
      final response = await ApiClient().client.get('/auth/me');
      final data = response.data['data'] ?? response.data;
      if (data != null) {
        if (_userData != null) {
          final Map<String, dynamic> merged = Map<String, dynamic>.from(
            _userData!,
          );
          merged['user'] = data['user'] ?? data;
          _userData = merged;
        } else {
          _userData = data;
        }

        final userMap = data['user'] ?? data;
        String? studentFoto =
            userMap['avatar_url']?.toString() ??
            userMap['avatar']?.toString() ??
            data['avatar_url']?.toString() ??
            data['avatar']?.toString();

        final lowerFoto = studentFoto?.toLowerCase() ?? '';
        final isFotoPlaceholder =
            lowerFoto.contains('logo') ||
            lowerFoto.contains('default') ||
            lowerFoto.contains('ui-avatars.com');

        if (studentFoto == null || studentFoto.isEmpty || isFotoPlaceholder) {
          final mahasiswaMap =
              data['mahasiswa'] ??
              (_userData != null ? _userData!['mahasiswa'] : null);
          if (mahasiswaMap is Map) {
            final mFoto =
                mahasiswaMap['foto']?.toString() ??
                mahasiswaMap['foto_url']?.toString() ??
                mahasiswaMap['FotoURL']?.toString() ??
                mahasiswaMap['avatar']?.toString() ??
                mahasiswaMap['avatar_url']?.toString();
            if (mFoto != null && mFoto.isNotEmpty) {
              studentFoto = mFoto;
            }
          }
        }

        if (studentFoto != _studentAvatarUrl) {
          ApiGate.refreshAvatarCache();
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(_userData));

        final email =
            userMap['email']?.toString() ?? data['email']?.toString() ?? '';
        if (email.isNotEmpty) {
          if (studentFoto != null && studentFoto.trim().isNotEmpty) {
            final lower = studentFoto.toLowerCase();
            final isPlaceholder =
                lower.contains('logo') ||
                lower.contains('default') ||
                lower.contains('ui-avatars.com');
            if (!isPlaceholder) {
              _studentAvatarUrl = studentFoto;
              await prefs.setString('student_avatar_$email', studentFoto);
            } else {
              _studentAvatarUrl = null;
              await prefs.remove('student_avatar_$email');
            }
          } else {
            _studentAvatarUrl = null;
            await prefs.remove('student_avatar_$email');
          }
        }

        _loadCachedStudentAvatar(prefs);
        notifyListeners();
        return _userData;
      }
    } catch (_) {
      // ignore: data may not be cached, return null
    }
    return null;
  }

  /// Get permissions from login response
  /// This is the source of truth for permissions in mobile
  List<String> get permissions {
    final data = _userData?['user'] ?? _userData;
    if (data == null) return [];
    final perms = data['permissions'];
    if (perms is List) {
      return perms.map((e) => e.toString()).toList();
    }
    return [];
  }

  /// Get role display name (e.g., "Sekretaris", "Bendahara")
  String? get roleDisplay {
    final data = _userData?['user'] ?? _userData;
    if (data == null) return null;
    return data['role_display']?.toString();
  }

  String? get ormawaName {
    final data = _userData?['user'] ?? _userData;
    if (data == null) return null;
    return data['ormawa_name']?.toString() ??
        data['ormawa_singkatan']?.toString() ??
        data['ormawa']?['singkatan']?.toString() ??
        data['ormawa']?['Singkatan']?.toString() ??
        data['ormawa']?['nama']?.toString() ??
        data['ormawa']?['Nama']?.toString();
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    final perms = permissions;
    // Wildcard = full access
    if (perms.contains('*')) return true;
    return perms.contains(permission);
  }

  /// Check if user has ALL of the specified permissions
  bool hasAllPermissions(List<String> requiredPerms) {
    final perms = permissions;
    if (perms.contains('*')) return true;
    return requiredPerms.every((p) => perms.contains(p));
  }

  /// Check if user has ANY of the specified permissions
  bool hasAnyPermission(List<String> anyPerms) {
    final perms = permissions;
    if (perms.contains('*')) return true;
    return anyPerms.any((p) => perms.contains(p));
  }

  /// Extract a student NIM pattern from role data maps
  String? _extractNim(Map map) {
    if (map['nim'] != null && map['nim'].toString().isNotEmpty) {
      return map['nim'].toString();
    }
    if (map['NIM'] != null && map['NIM'].toString().isNotEmpty) {
      return map['NIM'].toString();
    }
    // Try to find a NIM pattern in other fields (e.g. description, label, role)
    final fields = [
      map['description']?.toString() ?? '',
      map['label']?.toString() ?? '',
      map['role']?.toString() ?? '',
      map['name']?.toString() ?? '',
    ];
    // Pattern: 2-3 letters followed by 5-8 digits (e.g. AK116001, FS02047, 251FS02047) or 10 digits
    final regex = RegExp(
      r'\b([A-Z]{1,3}\d{5,8}|\d{10})\b',
      caseSensitive: false,
    );
    for (final f in fields) {
      final match = regex.firstMatch(f);
      if (match != null) {
        return match.group(1);
      }
    }
    return null;
  }

  void _loadCachedStudentAvatar(SharedPreferences prefs) {
    final email =
        _userData?['user']?['email']?.toString() ??
        _userData?['email']?.toString() ??
        '';
    if (email.isNotEmpty) {
      _studentAvatarUrl = prefs.getString('student_avatar_$email');
      if (_userData != null) {
        final userMap = _userData!['user'] ?? _userData!;
        final userAvatar =
            userMap['avatar_url']?.toString() ??
            userMap['avatar']?.toString() ??
            _userData!['avatar_url']?.toString() ??
            _userData!['avatar']?.toString();
        if (userAvatar != null && userAvatar.trim().isNotEmpty) {
          final lower = userAvatar.toLowerCase();
          final isPlaceholder =
              lower.contains('logo') ||
              lower.contains('default') ||
              lower.contains('ui-avatars.com');
          if (!isPlaceholder) {
            _studentAvatarUrl = userAvatar;
            prefs.setString('student_avatar_$email', userAvatar);
            return;
          }
        }

        final m =
            _userData!['mahasiswa'] ??
            (_userData!['data'] != null
                ? _userData!['data']['mahasiswa']
                : null);
        if (m is Map) {
          final mFoto =
              m['foto']?.toString() ??
              m['avatar']?.toString() ??
              m['avatar_url']?.toString() ??
              m['foto_url']?.toString() ??
              m['FotoURL']?.toString();
          if (mFoto != null && mFoto.trim().isNotEmpty) {
            final lower = mFoto.toLowerCase();
            final isPlaceholder =
                lower.contains('logo') ||
                lower.contains('default') ||
                lower.contains('ui-avatars.com');
            if (!isPlaceholder) {
              _studentAvatarUrl = mFoto;
              prefs.setString('student_avatar_$email', mFoto);
            }
          }
        }
      }
    } else {
      _studentAvatarUrl = null;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      final response = await ApiClient().client.post(
        '/auth/profile/upload-avatar',
        data: formData,
      );

      final url =
          response.data['url'] ??
          response.data['foto_url'] ??
          response.data['file_url'] ??
          '';

      if (url.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final formattedUrl =
            url.contains('?') ? '$url&v=$timestamp' : '$url?v=$timestamp';
        _studentAvatarUrl = formattedUrl;

        if (_userData != null) {
          final Map<String, dynamic> updatedUserData =
              Map<String, dynamic>.from(_userData!);

          updatedUserData['foto'] = formattedUrl;
          updatedUserData['avatar'] = formattedUrl;
          updatedUserData['avatar_url'] = formattedUrl;
          updatedUserData['foto_url'] = formattedUrl;
          updatedUserData['FotoURL'] = formattedUrl;

          if (updatedUserData['user'] is Map) {
            final Map<String, dynamic> userMap = Map<String, dynamic>.from(
              updatedUserData['user'],
            );
            userMap['foto'] = formattedUrl;
            userMap['avatar'] = formattedUrl;
            userMap['avatar_url'] = formattedUrl;
            userMap['foto_url'] = formattedUrl;
            userMap['FotoURL'] = formattedUrl;
            updatedUserData['user'] = userMap;
          }

          if (updatedUserData['mahasiswa'] is Map) {
            final Map<String, dynamic> m = Map<String, dynamic>.from(
              updatedUserData['mahasiswa'],
            );
            m['foto'] = formattedUrl;
            m['avatar'] = formattedUrl;
            m['avatar_url'] = formattedUrl;
            m['foto_url'] = formattedUrl;
            m['FotoURL'] = formattedUrl;
            updatedUserData['mahasiswa'] = m;
          }

          _userData = updatedUserData;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_data', jsonEncode(_userData));
        }
        ApiGate.refreshAvatarCache();
        notifyListeners();
      }
      return url;
    } catch (e) {
      rethrow;
    }
  }
}
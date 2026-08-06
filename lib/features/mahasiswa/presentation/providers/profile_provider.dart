import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

class ProfileProvider extends ChangeNotifier {
  final StudentRepository _repository;

  ProfileProvider({required StudentRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String name = '';
  String nim = '';
  String prodi = '';
  String fakultas = '';
  String email = '';
  String phone = '';
  String birthPlaceDate = '';
  String gender = '';
  String address = '';
  String intakeYear = '';
  int semester = 0;
  double ipk = 0.0;
  int totalSks = 0;
  String? fotoUrl;
  
  Map<String, dynamic> rawProfileData = {};

  bool emailNotif = true;
  bool pushNotif = true;
  bool inAppNotif = true;

  bool get hasProfileData => name.isNotEmpty && nim.isNotEmpty;

  void updateNotifPreferences({
    bool? email,
    bool? push,
    bool? inApp,
  }) {
    if (email != null) emailNotif = email;
    if (push != null) pushNotif = push;
    if (inApp != null) inAppNotif = inApp;
    notifyListeners();
  }

  dynamic _extractValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data[key] != null && data[key].toString().trim().isNotEmpty) {
        return data[key];
      }
    }
    final containers = ['mahasiswa', 'akademik', 'data', 'user', 'profile', 'Pengguna', 'pengguna'];
    for (final c in containers) {
      if (data[c] != null && data[c] is Map) {
        final map = data[c] as Map;
        for (final key in keys) {
          if (map[key] != null && map[key].toString().trim().isNotEmpty) {
            return map[key];
          }
        }
      }
    }
    return null;
  }

  Future<void> fetchProfile() async {
    try {
      final profile = await _repository.getProfile();
      rawProfileData = profile;
      
      final m = profile['mahasiswa'] ?? profile['data']?['mahasiswa'] ?? profile;
      name = m['nama']?.toString() ?? m['Nama']?.toString() ?? name;
      nim = m['nim']?.toString() ?? m['NIM']?.toString() ?? nim;

      final prodiObj = m['ProgramStudi'] ?? m['program_studi'] ?? m['prodi_detail'] ?? m['ProdiDetail'];
      if (prodiObj != null && prodiObj is Map) {
        final jenjang = (prodiObj['jenjang'] ?? prodiObj['Jenjang'] ?? '').toString().trim();
        final namaObj = (prodiObj['nama'] ?? prodiObj['Nama'] ?? '').toString().trim();
        if (jenjang.isNotEmpty && namaObj.toLowerCase().startsWith(jenjang.toLowerCase())) {
          prodi = namaObj;
        } else {
          prodi = "$jenjang $namaObj".trim();
        }
      } else if (prodiObj != null && prodiObj is String) {
        prodi = prodiObj;
      } else {
        prodi = m['prodi_nama']?.toString() ?? m['prodi']?.toString() ?? m['Prodi']?.toString() ?? prodi;
      }

      final fakObj = m['Fakultas'] ?? m['fakultas'];
      if (fakObj != null) {
        fakultas = fakObj['nama']?.toString() ?? fakObj['Nama']?.toString() ?? fakultas;
      } else {
        fakultas = m['fakultas']?.toString() ?? fakultas;
      }

      email = _extractValue(profile, ['email_kampus', 'EmailKampus', 'email_institusi', 'EmailInstitusi', 'email_personal', 'EmailPersonal', 'email', 'Email'])?.toString() ?? email;
      phone = _extractValue(profile, ['no_hp', 'NoHP', 'no_wa', 'NoWA', 'telepon', 'Telepon', 'whatsapp', 'WhatsApp', 'phone', 'Phone'])?.toString() ?? phone;
      address = _extractValue(profile, ['alamat_domisili', 'AlamatDomisili', 'alamat', 'Alamat', 'address', 'Address'])?.toString() ?? address;
      gender = _extractValue(profile, ['jenis_kelamin', 'JenisKelamin', 'gender', 'Gender'])?.toString() ?? gender;
      
      final birthPlace = _extractValue(profile, ['tempat_lahir', 'TempatLahir'])?.toString();
      final birthDate = _extractValue(profile, ['tanggal_lahir', 'TanggalLahir'])?.toString();
      if (birthPlace != null && birthDate != null) {
        birthPlaceDate = '$birthPlace, $birthDate';
      }

      semester = int.tryParse(_extractValue(profile, ['semester_sekarang', 'SemesterSekarang', 'smt', 'Smt', 'semester_aktif', 'SemesterAktif', 'semester', 'Semester'])?.toString() ?? '') ?? semester;
      ipk = double.tryParse(_extractValue(profile, ['ipk', 'IPK'])?.toString() ?? '') ?? ipk;
      totalSks = int.tryParse(_extractValue(profile, ['total_sks', 'TotalSKS', 'sks_lulus', 'SKSLulus'])?.toString() ?? '') ?? totalSks;
      intakeYear = _extractValue(profile, ['angkatan', 'Angkatan', 'tahun_masuk', 'TahunMasuk'])?.toString() ?? intakeYear;

      final p = profile['profile'] ?? profile['data']?['profile'] ?? profile;
      fotoUrl = p['foto']?.toString() ?? p['Foto']?.toString() ?? fotoUrl;
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await fetchProfile();

      // Sync from AuthService as fallback
      final userData = AuthService().userData;
      if (userData != null) {
        final m = userData['mahasiswa'] ?? userData['data']?['mahasiswa'] ?? userData;
        name = m['nama']?.toString() ?? m['Nama']?.toString() ?? name;
        nim = m['nim']?.toString() ?? m['NIM']?.toString() ?? nim;
        
        // Similarly extract others to fallback if empty
        if (prodi.isEmpty) prodi = m['prodi_nama']?.toString() ?? prodi;
        if (fakultas.isEmpty) fakultas = m['fakultas']?.toString() ?? fakultas;
        
        final syncEmail = _extractValue(userData, ['email_kampus', 'email']);
        if (syncEmail != null && syncEmail.toString().trim().isNotEmpty) email = syncEmail.toString().trim();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await _repository.updateProfile(data);
      await fetchProfile();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword, String confirmPassword) async {
    try {
      await _repository.changePassword(oldPassword, newPassword, confirmPassword);
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final newUrl = await _repository.uploadAvatar(filePath);
      fotoUrl = newUrl;
      notifyListeners();
      return newUrl;
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }
}

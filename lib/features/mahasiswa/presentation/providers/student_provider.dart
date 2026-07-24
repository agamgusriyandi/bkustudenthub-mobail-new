import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/achievement.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/counseling_session.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/pkkmb_event.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_news.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/faculty_progress.dart';
import 'package:bkuhub_mobile/features/mahasiswa/data/models/scholarship_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_booking.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/insurance_claim.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository? _repository;

  dynamic _extractValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      if (data[key] != null && data[key].toString().trim().isNotEmpty) {
        return data[key];
      }
    }
    final containers = [
      'mahasiswa',
      'akademik',
      'data',
      'user',
      'profile',
      'Pengguna',
      'pengguna',
    ];
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

  StudentProvider({StudentRepository? repository}) : _repository = repository;

  // Profile Data - Will be populated from API via loadAllData()
  // Default values shown while loading
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
  
  // Full Raw Profile Data
  Map<String, dynamic> rawProfileData = {};

  // Notification Preferences
  bool emailNotif = true;
  bool pushNotif = true;
  bool inAppNotif = true;

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

  // Check if profile data has been loaded from API
  bool get hasProfileData => name.isNotEmpty && nim.isNotEmpty;

  // Data Lists
  List<Mission> _missions = [];
  List<Achievement> _achievements = [];
  List<Scholarship> _scholarships = [];
  List<CounselingSession> _counselingSessions = [];
  List<Aspiration> _aspirations = [];
  List<HealthRecord> _healthRecords = [];
  List<OrganizationHistory> _organizationHistory = [];
  List<Map<String, dynamic>> _iuranList = [];
  final List<PkkmbEvent> _pkkmbEvents = [];
  List<CampusNews> _campusNews = [];
  List<CampusEventSchedule> _campusEvents = [];
  List<FacultyProgress> _facultyProgress = [];
  Map<String, dynamic> _dashboardStats = {};

  List<HealthWorker> _healthWorkers = [];
  List<HealthSchedule> _healthSchedules = [];
  List<HealthBooking> _healthBookings = [];
  List<InsuranceClaim> _insuranceClaims = [];

  // Psychologist data - populated from API
  List<Psychologist> _availablePsychologists = [];

  // Schedule data - populated from API
  final List<Map<String, dynamic>> _schedules = [];

  // Local Rescheduled Bookings Cache (Workaround for buggy backend)
  Map<int, int> _localRescheduledBookings = {};

  Future<void> _loadRescheduledBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('local_rescheduled_bookings');
      if (jsonStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        _localRescheduledBookings = decoded.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
      }
    } catch (e) {
      debugPrint('Error loading local rescheduled bookings: $e');
    }
  }

  Future<void> _saveRescheduledBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _localRescheduledBookings.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
      await prefs.setString('local_rescheduled_bookings', encoded);
    } catch (e) {
      debugPrint('Error saving local rescheduled bookings: $e');
    }
  }

  void _applyLocalRescheduledBookings() {
    if (_localRescheduledBookings.isEmpty) return;

    // Copy the lists to avoid modifying unmodifiable lists if any
    final updatedBookings = List<HealthBooking>.from(_healthBookings);
    final updatedSchedules = List<HealthSchedule>.from(_healthSchedules);
    bool changed = false;

    // Use a copy of keys to avoid concurrent modification during iteration
    final keys = _localRescheduledBookings.keys.toList();
    for (final bookingId in keys) {
      final newScheduleId = _localRescheduledBookings[bookingId]!;
      final idx = updatedBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        // Otherwise, override the schedule in memory
        final newSIdx = updatedSchedules.indexWhere(
          (s) => s.id == newScheduleId,
        );
        if (newSIdx != -1) {
          final newSchedule = updatedSchedules[newSIdx];

          updatedBookings[idx] = HealthBooking(
            id: updatedBookings[idx].id,
            jadwalId: newScheduleId,
            jadwal: newSchedule,
            mahasiswaId: updatedBookings[idx].mahasiswaId,
            keluhan: updatedBookings[idx].keluhan,
            status: updatedBookings[idx].status,
            alasanPenolakan: updatedBookings[idx].alasanPenolakan,
          );

          // Workaround schedule capacities (strictly for visual feedback)
          final oldScheduleId = updatedBookings[idx].jadwalId;
          final oldSIdx = updatedSchedules.indexWhere(
            (s) => s.id == oldScheduleId,
          );
          if (oldSIdx != -1) {
            final os = updatedSchedules[oldSIdx];
            updatedSchedules[oldSIdx] = HealthSchedule(
              id: os.id,
              tenagaKesId: os.tenagaKesId,
              tenagaKes: os.tenagaKes,
              tanggal: os.tanggal,
              jamMulai: os.jamMulai,
              jamSelesai: os.jamSelesai,
              kuota: os.kuota,
              sisaKuota: os.sisaKuota + 1,
              lokasi: os.lokasi,
              tipeLayanan: os.tipeLayanan,
              catatan: os.catatan,
            );
          }

          final ns = updatedSchedules[newSIdx];
          updatedSchedules[newSIdx] = HealthSchedule(
            id: ns.id,
            tenagaKesId: ns.tenagaKesId,
            tenagaKes: ns.tenagaKes,
            tanggal: ns.tanggal,
            jamMulai: ns.jamMulai,
            jamSelesai: ns.jamSelesai,
            kuota: ns.kuota,
            sisaKuota: ns.sisaKuota - 1,
            lokasi: ns.lokasi,
            tipeLayanan: ns.tipeLayanan,
            catatan: ns.catatan,
          );

          changed = true;
        }
      }
    }

    if (changed) {
      _healthBookings = updatedBookings;
      _healthSchedules = updatedSchedules;
    }
  }

  // Loading States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Getters
  List<Mission> get missions => _missions;
  List<Achievement> get achievements => _achievements;
  List<Scholarship> get scholarships => _scholarships;
  List<CounselingSession> get counselingSessions => _counselingSessions;
  List<Aspiration> get aspirations => _aspirations;
  List<HealthRecord> get healthRecords => _healthRecords;
  List<Map<String, dynamic>> _rujukans = [];
  List<Map<String, dynamic>> get rujukans => _rujukans;
  List<HealthWorker> get healthWorkers => _healthWorkers;
  List<HealthSchedule> get healthSchedules => _healthSchedules;
  List<HealthBooking> get healthBookings => _healthBookings;
  List<InsuranceClaim> get insuranceClaims => _insuranceClaims;
  List<OrganizationHistory> get organizationHistory => _organizationHistory;
  List<Map<String, dynamic>> get iuranList => _iuranList;
  List<Psychologist> get availablePsychologists => _availablePsychologists;
  List<PkkmbEvent> get pkkmbEvents => _pkkmbEvents;
  List<CampusNews> get campusNews => _campusNews;
  List<CampusEventSchedule> get campusEvents => _campusEvents;
  List<FacultyProgress> get facultyProgress => _facultyProgress;
  List<Map<String, dynamic>> get schedules => _schedules;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  HealthRecord? get latestHealthRecord =>
      _healthRecords.isNotEmpty ? _healthRecords.first : null;

  // Logic Getters
  double get totalScore {
    final quizzes = _missions.where((m) => m.type == 'Quiz').toList();
    if (quizzes.isEmpty) return 0;
    int total = quizzes.fold(0, (sum, q) => sum + q.score);
    return total / quizzes.length;
  }

  bool get isEligibleForCertificate => totalScore >= 75;
  int get pendingMissionsCount => _missions.where((m) => !m.isCompleted).length;
  int get completedMissionsCount =>
      _missions.where((m) => m.isCompleted).length;
  double get missionProgress =>
      _missions.isEmpty ? 0 : completedMissionsCount / _missions.length;
  int get totalAchievements => _achievements.length;
  int get validatedAchievements =>
      _achievements
          .where(
            (a) =>
                a.status == 'Validated' ||
                a.status == 'Diverifikasi' ||
                a.status == 'Valid',
          )
          .length;
  int get pendingAchievements =>
      _achievements
          .where((a) => a.status == 'Pending' || a.status == 'Menunggu')
          .length;
  int get syncedAchievements =>
      _achievements
          .where((a) => a.isSynced || a.status == 'Diverifikasi')
          .length;
  int get totalAspirations => _aspirations.length;
  int get pendingAspirations =>
      _aspirations
          .where((a) => a.status == 'Pending' || a.status == 'In Progress')
          .length;
  int get resolvedAspirations =>
      _aspirations.where((a) => a.status == 'Resolved').length;

  // Data Loading
  Future<void> loadAllData() async {
    if (_repository == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _loadRescheduledBookings();
      // Refresh profile data from backend to ensure IPK and other fields are up to date
      await fetchProfile();

      // Sync profile data from session (needed for API calls fallback)
      final userData = AuthService().userData;
      if (userData != null) {
        final m =
            userData['mahasiswa'] ?? userData['data']?['mahasiswa'] ?? userData;
        name = m['nama']?.toString() ?? m['Nama']?.toString() ?? name;
        nim = m['nim']?.toString() ?? m['NIM']?.toString() ?? nim;

        final prodiObj =
            m['ProgramStudi'] ??
            m['program_studi'] ??
            m['prodi_detail'] ??
            m['ProdiDetail'];
        if (prodiObj != null && prodiObj is Map) {
          final jenjang =
              (prodiObj['jenjang'] ?? prodiObj['Jenjang'] ?? '')
                  .toString()
                  .trim();
          final nama =
              (prodiObj['nama'] ?? prodiObj['Nama'] ?? '').toString().trim();
          if (jenjang.isNotEmpty &&
              nama.toLowerCase().startsWith(jenjang.toLowerCase())) {
            prodi = nama;
          } else {
            prodi = "$jenjang $nama".trim();
          }
        } else if (prodiObj != null && prodiObj is String) {
          prodi = prodiObj;
        } else {
          prodi =
              m['prodi_nama']?.toString() ??
              m['prodi']?.toString() ??
              m['Prodi']?.toString() ??
              prodi;
        }

        final fakObj = m['Fakultas'] ?? m['fakultas'];
        if (fakObj != null) {
          fakultas =
              fakObj['nama']?.toString() ??
              fakObj['Nama']?.toString() ??
              fakultas;
        } else {
          fakultas = m['fakultas']?.toString() ?? fakultas;
        }

        final syncEmail =
            _extractValue(userData, [
              'email_kampus',
              'EmailKampus',
              'email_institusi',
              'EmailInstitusi',
              'email_personal',
              'EmailPersonal',
              'email',
              'Email',
            ])?.toString();
        if (syncEmail != null && syncEmail.trim().isNotEmpty) {
          email = syncEmail.trim();
        }

        final syncPhone =
            _extractValue(userData, [
              'no_hp',
              'NoHP',
              'no_wa',
              'NoWA',
              'telepon',
              'Telepon',
              'whatsapp',
              'WhatsApp',
              'phone',
              'Phone',
            ])?.toString();
        if (syncPhone != null && syncPhone.trim().isNotEmpty) {
          phone = syncPhone.trim();
        }

        final syncAddress =
            _extractValue(userData, [
              'alamat_domisili',
              'AlamatDomisili',
              'alamat',
              'Alamat',
              'address',
              'Address',
            ])?.toString();
        if (syncAddress != null && syncAddress.trim().isNotEmpty) {
          address = syncAddress.trim();
        }
        gender =
            m['jenis_kelamin']?.toString() ??
            m['JenisKelamin']?.toString() ??
            gender;
        intakeYear =
            (m['tahun_masuk'] ?? m['TahunMasuk'] ?? intakeYear).toString();
        semester =
            int.tryParse(
              _extractValue(m, [
                    'semester_sekarang',
                    'SemesterSekarang',
                    'semester',
                    'Semester',
                  ])?.toString() ??
                  '',
            ) ??
            semester;

        // Deep extract IPK to catch 3.48 vs 0.00 bug
        ipk =
            double.tryParse(
              _extractValue(m, ['ipk', 'IPK', 'gpa', 'GPA'])?.toString() ?? '',
            ) ??
            0.0;

        totalSks =
            int.tryParse(
              _extractValue(m, [
                    'total_sks',
                    'TotalSKS',
                    'sks',
                    'SKS',
                  ])?.toString() ??
                  '',
            ) ??
            0;

        final tempatLahir =
            m['tempat_lahir']?.toString() ?? m['TempatLahir'] ?? '';
        final tanggalLahir =
            m['tanggal_lahir']?.toString() ?? m['TanggalLahir'] ?? '';
        if (tempatLahir.isNotEmpty && tanggalLahir.isNotEmpty) {
          birthPlaceDate = "$tempatLahir, ${tanggalLahir.split('T').first}";
        } else if (tempatLahir.isNotEmpty) {
          birthPlaceDate = tempatLahir;
        } else if (tanggalLahir.isNotEmpty) {
          birthPlaceDate = tanggalLahir.split('T').first;
        }

        String? extractedFoto;
        final mMap =
            userData['mahasiswa'] ??
            (userData['data'] != null ? userData['data']['mahasiswa'] : null);
        if (mMap is Map) {
          extractedFoto =
              mMap['foto']?.toString() ??
              mMap['avatar']?.toString() ??
              mMap['avatar_url']?.toString() ??
              mMap['foto_url']?.toString() ??
              mMap['FotoURL']?.toString();
        }
        if (extractedFoto == null || extractedFoto.isEmpty) {
          extractedFoto =
              userData['foto']?.toString() ??
              userData['foto_url']?.toString() ??
              userData['FotoURL']?.toString();
        }

        final userAvatar =
            userData['avatar_url']?.toString() ??
            userData['avatar']?.toString() ??
            (userData['user'] != null && userData['user'] is Map
                ? (userData['user']['avatar_url']?.toString() ??
                    userData['user']['avatar']?.toString())
                : null);
        if (userAvatar != null && userAvatar.isNotEmpty) {
          extractedFoto ??= userAvatar;
        }

        fotoUrl = extractedFoto ?? fotoUrl;

        if (fotoUrl != null &&
            fotoUrl!.isNotEmpty &&
            !fotoUrl!.startsWith('http')) {
          String base = ApiGate.baseUrl;
          if (base.endsWith('/api')) {
            base = base.substring(0, base.length - 4);
          }
          if (fotoUrl!.startsWith('/')) {
            fotoUrl = '$base$fotoUrl';
          } else {
            fotoUrl = '$base/$fotoUrl';
          }
        }

        if (fotoUrl == null || fotoUrl!.isEmpty) {
          final parsedNama = name.isNotEmpty ? name : 'Mahasiswa';
          fotoUrl =
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(parsedNama)}&background=003399&color=fff&size=128';
        }

        debugPrint("AVATAR LOADED FROM AUTH SERVICE: $fotoUrl");
        debugPrint("USER DATA FROM AUTH: $userData");

        final prefs = await SharedPreferences.getInstance();
        final userEmail =
            userData['email']?.toString() ??
            (userData['user'] != null && userData['user'] is Map
                ? userData['user']['email']?.toString()
                : null) ??
            '';
        final currentRole = AuthService().currentRole;
        if (currentRole == UserRole.student && userEmail.isNotEmpty) {
          final lower = fotoUrl?.toLowerCase() ?? '';
          final isPlaceholder =
              lower.contains('logo') ||
              lower.contains('default') ||
              lower.contains('ui-avatars.com');
          if (fotoUrl != null && fotoUrl!.isNotEmpty && !isPlaceholder) {
            await prefs.setString('student_avatar_$userEmail', fotoUrl!);
          } else {
            await prefs.remove('student_avatar_$userEmail');
          }
        }
        emailNotif =
            prefs.getBool('student_email_notif') ??
            (m['email_notif'] == true ||
                m['email_notif'] == 1 ||
                m['email_notif']?.toString() == 'true' ||
                m['email_notif'] == null);
        pushNotif =
            prefs.getBool('student_push_notif') ??
            (m['push_notif'] == true ||
                m['push_notif'] == 1 ||
                m['push_notif']?.toString() == 'true' ||
                m['push_notif'] == null);
        inAppNotif =
            prefs.getBool('student_in_app_notif') ??
            (m['in_app_notif'] == true ||
                m['in_app_notif'] == 1 ||
                m['in_app_notif']?.toString() == 'true' ||
                m['in_app_notif'] == null);
      }

      // Fetch all independent data in parallel for better performance
      final results = await Future.wait([
        _repository.getMissions(), // Missions
        _repository.getAchievements(), // Achievements
        _repository.getScholarships(), // Scholarships
        _repository.getCounselingSessions(), // Counseling sessions
        _repository
            .getPsychologists() // Psychologists (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error loading psychologists: $e');
              return <Psychologist>[];
            }),
        _repository
            .getFacultyStatistics() // Faculty statistics (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error loading faculty statistics: $e');
              return <FacultyProgress>[];
            }),
        _repository.getAspirations(), // Aspirations
        _repository.getHealthRecords(), // Health records
        _repository.getRujukans(), // Rujukans
        _repository
            .getHealthWorkers() // Health workers (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error loading health workers: $e');
              return <HealthWorker>[];
            }),
        _repository
            .getHealthSchedules() // Health schedules (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error loading health schedules: $e');
              return <HealthSchedule>[];
            }),
        _repository
            .getHealthBookings() // Health bookings (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error loading health bookings: $e');
              return <HealthBooking>[];
            }),
        _repository
            .getInsuranceClaims() // Insurance claims (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error loading insurance claims: $e');
              return <InsuranceClaim>[];
            }),
        _repository.getOrganizationHistory(), // Organization history
        _repository
            .getPendaftaranList() // Pendaftaran list (may fail, wrapped)
            .catchError((e) {
              debugPrint('Error fetching pendaftaran list: $e');
              return <Map<String, dynamic>>[];
            }),
        _repository.getCampusEvents(), // Campus events
        _repository.getCampusNews(), // Campus news
        _repository.getDashboardStats(), // Dashboard stats
      ]);

      // Parse results - order matches Future.wait() order
      _missions = results[0] as List<Mission>;
      _achievements = List<Achievement>.from(results[1] as List<Achievement>);

      var fetchedScholarships = List<Scholarship>.from(
        results[2] as List<Scholarship>,
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        final appliedList = prefs.getStringList('applied_scholarships') ?? [];
        if (appliedList.isNotEmpty) {
          for (int i = 0; i < fetchedScholarships.length; i++) {
            if (appliedList.contains(fetchedScholarships[i].id)) {
              final s = fetchedScholarships[i];
              fetchedScholarships[i] = ScholarshipModel(
                id: s.id,
                title: s.title,
                provider: s.provider,
                category: s.category,
                deadline: s.deadline,
                coverAmount: s.coverAmount,
                description: s.description,
                status: 'Applied',
                applicationStatus: s.applicationStatus ?? 'Seleksi Berkas',
                motivasi: s.motivasi,
                ktmKtpUrl: s.ktmKtpUrl,
                sertifikatUrl: s.sertifikatUrl,
                transkripUrl: s.transkripUrl,
                fileKtm: s.fileKtm,
                fileSertifikat: s.fileSertifikat,
                fileTranskrip: s.fileTranskrip,
                customFieldsRaw: s.customFieldsRaw,
                customAnswersRaw: s.customAnswersRaw,
                kuota: s.kuota,
                minIpk: s.minIpk,
                persyaratan: s.persyaratan,
                skema: s.skema,
              );
            }
          }
        }
      } catch (e) {
        debugPrint('Error restoring applied scholarship state: $e');
      }
      _scholarships = fetchedScholarships;

      _counselingSessions = results[3] as List<CounselingSession>;
      final psychologists = results[4] as List<Psychologist>;
      if (psychologists.isNotEmpty) {
        _availablePsychologists = psychologists;
      }
      _facultyProgress = results[5] as List<FacultyProgress>;
      _aspirations = results[6] as List<Aspiration>;
      _healthRecords = results[7] as List<HealthRecord>;
      _rujukans = results[8] as List<Map<String, dynamic>>;
      _healthSchedules = results[10] as List<HealthSchedule>;
      _processHealthWorkers(results[9] as List<HealthWorker>);
      _healthBookings = results[11] as List<HealthBooking>;
      _applyLocalRescheduledBookings();
      _insuranceClaims = results[12] as List<InsuranceClaim>;
      final history = results[13] as List<OrganizationHistory>;
      final pendaftaran = results[14] as List<Map<String, dynamic>>;
      _campusEvents = results[15] as List<CampusEventSchedule>;
      _campusNews = results[16] as List<CampusNews>;
      _dashboardStats = results[17] as Map<String, dynamic>;

      // Process pendaftaran list
      List<OrganizationHistory> filteredPendaftaran =
          pendaftaran
              .where((p) => p['status']?.toString().toLowerCase() != 'aktif')
              .map((p) {
                final ormawa = p['Ormawa'] as Map<String, dynamic>? ?? {};
                final orgName = ormawa['nama']?.toString() ?? 'Organisasi';
                final type = ormawa['kategori']?.toString() ?? 'Organisasi';
                final role = p['role']?.toString() ?? 'Anggota';
                final divisi = p['divisi']?.toString() ?? '';
                final displayRole =
                    divisi.isNotEmpty ? '$role ($divisi)' : role;

                final createdAtStr =
                    p['created_at']?.toString() ??
                    p['CreatedAt']?.toString() ??
                    '';
                int periodStart = DateTime.now().year;
                if (createdAtStr.isNotEmpty) {
                  final parsed = DateTime.tryParse(createdAtStr);
                  if (parsed != null) periodStart = parsed.year;
                }

                final statusStr =
                    p['status']?.toString().toLowerCase() ?? 'pending';
                String statusVerifikasi = 'Pending';
                if (statusStr == 'ditolak' || statusStr == 'tidak_aktif') {
                  statusVerifikasi = 'Ditolak';
                }

                return OrganizationHistory(
                  id: 'pend_${p['id'] ?? p['ID']}',
                  namaOrganisasi: orgName,
                  tipe: type,
                  jabatan: displayRole,
                  periodeMulai: periodStart,
                  periodeSelesai: null,
                  deskripsiKegiatan: p['alasan']?.toString() ?? '',
                  apresiasi: '',
                  statusVerifikasi: statusVerifikasi,
                  achievements: [],
                );
              })
              .toList();

      _organizationHistory = [...history, ...filteredPendaftaran];
      await fetchProfile();
      try {
        _iuranList = await _repository.getIuranList();
      } catch (_) {}
    } catch (e) {
      debugPrint('Error loading student data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actions
  Future<Aspiration> getAspirationDetail(String id) async {
    if (_repository == null) {
      throw Exception('Repository not initialized');
    }
    try {
      return await _repository.getAspirationDetail(id);
    } catch (e) {
      debugPrint('Error get aspiration detail: $e');
      rethrow;
    }
  }

  // Healthcare Methods
  Future<void> refreshCampusEvents() async {
    if (_repository == null) return;
    try {
      _campusEvents = await _repository.getCampusEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing campus events: $e');
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.addHealthRecord(record);
        _healthRecords = await _repository.getHealthRecords();
      } else {
        _healthRecords.insert(0, record);
      }
    } catch (e) {
      debugPrint('Error adding health record: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createHealthBooking(int scheduleId, String keluhan) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.createHealthBooking(
          scheduleId: scheduleId,
          keluhan: keluhan,
        );

        final newSchedule = _healthSchedules.firstWhere(
          (s) => s.id == scheduleId,
          orElse: () => _healthSchedules.first,
        );
        final newBooking = HealthBooking(
          id: DateTime.now().millisecondsSinceEpoch,
          jadwalId: scheduleId,
          jadwal: newSchedule,
          mahasiswaId: 1, // dummy
          keluhan: keluhan,
          status: 'Menunggu',
          alasanPenolakan: '',
        );
        _healthBookings.insert(0, newBooking);

        final sIdx = _healthSchedules.indexWhere((s) => s.id == scheduleId);
        if (sIdx != -1) {
          final s = _healthSchedules[sIdx];
          _healthSchedules[sIdx] = HealthSchedule(
            id: s.id,
            tenagaKesId: s.tenagaKesId,
            tenagaKes: s.tenagaKes,
            tanggal: s.tanggal,
            jamMulai: s.jamMulai,
            jamSelesai: s.jamSelesai,
            kuota: s.kuota,
            sisaKuota: s.sisaKuota - 1,
            lokasi: s.lokasi,
            tipeLayanan: s.tipeLayanan,
            catatan: s.catatan,
          );
        }
      }
    } catch (e) {
      debugPrint('Error creating health booking: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelHealthBooking(String bookingId) async {
    try {
      if (_repository != null) {
        await _repository.cancelHealthBooking(bookingId);
        final bookingIdInt = int.tryParse(bookingId);
        if (bookingIdInt != null) {
          _localRescheduledBookings.remove(bookingIdInt);
          await _saveRescheduledBookings();
        }
        _healthBookings = await _repository.getHealthBookings();
        _healthSchedules = await _repository.getHealthSchedules();
        _applyLocalRescheduledBookings();
      }
    } catch (e) {
      debugPrint('Error cancelling health booking: $e');
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> rescheduleHealthBooking(
    String bookingId,
    int newScheduleId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        // 1. Call API
        await _repository.rescheduleHealthBooking(bookingId, newScheduleId);

        // Save to local cache workaround
        final bookingIdInt = int.tryParse(bookingId);
        if (bookingIdInt != null) {
          _localRescheduledBookings[bookingIdInt] = newScheduleId;
          await _saveRescheduledBookings();
        }

        // 2. Fetch updated data
        final updatedBookings = await _repository.getHealthBookings();
        final updatedSchedules = await _repository.getHealthSchedules();

        // 3. Check if backend updated successfully
        bool backendUpdated = false;
        if (bookingIdInt != null) {
          final bIdx = updatedBookings.indexWhere((b) => b.id == bookingIdInt);
          if (bIdx != -1 && updatedBookings[bIdx].jadwalId == newScheduleId) {
            backendUpdated = true;
          }
        }

        if (backendUpdated) {
          _healthBookings = updatedBookings;
          _healthSchedules = updatedSchedules;
        } else {
          // Fallback workaround for buggy backend
          _healthBookings = updatedBookings;
          _healthSchedules = updatedSchedules;

          if (bookingIdInt != null) {
            final idx = _healthBookings.indexWhere((b) => b.id == bookingIdInt);
            if (idx != -1) {
              final oldScheduleId = _healthBookings[idx].jadwalId;
              final newSchedule = _healthSchedules.firstWhere(
                (s) => s.id == newScheduleId,
                orElse: () => _healthSchedules.first,
              );

              _healthBookings[idx] = HealthBooking(
                id: _healthBookings[idx].id,
                jadwalId: newScheduleId,
                jadwal: newSchedule,
                mahasiswaId: _healthBookings[idx].mahasiswaId,
                keluhan: _healthBookings[idx].keluhan,
                status: _healthBookings[idx].status,
                alasanPenolakan: _healthBookings[idx].alasanPenolakan,
              );

              // Increment old schedule capacity
              final oldSIdx = _healthSchedules.indexWhere(
                (s) => s.id == oldScheduleId,
              );
              if (oldSIdx != -1) {
                final os = _healthSchedules[oldSIdx];
                _healthSchedules[oldSIdx] = HealthSchedule(
                  id: os.id,
                  tenagaKesId: os.tenagaKesId,
                  tenagaKes: os.tenagaKes,
                  tanggal: os.tanggal,
                  jamMulai: os.jamMulai,
                  jamSelesai: os.jamSelesai,
                  kuota: os.kuota,
                  sisaKuota: os.sisaKuota + 1,
                  lokasi: os.lokasi,
                  tipeLayanan: os.tipeLayanan,
                  catatan: os.catatan,
                );
              }

              // Decrement new schedule capacity
              final newSIdx = _healthSchedules.indexWhere(
                (s) => s.id == newScheduleId,
              );
              if (newSIdx != -1) {
                final ns = _healthSchedules[newSIdx];
                _healthSchedules[newSIdx] = HealthSchedule(
                  id: ns.id,
                  tenagaKesId: ns.tenagaKesId,
                  tenagaKes: ns.tenagaKes,
                  tanggal: ns.tanggal,
                  jamMulai: ns.jamMulai,
                  jamSelesai: ns.jamSelesai,
                  kuota: ns.kuota,
                  sisaKuota: ns.sisaKuota - 1,
                  lokasi: ns.lokasi,
                  tipeLayanan: ns.tipeLayanan,
                  catatan: ns.catatan,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error rescheduling health booking: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitInsuranceClaim({
    required String provider,
    required String tanggal,
    required String faskes,
    required String deskripsi,
    required double biaya,
    String? filePath,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        final claim = await _repository.createInsuranceClaim(
          provider: provider,
          tanggal: tanggal,
          faskes: faskes,
          deskripsi: deskripsi,
          biaya: biaya,
        );
        if (filePath != null && filePath.isNotEmpty) {
          await _repository.uploadInsuranceDocument(
            claimId: claim.id,
            filePath: filePath,
            docNumber: 1,
          );
        }
        _insuranceClaims = await _repository.getInsuranceClaims();
      }
    } catch (e) {
      debugPrint('Error submitting insurance claim: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadInsuranceFile(
    int claimId,
    String filePath,
    int docNumber,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.uploadInsuranceDocument(
          claimId: claimId,
          filePath: filePath,
          docNumber: docNumber,
        );
        _insuranceClaims = await _repository.getInsuranceClaims();
      }
    } catch (e) {
      debugPrint('Error uploading insurance document: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHealthData() async {
    if (_repository == null) return;
    try {
      final rawWorkers = await _repository.getHealthWorkers();
      _healthSchedules = await _repository.getHealthSchedules();
      _processHealthWorkers(rawWorkers);
      _healthBookings = await _repository.getHealthBookings();
      _applyLocalRescheduledBookings();
      _insuranceClaims = await _repository.getInsuranceClaims();
      _healthRecords = await _repository.getHealthRecords();
      _rujukans = await _repository.getRujukans();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing health data: $e');
    }
  }

  void _processHealthWorkers(List<HealthWorker> rawWorkers) {
    final List<HealthWorker> combinedWorkers = [];
    final Set<int> seenIds = {};

    // 1. Prioritize workers who have active schedules (e.g. sinta)
    for (final schedule in _healthSchedules) {
      final worker = schedule.tenagaKes;
      if (worker != null && !seenIds.contains(worker.id)) {
        if (!worker.nama.toLowerCase().contains('dummy') &&
            !worker.nama.toLowerCase().contains('superadmin')) {
          seenIds.add(worker.id);
          combinedWorkers.add(worker);
        }
      }
    }

    // 2. Add other workers from API who don't have schedules but are active (excluding dummies)
    for (final worker in rawWorkers) {
      if (!seenIds.contains(worker.id)) {
        if (!worker.nama.toLowerCase().contains('dummy') &&
            !worker.nama.toLowerCase().contains('superadmin')) {
          seenIds.add(worker.id);
          combinedWorkers.add(worker);
        }
      }
    }

    _healthWorkers = combinedWorkers;
  }

  void toggleMission(String? id) {
    if (id == null) return;
    final index = _missions.indexWhere((m) => m.id == id);
    if (index != -1) {
      _missions[index].isCompleted = !_missions[index].isCompleted;
      notifyListeners();
    }
  }

  Future<void> submitAppeal(String alasan) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.submitAppeal(alasan);
      }
    } catch (e) {
      debugPrint('Error submitting appeal: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAchievement(Achievement achievement) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.addAchievement(achievement);
        final latest = await _repository.getAchievements();
        _achievements = latest;
      } else {
        _achievements.insert(0, achievement);
      }
    } catch (e) {
      debugPrint('Error adding achievement: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteAchievement(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.deleteAchievement(id);
      }
      _achievements.removeWhere((a) => a.id == id);
    } catch (e) {
      debugPrint('Error deleting achievement: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateAchievement(String id, Achievement achievement) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.updateAchievement(id, achievement);
        final latest = await _repository.getAchievements();
        _achievements = latest;
      } else {
        final index = _achievements.indexWhere((a) => a.id == id);
        if (index != -1) {
          _achievements[index] = achievement;
        }
      }
    } catch (e) {
      debugPrint('Error updating achievement: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForScholarship(
    String id,
    String motivasi, {
    String? ktmKtpPath,
    String? sertifikatPath,
    String? transkripPath,
    String? customAnswers,
    String? rubrikAnswers,
  }) async {
    final index = _scholarships.indexWhere((s) => s.id == id);
    if (index != -1) {
      final s = _scholarships[index];

      // Differentiate between keep existing, new file, or deleted ("")
      final cleanKtm =
          (ktmKtpPath == null && s.ktmKtpUrl != null && s.ktmKtpUrl!.isNotEmpty)
              ? ""
              : ktmKtpPath;
      final cleanSertifikat =
          (sertifikatPath == null &&
                  s.sertifikatUrl != null &&
                  s.sertifikatUrl!.isNotEmpty)
              ? ""
              : sertifikatPath;
      final cleanTranskrip =
          (transkripPath == null &&
                  s.transkripUrl != null &&
                  s.transkripUrl!.isNotEmpty)
              ? ""
              : transkripPath;

      if (_repository != null) {
        await _repository.applyForScholarship(
          id,
          motivasi,
          ktmKtpPath: cleanKtm,
          sertifikatPath: cleanSertifikat,
          transkripPath: cleanTranskrip,
          customAnswers: customAnswers,
          rubrikAnswers: rubrikAnswers,
        );
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final appliedList = prefs.getStringList('applied_scholarships') ?? [];
        if (!appliedList.contains(id)) {
          appliedList.add(id);
          await prefs.setStringList('applied_scholarships', appliedList);
        }
      } catch (e) {
        debugPrint('Error saving applied scholarship to prefs: $e');
      }

      // Selalu update state lokal agar UI langsung reaktif
      _scholarships[index] = ScholarshipModel(
        id: s.id,
        title: s.title,
        provider: s.provider,
        category: s.category,
        deadline: s.deadline,
        coverAmount: s.coverAmount,
        description: s.description,
        status: 'Applied',
        applicationStatus: 'Seleksi Berkas',
        motivasi: motivasi,
        ktmKtpUrl: cleanKtm,
        sertifikatUrl: cleanSertifikat,
        transkripUrl: cleanTranskrip,
        fileKtm: s.fileKtm,
        fileSertifikat: s.fileSertifikat,
        fileTranskrip: s.fileTranskrip,
        customFieldsRaw: s.customFieldsRaw,
        customAnswersRaw: customAnswers,
        kuota: s.kuota,
        minIpk: s.minIpk,
        persyaratan: s.persyaratan,
        skema: s.skema,
      );

      if (_repository != null) {
        // Refresh the scholarships list from the server but preserve our applied status
        final freshScholarships = await _repository.getScholarships();
        for (int i = 0; i < freshScholarships.length; i++) {
          if (freshScholarships[i].id == id) {
            freshScholarships[i] = _scholarships[index];
          }
        }
        _scholarships = List<Scholarship>.from(freshScholarships);
      }

      notifyListeners();
    }
  }

  Future<String> uploadCustomFile(String filePath) async {
    return await _repository!.uploadCustomFile(filePath);
  }

  Future<void> cancelScholarshipApplication(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.cancelScholarshipApplication(id);
      }
      final index = _scholarships.indexWhere((s) => s.id == id);
      if (index != -1) {
        final s = _scholarships[index];
        _scholarships[index] = ScholarshipModel(
          id: s.id,
          title: s.title,
          provider: s.provider,
          category: s.category,
          deadline: s.deadline,
          coverAmount: s.coverAmount,
          description: s.description,
          status: 'Open',
          applicationStatus: null,
        );
      }

      try {
        final prefs = await SharedPreferences.getInstance();
        final appliedList = prefs.getStringList('applied_scholarships') ?? [];
        if (appliedList.contains(id)) {
          appliedList.remove(id);
          await prefs.setStringList('applied_scholarships', appliedList);
        }
      } catch (e) {
        debugPrint('Error removing applied scholarship from prefs: $e');
      }
    } catch (e) {
      debugPrint('Error cancelling scholarship: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAspiration(Aspiration aspiration) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.submitAspiration(aspiration);
        // Refresh silently in background to avoid long loading
        _repository
            .getAspirations()
            .then((list) {
              _aspirations = list;
              notifyListeners();
            })
            .catchError((e) {
              debugPrint('Background fetch aspirations error: $e');
            });
      } else {
        _aspirations.insert(0, aspiration);
      }
    } catch (e) {
      debugPrint('Error adding aspiration: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookCounseling(CounselingSession session) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.bookCounseling(session);
      }
      _counselingSessions.insert(0, session);
    } catch (e) {
      debugPrint('Error booking counseling: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getPsychologistSchedules(
    String psychologistId,
  ) async {
    try {
      if (_repository != null) {
        return await _repository.getPsychologistSchedules(psychologistId);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting psychologist schedules: $e');
      return [];
    }
  }

  Future<void> addOrganizationHistory(OrganizationHistory org) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.addOrganizationHistory(org);
        // Refresh from server to get correct ID
        _organizationHistory = await _repository.getOrganizationHistory();
      } else {
        _organizationHistory.insert(0, org);
      }
    } catch (e) {
      debugPrint('Error adding organization history: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrganizationHistory(
    String id,
    OrganizationHistory org,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.updateOrganizationHistory(id, org);
        // Refresh from server to get correct data
        _organizationHistory = await _repository.getOrganizationHistory();
      } else {
        final index = _organizationHistory.indexWhere((o) => o.id == id);
        if (index != -1) {
          _organizationHistory[index] = org;
        }
      }
    } catch (e) {
      debugPrint('Error updating organization history: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrganizationHistory(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.deleteOrganizationHistory(id);
      }
      _organizationHistory.removeWhere((o) => o.id == id);
    } catch (e) {
      debugPrint('Error deleting organization history: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadOrganizationDokumentasi(
    String id,
    String filePath,
  ) async {
    try {
      if (_repository != null) {
        final url = await _repository.uploadDokumentasiOrganisasi(id, filePath);
        _organizationHistory = await _repository.getOrganizationHistory();
        notifyListeners();
        return url;
      }
      return '';
    } catch (e) {
      debugPrint('Error uploading organization documentation: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrmawaList() async {
    try {
      if (_repository != null) {
        return await _repository.getOrmawaList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting ormawa list: $e');
      return [];
    }
  }

  Future<void> fetchIuranList() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        _iuranList = await _repository.getIuranList();
      }
    } catch (e) {
      debugPrint('Error fetching iuran list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payIuran(String detailId, String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.bayarIuran(detailId: detailId, filePath: filePath);
        await fetchIuranList();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error paying iuran: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Map<String, dynamic>>> getOrmawaDivisions(String ormawaId) async {
    try {
      if (_repository != null) {
        return await _repository.getOrmawaDivisions(ormawaId);
      }
      return [];
    } catch (e) {
      debugPrint('Error getting divisions: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getRecruitmentFields(String ormawaId) async {
    try {
      if (_repository != null) {
        return await _repository.getRecruitmentFields(ormawaId);
      }
      return {};
    } catch (e) {
      debugPrint('Error getting recruitment fields: $e');
      return {};
    }
  }

  Future<String> uploadRecruitmentFile(String filePath) async {
    try {
      if (_repository != null) {
        return await _repository.uploadRecruitmentFile(filePath);
      }
      return '';
    } catch (e) {
      debugPrint('Error uploading recruitment file: $e');
      rethrow;
    }
  }

  // Profile
  Future<void> fetchProfile() async {
    if (_repository == null) return;
    try {
      final data = await _repository.getProfile();
      rawProfileData = data;
      name = data['nama']?.toString() ?? data['Nama']?.toString() ?? name;
      nim = data['nim']?.toString() ?? data['NIM']?.toString() ?? nim;

      final m = data['mahasiswa'] ?? data;
      final prodiObj =
          m['ProgramStudi'] ??
          m['program_studi'] ??
          m['prodi_detail'] ??
          m['ProdiDetail'] ??
          data['ProgramStudi'] ??
          data['program_studi'];
      if (prodiObj != null && prodiObj is Map) {
        final jenjang =
            (prodiObj['jenjang'] ?? prodiObj['Jenjang'] ?? '')
                .toString()
                .trim();
        final nama =
            (prodiObj['nama'] ?? prodiObj['Nama'] ?? '').toString().trim();
        if (jenjang.isNotEmpty &&
            nama.toLowerCase().startsWith(jenjang.toLowerCase())) {
          prodi = nama;
        } else {
          prodi = "$jenjang $nama".trim();
        }
      } else if (prodiObj != null && prodiObj is String) {
        prodi = prodiObj;
      } else {
        prodi =
            m['prodi_nama']?.toString() ??
            m['prodi']?.toString() ??
            m['Prodi']?.toString() ??
            data['prodi']?.toString() ??
            data['Prodi']?.toString() ??
            prodi;
      }

      final fakObj = data['Fakultas'] ?? data['fakultas'];
      if (fakObj != null) {
        fakultas = fakObj['nama']?.toString() ?? fakultas;
      }

      final extractedEmail =
          _extractValue(data, [
            'email_kampus',
            'EmailKampus',
            'email_institusi',
            'EmailInstitusi',
            'email_personal',
            'EmailPersonal',
            'email',
            'Email',
          ])?.toString();
      if (extractedEmail != null && extractedEmail.trim().isNotEmpty) {
        email = extractedEmail.trim();
      }

      final extractedPhone =
          _extractValue(data, [
            'no_hp',
            'NoHP',
            'no_wa',
            'NoWA',
            'telepon',
            'Telepon',
            'whatsapp',
            'WhatsApp',
            'phone',
            'Phone',
          ])?.toString();
      if (extractedPhone != null && extractedPhone.trim().isNotEmpty) {
        phone = extractedPhone.trim();
      }

      final extractedAddress =
          _extractValue(data, [
            'alamat_domisili',
            'AlamatDomisili',
            'alamat',
            'Alamat',
            'address',
            'Address',
          ])?.toString();
      if (extractedAddress != null && extractedAddress.trim().isNotEmpty) {
        address = extractedAddress.trim();
      }
      gender =
          data['jenis_kelamin']?.toString() ??
          data['JenisKelamin']?.toString() ??
          gender;
      intakeYear =
          (data['tahun_masuk'] ?? data['TahunMasuk'] ?? intakeYear).toString();
      semester =
          int.tryParse(
            _extractValue(data, [
                  'semester_sekarang',
                  'SemesterSekarang',
                  'semester',
                  'Semester',
                ])?.toString() ??
                '',
          ) ??
          semester;

      // Deep extract IPK
      ipk =
          double.tryParse(
            _extractValue(data, ['ipk', 'IPK', 'gpa', 'GPA'])?.toString() ?? '',
          ) ??
          ipk;

      totalSks =
          int.tryParse(
            _extractValue(data, [
                  'total_sks',
                  'TotalSKS',
                  'sks',
                  'SKS',
                ])?.toString() ??
                '',
          ) ??
          totalSks;
      fotoUrl =
          data['foto']?.toString() ??
          data['foto_url']?.toString() ??
          data['FotoURL']?.toString() ??
          data['avatar_url']?.toString() ??
          data['avatar']?.toString() ??
          (data['user'] != null && data['user'] is Map
              ? (data['user']['avatar_url']?.toString() ??
                  data['user']['avatar']?.toString() ??
                  data['user']['foto']?.toString())
              : null);

      final tempatLahir =
          _extractValue(data, ['tempat_lahir', 'TempatLahir'])?.toString() ??
          '';
      final tanggalLahir =
          _extractValue(data, [
            'tanggal_lahir',
            'TanggalLahir',
            'tgl_lahir',
            'TglLahir',
          ])?.toString() ??
          '';
      if (tempatLahir.isNotEmpty && tanggalLahir.isNotEmpty) {
        birthPlaceDate = "$tempatLahir, ${tanggalLahir.split('T').first}";
      } else if (tempatLahir.isNotEmpty) {
        birthPlaceDate = tempatLahir;
      } else if (tanggalLahir.isNotEmpty) {
        birthPlaceDate = tanggalLahir.split('T').first;
      }

      final prefs = await SharedPreferences.getInstance();
      emailNotif =
          prefs.getBool('student_email_notif') ??
          (data['email_notif'] == true ||
              data['email_notif'] == 1 ||
              data['email_notif']?.toString() == 'true' ||
              data['email_notif'] == null);
      pushNotif =
          prefs.getBool('student_push_notif') ??
          (data['push_notif'] == true ||
              data['push_notif'] == 1 ||
              data['push_notif']?.toString() == 'true' ||
              data['push_notif'] == null);
      inAppNotif =
          prefs.getBool('student_in_app_notif') ??
          (data['in_app_notif'] == true ||
              data['in_app_notif'] == 1 ||
              data['in_app_notif']?.toString() == 'true' ||
              data['in_app_notif'] == null);

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (data.containsKey('email_notif')) {
        await prefs.setBool('student_email_notif', data['email_notif'] == true);
      }
      if (data.containsKey('push_notif')) {
        await prefs.setBool('student_push_notif', data['push_notif'] == true);
      }
      if (data.containsKey('in_app_notif')) {
        await prefs.setBool(
          'student_in_app_notif',
          data['in_app_notif'] == true,
        );
      }

      if (_repository != null) {
        await _repository.updateProfile(data);
      }
      await fetchProfile();
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.changePassword(
          oldPassword,
          newPassword,
          confirmPassword,
        );
      }
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      if (_repository != null) {
        final url = await _repository.uploadAvatar(filePath);

        if (url.isNotEmpty) {
          fotoUrl = url;
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          if (fotoUrl!.contains('?')) {
            fotoUrl = '$fotoUrl&v=$timestamp';
          } else {
            fotoUrl = '$fotoUrl?v=$timestamp';
          }

          // Persist the new profile photo URL to AuthService session cache and local SharedPreferences
          final authService = AuthService();
          if (authService.userData != null) {
            final Map<String, dynamic> updatedUserData =
                Map<String, dynamic>.from(authService.userData!);

            updatedUserData['foto'] = fotoUrl;
            updatedUserData['avatar'] = fotoUrl;
            updatedUserData['avatar_url'] = fotoUrl;
            updatedUserData['foto_url'] = fotoUrl;
            updatedUserData['FotoURL'] = fotoUrl;

            if (updatedUserData['user'] is Map) {
              final Map<String, dynamic> userMap = Map<String, dynamic>.from(
                updatedUserData['user'],
              );
              userMap['foto'] = fotoUrl;
              userMap['avatar'] = fotoUrl;
              userMap['avatar_url'] = fotoUrl;
              updatedUserData['user'] = userMap;
            }

            if (updatedUserData['mahasiswa'] is Map) {
              final Map<String, dynamic> m = Map<String, dynamic>.from(
                updatedUserData['mahasiswa'],
              );
              m['foto'] = fotoUrl;
              m['avatar'] = fotoUrl;
              m['avatar_url'] = fotoUrl;
              updatedUserData['mahasiswa'] = m;
            }

            if (updatedUserData['data'] is Map) {
              final Map<String, dynamic> dataMap = Map<String, dynamic>.from(
                updatedUserData['data'],
              );
              if (dataMap['mahasiswa'] is Map) {
                final Map<String, dynamic> m = Map<String, dynamic>.from(
                  dataMap['mahasiswa'],
                );
                m['foto'] = fotoUrl;
                m['avatar'] = fotoUrl;
                m['avatar_url'] = fotoUrl;
                dataMap['mahasiswa'] = m;
              }
              dataMap['foto'] = fotoUrl;
              dataMap['avatar'] = fotoUrl;
              dataMap['avatar_url'] = fotoUrl;
              updatedUserData['data'] = dataMap;
            }

            await authService.updateUserData(updatedUserData);
          }

          notifyListeners();
        } else {
          await fetchProfile();
        }

        return url;
      }
      return '';
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
      rethrow;
    }
  }

  Future<void> daftarOrmawa({
    required String ormawaId,
    required String alasan,
    String? cvUrl,
    String? divisi,
    String? divisiPilihanDua,
    Map<String, dynamic>? customAnswers,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository.daftarOrmawa(
          ormawaId: ormawaId,
          alasan: alasan,
          cvUrl: cvUrl,
          divisi: divisi,
          divisiPilihanDua: divisiPilihanDua,
          customAnswers: customAnswers,
        );
      }
      await loadAllData();
    } catch (e) {
      debugPrint('Error registering ormawa: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

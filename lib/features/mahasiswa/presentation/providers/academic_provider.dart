import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/achievement.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/pkkmb_event.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_news.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/faculty_progress.dart';

class AcademicProvider extends ChangeNotifier {
  final StudentRepository _repository;

  AcademicProvider({required StudentRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Mission> _missions = [];
  List<Achievement> _achievements = [];
  List<PkkmbEvent> _pkkmbEvents = [];
  List<CampusNews> _campusNews = [];
  List<CampusEventSchedule> _campusEvents = [];
  List<FacultyProgress> _facultyProgress = [];
  Map<String, dynamic> _dashboardStats = {};

  List<Mission> get missions => _missions;
  List<Achievement> get achievements => _achievements;
  List<PkkmbEvent> get pkkmbEvents => _pkkmbEvents;
  List<CampusNews> get campusNews => _campusNews;
  List<CampusEventSchedule> get campusEvents => _campusEvents;
  List<FacultyProgress> get facultyProgress => _facultyProgress;
  Map<String, dynamic> get dashboardStats => _dashboardStats;

  // Logic Getters
  double get totalScore {
    final quizzes = _missions.where((m) => m.type == 'Quiz').toList();
    if (quizzes.isEmpty) return 0;
    int total = quizzes.fold(0, (sum, q) => sum + q.score);
    return total / quizzes.length;
  }

  bool get isEligibleForCertificate => totalScore >= 75;
  int get pendingMissionsCount => _missions.where((m) => !m.isCompleted).length;
  int get completedMissionsCount => _missions.where((m) => m.isCompleted).length;
  double get missionProgress => _missions.isEmpty ? 0 : completedMissionsCount / _missions.length;
  
  int get totalAchievements => _achievements.length;
  int get validatedAchievements => _achievements.where((a) => a.status == 'Validated' || a.status == 'Diverifikasi' || a.status == 'Valid').length;
  int get pendingAchievements => _achievements.where((a) => a.status == 'Pending' || a.status == 'Menunggu').length;
  int get syncedAchievements => _achievements.where((a) => a.isSynced || a.status == 'Diverifikasi').length;

  Future<void> loadAcademicData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getMissions(),
        _repository.getAchievements(),
        _repository.getFacultyStatistics().catchError((_) => <FacultyProgress>[]),
        _repository.getPkkmbEvents(),
        _repository.getCampusEvents(),
        _repository.getCampusNews(),
        _repository.getDashboardStats(),
      ]);

      _missions = results[0] as List<Mission>;
      _achievements = List<Achievement>.from(results[1] as List<dynamic>);
      _facultyProgress = results[2] as List<FacultyProgress>;
      _pkkmbEvents = results[3] as List<PkkmbEvent>;
      _campusEvents = results[4] as List<CampusEventSchedule>;
      _campusNews = results[5] as List<CampusNews>;
      _dashboardStats = results[6] as Map<String, dynamic>;
      
    } catch (e) {
      debugPrint('Error loading academic data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCampusEvents() async {
    try {
      _campusEvents = await _repository.getCampusEvents();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refresh campus events: $e');
    }
  }

  void toggleMission(String? id) {
    if (id == null) return;
    final idx = _missions.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final m = _missions[idx];
      _missions[idx] = Mission(
        id: m.id,
        title: m.title,
        desc: m.desc,
        score: m.score,
        isCompleted: !m.isCompleted,
        type: m.type,
      );
      notifyListeners();
    }
  }

  Future<void> addAchievement(Achievement achievement) async {
    try {
      await _repository.addAchievement(achievement);
      _achievements = await _repository.getAchievements();
      notifyListeners();
    } catch (e) {
      debugPrint('Error add achievement: $e');
      rethrow;
    }
  }

  Future<void> deleteAchievement(String id) async {
    try {
      await _repository.deleteAchievement(id);
      _achievements.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error delete achievement: $e');
      rethrow;
    }
  }

  Future<void> updateAchievement(String id, Achievement achievement) async {
    try {
      await _repository.updateAchievement(id, achievement);
      _achievements = await _repository.getAchievements();
      notifyListeners();
    } catch (e) {
      debugPrint('Error update achievement: $e');
      rethrow;
    }
  }
}

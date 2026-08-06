import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/counseling_session.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';

class MahasiswaCounselingProvider extends ChangeNotifier {
  final StudentRepository _repository;

  MahasiswaCounselingProvider({required StudentRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CounselingSession> _counselingSessions = [];
  List<Psychologist> _availablePsychologists = [];
  List<Aspiration> _aspirations = [];
  List<Map<String, dynamic>> _rujukans = [];

  List<CounselingSession> get counselingSessions => _counselingSessions;
  List<Psychologist> get availablePsychologists => _availablePsychologists;
  List<Aspiration> get aspirations => _aspirations;
  List<Map<String, dynamic>> get rujukans => _rujukans;

  int get totalAspirations => _aspirations.length;
  int get pendingAspirations => _aspirations.where((a) => a.status == 'Pending' || a.status == 'In Progress').length;
  int get resolvedAspirations => _aspirations.where((a) => a.status == 'Resolved').length;

  Future<void> loadCounselingData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getCounselingSessions(),
        _repository.getPsychologists().catchError((_) => <Psychologist>[]),
        _repository.getAspirations(),
        _repository.getRujukans(),
      ]);

      _counselingSessions = results[0] as List<CounselingSession>;
      _availablePsychologists = results[1] as List<Psychologist>;
      _aspirations = results[2] as List<Aspiration>;
      _rujukans = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      debugPrint('Error loading counseling data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> bookCounseling(CounselingSession session) async {
    try {
      await _repository.bookCounseling(session);
      _counselingSessions = await _repository.getCounselingSessions();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPsychologistSchedules(String psychologistId) async {
    try {
      return await _repository.getPsychologistSchedules(psychologistId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAspiration(Aspiration aspiration) async {
    try {
      await _repository.submitAspiration(aspiration);
      await refreshAspirations();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refreshAspirations() async {
    try {
      _aspirations = await _repository.getAspirations();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<Aspiration> getAspirationDetail(String id) async {
    try {
      return await _repository.getAspirationDetail(id);
    } catch (e) {
      rethrow;
    }
  }
}

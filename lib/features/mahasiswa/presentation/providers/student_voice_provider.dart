import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/aspiration.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:flutter/foundation.dart';

class StudentVoiceProvider extends ChangeNotifier {
  final StudentRepository? _repository;

  bool _isLoading = false;
  String _error = '';
  List<Aspiration> _aspirations = [];

  StudentVoiceProvider({StudentRepository? repository}) : _repository = repository;

  bool get isLoading => _isLoading;
  String get error => _error;
  List<Aspiration> get aspirations => _aspirations;

  int get totalAspirations => _aspirations.length;
  int get pendingAspirations =>
      _aspirations.where((a) => a.status == 'Pending').length;
  int get resolvedAspirations =>
      _aspirations.where((a) => a.status == 'Resolved').length;

  Future<void> fetchAspirations() async {
    if (_repository == null) return;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _aspirations = await _repository.getAspirations();
    } catch (e) {
      _error = e.toString();
      debugPrint(e.toString()); //'Error fetching aspirations', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Aspiration> getAspirationDetail(String id) async {
    if (_repository == null) throw Exception('Repository not initialized');
    _isLoading = true;
    notifyListeners();
    try {
      final detail = await _repository.getAspirationDetail(id);
      return detail;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAspiration(Aspiration aspiration) async {
    if (_repository == null) throw Exception('Repository not initialized');
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.submitAspiration(aspiration);
      try {
        final list = await _repository.getAspirations();
        _aspirations = list;
      } catch (_) {
        _aspirations.insert(0, aspiration);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

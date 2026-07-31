import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'dart:developer';

class AdminPsychologistProvider extends ChangeNotifier {
  final ApiClient _apiClient;

  AdminPsychologistProvider({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ─── Psychologists ──────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _psychologists = [];
  List<Map<String, dynamic>> get psychologists => _psychologists;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Map<String, dynamic>? _selectedPsychologist;
  Map<String, dynamic>? get selectedPsychologist => _selectedPsychologist;

  // ─── Medical Records ──────────────────────────────────────────────────────
  Map<String, dynamic> _medicalRecord = {};
  Map<String, dynamic> get medicalRecord => _medicalRecord;

  bool _medicalRecordLoading = false;
  bool get medicalRecordLoading => _medicalRecordLoading;

  // ─── Schedules ──────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _allSchedules = [];
  List<Map<String, dynamic>> get allSchedules => _allSchedules;

  bool _schedulesLoading = false;
  bool get schedulesLoading => _schedulesLoading;

  // ─── Psychologist CRUD ──────────────────────────────────────────────────────
  Future<void> loadPsychologists({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final response =
          await _apiClient.client.get('/api/admin/psychologists');
      final data = response.data['data'];
      if (data is List) {
        _psychologists = data.cast<Map<String, dynamic>>();
      } else {
        _psychologists = [];
      }
    } catch (e) {
      log('AdminPsychologistProvider.loadPsychologists error: $e');
      if (!silent) {
        _error = 'Gagal memuat daftar psikolog';
      }
    }
    if (!silent) {
      _loading = false;
    }
    notifyListeners();
  }

  Future<bool> createPsychologist(Map<String, dynamic> data) async {
    try {
      await _apiClient.client.post('/api/admin/psychologists', data: data);
      await loadPsychologists(silent: true);
      return true;
    } catch (e) {
      log('AdminPsychologistProvider.createPsychologist error: $e');
      return false;
    }
  }

  Future<void> loadPsychologistDetail(String id) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response =
          await _apiClient.client.get('/api/admin/psychologists/$id');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        _selectedPsychologist = data;
      }
    } catch (e) {
      log('AdminPsychologistProvider.loadPsychologistDetail error: $e');
      _error = 'Gagal memuat detail psikolog';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> updatePsychologist(String id, Map<String, dynamic> data) async {
    try {
      await _apiClient.client
          .put('/api/admin/psychologists/$id', data: data);
      await loadPsychologists(silent: true);
      return true;
    } catch (e) {
      log('AdminPsychologistProvider.updatePsychologist error: $e');
      return false;
    }
  }

  // ─── Medical Records ──────────────────────────────────────────────────────
  Future<void> loadMedicalRecord(String patientId) async {
    _medicalRecordLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _apiClient.client
          .get('/api/psychologist/patients/$patientId/medical-record');
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        _medicalRecord = data;
      } else {
        _medicalRecord = {};
      }
    } catch (e) {
      log('AdminPsychologistProvider.loadMedicalRecord error: $e');
      _error = 'Gagal memuat rekam medis';
    }
    _medicalRecordLoading = false;
    notifyListeners();
  }

  Future<bool> createMedicalRecord(Map<String, dynamic> data) async {
    try {
      await _apiClient.client
          .post('/api/psychologist/medical-records', data: data);
      return true;
    } catch (e) {
      log('AdminPsychologistProvider.createMedicalRecord error: $e');
      return false;
    }
  }

  // ─── Schedules ──────────────────────────────────────────────────────────────
  Future<void> loadAllSchedules() async {
    _schedulesLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response =
          await _apiClient.client.get('/api/psychologist/schedules');
      final data = response.data['data'];
      if (data is List) {
        _allSchedules = data.cast<Map<String, dynamic>>();
      } else {
        _allSchedules = [];
      }
    } catch (e) {
      log('AdminPsychologistProvider.loadAllSchedules error: $e');
      _error = 'Gagal memuat jadwal';
    }
    _schedulesLoading = false;
    notifyListeners();
  }

  void clearSelectedPsychologist() {
    _selectedPsychologist = null;
    notifyListeners();
  }

  void clearState() {
    _psychologists = [];
    _selectedPsychologist = null;
    _medicalRecord = {};
    _allSchedules = [];
    _error = null;
    notifyListeners();
  }
}

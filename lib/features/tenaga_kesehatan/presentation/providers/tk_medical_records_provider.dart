import 'package:flutter/foundation.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/schedule.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tenaga_kesehatan.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';

class TkMedicalRecordsProvider extends ChangeNotifier {
  final TkRepository repository;

  TkMedicalRecordsProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<MedicalRecord> _medicalRecords = [];
  List<MedicalRecord> get medicalRecords => _medicalRecords;

  List<Schedule> _schedules = [];
  List<Schedule> get schedules => _schedules;

  List<Map<String, dynamic>> _screenings = [];
  List<Map<String, dynamic>> get screenings => _screenings;

  List<TenagaKesehatan> _tkList = [];
  List<TenagaKesehatan> get tkList => _tkList;

  // Filter
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  String _statusFilter = 'Semua';
  String get statusFilter => _statusFilter;

  List<MedicalRecord> get filteredRecords {
    var result = _medicalRecords;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) {
        final nama = (r.namaPemeriksa ?? '').toLowerCase();
        return nama.contains(q) ||
            r.hasil?.toLowerCase().contains(q) == true ||
            r.statusKesehatan.toLowerCase().contains(q);
      }).toList();
    }
    if (_statusFilter != 'Semua') {
      result = result.where((r) => r.statusCategory == _statusFilter).toList();
    }
    return result;
  }

  List<Map<String, dynamic>> get filteredScreenings {
    if (_searchQuery.isEmpty) return _screenings;
    final q = _searchQuery.toLowerCase();
    return _screenings.where((s) {
      final name = (s['nama'] ?? s['patient_name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _statusFilter = filter;
    notifyListeners();
  }

  Future<void> loadMedicalRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _medicalRecords = [];
      // In production, would fetch from API
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _schedules = await repository.getSchedules();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<void> loadScreenings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _screenings = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<void> loadTkList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tkList = [];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<bool> createPatient(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.searchPatients(data['nama'] ?? '');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import '../../data/models/presensi_model.dart';
import '../../data/repositories/presensi_repository.dart';

class PresensiProvider extends ChangeNotifier {
  final PresensiRepository _repository;

  List<PresensiModel> _presensiList = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime _selectedDate = DateTime.now();

  PresensiProvider({PresensiRepository? repository})
      : _repository = repository ?? PresensiRepository();

  List<PresensiModel> get presensiList => _presensiList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  String get _formattedDate =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> loadPresensi() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _presensiList = await _repository.getPresensi(date: _formattedDate);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadPresensi();
  }

  Future<void> checkIn(PresensiModel presensi) async {
    try {
      await _repository.checkIn(presensi.id);
      await loadPresensi();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> refresh() => loadPresensi();
}

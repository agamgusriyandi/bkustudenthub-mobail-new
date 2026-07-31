import 'package:flutter/material.dart';
import '../../data/models/counseling_history_model.dart';
import '../../data/repositories/counseling_history_repository.dart';

class CounselingHistoryProvider extends ChangeNotifier {
  final CounselingHistoryRepository _repository;

  List<CounselingHistoryModel> _historyList = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedFilter;

  CounselingHistoryProvider({CounselingHistoryRepository? repository})
      : _repository = repository ?? CounselingHistoryRepository();

  List<CounselingHistoryModel> get historyList => _historyList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get selectedFilter => _selectedFilter;

  List<CounselingHistoryModel> get filteredList {
    if (_selectedFilter == null) return _historyList;
    return _historyList
        .where((h) => h.statusLabel == _selectedFilter)
        .toList();
  }

  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _historyList = await _repository.getHistory(status: _selectedFilter);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setFilter(String? filter) {
    _selectedFilter = filter;
    notifyListeners();
    loadHistory();
  }

  Future<void> cancelBooking(int bookingId, {String? reason}) async {
    try {
      await _repository.cancelBooking(bookingId, reason: reason);
      await loadHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> rescheduleBooking(
    int bookingId, {
    required String newDate,
    required String newTime,
  }) async {
    try {
      await _repository.rescheduleBooking(
        bookingId,
        newDate: newDate,
        newTime: newTime,
      );
      await loadHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> refresh() => loadHistory();
}

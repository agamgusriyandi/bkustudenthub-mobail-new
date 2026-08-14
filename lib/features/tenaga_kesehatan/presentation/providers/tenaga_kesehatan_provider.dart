import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tenaga_kesehatan.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';

class TenagaKesehatanProvider extends ChangeNotifier {
  final TkRepository repository;

  TenagaKesehatanProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<TenagaKesehatan> _tkList = [];
  List<TenagaKesehatan> get tkList => _tkList;

  Future<void> loadTenagaKesehatanList() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tkList = await repository.getTenagaKesehatanList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<bool> createTenagaKesehatan(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await repository.createTenagaKesehatan(data);
      if (success) {
        await loadTenagaKesehatanList();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTenagaKesehatan(int id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await repository.updateTenagaKesehatan(id, data);
      if (success) {
        await loadTenagaKesehatanList();
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTenagaKesehatan(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await repository.deleteTenagaKesehatan(id);
      if (success) {
        _tkList.removeWhere((item) => item.id == id);
      }
      _isLoading = false;
      notifyListeners();
      return success;
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

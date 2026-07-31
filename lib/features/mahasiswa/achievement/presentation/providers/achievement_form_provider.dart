import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/data/models/achievement_form_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/data/repositories/achievement_repository.dart';

class AchievementFormProvider extends ChangeNotifier {
  final AchievementRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  AchievementFormProvider({AchievementRepository? repository})
      : _repository = repository ?? AchievementRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  Future<void> submitAchievement(AchievementFormModel form, {String? filePath}) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _repository.createAchievement(form, filePath: filePath);
      _isSuccess = true;
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateAchievement(int id, AchievementFormModel form, {String? filePath}) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _repository.updateAchievement(id, form, filePath: filePath);
      _isSuccess = true;
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();
  }
}

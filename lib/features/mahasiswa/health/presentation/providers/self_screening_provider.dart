import 'package:flutter/material.dart';
import '../../data/models/screening_model.dart';
import '../../data/repositories/screening_repository.dart';

class SelfScreeningProvider extends ChangeNotifier {
  final ScreeningRepository _repository;

  int _currentQuestionIndex = 0;
  final List<bool?> _answers = List<bool?>.filled(20, null);
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  ScreeningResult? _latestResult;
  ScreeningResult? _submitResult;
  bool _showResult = false;

  SelfScreeningProvider({ScreeningRepository? repository})
      : _repository = repository ?? ScreeningRepository();

  int get currentQuestionIndex => _currentQuestionIndex;
  List<bool?> get answers => _answers;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  ScreeningResult? get latestResult => _latestResult;
  ScreeningResult? get submitResult => _submitResult;
  bool get showResult => _showResult;

  int get answeredCount => _answers.where((a) => a != null).length;
  bool get isComplete => answeredCount == 20;
  bool get canGoNext => _currentQuestionIndex < 19;
  bool get canGoPrevious => _currentQuestionIndex > 0;
  bool get isLastQuestion => _currentQuestionIndex == 19;

  ScreeningQuestion get currentQuestion =>
      ScreeningResult.srq20Questions[_currentQuestionIndex];

  int get calculatedScore =>
      _answers.where((a) => a == true).length;

  ScreeningLevel get calculatedLevel =>
      ScreeningResult.calculateLevel(calculatedScore);

  List<SelfScreeningIntake> _myScreenings = [];
  List<SelfScreeningIntake> get myScreenings => _myScreenings;

  Future<void> loadLatestScreening() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getLatestScreening().catchError((_) => null),
        _repository.getMyScreenings().catchError((_) => <SelfScreeningIntake>[]),
      ]);
      _latestResult = results[0] as ScreeningResult?;
      _myScreenings = results[1] as List<SelfScreeningIntake>;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitClinicalScreening({
    required String keluhanUtama,
    required int skalaNyeri,
    String alergiObat = '',
    String konsumsiObat = '',
    int? bookingId,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createClinicalScreening(
        keluhanUtama: keluhanUtama,
        skalaNyeri: skalaNyeri,
        alergiObat: alergiObat,
        konsumsiObat: konsumsiObat,
        bookingId: bookingId,
      );
      _myScreenings.insert(0, created);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void setAnswer(int questionIndex, bool value) {
    _answers[questionIndex] = value;
    notifyListeners();
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < 20) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void goNext() {
    if (canGoNext) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void goPrevious() {
    if (canGoPrevious) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void resetScreening() {
    _currentQuestionIndex = 0;
    for (int i = 0; i < 20; i++) {
      _answers[i] = null;
    }
    _showResult = false;
    _submitResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> submitScreening() async {
    if (!isComplete) {
      _errorMessage = 'Harap menjawab semua pertanyaan terlebih dahulu';
      notifyListeners();
      return;
    }

    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final boolAnswers = _answers.map((a) => a ?? false).toList();
      _submitResult = await _repository.submitScreening(answers: boolAnswers);
      _showResult = true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => loadLatestScreening();
}

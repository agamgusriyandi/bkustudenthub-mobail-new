import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/remedial_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/repositories/remedial_repository.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';

class KencanaRemedialProvider extends ChangeNotifier {
  final RemedialRepository _repository = RemedialRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<KencanaRemedialItem> _remedials = [];
  List<KencanaRemedialItem> get remedials => _remedials;

  String _periodStatus = '';
  String get periodStatus => _periodStatus;

  String _periodStage = '';
  String get periodStage => _periodStage;

  Future<void> fetchRemedials() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _repository.getRemedials();
      _remedials = data['remedials'] as List<KencanaRemedialItem>;
      _periodStatus = data['periodStatus'] as String;
      _periodStage = data['periodStage'] as String;
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitRemedial({
    required int remedialId,
    required String text,
    String? linkUrl,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.submitRemedial(
        remedialId: remedialId,
        text: text,
        linkUrl: linkUrl,
      );
      if (success) {
        await fetchRemedials();
      }
      return success;
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}

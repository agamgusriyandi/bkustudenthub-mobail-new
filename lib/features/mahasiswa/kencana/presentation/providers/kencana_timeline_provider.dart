import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/timeline_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/repositories/timeline_repository.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';

class KencanaTimelineProvider extends ChangeNotifier {
  final TimelineRepository _repository = TimelineRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<KencanaTimelineStage> _stages = [];
  List<KencanaTimelineStage> get stages => _stages;

  Future<void> fetchTimeline() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _stages = await _repository.getTimeline();
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}

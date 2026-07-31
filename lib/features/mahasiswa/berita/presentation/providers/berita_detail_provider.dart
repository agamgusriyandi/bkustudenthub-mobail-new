import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/berita/data/models/berita_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/berita/data/repositories/berita_repository.dart';

class BeritaDetailProvider extends ChangeNotifier {
  final BeritaRepository _repository;

  BeritaModel? _berita;
  bool _isLoading = false;
  String? _errorMessage;

  BeritaDetailProvider({BeritaRepository? repository})
      : _repository = repository ?? BeritaRepository();

  BeritaModel? get berita => _berita;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBerita(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _berita = await _repository.getBeritaDetail(id);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}

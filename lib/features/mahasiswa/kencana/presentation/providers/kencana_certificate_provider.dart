import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/certificate_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/repositories/certificate_repository.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';

class KencanaCertificateProvider extends ChangeNotifier {
  final CertificateRepository _repository = CertificateRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  KencanaCertificate? _certificate;
  KencanaCertificate? get certificate => _certificate;

  Future<void> fetchCertificate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _certificate = await _repository.getCertificate();
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }
}

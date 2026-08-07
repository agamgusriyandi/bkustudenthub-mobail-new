import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/certificate_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/repositories/certificate_repository.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'package:printing/printing.dart';

class KencanaCertificateProvider extends ChangeNotifier {
  final CertificateRepository _repository = CertificateRepository();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

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

  Future<void> downloadCertificate() async {
    _isDownloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cert = _certificate ??
          KencanaCertificate(
            id: 1,
            fileUrl: '/storage/certificates/sertifikat_kencana.pdf',
            certificateNumber: 'CERT/KENCANA/2026/001',
            predicate: 'Sangat Memuaskan',
            studentName: 'SABILLA SRI ANGGITA PUTRI SETIADI',
            periodName: '2026',
            finalScore: 82.7,
          );
      final bytes = await _repository.downloadCertificateBytes(cert);
      final filename =
          'sertifikat_kencana_${cert.studentName?.replaceAll(' ', '_') ?? 'mahasiswa'}.pdf';

      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename: filename,
      );
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }

  Future<void> shareCertificate() async {
    if (_certificate == null || !_certificate!.hasFile) return;
    _isDownloading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final bytes = await _repository.downloadCertificateBytes(_certificate!);
      await Printing.sharePdf(
        bytes: Uint8List.fromList(bytes),
        filename:
            'sertifikat_${_certificate!.certificateNumber ?? _certificate!.id}.pdf',
      );
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}

import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_insurance_claim_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_bap_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_clinical_report_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import '../../../../core/error/error_handler.dart';

class TkHealthProvider extends ChangeNotifier {
  final TkRepository repository;

  TkHealthProvider({required this.repository});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // State for Insurance Claims
  List<TkInsuranceClaimModel> _claims = [];
  List<TkInsuranceClaimModel> get claims => _claims;

  // State for BAP
  List<TkBapModel> _baps = _getDefaultBaps();
  List<TkBapModel> get baps => _baps;

  // State for Clinical Reports
  TkClinicalReportModel? _clinicalReports;
  TkClinicalReportModel? get clinicalReports => _clinicalReports;

  // ==================== INSURANCE CLAIMS ====================

  Future<void> fetchInsuranceClaims() async {
    _setLoading(true);
    try {
      _claims = await repository.getInsuranceClaims();
      _error = null;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error fetching insurance claims: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateClaimStatus(
    int id,
    String status, {
    String? catatanReview,
  }) async {
    _setLoading(true);
    try {
      final updatedClaim = await repository.updateInsuranceClaimStatus(
        id,
        status,
        catatanReview: catatanReview,
      );
      final index = _claims.indexWhere((c) => c.id == id);
      if (index != -1) {
        _claims[index] = updatedClaim;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error updating claim status: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBAPs() async {
    _setLoading(true);
    try {
      final res = await repository.getBAPs();
      if (res.isNotEmpty) {
        _baps = res;
      } else {
        _baps = _getDefaultBaps();
      }
      _error = null;
    } catch (e) {
      _baps = _getDefaultBaps();
      _error = null;
      log('Error fetching BAPs: $e');
    } finally {
      _setLoading(false);
    }
  }

  static List<TkBapModel> _getDefaultBaps() {
    return [
      TkBapModel(
        id: 1,
        namaKegiatan: 'Pemeriksaan Kesehatan Mahasiswa Baru 2026',
        tanggalPelaksanaan: DateTime.now().subtract(const Duration(days: 2)),
        waktuMulai: '08:00',
        waktuSelesai: '15:00',
        tempat: 'Auditorium Kampus Utama BKU',
        jumlahPeserta: 150,
        jumlahDiperiksa: 145,
        totalLayak: 130,
        totalPantauan: 12,
        totalTidakLayak: 3,
        status: 'FINAL',
        ttdKepalaDivisiNama: 'Dr. H. Ahmad Sudrajat, M.Kes',
        ttdKepalaDivisiNik: '197508122003121002',
        ttdTimMedisNama: 'dr. Siti Rahmawati, Sp.PK',
        ttdTimMedisNik: '198204152009122003',
      ),
      TkBapModel(
        id: 2,
        namaKegiatan: 'Screening Kesehatan Berkala & Donor Darah',
        tanggalPelaksanaan: DateTime.now().subtract(const Duration(days: 10)),
        waktuMulai: '09:00',
        waktuSelesai: '14:30',
        tempat: 'Klinik Pratama BKU',
        jumlahPeserta: 80,
        jumlahDiperiksa: 78,
        totalLayak: 70,
        totalPantauan: 6,
        totalTidakLayak: 2,
        status: 'DRAFT',
        ttdKepalaDivisiNama: 'Dr. H. Ahmad Sudrajat, M.Kes',
        ttdKepalaDivisiNik: '197508122003121002',
        ttdTimMedisNama: 'dr. Budi Santoso',
        ttdTimMedisNik: '198801202014021001',
      ),
    ];
  }

  Future<bool> createBAP(Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final newBap = await repository.createBAP(data);
      _baps.insert(0, newBap);
      _error = null;
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error creating BAP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateBAP(int id, Map<String, dynamic> data) async {
    _setLoading(true);
    try {
      final updatedBap = await repository.updateBAP(id, data);
      final index = _baps.indexWhere((b) => b.id == id);
      if (index != -1) {
        _baps[index] = updatedBap;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error updating BAP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteBAP(int id) async {
    _setLoading(true);
    try {
      await repository.deleteBAP(id);
      _baps.removeWhere((b) => b.id == id);
      _error = null;
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error deleting BAP: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> downloadBAP(int id) async {
    _setLoading(true);
    try {
      final url = await repository.exportBAPPdf(id);
      _error = null;
      return url;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error getting download URL: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<String>> uploadBapPhotos(List<String> filePaths) async {
    _setLoading(true);
    try {
      final urls = await repository.uploadBapPhotos(filePaths);
      _error = null;
      return urls;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error uploading BAP photos: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // ==================== CLINICAL REPORTS ====================

  Future<void> fetchClinicalReports({
    String? startDate,
    String? endDate,
  }) async {
    _setLoading(true);
    try {
      _clinicalReports = await repository.getClinicalReports(
        startDate: startDate,
        endDate: endDate,
      );
      _error = null;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error fetching clinical reports: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getReportExcelUrl() async {
    _setLoading(true);
    try {
      final url = await repository.exportReportExcel();
      _error = null;
      return url;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error getting report excel URL: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getOfflineFormPdfUrl() async {
    _setLoading(true);
    try {
      final url = await repository.exportOfflineRegistrationFormPdf();
      _error = null;
      return url;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error getting offline form URL: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getReportPdfUrl() async {
    _setLoading(true);
    try {
      final url = await repository.exportReportPdf();
      _error = null;
      return url;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      log('Error getting report PDF URL: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

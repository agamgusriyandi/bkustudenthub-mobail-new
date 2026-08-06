import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';

class OrganizationProvider extends ChangeNotifier {
  final StudentRepository _repository;

  OrganizationProvider({required StudentRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<OrganizationHistory> _organizationHistory = [];
  List<Map<String, dynamic>> _iuranList = [];

  List<OrganizationHistory> get organizationHistory => _organizationHistory;
  List<Map<String, dynamic>> get iuranList => _iuranList;

  Future<String?> uploadOrganizationDokumentasi(String id, dynamic file) async {
    return ""; // Note: fix uploadOrganizationDokumentasi
  }

  Future<void> loadOrganizationData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getOrganizationHistory(),
      ]);

      _organizationHistory = results[0];
    } catch (e) {
      debugPrint('Error loading organization data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchIuranList() async {
    try {
      _isLoading = true;
      notifyListeners();
      _iuranList = await _repository.getIuranList();
    } catch (e) {
      debugPrint('Error fetching iuran list: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrganizationHistory(OrganizationHistory org) async {
    try {
      await _repository.addOrganizationHistory(org);
      _organizationHistory = await _repository.getOrganizationHistory();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateOrganizationHistory(String id, OrganizationHistory org) async {
    try {
      await _repository.updateOrganizationHistory(id, org);
      _organizationHistory = await _repository.getOrganizationHistory();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteOrganizationHistory(String id) async {
    try {
      await _repository.deleteOrganizationHistory(id);
      _organizationHistory.removeWhere((o) => o.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  Future<String> uploadDokumentasi(String id, String filePath) async {
    try {
      return await _repository.uploadDokumentasiOrganisasi(id, filePath);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrmawaList() async {
    try {
      return await _repository.getOrmawaList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> payIuran(String detailId, String filePath) async {
    try {
      await _repository.bayarIuran(detailId: detailId, filePath: filePath);
      await fetchIuranList();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getOrmawaDivisions(String ormawaId) async {
    try {
      return await _repository.getOrmawaDivisions(ormawaId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRecruitmentFields(String ormawaId) async {
    try {
      return await _repository.getRecruitmentFields(ormawaId);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadRecruitmentFile(String filePath) async {
    try {
      return await _repository.uploadRecruitmentFile(filePath);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> daftarOrmawa({
    required String ormawaId,
    required String alasan,
    String? cvUrl,
    String? divisi,
    String? divisiPilihanDua,
    Map<String, dynamic>? customAnswers,
  }) async {
    try {
      await _repository.daftarOrmawa(
        ormawaId: ormawaId,
        alasan: alasan,
        divisi: divisi,
        customAnswers: customAnswers,
      );
    } catch (e) {
      rethrow;
    }
  }
}

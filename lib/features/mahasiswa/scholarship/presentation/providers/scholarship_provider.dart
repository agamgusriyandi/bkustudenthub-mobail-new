import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/features/mahasiswa/data/models/scholarship_model.dart';

class ScholarshipProvider extends ChangeNotifier {
  final StudentRepository _repository;

  ScholarshipProvider({required StudentRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedCategory = 'Internal';
  String get selectedCategory => _selectedCategory;

  List<Scholarship> _scholarships = [];
  List<Scholarship> get scholarships => _scholarships;

  List<Scholarship> get filteredScholarships {
    return _scholarships.where((s) => s.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadScholarships() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedScholarships = await _repository.getScholarships();

      try {
        final prefs = await SharedPreferences.getInstance();
        final localDataStr = prefs.getString('local_scholarship_applications');
        if (localDataStr != null) {
          final List<dynamic> appliedList = jsonDecode(localDataStr);
          for (int i = 0; i < fetchedScholarships.length; i++) {
            if (appliedList.contains(fetchedScholarships[i].id)) {
              final s = fetchedScholarships[i];
              fetchedScholarships[i] = ScholarshipModel(
                id: s.id,
                title: s.title,
                provider: s.provider,
                deadline: s.deadline,
                coverAmount: s.coverAmount,
                category: s.category,
                description: s.description,
                status: s.status,
                applicationStatus: 'Menunggu',
                persyaratan: s.persyaratan,
              );
            }
          }
        }
      } catch (_) {}

      _scholarships = fetchedScholarships;
    } catch (e) {
      debugPrint('Error loadScholarships: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForScholarship(
    String id,
    String motivasi, {
    String? ktmKtpPath,
    String? sertifikatPath,
    String? transkripPath,
    String? customAnswers,
    String? rubrikAnswers,
  }) async {
    try {
      await _repository.applyForScholarship(
        id,
        motivasi,
        ktmKtpPath: ktmKtpPath,
        sertifikatPath: sertifikatPath,
        transkripPath: transkripPath,
        customAnswers: customAnswers,
        rubrikAnswers: rubrikAnswers,
      );

      final index = _scholarships.indexWhere((s) => s.id == id);
      final s = _scholarships[index];
      _scholarships[index] = ScholarshipModel(
        id: s.id,
        title: s.title,
        provider: s.provider,
        deadline: s.deadline,
        coverAmount: s.coverAmount,
        category: s.category,
        description: s.description,
        status: s.status,
        applicationStatus: 'Menunggu',
        persyaratan: s.persyaratan,
      );
      
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        final localDataStr = prefs.getString('local_scholarship_applications');
        List<dynamic> appliedList = localDataStr != null ? jsonDecode(localDataStr) : [];
        if (!appliedList.contains(id)) {
          appliedList.add(id);
          await prefs.setString('local_scholarship_applications', jsonEncode(appliedList));
        }
      } catch (_) {}
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadCustomFile(String filePath) async {
    try {
      return await _repository.uploadCustomFile(filePath);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelScholarshipApplication(String id) async {
    try {
      final index = _scholarships.indexWhere((s) => s.id == id);
      if (index == -1) throw Exception('Beasiswa tidak ditemukan');

      await _repository.cancelScholarshipApplication(id);

      final s = _scholarships[index];
      _scholarships[index] = ScholarshipModel(
        id: s.id,
        title: s.title,
        provider: s.provider,
        deadline: s.deadline,
        coverAmount: s.coverAmount,
        category: s.category,
        description: s.description,
        status: s.status,
        applicationStatus: null,
        persyaratan: s.persyaratan,
      );
      
      notifyListeners();

      try {
        final prefs = await SharedPreferences.getInstance();
        final localDataStr = prefs.getString('local_scholarship_applications');
        if (localDataStr != null) {
          List<dynamic> appliedList = jsonDecode(localDataStr);
          appliedList.remove(id);
          await prefs.setString('local_scholarship_applications', jsonEncode(appliedList));
        }
      } catch (_) {}
    } catch (e) {
      rethrow;
    }
  }
}

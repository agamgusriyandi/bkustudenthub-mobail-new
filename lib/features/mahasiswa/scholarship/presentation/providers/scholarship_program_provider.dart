import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/data/models/scholarship_program_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/data/repositories/scholarship_program_repository.dart';

class ScholarshipProgramProvider extends ChangeNotifier {
  final ScholarshipProgramRepository _repository;

  ScholarshipProgramModel? _program;
  bool _isLoading = false;
  bool _isApplying = false;
  String? _errorMessage;
  bool _applySuccess = false;

  ScholarshipProgramProvider({ScholarshipProgramRepository? repository})
      : _repository = repository ?? ScholarshipProgramRepository();

  ScholarshipProgramModel? get program => _program;
  bool get isLoading => _isLoading;
  bool get isApplying => _isApplying;
  String? get errorMessage => _errorMessage;
  bool get applySuccess => _applySuccess;

  Future<void> fetchProgram(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _program = await _repository.getProgramDetail(id);
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> applyProgram(int id) async {
    _isApplying = true;
    _errorMessage = null;
    _applySuccess = false;
    notifyListeners();

    try {
      await _repository.applyProgram(id);
      _applySuccess = true;
      if (_program != null) {
        _program = ScholarshipProgramModel(
          id: _program!.id,
          nama: _program!.nama,
          deskripsi: _program!.deskripsi,
          penyelenggara: _program!.penyelenggara,
          kategori: _program!.kategori,
          deadline: _program!.deadline,
          nilaiBantuan: _program!.nilaiBantuan,
          kuota: _program!.kuota,
          ipkMin: _program!.ipkMin,
          persyaratan: _program!.persyaratan,
          status: _program!.status,
          isApplied: true,
        );
      }
    } catch (e) {
      _errorMessage = ErrorHelper.getMessage(e);
    }

    _isApplying = false;
    notifyListeners();
  }
}

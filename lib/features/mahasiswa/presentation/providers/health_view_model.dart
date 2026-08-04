import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_booking.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/insurance_claim.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';

class HealthViewModel extends ChangeNotifier {
  final StudentRepository? _repository;

  HealthViewModel({StudentRepository? repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<HealthRecord> _healthRecords = [];
  List<HealthWorker> _healthWorkers = [];
  List<HealthSchedule> _healthSchedules = [];
  List<HealthBooking> _healthBookings = [];
  List<InsuranceClaim> _insuranceClaims = [];
  List<Map<String, dynamic>> _rujukans = [];

  List<HealthRecord> get healthRecords => _healthRecords;
  List<HealthWorker> get healthWorkers => _healthWorkers;
  List<HealthSchedule> get healthSchedules => _healthSchedules;
  List<HealthBooking> get healthBookings => _healthBookings;
  List<InsuranceClaim> get insuranceClaims => _insuranceClaims;
  List<Map<String, dynamic>> get rujukans => _rujukans;

  HealthRecord? get latestHealthRecord =>
      _healthRecords.isNotEmpty ? _healthRecords.first : null;

  Map<int, int> _localRescheduledBookings = {};

  Future<void> _loadRescheduledBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('local_rescheduled_bookings');
      if (jsonStr != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonStr);
        _localRescheduledBookings = decoded.map(
          (key, value) => MapEntry(int.parse(key), value as int),
        );
      }
    } catch (_) {}
  }

  Future<void> _saveRescheduledBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _localRescheduledBookings.map(
          (key, value) => MapEntry(key.toString(), value),
        ),
      );
      await prefs.setString('local_rescheduled_bookings', encoded);
    } catch (_) {}
  }

  void _applyLocalRescheduledBookings() {
    if (_localRescheduledBookings.isEmpty) return;

    final updatedBookings = List<HealthBooking>.from(_healthBookings);
    final updatedSchedules = List<HealthSchedule>.from(_healthSchedules);
    bool changed = false;

    final keys = _localRescheduledBookings.keys.toList();
    for (final bookingId in keys) {
      final newScheduleId = _localRescheduledBookings[bookingId]!;
      final idx = updatedBookings.indexWhere((b) => b.id == bookingId);
      if (idx != -1) {
        final newSIdx = updatedSchedules.indexWhere(
          (s) => s.id == newScheduleId,
        );
        if (newSIdx != -1) {
          final newSchedule = updatedSchedules[newSIdx];

          updatedBookings[idx] = HealthBooking(
            id: updatedBookings[idx].id,
            jadwalId: newScheduleId,
            jadwal: newSchedule,
            mahasiswaId: updatedBookings[idx].mahasiswaId,
            keluhan: updatedBookings[idx].keluhan,
            status: updatedBookings[idx].status,
            alasanPenolakan: updatedBookings[idx].alasanPenolakan,
          );

          final oldScheduleId = updatedBookings[idx].jadwalId;
          final oldSIdx = updatedSchedules.indexWhere(
            (s) => s.id == oldScheduleId,
          );
          if (oldSIdx != -1) {
            final os = updatedSchedules[oldSIdx];
            updatedSchedules[oldSIdx] = HealthSchedule(
              id: os.id,
              tenagaKesId: os.tenagaKesId,
              tenagaKes: os.tenagaKes,
              tanggal: os.tanggal,
              jamMulai: os.jamMulai,
              jamSelesai: os.jamSelesai,
              kuota: os.kuota,
              sisaKuota: os.sisaKuota + 1,
              lokasi: os.lokasi,
              tipeLayanan: os.tipeLayanan,
              catatan: os.catatan,
            );
          }

          final ns = updatedSchedules[newSIdx];
          updatedSchedules[newSIdx] = HealthSchedule(
            id: ns.id,
            tenagaKesId: ns.tenagaKesId,
            tenagaKes: ns.tenagaKes,
            tanggal: ns.tanggal,
            jamMulai: ns.jamMulai,
            jamSelesai: ns.jamSelesai,
            kuota: ns.kuota,
            sisaKuota: ns.sisaKuota - 1,
            lokasi: ns.lokasi,
            tipeLayanan: ns.tipeLayanan,
            catatan: ns.catatan,
          );

          changed = true;
        }
      }
    }

    if (changed) {
      _healthBookings = updatedBookings;
      _healthSchedules = updatedSchedules;
    }
  }

  Future<void> loadInitialData() async {
    if (_repository == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _loadRescheduledBookings();
      final results = await Future.wait([
        _repository!.getHealthRecords().catchError((e) => <HealthRecord>[]),
        _repository!.getRujukans().catchError((e) => <Map<String, dynamic>>[]),
        _repository!.getHealthWorkers().catchError((e) => <HealthWorker>[]),
        _repository!.getHealthSchedules().catchError((e) => <HealthSchedule>[]),
        _repository!.getHealthBookings().catchError((e) => <HealthBooking>[]),
        _repository!.getInsuranceClaims().catchError((e) => <InsuranceClaim>[]),
      ]);

      _healthRecords = results[0] as List<HealthRecord>;
      _rujukans = results[1] as List<Map<String, dynamic>>;
      _healthSchedules = results[3] as List<HealthSchedule>;
      _processHealthWorkers(results[2] as List<HealthWorker>);
      _healthBookings = results[4] as List<HealthBooking>;
      _applyLocalRescheduledBookings();
      _insuranceClaims = results[5] as List<InsuranceClaim>;
    } catch (_) {
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository!.addHealthRecord(record);
        _healthRecords = await _repository!.getHealthRecords();
      } else {
        _healthRecords.insert(0, record);
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createHealthBooking(int scheduleId, String keluhan) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository!.createHealthBooking(
          scheduleId: scheduleId,
          keluhan: keluhan,
        );

        final newSchedule = _healthSchedules.firstWhere(
          (s) => s.id == scheduleId,
          orElse: () => _healthSchedules.first,
        );
        final newBooking = HealthBooking(
          id: DateTime.now().millisecondsSinceEpoch,
          jadwalId: scheduleId,
          jadwal: newSchedule,
          mahasiswaId: 1, 
          keluhan: keluhan,
          status: 'Menunggu',
          alasanPenolakan: '',
        );
        _healthBookings.insert(0, newBooking);

        final sIdx = _healthSchedules.indexWhere((s) => s.id == scheduleId);
        if (sIdx != -1) {
          final s = _healthSchedules[sIdx];
          _healthSchedules[sIdx] = HealthSchedule(
            id: s.id,
            tenagaKesId: s.tenagaKesId,
            tenagaKes: s.tenagaKes,
            tanggal: s.tanggal,
            jamMulai: s.jamMulai,
            jamSelesai: s.jamSelesai,
            kuota: s.kuota,
            sisaKuota: s.sisaKuota - 1,
            lokasi: s.lokasi,
            tipeLayanan: s.tipeLayanan,
            catatan: s.catatan,
          );
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelHealthBooking(String bookingId) async {
    try {
      if (_repository != null) {
        await _repository!.cancelHealthBooking(bookingId);
        final bookingIdInt = int.tryParse(bookingId);
        if (bookingIdInt != null) {
          _localRescheduledBookings.remove(bookingIdInt);
          await _saveRescheduledBookings();
        }
        _healthBookings = await _repository!.getHealthBookings();
        _healthSchedules = await _repository!.getHealthSchedules();
        _applyLocalRescheduledBookings();
      }
    } catch (e) {
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> rescheduleHealthBooking(
    String bookingId,
    int newScheduleId,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository!.rescheduleHealthBooking(bookingId, newScheduleId);

        final bookingIdInt = int.tryParse(bookingId);
        if (bookingIdInt != null) {
          _localRescheduledBookings[bookingIdInt] = newScheduleId;
          await _saveRescheduledBookings();
        }

        final updatedBookings = await _repository!.getHealthBookings();
        final updatedSchedules = await _repository!.getHealthSchedules();

        bool backendUpdated = false;
        if (bookingIdInt != null) {
          final bIdx = updatedBookings.indexWhere((b) => b.id == bookingIdInt);
          if (bIdx != -1 && updatedBookings[bIdx].jadwalId == newScheduleId) {
            backendUpdated = true;
          }
        }

        if (backendUpdated) {
          _healthBookings = updatedBookings;
          _healthSchedules = updatedSchedules;
        } else {
          _healthBookings = updatedBookings;
          _healthSchedules = updatedSchedules;

          if (bookingIdInt != null) {
            final idx = _healthBookings.indexWhere((b) => b.id == bookingIdInt);
            if (idx != -1) {
              final oldScheduleId = _healthBookings[idx].jadwalId;
              final newSchedule = _healthSchedules.firstWhere(
                (s) => s.id == newScheduleId,
                orElse: () => _healthSchedules.first,
              );

              _healthBookings[idx] = HealthBooking(
                id: _healthBookings[idx].id,
                jadwalId: newScheduleId,
                jadwal: newSchedule,
                mahasiswaId: _healthBookings[idx].mahasiswaId,
                keluhan: _healthBookings[idx].keluhan,
                status: _healthBookings[idx].status,
                alasanPenolakan: _healthBookings[idx].alasanPenolakan,
              );

              final oldSIdx = _healthSchedules.indexWhere(
                (s) => s.id == oldScheduleId,
              );
              if (oldSIdx != -1) {
                final os = _healthSchedules[oldSIdx];
                _healthSchedules[oldSIdx] = HealthSchedule(
                  id: os.id,
                  tenagaKesId: os.tenagaKesId,
                  tenagaKes: os.tenagaKes,
                  tanggal: os.tanggal,
                  jamMulai: os.jamMulai,
                  jamSelesai: os.jamSelesai,
                  kuota: os.kuota,
                  sisaKuota: os.sisaKuota + 1,
                  lokasi: os.lokasi,
                  tipeLayanan: os.tipeLayanan,
                  catatan: os.catatan,
                );
              }

              final newSIdx = _healthSchedules.indexWhere(
                (s) => s.id == newScheduleId,
              );
              if (newSIdx != -1) {
                final ns = _healthSchedules[newSIdx];
                _healthSchedules[newSIdx] = HealthSchedule(
                  id: ns.id,
                  tenagaKesId: ns.tenagaKesId,
                  tenagaKes: ns.tenagaKes,
                  tanggal: ns.tanggal,
                  jamMulai: ns.jamMulai,
                  jamSelesai: ns.jamSelesai,
                  kuota: ns.kuota,
                  sisaKuota: ns.sisaKuota - 1,
                  lokasi: ns.lokasi,
                  tipeLayanan: ns.tipeLayanan,
                  catatan: ns.catatan,
                );
              }
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitInsuranceClaim({
    required String provider,
    required String tanggal,
    required String faskes,
    required String deskripsi,
    required double biaya,
    String? filePath,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        final claim = await _repository!.createInsuranceClaim(
          provider: provider,
          tanggal: tanggal,
          faskes: faskes,
          deskripsi: deskripsi,
          biaya: biaya,
        );
        if (filePath != null && filePath.isNotEmpty) {
          await _repository!.uploadInsuranceDocument(
            claimId: claim.id,
            filePath: filePath,
            docNumber: 1,
          );
        }
        _insuranceClaims = await _repository!.getInsuranceClaims();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadInsuranceFile(
    int claimId,
    String filePath,
    int docNumber,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_repository != null) {
        await _repository!.uploadInsuranceDocument(
          claimId: claimId,
          filePath: filePath,
          docNumber: docNumber,
        );
        _insuranceClaims = await _repository!.getInsuranceClaims();
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHealthData() async {
    if (_repository == null) return;
    try {
      final rawWorkers = await _repository!.getHealthWorkers();
      _healthSchedules = await _repository!.getHealthSchedules();
      _processHealthWorkers(rawWorkers);
      _healthBookings = await _repository!.getHealthBookings();
      _applyLocalRescheduledBookings();
      _insuranceClaims = await _repository!.getInsuranceClaims();
      _healthRecords = await _repository!.getHealthRecords();
      _rujukans = await _repository!.getRujukans();
      notifyListeners();
    } catch (_) {}
  }

  void _processHealthWorkers(List<HealthWorker> rawWorkers) {
    final List<HealthWorker> combinedWorkers = [];
    final Set<int> seenIds = {};

    for (final schedule in _healthSchedules) {
      final worker = schedule.tenagaKes;
      if (worker != null && !seenIds.contains(worker.id)) {
        if (!worker.nama.toLowerCase().contains('dummy') &&
            worker.nama.trim().isNotEmpty) {
          combinedWorkers.add(worker);
          seenIds.add(worker.id);
        }
      }
    }

    for (final worker in rawWorkers) {
      if (!seenIds.contains(worker.id)) {
        if (!worker.nama.toLowerCase().contains('dummy') &&
            worker.nama.trim().isNotEmpty) {
          combinedWorkers.add(worker);
          seenIds.add(worker.id);
        }
      }
    }

    _healthWorkers = combinedWorkers;
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/repositories/student_repository.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_booking.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/insurance_claim.dart';

class HealthProvider extends ChangeNotifier {
  final StudentRepository _repository;

  HealthProvider({required StudentRepository repository}) : _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<HealthRecord> _healthRecords = [];
  List<HealthWorker> _healthWorkers = [];
  List<HealthSchedule> _healthSchedules = [];
  List<HealthBooking> _healthBookings = [];
  List<InsuranceClaim> _insuranceClaims = [];

  List<HealthRecord> get healthRecords => _healthRecords;
  List<HealthWorker> get healthWorkers => _healthWorkers;
  List<HealthSchedule> get healthSchedules => _healthSchedules;
  List<HealthBooking> get healthBookings => _healthBookings;
  List<InsuranceClaim> get insuranceClaims => _insuranceClaims;

  HealthRecord? get latestHealthRecord => _healthRecords.isNotEmpty ? _healthRecords.first : null;

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
    } catch (_) {
      // ignore
    }
  }

  Future<void> _saveRescheduledBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _localRescheduledBookings.map((key, value) => MapEntry(key.toString(), value)),
      );
      await prefs.setString('local_rescheduled_bookings', encoded);
    } catch (_) {
      // ignore
    }
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
        final newSIdx = updatedSchedules.indexWhere((s) => s.id == newScheduleId);
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
          final oldSIdx = updatedSchedules.indexWhere((s) => s.id == oldScheduleId);
          if (oldSIdx != -1) {
            final os = updatedSchedules[oldSIdx];
            updatedSchedules[oldSIdx] = HealthSchedule(
              id: os.id, tenagaKesId: os.tenagaKesId, tenagaKes: os.tenagaKes,
              tanggal: os.tanggal, jamMulai: os.jamMulai, jamSelesai: os.jamSelesai,
              kuota: os.kuota, sisaKuota: os.sisaKuota + 1, lokasi: os.lokasi,
              tipeLayanan: os.tipeLayanan, catatan: os.catatan,
            );
          }

          final ns = updatedSchedules[newSIdx];
          updatedSchedules[newSIdx] = HealthSchedule(
            id: ns.id, tenagaKesId: ns.tenagaKesId, tenagaKes: ns.tenagaKes,
            tanggal: ns.tanggal, jamMulai: ns.jamMulai, jamSelesai: ns.jamSelesai,
            kuota: ns.kuota, sisaKuota: ns.sisaKuota - 1, lokasi: ns.lokasi,
            tipeLayanan: ns.tipeLayanan, catatan: ns.catatan,
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

  void _processHealthWorkers(List<HealthWorker> rawWorkers) {
    if (rawWorkers.isEmpty) {
      _healthWorkers = [];
      return;
    }
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

  Future<void> loadHealthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadRescheduledBookings();
      final results = await Future.wait([
        _repository.getHealthWorkers(),
        _repository.getHealthSchedules(),
        _repository.getHealthBookings(),
        _repository.getInsuranceClaims(),
        _repository.getHealthRecords(),
      ]);

      _healthSchedules = results[1] as List<HealthSchedule>;
      _processHealthWorkers(results[0] as List<HealthWorker>);
      _healthBookings = results[2] as List<HealthBooking>;
      _insuranceClaims = results[3] as List<InsuranceClaim>;
      _healthRecords = results[4] as List<HealthRecord>;

      _applyLocalRescheduledBookings();
    } catch (e) {
      debugPrint('Error loading health data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHealthData() async {
    try {
      final rawWorkers = await _repository.getHealthWorkers();
      _healthSchedules = await _repository.getHealthSchedules();
      _processHealthWorkers(rawWorkers);
      _healthBookings = await _repository.getHealthBookings();
      _insuranceClaims = await _repository.getInsuranceClaims();
      _healthRecords = await _repository.getHealthRecords();
      _applyLocalRescheduledBookings();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshHealthData: $e');
    }
  }

  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      await _repository.addHealthRecord(record);
      _healthRecords = await _repository.getHealthRecords();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createHealthBooking(int scheduleId, String keluhan) async {
    try {
      await _repository.createHealthBooking(scheduleId: scheduleId, keluhan: keluhan);
      await refreshHealthData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelHealthBooking(String bookingId) async {
    try {
      await _repository.cancelHealthBooking(bookingId);
      await refreshHealthData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rescheduleHealthBooking(String bookingId, int newScheduleId) async {
    try {
      await _repository.rescheduleHealthBooking(bookingId, newScheduleId);
      _localRescheduledBookings[int.parse(bookingId)] = newScheduleId;
      await _saveRescheduledBookings();
      await refreshHealthData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitInsuranceClaim({
    required String judul,
    required String deskripsi,
    required String tanggalKejadian,
    required String biayaPengajuan,
  }) async {
    try {
      await _repository.createInsuranceClaim(
        provider: judul,
        tanggal: tanggalKejadian,
        faskes: 'Umum',
        deskripsi: deskripsi,
        biaya: double.tryParse(biayaPengajuan) ?? 0.0,
      );
      _insuranceClaims = await _repository.getInsuranceClaims();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> uploadInsuranceFile(String claimId, String type, String filePath) async {
    try {
      await _repository.uploadInsuranceDocument(claimId: int.tryParse(claimId) ?? 0, docNumber: 1, filePath: filePath);
      _insuranceClaims = await _repository.getInsuranceClaims();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

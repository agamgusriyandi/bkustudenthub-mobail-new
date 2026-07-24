import 'package:flutter/foundation.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/schedule.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import '../../../../core/error/error_handler.dart';

class TkScheduleProvider extends ChangeNotifier {
  final TkRepository repository;

  TkScheduleProvider({required this.repository});

  // State
  bool _isLoading = false;
  String? _error;
  List<Schedule> _schedules = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Schedule> get schedules => _schedules;
  List<Schedule> get upcomingSchedules {
    final now = DateTime.now();
    return _schedules
        .where((s) => s.tanggal.isAfter(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
  }

  Future<void> loadSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final futures = await Future.wait([
        repository.getSchedules(),
        repository.getBookings(),
      ]);
      final fetchedSchedules = futures[0] as List<Schedule>;
      final fetchedBookings = futures[1] as List<Booking>;

      // Count bookings per schedule ID (where status is not Ditolak / Dibatalkan)
      final bookingCounts = <int, int>{};
      for (final booking in fetchedBookings) {
        if (booking.status != 'Ditolak' && booking.status != 'Dibatalkan') {
          bookingCounts[booking.jadwalId] =
              (bookingCounts[booking.jadwalId] ?? 0) + 1;
        }
      }

      // Map schedules with calculated bookedCount and sisaKuota
      _schedules =
          fetchedSchedules.map((s) {
            final count = bookingCounts[s.id] ?? 0;
            return Schedule(
              id: s.id,
              tenagaKesId: s.tenagaKesId,
              tanggal: s.tanggal,
              jamMulai: s.jamMulai,
              jamSelesai: s.jamSelesai,
              kuota: s.kuota,
              eventId: s.eventId,
              lokasi: s.lokasi,
              tipeLayanan: s.tipeLayanan,
              catatan: s.catatan,
              isRepeat: s.isRepeat,
              repeatDays: s.repeatDays,
              bookedCount: count,
              sisaKuota: s.kuota - count,
            );
          }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<bool> createSchedule({
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
    required int kuota,
    required String lokasi,
    required String tipeLayanan,
    String? catatan,
    bool isRepeat = false,
    String? repeatDays,
  }) async {
    try {
      final newSchedule = await repository.createSchedule({
        'tanggal': tanggal,
        'jam_mulai': jamMulai,
        'jam_selesai': jamSelesai,
        'kuota': kuota,
        'lokasi': lokasi,
        'tipe_layanan': tipeLayanan,
        'catatan': catatan,
        'is_repeat': isRepeat,
        'repeat_days': repeatDays,
      });

      final wrappedSchedule = Schedule(
        id: newSchedule.id,
        tenagaKesId: newSchedule.tenagaKesId,
        tanggal: newSchedule.tanggal,
        jamMulai: newSchedule.jamMulai,
        jamSelesai: newSchedule.jamSelesai,
        kuota: newSchedule.kuota,
        eventId: newSchedule.eventId,
        lokasi: newSchedule.lokasi,
        tipeLayanan: newSchedule.tipeLayanan,
        catatan: newSchedule.catatan,
        isRepeat: newSchedule.isRepeat,
        repeatDays: newSchedule.repeatDays,
        bookedCount: 0,
        sisaKuota: newSchedule.kuota,
      );

      _schedules.insert(0, wrappedSchedule);
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateSchedule(
    int id, {
    String? tanggal,
    String? jamMulai,
    String? jamSelesai,
    int? kuota,
    String? lokasi,
    String? tipeLayanan,
    String? catatan,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (tanggal != null) data['tanggal'] = tanggal;
      if (jamMulai != null) data['jam_mulai'] = jamMulai;
      if (jamSelesai != null) data['jam_selesai'] = jamSelesai;
      if (kuota != null) data['kuota'] = kuota;
      if (lokasi != null) data['lokasi'] = lokasi;
      if (tipeLayanan != null) data['tipe_layanan'] = tipeLayanan;
      if (catatan != null) data['catatan'] = catatan;

      final updated = await repository.updateSchedule(id, data);
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) {
        final currentBookedCount = _schedules[index].bookedCount ?? 0;
        final wrappedUpdated = Schedule(
          id: updated.id,
          tenagaKesId: updated.tenagaKesId,
          tanggal: updated.tanggal,
          jamMulai: updated.jamMulai,
          jamSelesai: updated.jamSelesai,
          kuota: updated.kuota,
          eventId: updated.eventId,
          lokasi: updated.lokasi,
          tipeLayanan: updated.tipeLayanan,
          catatan: updated.catatan,
          isRepeat: updated.isRepeat,
          repeatDays: updated.repeatDays,
          bookedCount: currentBookedCount,
          sisaKuota: updated.kuota - currentBookedCount,
        );
        _schedules[index] = wrappedUpdated;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      await repository.deleteSchedule(id);
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

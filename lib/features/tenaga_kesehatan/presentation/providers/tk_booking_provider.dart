import 'package:flutter/foundation.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import '../../../../core/error/error_handler.dart';

class TkBookingProvider extends ChangeNotifier {
  final TkRepository repository;

  TkBookingProvider({required this.repository});

  // State
  bool _isLoading = false;
  String? _error;
  List<Booking> _bookings = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Booking> get bookings => _bookings;
  List<Booking> get allBookings => _bookings;

  List<Booking> get pendingBookings =>
      _bookings.where((b) => b.status == 'Menunggu Konfirmasi').toList();

  List<Booking> get confirmedBookings =>
      _bookings.where((b) => b.status == 'Dikonfirmasi').toList();

  List<Booking> get completedBookings =>
      _bookings.where((b) => b.status == 'Selesai').toList();

  List<Booking> get rejectedBookings =>
      _bookings.where((b) => b.status == 'Ditolak').toList();

  int get pendingCount => pendingBookings.length;
  int get confirmedCount => confirmedBookings.length;

  Future<void> loadBookings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bookings = await repository.getBookings();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<bool> acceptBooking(int id) async {
    try {
      await repository.updateBookingStatus(id, 'Dikonfirmasi');
      _updateBookingStatusInList(id, 'Dikonfirmasi');
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectBooking(int id, {String? alasan}) async {
    try {
      await repository.updateBookingStatus(
        id,
        'Ditolak',
        alasanPenolakan: alasan,
      );
      _updateBookingStatusInList(id, 'Ditolak');
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeBooking(int id) async {
    try {
      await repository.updateBookingStatus(id, 'Selesai');
      _updateBookingStatusInList(id, 'Selesai');
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  void _updateBookingStatusInList(int id, String newStatus) {
    final index = _bookings.indexWhere((b) => b.id == id);
    if (index != -1) {
      final old = _bookings[index];
      _bookings[index] = Booking(
        id: old.id,
        mahasiswaId: old.mahasiswaId,
        jadwalId: old.jadwalId,
        nama: old.nama,
        nim: old.nim,
        email: old.email,
        phone: old.phone,
        prodi: old.prodi,
        fakultas: old.fakultas,
        semester: old.semester,
        fotoURL: old.fotoURL,
        jadwalTanggal: old.jadwalTanggal,
        waktu: old.waktu,
        rawDate: old.rawDate,
        tipeLayanan: old.tipeLayanan,
        lokasi: old.lokasi,
        keluhan: old.keluhan,
        status: newStatus,
        alasanPenolakan: old.alasanPenolakan,
        createdAt: old.createdAt,
      );
      notifyListeners();
    }
  }

  Future<bool> createManualBooking(int mahasiswaId, String keluhan) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await repository.createManualBooking(mahasiswaId, keluhan);
      await loadBookings();
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

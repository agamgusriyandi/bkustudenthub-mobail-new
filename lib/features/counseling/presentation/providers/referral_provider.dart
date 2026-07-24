import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/counseling/data/models/counseling_models.dart';
import 'package:bkuhub_mobile/features/counseling/domain/repositories/counseling_repository.dart';
import 'package:bkuhub_mobile/core/utils/error_helper.dart';
import 'dart:developer';

class ReferralProvider extends ChangeNotifier {
  final CounselingRepository repository;

  List<Referral> _referrals = _getDefaultReferrals();
  bool _isLoading = false;
  String? _error;
  bool _isCreating = false;
  bool _isSending = false;

  String? _debugRawResponse;

  ReferralProvider({required this.repository});

  List<Referral> get referrals => _referrals;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreating => _isCreating;
  bool get isSending => _isSending;
  String? get debugRawResponse => _debugRawResponse;

  static List<Referral> _getDefaultReferrals() {
    return [
      Referral(
        id: 1,
        mahasiswaId: 101,
        mahasiswaNama: 'Ahmad Fauzi',
        mahasiswaNim: '220401015',
        tipe: 'Medis',
        alasan: 'Rujukan pemeriksaan psikiatri & konsultasi lanjutan kecemasan akademik.',
        status: 'Sent',
        approvalStatus: 'disetujui',
        pihakTujuan: 'Rumah Sakit Umum Daerah BKU',
        emailTujuan: 'rujukan.rsud@bku.ac.id',
        tanggalDibuat: DateTime.now().subtract(const Duration(days: 3)),
        suratRujiukanUrl: 'https://example.com/rujukan-1.pdf',
      ),
      Referral(
        id: 2,
        mahasiswaId: 102,
        mahasiswaNama: 'Siti Sarah',
        mahasiswaNim: '220401088',
        tipe: 'Akademik',
        alasan: 'Pendampingan konsultasi beban SKS & bimbingan belajar khusus.',
        status: 'Pending',
        approvalStatus: 'pending',
        pihakTujuan: 'Pusat Bimbingan Akademik BKU',
        emailTujuan: 'bimbingan@bku.ac.id',
        tanggalDibuat: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  Future<void> loadReferrals() async {
    _isLoading = true;
    _error = null;
    _debugRawResponse = null;
    notifyListeners();
    try {
      final data = await repository.getReferrals();
      _debugRawResponse = data.toString();
      if (data.isNotEmpty) {
        _referrals = data.map((item) => Referral.fromJson(item)).toList();
      } else {
        _referrals = _getDefaultReferrals();
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error loading referrals: $e');
      _referrals = _getDefaultReferrals();
      _error = null;
      _debugRawResponse = 'Error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createReferral({
    required int mahasiswaId,
    required String tipe,
    required String alasan,
    required String pihakTujuan,
    required String emailTujuan,
    int? bookingId,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();
    try {
      await repository.createReferral(
        mahasiswaId: mahasiswaId,
        tipe: tipe,
        alasan: alasan,
        pihakTujuan: pihakTujuan,
        emailTujuan: emailTujuan,
        bookingId: bookingId,
      );

      // Reload referrals after creating
      await loadReferrals();
      _isCreating = false;
      notifyListeners();
      return true;
    } catch (e) {
      log('Error creating referral: $e');
      _error = ErrorHelper.getMessage(e, fallback: 'Gagal membuat rujukan');
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendReferral(int referralId) async {
    _isSending = true;
    _error = null;
    notifyListeners();
    try {
      await repository.sendReferral(referralId);

      // Reload referrals after sending
      await loadReferrals();
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      log('Error sending referral: $e');
      _error = ErrorHelper.getMessage(e, fallback: 'Gagal mengirim rujukan');
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> confirmReferralReceived(int referralId) async {
    _isSending = true;
    _error = null;
    notifyListeners();
    try {
      await repository.confirmReferralReceived(referralId);

      // Reload referrals after confirming
      await loadReferrals();
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      log('Error confirming referral received: $e');
      _error = ErrorHelper.getMessage(
        e,
        fallback: 'Gagal mengkonfirmasi rujukan',
      );
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  Future<String?> downloadReferral(int referralId) async {
    try {
      return await repository.downloadReferral(referralId);
    } catch (e) {
      log('Error getting referral download URL: $e');
      _error = ErrorHelper.getMessage(e, fallback: 'Gagal mengunduh rujukan');
      return null;
    }
  }
}

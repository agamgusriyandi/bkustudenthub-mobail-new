import 'package:flutter/foundation.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/repositories/tk_repository.dart';
import '../../../../core/error/error_handler.dart';

class TkPatientProvider extends ChangeNotifier {
  final TkRepository repository;

  TkPatientProvider({required this.repository});

  // State
  bool _isLoading = false;
  bool _isLoadingRecord = false;
  bool _isSaving = false;
  String? _error;
  List<Patient> _patients = [];
  List<Patient> _allPatients = [];
  Patient? _selectedPatient;
  List<MedicalRecord> _medicalRecords = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingRecord => _isLoadingRecord;
  bool get isSaving => _isSaving;
  String? get error => _error;
  List<Patient> get patients => _patients;
  Patient? get selectedPatient => _selectedPatient;
  List<MedicalRecord> get medicalRecords => _medicalRecords;

  List<Map<String, dynamic>> _referrals = [];
  List<Map<String, dynamic>> get referrals => _referrals;

  List<Map<String, dynamic>> _psychologists = [];
  List<Map<String, dynamic>> _psychologistSchedules = [];

  List<Map<String, dynamic>> get psychologists => _psychologists;
  List<Map<String, dynamic>> get psychologistSchedules =>
      _psychologistSchedules;

  List<Patient> get recentPatients => _patients.take(10).toList();

  Future<void> loadPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _patients = await repository.getPatients();
      _allPatients = List.from(_patients);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<List<Patient>> searchPatients(String query) async {
    if (query.isEmpty) {
      return List.from(_allPatients);
    }

    try {
      final results = await repository.searchPatients(query);
      return results;
    } catch (e) {
      // Fallback to local search
      final results =
          _allPatients.where((p) {
            return p.nama.toLowerCase().contains(query.toLowerCase()) ||
                p.nim.toLowerCase().contains(query.toLowerCase());
          }).toList();

      return results;
    }
  }

  Future<void> selectPatient(Patient patient) async {
    _selectedPatient = patient;
    _medicalRecords = [];
    notifyListeners();

    // Load medical records
    await loadPatientMedicalRecord(patient.id);
  }

  Future<void> loadPatientMedicalRecord(int patientId) async {
    _isLoadingRecord = true;
    notifyListeners();

    try {
      final data = await repository.getPatientMedicalRecord(patientId);

      // Parse patient data if included
      if (data['patient'] != null && _selectedPatient == null) {
        _selectedPatient = Patient.fromJson(data['patient']);
      }

      // Parse medical records
      final records = data['records'] as List?;
      if (records != null) {
        _medicalRecords =
            records.map((json) => MedicalRecord.fromJson(json)).toList();
        _medicalRecords.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      }

      _isLoadingRecord = false;
      notifyListeners();

      // Load referrals after loading medical records
      await loadPatientReferrals(patientId);
    } catch (e) {
      _isLoadingRecord = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<void> loadPatientReferrals(int patientId) async {
    try {
      final allReferrals = await repository.getReferrals();
      _referrals =
          allReferrals
              .where(
                (r) =>
                    (r['mahasiswa_id'] == patientId ||
                        r['MahasiswaID'] == patientId),
              )
              .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading patient referrals: $e');
    }
  }

  Future<void> loadPsychologists() async {
    try {
      _psychologists = await repository.getPsychologists();
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<void> loadPsychologistSchedules(int id) async {
    try {
      _psychologistSchedules = await repository.getPsychologistSchedules(id);
      notifyListeners();
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
    }
  }

  Future<int?> createScreening({
    required int patientId,
    required double tinggiBadan,
    required double beratBadan,
    required int sistole,
    required int diastole,
    required double suhuTubuh,
    required int denyutNadi,
    required int respirationRate,
    required int spO2,
    required String hasil,
    String? jenisPemeriksaan,
    String? keluhan,
    int? skalaNyeri,
    String? riwayatPenyakit,
    String? alergiObat,
    String? kondisiPsikologis,
    String? tindakanDiberikan,
    String? obatDiberikan,
    String? catatan,
    String? rekomendasi,
    DateTime? tanggalScreening,
    String? sumberPemeriksaan,
    int? gulaDarah,
    String? golonganDarah,
    String? tesButaWarna,
    String? konsumsiObatTerkini,
    bool eskalasiPsikolog = false,
    bool eskalasiFakultas = false,
    int? psikologId,
    int? psikologSlotId,
    int? bookingId,
  }) async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final data = {
        'tinggi_badan': tinggiBadan,
        'berat_badan': beratBadan,
        'sistole': sistole,
        'diastole': diastole,
        'suhu_tubuh': suhuTubuh,
        'denyut_nadi': denyutNadi,
        'respiration_rate': respirationRate,
        'spo2': spO2,
        'hasil': hasil,
        if (jenisPemeriksaan != null) 'jenis_pemeriksaan': jenisPemeriksaan,
        if (keluhan != null) 'keluhan': keluhan,
        if (skalaNyeri != null) 'skala_nyeri': skalaNyeri,
        if (riwayatPenyakit != null) 'riwayat_penyakit': riwayatPenyakit,
        if (alergiObat != null) 'alergi_obat': alergiObat,
        if (kondisiPsikologis != null) 'kondisi_psikologis': kondisiPsikologis,
        if (tindakanDiberikan != null) 'tindakan_diberikan': tindakanDiberikan,
        if (obatDiberikan != null) 'obat_diberikan': obatDiberikan,
        if (catatan != null) 'catatan': catatan,
        if (rekomendasi != null) 'rekomendasi': rekomendasi,
        if (tanggalScreening != null)
          'tanggal':
              "${tanggalScreening.year.toString().padLeft(4, '0')}-${tanggalScreening.month.toString().padLeft(2, '0')}-${tanggalScreening.day.toString().padLeft(2, '0')}",
        if (sumberPemeriksaan != null) 'sumber': sumberPemeriksaan,
        if (gulaDarah != null) 'gula_darah': gulaDarah,
        if (golonganDarah != null) 'golongan_darah': golonganDarah,
        if (tesButaWarna != null) 'buta_warna': tesButaWarna,
        if (konsumsiObatTerkini != null) 'konsumsi_obat': konsumsiObatTerkini,
        'eskalasi_psikolog': eskalasiPsikolog,
        'eskalasi_fakultas': eskalasiFakultas,
        if (psikologId != null) 'psikolog_id': psikologId,
        if (psikologSlotId != null) 'psikolog_slot_id': psikologSlotId,
        if (bookingId != null) 'booking_id': bookingId,
        'akhiri_sesi': true, // Always finish session to prevent reuse
      };

      final record = await repository.createScreening(patientId, data);
      _medicalRecords.insert(0, record);
      _isSaving = false;
      notifyListeners();
      return record.id;
    } catch (e) {
      _isSaving = false;
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> createReferral({
    required int patientId,
    int? selfScreeningId,
    required String faskesTujuan,
    required String alasanRujukan,
    required String keluhanUtama,
    required double suhuTubuh,
    required int sistole,
    required int diastole,
    required int denyutNadi,
    required int respirationRate,
    required int spo2,
    required String diagnosis,
    required String rekomendasiAsuransi,
  }) async {
    try {
      await repository.createReferral({
        'mahasiswa_id': patientId,
        if (selfScreeningId != null) 'self_screening_id': selfScreeningId,
        'faskes_tujuan': faskesTujuan,
        'alasan_rujukan': alasanRujukan,
        'keluhan_utama': keluhanUtama,
        'suhu_tubuh': suhuTubuh,
        'sistole': sistole,
        'diastole': diastole,
        'denyut_nadi': denyutNadi,
        'respiration_rate': respirationRate,
        'spo2': spo2,
        'diagnosis': diagnosis,
        'rekomendasi_asuransi': rekomendasiAsuransi,
      });
      return true;
    } catch (e) {
      _error = ErrorHandler.getMessage(e);
      notifyListeners();
      return false;
    }
  }

  void clearSelection() {
    _selectedPatient = null;
    _medicalRecords = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tk_profile.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/schedule.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/booking.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/patient.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_insurance_claim_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_bap_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_clinical_report_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/tenaga_kesehatan.dart';

abstract class TkRepository {
  // Profile
  Future<TkProfile> getProfile();
  Future<TkProfile> updateProfile(Map<String, dynamic> data);
  Future<String> uploadAvatar(String imagePath);
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  );

  // Dashboard
  Future<Map<String, dynamic>> getDashboard();
  Future<List<Map<String, dynamic>>> getActivities();

  // Schedules
  Future<List<Schedule>> getSchedules();
  Future<Schedule> createSchedule(Map<String, dynamic> data);
  Future<Schedule> updateSchedule(int id, Map<String, dynamic> data);
  Future<void> deleteSchedule(int id);

  // Bookings
  Future<List<Booking>> getBookings();
  Future<Booking> getBookingDetail(int id);
  Future<Booking> updateBookingStatus(
    int id,
    String status, {
    String? alasanPenolakan,
  });
  Future<void> createManualBooking(int mahasiswaId, String keluhan);

  // Patients
  Future<List<Patient>> getPatients();
  Future<List<Patient>> searchPatients(String query);
  Future<Map<String, dynamic>> getPatientMedicalRecord(int patientId);

  // Screening & Medical Records
  Future<List<MedicalRecord>> getAllMedicalRecords();
  Future<MedicalRecord> createScreening(
    int patientId,
    Map<String, dynamic> data,
  );

  // Referral (Rujukan)
  Future<List<Map<String, dynamic>>> getPsychologists();
  Future<List<Map<String, dynamic>>> getPsychologistSchedules(int id);
  Future<void> createReferral(Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getReferrals();

  // Insurance Claims
  Future<List<TkInsuranceClaimModel>> getInsuranceClaims();
  Future<TkInsuranceClaimModel> updateInsuranceClaimStatus(
    int id,
    String status, {
    String? catatanReview,
  });

  // BAP Kesehatan
  Future<List<TkBapModel>> getBAPs();
  Future<TkBapModel> getBapDetail(int id);
  Future<TkBapModel> createBAP(Map<String, dynamic> data);
  Future<TkBapModel> updateBAP(int id, Map<String, dynamic> data);
  Future<void> deleteBAP(int id);
  Future<String> exportBAPPdf(int id);
  Future<List<String>> uploadBapPhotos(List<String> filePaths);

  // Clinical Reports
  Future<TkClinicalReportModel> getClinicalReports({
    String? startDate,
    String? endDate,
  });
  Future<String> exportReportExcel();
  Future<String> exportOfflineRegistrationFormPdf();
  Future<String> exportReportPdf();

  // Admin Tenaga Kesehatan CRUD
  Future<List<TenagaKesehatan>> getTenagaKesehatanList();
  Future<bool> createTenagaKesehatan(Map<String, dynamic> data);
  Future<bool> updateTenagaKesehatan(int id, Map<String, dynamic> data);
  Future<bool> deleteTenagaKesehatan(int id);
}

import '../entities/achievement.dart';
import '../entities/scholarship.dart';
import '../entities/mission.dart';
import '../entities/counseling_session.dart';
import '../entities/aspiration.dart';
import '../entities/health_record.dart';
import '../entities/organization_history.dart';
import '../entities/campus_news.dart';
import '../entities/faculty_progress.dart';
import '../entities/pkkmb_event.dart';
import '../entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import '../entities/health_booking.dart';
import '../entities/insurance_claim.dart';

abstract class StudentRepository {
  Future<Map<String, dynamic>> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  );
  Future<String> uploadAvatar(String filePath);
  Future<List<FacultyProgress>> getFacultyStatistics();
  Future<List<Achievement>> getAchievements();
  Future<List<Scholarship>> getScholarships();
  Future<List<Mission>> getMissions();
  Future<List<CounselingSession>> getCounselingSessions();
  Future<List<Psychologist>> getPsychologists();
  Future<List<Map<String, dynamic>>> getPsychologistSchedules(
    String psychologistId,
  );
  Future<List<Aspiration>> getAspirations();
  Future<Aspiration> getAspirationDetail(String id);
  Future<List<HealthRecord>> getHealthRecords();
  Future<List<Map<String, dynamic>>> getRujukans();
  Future<List<OrganizationHistory>> getOrganizationHistory();
  Future<List<PkkmbEvent>> getPkkmbEvents();
  Future<List<CampusEventSchedule>> getCampusEvents();
  Future<List<CampusNews>> getCampusNews();
  Future<Map<String, dynamic>> getDashboardStats();

  Future<void> addAchievement(Achievement achievement);
  Future<void> updateAchievement(String id, Achievement achievement);
  Future<void> deleteAchievement(String id);
  Future<void> applyForScholarship(
    String scholarshipId,
    String motivasi, {
    String? ktmKtpPath,
    String? sertifikatPath,
    String? transkripPath,
    String? customAnswers,
    String? rubrikAnswers,
  });

  Future<void> cancelScholarshipApplication(String scholarshipId);

  Future<String> uploadCustomFile(String filePath);
  Future<void> submitAspiration(Aspiration aspiration);
  Future<void> addHealthRecord(HealthRecord record);
  Future<void> bookCounseling(CounselingSession session);
  Future<void> addOrganizationHistory(OrganizationHistory org);
  Future<void> submitAppeal(String alasan);
  Future<void> updateOrganizationHistory(String id, OrganizationHistory org);
  Future<void> deleteOrganizationHistory(String id);
  Future<String> uploadDokumentasiOrganisasi(String id, String filePath);
  Future<List<Map<String, dynamic>>> getOrmawaList();
  Future<List<Map<String, dynamic>>> getPendaftaranList();
  Future<List<Map<String, dynamic>>> getOrmawaDivisions(String ormawaId);
  Future<Map<String, dynamic>> getRecruitmentFields(String ormawaId);
  Future<String> uploadRecruitmentFile(String filePath);
  Future<void> daftarOrmawa({
    required String ormawaId,
    required String alasan,
    String? cvUrl,
    String? divisi,
    String? divisiPilihanDua,
    Map<String, dynamic>? customAnswers,
  });

  // Health Worker Bookings
  Future<List<HealthWorker>> getHealthWorkers();
  Future<List<HealthSchedule>> getHealthSchedules();
  Future<List<HealthBooking>> getHealthBookings();
  Future<void> createHealthBooking({
    required int scheduleId,
    required String keluhan,
  });
  Future<void> cancelHealthBooking(String bookingId);
  Future<void> rescheduleHealthBooking(String bookingId, int newScheduleId);

  // Insurance Claims
  Future<List<InsuranceClaim>> getInsuranceClaims();
  Future<InsuranceClaim> createInsuranceClaim({
    required String provider,
    required String tanggal,
    required String faskes,
    required String deskripsi,
    required double biaya,
  });
  Future<void> uploadInsuranceDocument({
    required int claimId,
    required String filePath,
    required int docNumber,
  });

  Future<List<Map<String, dynamic>>> getIuranList();
  Future<void> bayarIuran({required String detailId, required String filePath});
}

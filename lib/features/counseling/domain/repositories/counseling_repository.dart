import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';

abstract class CounselingRepository {
  Future<Psychologist> getProfile();
  Future<void> updateProfile(Map<String, dynamic> data);
  Future<void> updateAvailability(bool isAvailable);
  Future<String> uploadAvatar(String imagePath);
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  );
  Future<Map<String, dynamic>> getDashboard();
  Future<List<Map<String, dynamic>>> getBookings();
  Future<void> updateBookingStatus(
    String id,
    String status, {
    String? note,
    String? linkMeeting,
  });
  Future<void> confirmBooking(
    String bookingId, {
    String? meetingLink,
    String? notes,
  });
  Future<void> completeBooking(String bookingId, {String? notes});
  Future<void> rejectBooking(String bookingId, String reason);
  Future<List<Map<String, dynamic>>> getSchedules();
  Future<List<Map<String, dynamic>>> saveSchedules(
    List<Map<String, dynamic>> schedules,
  );
  Future<List<Map<String, dynamic>>> getPatients();
  Future<Map<String, dynamic>> getMedicalRecord(String patientId);
  Future<void> createSessionNote(String patientId, Map<String, dynamic> data);
  Future<void> updatePatientStatus(
    String patientId,
    String status, {
    String? notes,
  });
  Future<Map<String, dynamic>> getAssessments();
  Future<void> createAssessment(Map<String, dynamic> data);
  Future<void> submitAssessmentResult(Map<String, dynamic> data);
  Future<Map<String, dynamic>> getAnalytics();
  Future<List<Map<String, dynamic>>> getReferrals();
  Future<Map<String, dynamic>> createReferral({
    required int mahasiswaId,
    required String tipe,
    required String alasan,
    required String pihakTujuan,
    required String emailTujuan,
    int? bookingId,
  });
  Future<Map<String, dynamic>> sendReferral(int referralId);
  Future<Map<String, dynamic>> confirmReferralReceived(int referralId);
  Future<String> downloadReferral(int referralId);
  Future<String> exportPatientsRecapPDF();
  Future<String> exportSessionNotePDF(String id);
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead();
  Future<void> deleteNotification(String id);
}

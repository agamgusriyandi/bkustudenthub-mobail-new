import '../entities/ormawa_notification.dart';
import '../entities/ormawa_proposal.dart';
import '../entities/ormawa_agenda.dart';
import '../entities/ormawa_attendance.dart';
import '../entities/ormawa_finance.dart';
import '../entities/ormawa_lpj.dart';
import '../entities/ormawa_aspiration.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_role.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_financial_setting.dart';

abstract class OrmawaRepository {
  Future<List<OrmawaProposal>> getProposals(String ormawaId);
  Future<List<OrmawaAgenda>> getAgendas(String ormawaId);
  Future<Map<String, dynamic>> getMembersData(
    String ormawaId, {
    String? periode,
  });
  Future<void> regenerateMembers(String ormawaId);
  Future<void> createDivisionInline(String ormawaId, String name);

  Future<Map<String, dynamic>> getStats(String ormawaId);
  Future<Map<String, dynamic>> getGamifikasiSummary();
  Future<List<Map<String, dynamic>>> getGamifikasiHistory();
  Future<List<Map<String, dynamic>>> getGamifikasiLeaderboard();
  Future<List<Map<String, dynamic>>> getGamifikasiRules();

  Future<void> addProposal(OrmawaProposal proposal);
  Future<void> createProposal(Map<String, dynamic> data);
  Future<void> updateProposal(OrmawaProposal proposal);
  Future<void> updateProposalData(String id, Map<String, dynamic> data);
  Future<void> resubmitProposal(String proposalId);
  Future<void> deleteProposal(String proposalId);

  Future<void> addMember(String ormawaId, Map<String, dynamic> data);
  Future<void> updateMember(String id, Map<String, dynamic> data);
  Future<void> deleteMember(String id);

  Future<List<Map<String, dynamic>>> getStudents();

  Future<void> addAgenda(String ormawaId, Map<String, dynamic> data);
  Future<void> updateAgenda(String id, Map<String, dynamic> data);
  Future<void> deleteAgenda(String id);

  Future<List<OrmawaFinance>> getFinance(String ormawaId);
  Future<void> addFinance(String ormawaId, Map<String, dynamic> data);
  Future<void> deleteFinance(String id);
  Future<Map<String, dynamic>?> getBudgetStatus(String ormawaId);
  Future<String> generateReportNumber(String ormawaId);
  Future<Map<String, dynamic>> getBankAccount(String ormawaId);
  Future<void> updateBankAccount(String ormawaId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getIurans(String ormawaId);
  Future<void> createIuran(String ormawaId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getIuranMembers(String iuranId, String ormawaId);
  Future<void> verifyIuranPayment(String detailId, String ormawaId, Map<String, dynamic> data);
  Future<List<Map<String, dynamic>>> getMyIurans(String ormawaId);
  Future<void> payMyIuran(String detailId, String ormawaId, Map<String, dynamic> data);

  Future<List<OrmawaLPJ>> getLPJs(String ormawaId);
  Future<List<dynamic>> getLpjDocuments(String lpjId);
  Future<void> addLPJ(Map<String, dynamic> data);
  Future<void> updateLPJ(String id, Map<String, dynamic> data);
  Future<void> deleteLPJ(String id);

  Future<List<OrmawaAspiration>> getAspirations(String ormawaId);
  Future<void> respondToAspiration(String id, Map<String, dynamic> data);

  Future<List<OrmawaAnnouncement>> getAnnouncements(String ormawaId);
  Future<void> createAnnouncement(Map<String, dynamic> data);
  Future<void> updateAnnouncement(String id, Map<String, dynamic> data);
  Future<void> deleteAnnouncement(String id);

  Future<List<OrmawaAttendance>> getAttendance(String eventId);
  Future<void> submitAttendance(
    String eventId,
    String mahasiswaId,
    String status,
  );

  Future<List<Map<String, dynamic>>> getAbsensiManagement(String ormawaId);
  Future<void> createAbsensiManagement(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getAbsensiManagementDetail(String id);
  Future<void> updateAbsensiManagement(String id, Map<String, dynamic> data);

  Future<Map<String, dynamic>> getRoleDetails(String roleId);

  Future<List<OrmawaRole>> getRoles();
  Future<void> createRole(Map<String, dynamic> data);
  Future<void> updateRole(String id, Map<String, dynamic> data);
  Future<void> deleteRole(String id);

  Future<List<OrmawaDivision>> getDivisions({String? ormawaId});
  Future<void> createDivision(Map<String, dynamic> data);
  Future<void> deleteDivision(String id);
  Future<List<OrmawaNotification>> getNotifications(String ormawaId);
  Future<void> markNotificationAsRead(String id);
  Future<void> markAllNotificationsAsRead(String ormawaId);
  Future<void> deleteNotification(String id);
  Future<String?> getActiveAcademicYear();

  Future<Map<String, dynamic>> getRecruitmentSettings(String ormawaId);
  Future<void> updateRecruitmentSettings(
    String ormawaId,
    Map<String, dynamic> data,
  );
  Future<List<Map<String, dynamic>>> getRecruitmentApplicants(String ormawaId);
  Future<void> reviewRecruitmentApplicant(
    String applicantId,
    String status, {
    String? role,
    String? divisi,
    String? rejectionReason,
  });
  Future<List<Map<String, dynamic>>> getRecruitmentFormFields(String ormawaId);
  Future<void> saveRecruitmentFormFields(
    String ormawaId,
    List<Map<String, dynamic>> fields,
  );

  Future<Map<String, dynamic>> getOrmawaSettings(String ormawaId);
  Future<void> updateOrmawaSettings(String ormawaId, Map<String, dynamic> data);

  Future<String?> uploadFile(String filePath);

  Future<List<OrmawaOrganisasi>> getOrganisasiList();
  Future<void> createOrganisasi(Map<String, dynamic> data);
  Future<void> updateOrganisasi(String id, Map<String, dynamic> data);
  Future<void> deleteOrganisasi(String id);

  Future<List<OrmawaFinancialSetting>> getFinancialSettings({String? ormawaId, String? periode});
  Future<List<OrmawaFinancialAuditLog>> getFinancialAuditLogs(String ormawaId);
  Future<void> updateFinancialSetting(Map<String, dynamic> data);
}
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/network/api_interceptors.dart';
import 'package:bkuhub_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:bkuhub_mobile/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:bkuhub_mobile/features/auth/presentation/pages/splash_screen.dart';
import 'package:bkuhub_mobile/features/auth/presentation/pages/web_redirect_screen.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/features/main/presentation/pages/main_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/main/presentation/pages/ormawa_main_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/organisasi/presentation/pages/organisasi_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_main_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/student_counseling_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';

import 'package:bkuhub_mobile/features/counseling/presentation/pages/session_note_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/counseling_booking_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/schedule_management_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/add_schedule_slot_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/patient_list_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/notifications/presentation/pages/notifications_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/notifications/presentation/pages/ormawa_notifications_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_analytics_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/create_referral_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_bookings_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_edit_profile_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_notifications_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/health_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/referral_management_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/assessment_management_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/assessment_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/admin_psychologist_list_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/create_psychologist_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/psychologist_detail_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/edit_psychologist_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/patient_medical_record_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/create_medical_record_screen.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/pages/all_schedules_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_add_schedule_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_patient_detail_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_screening_input_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_qr_scan_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_notifications_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_insurance_claims_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_bap_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_bap_form_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_clinical_reports_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_referral_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_bap_model.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_emr_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_live_examination_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/create_patient_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_patient_record_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_medical_records_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_screenings_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_insurance_review_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_all_schedules_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/admin_tk_list_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/create_tk_screen.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/edit_tk_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_stage_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_session_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_score_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_attendance_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_invitations_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_banding_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_qr_scan_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_handbook_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_timeline_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_remedial_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_certificate_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/providers/kencana_remedial_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/providers/kencana_certificate_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_main_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_mentee_detail_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_recruit_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_absence_requests_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_groups_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_group_detail_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_available_students_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_notes_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_note_detail_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_essay_grading_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_session_attendance_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_materials_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_handbook_review_detail_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_handbook_review_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_scoring_detail_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_notifications_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_handbook_list_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_banding_screen.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/pages/mentor_banding_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_profile_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_security_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/struktur/presentation/pages/ormawa_struktur_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/ormawa_recruitment_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/aspirasi/presentation/pages/ormawa_aspirasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_pipeline_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_review_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/create_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/ormawa_proposal_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/ormawa_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/create_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/edit_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/ormawa_pengumuman_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_kalender_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/kalender/presentation/pages/ormawa_agenda_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_settings_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/struktur/presentation/pages/manage_struktur_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/ormawa_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/create_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/anggota/presentation/pages/edit_anggota_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_pipeline_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_review_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/create_lpj_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/edit_lpj_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/lpj/presentation/pages/ormawa_lpj_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/ormawa_keuangan_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/create_keuangan_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/ormawa_mutasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/keuangan/presentation/pages/ormawa_iuran_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/jadwal/presentation/pages/create_kegiatan_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/jadwal/presentation/pages/ormawa_jadwal_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/staf/presentation/pages/ormawa_staf_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/gamifikasi/presentation/pages/ormawa_gamifikasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pagu/presentation/pages/ormawa_pagu_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/ormawa_organisasi_list_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/create_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/ormawa_organisasi_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/edit_organisasi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/rbac/presentation/pages/ormawa_rbac_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_management_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/create_absensi_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_detail_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/edit_absensi_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presensi/presentation/pages/presensi_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/counseling_history_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/counseling/presentation/pages/medical_record_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/self_screening_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/berita/presentation/pages/berita_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/create_achievement_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/edit_achievement_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_program_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/medical_referral_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/insurance_claim_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/quiz_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/assignment_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_application_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/recruitment_history_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/recruitment_form_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/pages/recruitment_settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String webRedirect = '/web-redirect';
  static const String studentMain = '/main';
  static const String ormawaMain = '/ormawa';
  static const String organisasi = '/organisasi';
  static const String health = '/health';
  static const String psychologistMain = '/psychologist';
  static const String tkMain = '/tenagakes';
  static const String mentorKencanaMain = '/mentor-kencana';
  static const String mentorMenteeDetail = '/mentor-kencana/mentee/:id';
  static const String mentorRecruit = '/mentor-kencana/recruit';
  static const String mentorAbsenceRequests =
      '/mentor-kencana/absence-requests';
  static const String mentorGroups = '/mentor-kencana/groups';
  static const String mentorGroupDetail = '/mentor-kencana/groups/:id';
  static const String mentorAvailableStudents =
      '/mentor-kencana/available-students';
  static const String mentorNotes = '/mentor-kencana/notes';
  static const String mentorNoteDetail = '/mentor-kencana/notes/:id';
  static const String mentorEssayGrading = '/mentor-kencana/essay-grading';
  static const String mentorSessionAttendance =
      '/mentor-kencana/session-attendance/:sessionId';
  static const String mentorSessionAttendanceAlt =
      '/mentor-kencana/attendance/session/:sessionId';
  static const String mentorMaterials = '/mentor-kencana/materials';
  static const String mentorHandbookDetail = '/mentor-kencana/handbook/:id';
  static const String mentorHandbookReview = '/mentor-kencana/handbook/review/:id';
  static const String mentorScoringDetail = '/mentor-kencana/scoring/:sessionId';
  static const String mentorNotifications = '/mentor-kencana/notifications';
  static const String mentorHandbookList = '/mentor-kencana/handbook';
  static const String mentorBanding = '/mentor-banding';
  static const String mentorBandingDetail = '/mentor-banding-detail';
  static const String kencanaStage = '/kencana/stage/:id';
  static const String kencanaSession = '/kencana/session/:id';
  static const String kencanaScore = '/kencana/score';
  static const String kencanaAttendance = '/kencana/attendance';
  static const String kencanaInvitations = '/kencana/invitations';
  static const String kencanaBanding = '/kencana/banding';
  static const String kencanaHandbook = '/kencana/handbook';
  static const String kencanaTimeline = '/kencana/timeline';
  static const String kencanaRemedial = '/kencana/remedial';
  static const String kencanaCertificate = '/kencana/certificate';
  static const String kencanaQuiz = '/kencana/quiz/:id';
  static const String kencanaAssignment = '/kencana/assignment/:id';
  static const String presensi = '/presensi';
  static const String selfScreening = '/health/self-screening';
  static const String counselingHistory = '/counseling/history';
  static const String medicalRecordDetail = '/counseling/medical-record';
  static const String studentVoice = '/student/voice';
  static const String studentVoiceDetail = '/student/voice/:id';
  static const String medicalReferral = '/health/referrals';
  static const String insuranceClaim = '/health/insurance';
  static const String scholarshipDetail = '/scholarship/pengajuan/:id';

  // Berita Routes
  static const String beritaDetail = '/berita/:id';

  // Achievement Routes
  static const String createAchievement = '/achievement/create';
  static const String editAchievement = '/achievement/edit';

  // Scholarship Program Routes
  static const String scholarshipProgramDetail = '/scholarship/program/:id';
  static const String scholarshipApply = '/scholarship/apply/:id';

  // Counseling Routes
  static const String psychologistAnalytics = '/counseling/analytics';
  static const String createReferral = '/counseling/referrals/create';
  static const String psychologistBookings = '/counseling/bookings';
  static const String studentCounseling = '/counseling/student';
  static const String sessionNote = '/counseling/session-note';
  static const String counselingBooking = '/counseling/booking';
  static const String scheduleManagement = '/counseling/schedule-management';
  static const String addScheduleSlot = '/counseling/add-slot';
  static const String patientList = '/counseling/patients';
  static const String psychologistEditProfile = '/counseling/edit-profile';
  static const String referralManagement = '/counseling/referrals';
  static const String assessmentManagement = '/counseling/assessments';
  static const String assessment = '/counseling/assessment';

  // Admin Psychology Routes
  static const String adminPsychologistList = '/counseling/admin/psikolog';
  static const String createPsychologist = '/counseling/admin/psikolog/create';
  static const String psychologistDetail = '/counseling/admin/psikolog/:id';
  static const String editPsychologist = '/counseling/admin/psikolog/:id/edit';
  static const String patientMedicalRecord = '/counseling/patients/:id/medical-record';
  static const String createMedicalRecord = '/counseling/patients/:id/medical-record/create';
  static const String allSchedules = '/counseling/all-schedules';

  // TK (Tenaga Kesehatan) Routes
  static const String tkAddSchedule = '/tk/add-schedule';
  static const String tkPatientDetail = '/tk/patient';
  static const String tkScreening = '/tk/screening';
  static const String tkQrScan = '/tk/qr-scan';
  static const String tkInsuranceClaims = '/tk/insurance-claims';
  static const String tkBap = '/tk/bap';
  static const String tkBapForm = '/tk/bap/form';
  static const String tkClinicalReports = '/tk/reports';
  static const String tkReferralManagement = '/tk/referrals';
  static const String tkEmr = '/tk/emr';
  static const String tkLiveExam = '/tk/live-exam';
  static const String tkCreatePatient = '/tk/create-patient';
  static const String tkPatientRecord = '/tk/patient-record';
  static const String tkMedicalRecords = '/tk/medical-records';
  static const String tkScreenings = '/tk/screenings';
  static const String tkInsuranceReview = '/tk/insurance-review';
  static const String tkAllSchedules = '/tk/all-schedules';
  static const String adminTkList = '/tk/admin/list';
  static const String adminCreateTk = '/tk/admin/create';
  static const String adminEditTk = '/tk/admin/edit';

  // Notification Routes
  static const String studentNotifications = '/notifications/student';
  static const String ormawaNotifications = '/notifications/ormawa';
  static const String psychologistNotifications = '/notifications/psychologist';
  static const String tkNotifications = '/notifications/tk';

  // Ormawa Sub-Routes
  static const String ormawaSettings = '/ormawa/settings';
  static const String ormawaProfile = '/ormawa/profile';
  static const String ormawaSecurity = '/ormawa/security';
  static const String ormawaStruktur = '/ormawa/struktur';
  static const String ormawaRecruitment = '/ormawa/recruitment';
  static const String ormawaAspirasi = '/ormawa/aspirasi';
  static const String ormawaProposal = '/ormawa/proposal';
  static const String ormawaAgenda = '/ormawa/agenda';
  static const String ormawaPengumuman = '/ormawa/pengumuman';
  static const String ormawaStrukturManage = '/ormawa/struktur/manage';
  static const String ormawaAnggotaDetail = '/ormawa/anggota-detail';
  static const String ormawaRecruitmentHistory = '/ormawa/recruitment/history';
  static const String ormawaRecruitmentForm = '/ormawa/recruitment/form';
  static const String ormawaRecruitmentSettings = '/ormawa/recruitment/settings';
  static const String ormawaCreateProposal = '/ormawa/proposal/create';
  static const String ormawaProposalDetail = '/ormawa/proposal/detail';
  static const String ormawaAgendaDetail = '/ormawa/agenda/detail';

  // Ormawa RBAC Route
  static const String ormawaRbac = '/ormawa/rbac';

  // Ormawa Phase 2 Routes
  static const String ormawaLpj = '/ormawa/lpj';
  static const String ormawaLpjCreate = '/ormawa/lpj/create';
  static const String ormawaLpjDetail = '/ormawa/lpj/detail';
  static const String ormawaLpjEdit = '/ormawa/lpj/edit';
  static const String ormawaKeuanganDetail = '/ormawa/keuangan/detail';
  static const String ormawaKeuanganEdit = '/ormawa/keuangan/edit';
  static const String ormawaMutasi = '/ormawa/mutasi';
  static const String ormawaIuran = '/ormawa/iuran';
  static const String ormawaAnggotaCreate = '/ormawa/anggota/create';
  static const String ormawaAnggotaEdit = '/ormawa/anggota/edit';
  static const String ormawaJadwalCreate = '/ormawa/jadwal/create';
  static const String ormawaJadwalDetail = '/ormawa/jadwal/detail';
  static const String ormawaJadwalEdit = '/ormawa/jadwal/edit';
  static const String ormawaPengumumanCreate = '/ormawa/pengumuman/create';
  static const String ormawaPengumumanDetail = '/ormawa/pengumuman/detail';
  static const String ormawaPengumumanEdit = '/ormawa/pengumuman/edit';
  static const String ormawaStaf = '/ormawa/staf';
  static const String ormawaGamifikasi = '/ormawa/gamifikasi';
  static const String ormawaPagu = '/ormawa/pagu';

  // Ormawa Organisasi Routes
  static const String ormawaOrganisasi = '/ormawa/organisasi';
  static const String ormawaOrganisasiCreate = '/ormawa/organisasi/create';
  static const String ormawaOrganisasiDetail = '/ormawa/organisasi/detail';
  static const String ormawaOrganisasiEdit = '/ormawa/organisasi/edit';

  // Ormawa Absensi Management Routes
  static const String ormawaAbsensiManagement = '/ormawa/absensi-management';
  static const String ormawaAbsensiManagementCreate = '/ormawa/absensi-management/create';
  static const String ormawaAbsensiManagementDetail = '/ormawa/absensi-management/detail';
  static const String ormawaAbsensiManagementEdit = '/ormawa/absensi-management/edit';
  static const String ormawaProposalPipeline = '/ormawa/proposal-pipeline';
  static const String ormawaLpjPipeline = '/ormawa/lpj-pipeline';
  static const String ormawaProposalReview = '/ormawa/proposal-review';
  static const String ormawaLpjReview = '/ormawa/lpj-review';
  static const String ormawaKeuanganCreate = '/ormawa/keuangan/create';

  // Compatibility aliases
  static const String main = studentMain;
  static const String ormawa = ormawaMain;

  static final GoRouter router = GoRouter(
    navigatorKey:
        apiNavigatorKey, // For 401 handling - allows navigation from interceptors
    initialLocation: splash,
    redirect: (context, state) {
      final role = AuthService().currentRole;
      final path = state.uri.path;

      // Allow public routes
      if (path == splash ||
          path == login ||
          path == forgotPassword ||
          path == webRedirect) {
        return null;
      }

      // Guest trying to access protected routes -> return to login
      if (role == UserRole.guest) {
        return login;
      }

      // Redirect from root or main screen to role-specific dashboard if role is not student
      if (path == studentMain || path == '/' || path.isEmpty) {
        if (role == UserRole.ormawa) {
          return ormawaMain;
        } else if (role == UserRole.psychologist) {
          return psychologistMain;
        } else if (role == UserRole.tenagaKesehatan) {
          return tkMain;
        } else if (role == UserRole.mentorKencana) {
          return mentorKencanaMain;
        }
      }

      // Role-based route guards
      if (path.startsWith('/ormawa') && role != UserRole.ormawa) {
        return studentMain;
      }
      if ((path.startsWith('/tk') || path.startsWith('/tenagakes')) &&
          role != UserRole.tenagaKesehatan) {
        return studentMain;
      }
      if ((path.startsWith('/counseling') || path == psychologistMain) &&
          role != UserRole.psychologist &&
          role != UserRole.student &&
          role != UserRole.tenagaKesehatan) {
        return studentMain;
      }
      if (path.startsWith('/kencana') && role != UserRole.student) {
        return studentMain;
      }
      if (path.startsWith('/presensi') && role != UserRole.student) {
        return studentMain;
      }
      if (path.startsWith('/mentor-kencana') &&
          role != UserRole.mentorKencana) {
        return studentMain;
      }

      return null;
    },
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: webRedirect,
        builder: (context, state) => const WebRedirectScreen(),
      ),
      GoRoute(
        path: studentMain,
        builder: (context, state) => const MainScreen(),
      ),
      GoRoute(
        path: ormawaMain,
        builder: (context, state) => const OrmawaMainScreen(),
      ),
      GoRoute(
        path: organisasi,
        builder: (context, state) => const OrganisasiScreen(),
      ),
      GoRoute(path: health, builder: (context, state) => const HealthScreen()),
      GoRoute(
        path: mentorKencanaMain,
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = int.tryParse(tabStr ?? '0') ?? 0;
          return MentorMainScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: mentorMenteeDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MentorMenteeDetailScreen(studentId: id);
        },
      ),
      GoRoute(
        path: mentorRecruit,
        builder: (context, state) => const MentorRecruitScreen(),
      ),
      GoRoute(
        path: mentorAbsenceRequests,
        builder: (context, state) => const MentorAbsenceRequestsScreen(),
      ),
      GoRoute(
        path: mentorGroups,
        builder: (context, state) => const MentorGroupsScreen(),
      ),
      GoRoute(
        path: mentorGroupDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MentorGroupDetailScreen(groupId: id);
        },
      ),
      GoRoute(
        path: mentorAvailableStudents,
        builder: (context, state) => const MentorAvailableStudentsScreen(),
      ),
      GoRoute(
        path: mentorNotes,
        builder: (context, state) => const MentorNotesScreen(),
      ),
      GoRoute(
        path: mentorNoteDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MentorNoteDetailScreen(noteId: id);
        },
      ),
      GoRoute(
        path: mentorEssayGrading,
        builder: (context, state) {
          final qIdStr = state.uri.queryParameters['quiz_id'];
          final qId = qIdStr != null ? int.tryParse(qIdStr) : null;
          return MentorEssayGradingScreen(quizId: qId);
        },
      ),
      GoRoute(
        path: mentorSessionAttendance,
        builder: (context, state) {
          final sessionStr =
              state.pathParameters['sessionId'] ?? '0';
          final sessionId = int.tryParse(sessionStr) ?? 0;
          final title = state.uri.queryParameters['title'] ?? '';
          return MentorSessionAttendanceScreen(sessionId: sessionId, sessionTitle: title);
        },
      ),
      GoRoute(
        path: mentorSessionAttendanceAlt,
        builder: (context, state) {
          final sessionStr =
              state.pathParameters['sessionId'] ?? '0';
          final sessionId = int.tryParse(sessionStr) ?? 0;
          final title = state.uri.queryParameters['title'] ?? '';
          return MentorSessionAttendanceScreen(sessionId: sessionId, sessionTitle: title);
        },
      ),
      GoRoute(
        path: mentorMaterials,
        builder: (context, state) => const MentorMaterialsScreen(),
      ),
      GoRoute(
        path: mentorHandbookDetail,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          return MentorHandbookReviewDetailScreen(handbookId: id);
        },
      ),
      GoRoute(
        path: mentorHandbookReview,
        builder: (context, state) {
          final idStr = state.pathParameters['id'] ?? '0';
          final id = int.tryParse(idStr) ?? 0;
          final name = state.uri.queryParameters['name'] ?? '';
          return MentorHandbookReviewScreen(
            studentId: id,
            studentName: name,
          );
        },
      ),
      GoRoute(
        path: mentorScoringDetail,
        builder: (context, state) {
          final sessionStr = state.pathParameters['sessionId'] ?? '0';
          final sessionId = int.tryParse(sessionStr) ?? 0;
          final title = state.uri.queryParameters['title'] ?? 'Sesi';
          return MentorScoringDetailScreen(
            sessionId: sessionId,
            sessionTitle: title,
          );
        },
      ),
      GoRoute(
        path: mentorNotifications,
        builder: (context, state) => const MentorNotificationsScreen(),
      ),
      GoRoute(
        path: mentorHandbookList,
        builder: (context, state) => const MentorHandbookListScreen(),
      ),
      GoRoute(
        path: mentorBanding,
        builder: (context, state) => const MentorBandingScreen(),
      ),
      GoRoute(
        path: mentorBandingDetail,
        builder: (context, state) {
          final item = state.extra as BandingModel;
          return MentorBandingDetailScreen(banding: item);
        },
      ),
      GoRoute(
        path: '/kencana/stage/:id',
        builder: (context, state) {
          final stageId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return KencanaStageScreen(stageId: stageId);
        },
      ),
      GoRoute(
        path: '/kencana/session/:id',
        builder: (context, state) {
          final sessionId =
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return KencanaSessionScreen(sessionId: sessionId);
        },
      ),
      GoRoute(
        path: '/kencana/score',
        builder: (context, state) => const KencanaScoreScreen(),
      ),
      GoRoute(
        path: '/kencana/attendance',
        builder: (context, state) => const KencanaAttendanceScreen(),
      ),
      GoRoute(
        path: kencanaInvitations,
        builder: (context, state) => const KencanaInvitationsScreen(),
      ),
      GoRoute(
        path: kencanaBanding,
        builder: (context, state) => const KencanaBandingScreen(),
      ),
      GoRoute(
        path: kencanaHandbook,
        builder: (context, state) => const KencanaHandbookScreen(),
      ),
      GoRoute(
        path: kencanaTimeline,
        builder: (context, state) => const KencanaTimelineScreen(),
      ),
      GoRoute(
        path: kencanaRemedial,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => KencanaRemedialProvider()..fetchRemedials(),
          child: const KencanaRemedialScreen(),
        ),
      ),
      GoRoute(
        path: kencanaCertificate,
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => KencanaCertificateProvider()..fetchCertificate(),
          child: const KencanaCertificateScreen(),
        ),
      ),
      GoRoute(
        path: kencanaQuiz,
        builder: (context, state) {
          final mission = state.extra as Mission?;
          if (mission == null) return const Scaffold(body: Center(child: Text('Invalid quiz')));
          return QuizScreen(mission: mission);
        },
      ),
      GoRoute(
        path: kencanaAssignment,
        builder: (context, state) {
          final mission = state.extra as Mission?;
          if (mission == null) return const Scaffold(body: Center(child: Text('Invalid assignment')));
          return AssignmentScreen(mission: mission);
        },
      ),
      GoRoute(
        path: '/kencana/qr-scan',
        builder: (context, state) => const KencanaQrScanScreen(),
      ),
      GoRoute(
        path: presensi,
        builder: (context, state) => const PresensiScreen(),
      ),
      GoRoute(
        path: selfScreening,
        builder: (context, state) => const SelfScreeningScreen(),
      ),
      GoRoute(
        path: counselingHistory,
        builder: (context, state) => const CounselingHistoryScreen(),
      ),
      GoRoute(
        path: medicalRecordDetail,
        builder: (context, state) {
          final record = state.extra;
          if (record is! Map<String, dynamic>) {
            return const Scaffold(
              body: Center(child: Text('Invalid medical record')),
            );
          }
          return MedicalRecordDetailScreen(record: record);
        },
      ),
      GoRoute(
        path: studentVoice,
        builder: (context, state) => const StudentVoiceScreen(),
      ),
      GoRoute(
        path: studentVoiceDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return StudentVoiceDetailScreen(aspirationId: id);
        },
      ),
      GoRoute(
        path: medicalReferral,
        builder: (context, state) => const MedicalReferralScreen(),
      ),
      GoRoute(
        path: insuranceClaim,
        builder: (context, state) => const InsuranceClaimScreen(),
      ),
      GoRoute(
        path: scholarshipDetail,
        builder: (context, state) {
          final scholarship = state.extra as Scholarship?;
          if (scholarship == null) return const Scaffold(body: Center(child: Text('Invalid scholarship')));
          return ScholarshipApplicationDetailScreen(scholarship: scholarship);
        },
      ),
      GoRoute(
        path: '/berita/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return BeritaDetailScreen(beritaId: id);
        },
      ),
      GoRoute(
        path: createAchievement,
        builder: (context, state) => const CreateAchievementScreen(),
      ),
      GoRoute(
        path: '/achievement/edit',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EditAchievementScreen(
            achievementId: extra?['id'] ?? 0,
            namaPrestasi: extra?['namaPrestasi'] ?? '',
            tingkat: extra?['tingkat'] ?? 'Lokal',
            tanggal: extra?['tanggal'] ?? DateTime.now(),
            deskripsi: extra?['deskripsi'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/scholarship/program/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ScholarshipProgramDetailScreen(programId: id);
        },
      ),
      GoRoute(
        path: '/scholarship/apply/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ScholarshipProgramDetailScreen(programId: id);
        },
      ),
      GoRoute(
        path: psychologistMain,
        builder: (context, state) => const PsychologistMainScreen(),
      ),
      GoRoute(
        path: studentCounseling,
        builder: (context, state) => const StudentCounselingScreen(),
      ),
      GoRoute(
        path: counselingBooking,
        builder: (context, state) {
          final psikologId = state.uri.queryParameters['psikolog_id'];
          final rescheduleBookingId =
              state.uri.queryParameters['reschedule_booking_id'];
          return CounselingBookingScreen(
            psikologId: psikologId,
            rescheduleBookingId: rescheduleBookingId,
          );
        },
      ),
      GoRoute(
        path: studentNotifications,
        builder: (context, state) => const StudentNotificationsScreen(),
      ),
      GoRoute(
        path: ormawaNotifications,
        builder: (context, state) => const OrmawaNotificationsScreen(),
      ),
      GoRoute(
        path: psychologistNotifications,
        builder: (context, state) => const PsychologistNotificationsScreen(),
      ),
      GoRoute(
        path: scheduleManagement,
        builder: (context, state) => const ScheduleManagementScreen(),
      ),
      GoRoute(
        path: patientList,
        builder:
            (context, state) => const PatientListScreen(showBackButton: true),
      ),
      GoRoute(
        path: addScheduleSlot,
        builder: (context, state) => const AddScheduleSlotScreen(),
      ),
      GoRoute(
        path: psychologistAnalytics,
        builder: (context, state) => const PsychologistAnalyticsScreen(),
      ),
      GoRoute(
        path: createReferral,
        builder: (context, state) {
          final studentId = state.uri.queryParameters['student_id'];
          return CreateReferralScreen(studentId: studentId);
        },
      ),
      GoRoute(
        path: psychologistBookings,
        builder: (context, state) => const PsychologistBookingsScreen(),
      ),
      GoRoute(
        path: sessionNote,
        builder: (context, state) {
          final studentName = state.uri.queryParameters['name'] ?? 'Mahasiswa';
          final studentId = state.uri.queryParameters['studentId'] ?? '000000';
          return SessionNoteScreen(
            studentName: studentName,
            studentId: studentId,
          );
        },
      ),
      GoRoute(
        path: psychologistEditProfile,
        builder: (context, state) => const PsychologistEditProfileScreen(),
      ),
      GoRoute(
        path: referralManagement,
        builder: (context, state) => const ReferralManagementScreen(),
      ),
      GoRoute(
        path: assessmentManagement,
        builder: (context, state) => const AssessmentManagementScreen(),
      ),
      GoRoute(
        path: assessment,
        builder: (context, state) => const AssessmentScreen(),
      ),
      // Admin Psychology Routes
      GoRoute(
        path: adminPsychologistList,
        builder: (context, state) => const AdminPsychologistListScreen(),
      ),
      GoRoute(
        path: createPsychologist,
        builder: (context, state) => const CreatePsychologistScreen(),
      ),
      GoRoute(
        path: '/counseling/admin/psikolog/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return PsychologistDetailScreen(psychologistId: id);
        },
      ),
      GoRoute(
        path: '/counseling/admin/psikolog/:id/edit',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return EditPsychologistScreen(psychologistId: id);
        },
      ),
      GoRoute(
        path: '/counseling/patients/:id/medical-record',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          final name = state.uri.queryParameters['name'] ?? 'Pasien';
          return PatientMedicalRecordScreen(
            patientId: id,
            patientName: name,
          );
        },
      ),
      GoRoute(
        path: '/counseling/patients/:id/medical-record/create',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '0';
          return CreateMedicalRecordScreen(patientId: id);
        },
      ),
      GoRoute(
        path: allSchedules,
        builder: (context, state) => const AllSchedulesScreen(),
      ),
      // TK (Tenaga Kesehatan) Routes
      GoRoute(
        path: tkMain,
        builder: (context, state) {
          final tabStr = state.uri.queryParameters['tab'];
          final initialTab = int.tryParse(tabStr ?? '0') ?? 0;
          return TkMainScreen(initialTab: initialTab);
        },
      ),
      GoRoute(
        path: tkAddSchedule,
        builder: (context, state) => const TkAddScheduleScreen(),
      ),
      GoRoute(
        path: '/tk/patient/:id',
        builder: (context, state) {
          final patientId =
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return TkPatientDetailScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: tkScreening,
        builder: (context, state) {
          final patientIdStr = state.uri.queryParameters['patient_id'];
          final patientId =
              patientIdStr != null ? int.tryParse(patientIdStr) : null;
          return TkScreeningInputScreen(patientId: patientId);
        },
      ),
      GoRoute(
        path: tkQrScan,
        builder: (context, state) => const TkQrScanScreen(),
      ),
      GoRoute(
        path: tkNotifications,
        builder: (context, state) => const TkNotificationsScreen(),
      ),
      GoRoute(
        path: tkInsuranceClaims,
        builder: (context, state) => const TkInsuranceClaimsScreen(),
      ),
      GoRoute(path: tkBap, builder: (context, state) => const TkBapScreen()),
      GoRoute(
        path: tkBapForm,
        builder: (context, state) {
          final extra = state.extra;
          return TkBapFormScreen(
            existingBap: extra is TkBapModel ? extra : null,
          );
        },
      ),
      GoRoute(
        path: tkClinicalReports,
        builder: (context, state) => const TkClinicalReportsScreen(),
      ),
      GoRoute(
        path: tkReferralManagement,
        builder: (context, state) => const TkReferralScreen(),
      ),
      GoRoute(
        path: tkEmr,
        builder: (context, state) => const TkEmrScreen(),
      ),
      GoRoute(
        path: tkLiveExam,
        builder: (context, state) => const TkLiveExaminationScreen(),
      ),
      GoRoute(
        path: tkCreatePatient,
        builder: (context, state) => const CreatePatientScreen(),
      ),
      GoRoute(
        path: '/tk/patient-record/:id',
        builder: (context, state) {
          final patientId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          final name = state.uri.queryParameters['name'];
          return TkPatientRecordScreen(patientId: patientId, patientName: name);
        },
      ),
      GoRoute(
        path: tkMedicalRecords,
        builder: (context, state) => const TkMedicalRecordsScreen(),
      ),
      GoRoute(
        path: tkScreenings,
        builder: (context, state) => const TkScreeningsScreen(),
      ),
      GoRoute(
        path: tkInsuranceReview,
        builder: (context, state) => const TkInsuranceReviewScreen(),
      ),
      GoRoute(
        path: tkAllSchedules,
        builder: (context, state) => const TkAllSchedulesScreen(),
      ),
      GoRoute(
        path: adminTkList,
        builder: (context, state) => const AdminTkListScreen(),
      ),
      GoRoute(
        path: adminCreateTk,
        builder: (context, state) => const CreateTkScreen(),
      ),
      GoRoute(
        path: adminEditTk,
        builder: (context, state) {
          final tkId = state.uri.queryParameters['id'] ?? '0';
          final data = state.extra as Map<String, dynamic>?;
          return EditTkScreen(tkId: tkId, initialData: data);
        },
      ),
      // Ormawa Sub-Routes
      GoRoute(
        path: ormawaSettings,
        builder: (context, state) => const OrmawaSettingsScreen(),
      ),
      GoRoute(
        path: ormawaProfile,
        builder: (context, state) => const OrmawaProfileScreen(),
      ),
      GoRoute(
        path: ormawaSecurity,
        builder: (context, state) => const OrmawaSecurityScreen(),
      ),
      GoRoute(
        path: ormawaStruktur,
        builder: (context, state) => const OrmawaStrukturScreen(),
      ),
      GoRoute(
        path: ormawaRecruitment,
        builder: (context, state) => const OrmawaRecruitmentScreen(),
      ),
      GoRoute(
        path: ormawaAspirasi,
        builder: (context, state) => const OrmawaAspirasiScreen(),
      ),
      GoRoute(
        path: ormawaProposal,
        builder: (context, state) => const OrmawaProposalScreen(),
      ),
      GoRoute(
        path: ormawaAgenda,
        builder: (context, state) => const OrmawaKalenderScreen(),
      ),
      GoRoute(
        path: ormawaPengumuman,
        builder: (context, state) => const OrmawaPengumumanScreen(),
      ),
      GoRoute(
        path: ormawaStrukturManage,
        builder: (context, state) => const ManageStrukturScreen(),
      ),
      GoRoute(
        path: ormawaAnggotaDetail,
        builder: (context, state) {
          final member = state.extra;
          return OrmawaAnggotaDetailScreen(member: member as dynamic);
        },
      ),
      GoRoute(
        path: ormawaRecruitmentHistory,
        builder: (context, state) => const RecruitmentHistoryScreen(),
      ),
      GoRoute(
        path: ormawaRecruitmentForm,
        builder: (context, state) => const RecruitmentFormScreen(),
      ),
      GoRoute(
        path: ormawaRecruitmentSettings,
        builder: (context, state) => const RecruitmentSettingsScreen(),
      ),
      GoRoute(
        path: ormawaCreateProposal,
        builder: (context, state) {
          final initialProposal = state.extra;
          return CreateProposalScreen(initialProposal: initialProposal as dynamic);
        },
      ),
      GoRoute(
        path: ormawaProposalDetail,
        builder: (context, state) {
          final proposal = state.extra;
          return OrmawaProposalDetailScreen(proposal: proposal as dynamic);
        },
      ),
      GoRoute(
        path: ormawaAgendaDetail,
        builder: (context, state) {
          final agenda = state.extra;
          return OrmawaAgendaDetailScreen(agenda: agenda as dynamic);
        },
      ),
      // Ormawa RBAC Route
      GoRoute(
        path: ormawaRbac,
        builder: (context, state) => const OrmawaRbacScreen(),
      ),
      // Ormawa Phase 2 Routes
      GoRoute(
        path: ormawaLpj,
        builder: (context, state) => const OrmawaLpjScreen(),
      ),
      GoRoute(
        path: ormawaLpjCreate,
        builder: (context, state) => const CreateLpjScreen(),
      ),
      GoRoute(
        path: ormawaLpjDetail,
        builder: (context, state) {
          final lpj = state.extra;
          return OrmawaLpjDetailScreen(lpj: lpj);
        },
      ),
      GoRoute(
        path: ormawaLpjEdit,
        builder: (context, state) {
          final lpj = state.extra;
          return EditLpjScreen(lpj: lpj);
        },
      ),
      GoRoute(
        path: ormawaKeuanganDetail,
        builder: (context, state) {
          final transaksi = state.extra;
          return OrmawaKeuanganDetailScreen(transaksi: transaksi);
        },
      ),
      GoRoute(
        path: ormawaKeuanganEdit,
        builder: (context, state) {
          final transaksi = state.extra;
          return EditKeuanganScreen(transaksi: transaksi);
        },
      ),
      GoRoute(
        path: ormawaMutasi,
        builder: (context, state) => const OrmawaMutasiScreen(),
      ),
      GoRoute(
        path: ormawaIuran,
        builder: (context, state) => const OrmawaIuranScreen(),
      ),
      GoRoute(
        path: ormawaAnggotaCreate,
        builder: (context, state) => const CreateAnggotaScreen(),
      ),
      GoRoute(
        path: ormawaAnggotaEdit,
        builder: (context, state) {
          final member = state.extra;
          return EditAnggotaScreen(member: member);
        },
      ),
      GoRoute(
        path: ormawaJadwalCreate,
        builder: (context, state) => const CreateKegiatanScreen(),
      ),
      GoRoute(
        path: ormawaJadwalDetail,
        builder: (context, state) {
          final kegiatan = state.extra;
          return OrmawaJadwalDetailScreen(kegiatan: kegiatan);
        },
      ),
      GoRoute(
        path: ormawaJadwalEdit,
        builder: (context, state) {
          final kegiatan = state.extra;
          return EditKegiatanScreen(kegiatan: kegiatan);
        },
      ),
      GoRoute(
        path: ormawaPengumumanCreate,
        builder: (context, state) => const CreatePengumumanScreen(),
      ),
      GoRoute(
        path: ormawaPengumumanDetail,
        builder: (context, state) {
          final announcement = state.extra;
          return OrmawaPengumumanDetailScreen(announcement: announcement);
        },
      ),
      GoRoute(
        path: ormawaPengumumanEdit,
        builder: (context, state) {
          final announcement = state.extra;
          return EditPengumumanScreen(announcement: announcement);
        },
      ),
      GoRoute(
        path: ormawaStaf,
        builder: (context, state) => const OrmawaStafScreen(),
      ),
      GoRoute(
        path: ormawaGamifikasi,
        builder: (context, state) => const OrmawaGamifikasiScreen(),
      ),
      GoRoute(
        path: ormawaPagu,
        builder: (context, state) => const OrmawaPaguScreen(),
      ),
      GoRoute(
        path: ormawaProposalPipeline,
        builder: (context, state) => const OrmawaProposalPipelineScreen(),
      ),
      GoRoute(
        path: ormawaLpjPipeline,
        builder: (context, state) => const OrmawaLpjPipelineScreen(),
      ),
      GoRoute(
        path: ormawaProposalReview,
        builder: (context, state) => const OrmawaProposalReviewScreen(),
      ),
      GoRoute(
        path: ormawaLpjReview,
        builder: (context, state) => const OrmawaLpjReviewScreen(),
      ),
      GoRoute(
        path: ormawaKeuanganCreate,
        builder: (context, state) => const CreateKeuanganScreen(),
      ),
      // Ormawa Absensi Management Routes
      GoRoute(
        path: ormawaAbsensiManagement,
        builder: (context, state) => const OrmawaAbsensiManagementScreen(),
      ),
      GoRoute(
        path: ormawaAbsensiManagementCreate,
        builder: (context, state) => const CreateAbsensiScreen(),
      ),
      GoRoute(
        path: ormawaAbsensiManagementDetail,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          final id = data?['id'] ?? '';
          return OrmawaAbsensiManagementDetailScreen(
            absensiId: id.toString(),
            absensiData: data ?? {},
          );
        },
      ),
      GoRoute(
        path: ormawaAbsensiManagementEdit,
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>?;
          final id = data?['id'] ?? '';
          return EditAbsensiScreen(
            absensiId: id.toString(),
            absensiData: data ?? {},
          );
        },
      ),
      // Ormawa Organisasi Routes
      GoRoute(
        path: ormawaOrganisasi,
        builder: (context, state) => const OrmawaOrganisasiListScreen(),
      ),
      GoRoute(
        path: ormawaOrganisasiCreate,
        builder: (context, state) => const CreateOrganisasiScreen(),
      ),
      GoRoute(
        path: ormawaOrganisasiDetail,
        builder: (context, state) {
          final organisasi = state.extra;
          return OrmawaOrganisasiDetailScreen(organisasi: organisasi as dynamic);
        },
      ),
      GoRoute(
        path: ormawaOrganisasiEdit,
        builder: (context, state) {
          final organisasi = state.extra;
          return EditOrganisasiScreen(organisasi: organisasi as dynamic);
        },
      ),
    ],
  );
}

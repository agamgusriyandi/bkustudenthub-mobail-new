
BKU StudentHub
›
CMS & SISTEM
›
Api Docs

corporate_fare
Semua Fakultas
expand_more

calendar_month
2025/2026 · Genap
expand_more

filter_alt_off
Reset

search
Cari menu...
⌘K


Avatar
Superadmin
super_admin
expand_more
Daftar Modul
search
search
Cari modul...

api
API Documentation

stethoscope
Roll Tenaga Kesehatan
expand_more

monitor_heart
Dashboard

edit_square
Kelola Menu
SIAKAD API Documentation
 1.0 
OAS 2.0
[ Base URL: localhost:8080/ ]
API Documentation for SIAKAD BKU STUDENT HUB Backend


Authorize
Mahasiswa


GET
/achievement/
GetAchievements



POST
/achievement/
CreateAchievement



GET
/achievement/{id}
GetAchievementDetail



PUT
/achievement/{id}
UpdateAchievement



DELETE
/achievement/{id}
DeleteAchievement



GET
/api/mahasiswa/akademik
GetAkademikData



POST
/api/mahasiswa/auto/ChangePasswordAuth
ChangePasswordAuth



POST
/api/mahasiswa/auto/Login
Login



POST
/api/mahasiswa/auto/Logout
Logout



POST
/api/mahasiswa/auto/RefreshToken
RefreshToken



GET
/api/mahasiswa/kegiatan
GetKegiatan



GET
/api/mahasiswa/summary
GetStudentSummary



GET
/api/psychologists
ListPsychologists



GET
/api/psychologists/{id}/schedules
GetPsychologistSchedules



POST
/counseling/booking
CreateBooking



GET
/counseling/faculty-statistics
GetFacultyStatistics



GET
/counseling/jadwal
GetCounselingJadwal



GET
/counseling/medical-record
GetStudentPsychologistMedicalRecord



GET
/counseling/psychologist-bookings
GetStudentPsychologistBookings



POST
/counseling/psychologist-bookings
CreateStudentPsychologistBooking



DELETE
/counseling/psychologist-bookings/{id}
CancelStudentPsychologistBooking



GET
/counseling/psychologist-bookings/{id}/export-pdf
ExportBookingSessionNotePDF



PUT
/counseling/psychologist-bookings/{id}/reschedule
RescheduleStudentPsychologistBooking



GET
/counseling/psychologist-schedules
GetAvailablePsychologistSchedules



GET
/counseling/referrals
GetStudentReferrals



POST
/counseling/request
RequestCounseling



GET
/counseling/riwayat
GetCounselingRiwayat



DELETE
/counseling/riwayat/{id}
CancelBooking



GET
/counseling/session-notes/{id}/export-pdf
ExportStudentSessionNotePDF



GET
/counseling/status
GetCounselingStatus



POST
/kencana-student/banding
SubmitBanding



GET
/kencana/banding
GetBandingList



POST
/kencana/check-in/{id}
CheckIn



GET
/kencana/kegiatan
GetPkkmbKegiatan



GET
/kencana/kuis/{id}/soal
GetKuisSoal



POST
/kencana/kuis/{id}/submit
SubmitKuis



GET
/kencana/progress
GetProgress



GET
/kencana/sertifikat
GetSertifikat



POST
/kencana/sertifikat/generate
GenerateSertifikat



PUT
/notifikasi/baca-semua
MarkAllAsRead



DELETE
/notifikasi/hapus-bulk
DeleteBulk



DELETE
/notifikasi/hapus-dibaca
DeleteRead



GET
/notifikasi/unread-count
GetUnreadCount



PUT
/notifikasi/{id}/baca
MarkAsRead



GET
/organisasi/
GetList



POST
/organisasi/
Create



POST
/organisasi/daftar
DaftarOrmawa



GET
/organisasi/divisions/{ormawaId}
GetOrmawaDivisions



GET
/organisasi/ormawa-list
GetOrmawaList



GET
/organisasi/pendaftaran
GetPendaftaranList



GET
/organisasi/recruitment-fields/{ormawaId}
GetRecruitmentFields



POST
/organisasi/upload-file
UploadRecruitmentFile



PUT
/organisasi/{id}
Update



DELETE
/organisasi/{id}
Delete



GET
/profil/
GetProfile



POST
/profil/foto
UploadAvatar



GET
/profil/preferensi-notif
GetPreferensiNotif



PUT
/profil/preferensi-notif
UpdatePreferensiNotif



GET
/profil/riwayat-login
GetRiwayatLogin



GET
/profil/sesi-aktif
GetSesiAktif



GET
/scholarship/
GetKatalogBeasiswa



GET
/scholarship/pengajuan/{id}
GetPengajuanDetail



GET
/scholarship/riwayat
GetRiwayatPengajuan



POST
/scholarship/upload-custom-file
UploadScholarshipCustomFile



GET
/scholarship/{id}
GetBeasiswaDetail



POST
/scholarship/{id}/daftar
DaftarBeasiswa



GET
/student-health/bookings
GetStudentHealthBookings



POST
/student-health/bookings
CreateStudentHealthBooking



DELETE
/student-health/bookings/{id}
CancelStudentHealthBooking



PUT
/student-health/bookings/{id}/reschedule
RescheduleStudentHealthBooking



GET
/student-health/health-worker-schedules
GetAvailableHealthSchedules



GET
/student-health/health-workers
ListHealthWorkers



GET
/student-health/health-workers/{id}/schedules
GetHealthWorkerSchedules



POST
/student-health/mandiri
CreateHealthMandiri



POST
/student-health/record
CreateHealthRecord



GET
/student-health/ringkasan
GetHealthRingkasan



GET
/student-health/riwayat
GetHealthRiwayat



GET
/student-health/riwayat/{id}
GetHealthDetail



GET
/student-health/tips
GetHealthTips



GET
/student-voice/
GetAspirasiList



POST
/student-voice/create
CreateAspirasi



GET
/student-voice/stats
GetStats



GET
/student-voice/{id}
GetDetail



PUT
/student-voice/{id}/cancel
CancelAspirasi


TenagaKesehatan


GET
/api/activities
GetActivities



GET
/api/bookings
GetBookings



POST
/api/bookings/manual
CreateManualBooking



GET
/api/bookings/{id}
GetBookingDetail



PUT
/api/bookings/{id}/status
UpdateBookingStatus



PUT
/api/change-password
ChangePassword



GET
/api/dashboard
GetDashboard



GET
/api/me
GetMe



GET
/api/medical-records
GetAllMedicalRecords



GET
/api/medical-records/{id}/export-pdf
ExportMedicalRecordPDF



PUT
/api/medical-records/{record_id}
UpdateMedicalRecord



GET
/api/patients
GetPatients



GET
/api/patients/{id}/medical-record
GetMedicalRecord



POST
/api/patients/{id}/screening
CreateScreening



PUT
/api/profile
UpdateProfile



GET
/api/reports/export-excel
ExportExcel



GET
/api/reports/export-offline-form
ExportRegistrationFormPDF



GET
/api/reports/export-pdf
ExportPDF



GET
/api/schedules
GetSchedules



POST
/api/schedules
CreateSchedule



PUT
/api/schedules/{id}
UpdateSchedule



DELETE
/api/schedules/{id}
DeleteSchedule



GET
/api/students/lookup
LookupStudent


Psychologist


GET
/api/analytics
GetAnalytics



GET
/api/analytics/export-pdf
ExportAnalyticsPDF



GET
/api/assessments
GetAssessments



POST
/api/assessments
CreateAssessment



GET
/api/fakultas
GetFakultasList



PUT
/api/notifications/read-all
MarkAllNotificationsRead



PUT
/api/notifications/{id}/read
MarkNotificationRead



GET
/api/patients/export-pdf
ExportPatientsRecapPDF



POST
/api/patients/{id}/session-notes
CreateSessionNote



PUT
/api/patients/{studentId}/status
UpdatePatientStatus



GET
/api/prodi
GetProdiList



GET
/api/referrals
GetReferrals



POST
/api/referrals
CreateReferral



POST
/api/referrals/{id}/confirm-received
ConfirmReferralReceived



GET
/api/referrals/{id}/download
DownloadReferralPDF



POST
/api/referrals/{id}/send
SendReferral



PUT
/api/schedules
SaveSchedules



PUT
/api/session-notes/{id}
UpdateSessionNote



GET
/api/session-notes/{id}/export-pdf
ExportSessionNotePDF



GET
/notifikasi/
GetNotifications



DELETE
/notifikasi/{id}
DeleteNotification


Auth


POST
/api/auth/login
Login API

Kencana


POST
/api/kencana/auto/SyncFromSevimaPeriod
SyncFromSevimaPeriod



POST
/kencana-admin/assignments
CreateAssignment



PUT
/kencana-admin/assignments/{id}
UpdateAssignment



DELETE
/kencana-admin/assignments/{id}
DeleteAssignment



GET
/kencana-admin/certificate-settings
GetCertificateSettings



PUT
/kencana-admin/certificate-settings
UpdateCertificateSettings



POST
/kencana-admin/certificate-settings/left-logo
UploadCertificateLeftLogo



POST
/kencana-admin/certificate-settings/logo
UploadCertificateLogo



POST
/kencana-admin/certificate-settings/right-logo
UploadCertificateRightLogo



POST
/kencana-admin/materials
CreateMaterial



POST
/kencana-admin/materials/upload
UploadMaterial



PUT
/kencana-admin/materials/{id}
UpdateMaterial



DELETE
/kencana-admin/materials/{id}
DeleteMaterial



GET
/kencana-admin/mentor-assignments
ListMentorAssignments



POST
/kencana-admin/mentor-assignments
CreateMentorAssignment



DELETE
/kencana-admin/mentor-assignments/{id}
DeleteMentorAssignment



PUT
/kencana-admin/mentor-assignments/{id}/move
MoveMentorAssignment



GET
/kencana-admin/monitoring/faculty-compliance
GetFacultyComplianceMonitoring



GET
/kencana-admin/periods
ListPeriods



POST
/kencana-admin/periods
CreatePeriod



PUT
/kencana-admin/periods/{id}
UpdatePeriod



POST
/kencana-admin/periods/{id}/faculty/open
OpenFacultyPhases



GET
/kencana-admin/periods/{id}/phases
GetPeriodPhases



PUT
/kencana-admin/periods/{id}/timeline/{phaseType}
UpdateTimelinePhase



POST
/kencana-admin/periods/{id}/university/{action}
UpdateUniversityPhase



GET
/kencana-admin/pmb-periods
ListPMBPeriods



POST
/kencana-admin/questions
CreateQuestion



PUT
/kencana-admin/questions/{id}
UpdateQuestion



POST
/kencana-admin/quizzes
CreateQuiz



GET
/kencana-admin/quizzes/{id}
GetQuizDetail



PUT
/kencana-admin/quizzes/{id}
UpdateQuiz



DELETE
/kencana-admin/quizzes/{id}
DeleteQuiz



POST
/kencana-admin/remedials
CreateRemedial



POST
/kencana-admin/reset-data
ResetKencanaData



GET
/kencana-admin/score-items
AdminListScoreItems



POST
/kencana-admin/score-items
UpsertScoreItem



POST
/kencana-admin/score-items/bulk
BulkUpsertScoreItems



POST
/kencana-admin/scores/calculate
CalculateAllScores



GET
/kencana-admin/scores/export-excel
AdminDownloadScoresExcel



GET
/kencana-admin/scores/export-pdf
AdminDownloadScoresPDF



POST
/kencana-admin/upload
UploadMedia



GET
/kencana-fakultas/announcements
ListAnnouncements



POST
/kencana-fakultas/announcements
CreateAnnouncement



PUT
/kencana-fakultas/announcements/{id}
UpdateAnnouncement



DELETE
/kencana-fakultas/announcements/{id}
DeleteAnnouncement



GET
/kencana-fakultas/banding
AdminListBanding



PUT
/kencana-fakultas/banding/{id}
AdminRespondBanding



GET
/kencana-fakultas/certificates
ListCertificates



POST
/kencana-fakultas/certificates/generate
GenerateCertificate



POST
/kencana-fakultas/certificates/generate-bulk
GenerateBulkCertificates



GET
/kencana-fakultas/certificates/{id}
GetCertificateDetail



GET
/kencana-fakultas/dashboard/stats
GetDashboardStats



GET
/kencana-fakultas/groups
ListGroups



POST
/kencana-fakultas/groups
CreateGroup



POST
/kencana-fakultas/groups/auto-assign
AutoAssignGroups



GET
/kencana-fakultas/groups/{id}
GetGroup



PUT
/kencana-fakultas/groups/{id}
UpdateGroup



DELETE
/kencana-fakultas/groups/{id}
DeleteGroup



POST
/kencana-fakultas/groups/{id}/members
AddGroupMembers



DELETE
/kencana-fakultas/groups/{id}/members/{studentId}
RemoveGroupMember



GET
/kencana-fakultas/mentors
ListMentors



POST
/kencana-fakultas/mentors
CreateMentor



PUT
/kencana-fakultas/mentors/{id}
UpdateMentor



DELETE
/kencana-fakultas/mentors/{id}
DeleteMentor



GET
/kencana-fakultas/participants
ListParticipants



GET
/kencana-fakultas/phase
GetFacultyPhase



PUT
/kencana-fakultas/phase
UpdateFacultyPhase



POST
/kencana-fakultas/phase/complete
CompleteFacultyPhase



POST
/kencana-fakultas/phase/start
StartFacultyPhase



POST
/kencana-fakultas/phase/undo
UndoFacultyPhase



GET
/kencana-fakultas/remedials
ListRemedials



GET
/kencana-fakultas/scores
ListScores



GET
/kencana-fakultas/scores/summary
ScoreSummary



GET
/kencana-fakultas/sessions
ListSessions



POST
/kencana-fakultas/sessions
CreateSession



GET
/kencana-fakultas/sessions/{id}
GetAdminSessionDetail



PUT
/kencana-fakultas/sessions/{id}
UpdateSession



DELETE
/kencana-fakultas/sessions/{id}
DeleteSession



GET
/kencana-fakultas/sessions/{id}/qr-token
GetSessionQRToken



POST
/kencana-fakultas/sessions/{id}/qr-token/regenerate
RegenerateQRToken



GET
/kencana-fakultas/stages
ListStages



POST
/kencana-fakultas/stages
CreateStage



PUT
/kencana-fakultas/stages/{id}
UpdateStage



GET
/kencana-fakultas/students
SearchStudents



GET
/kencana-mentor/absence-requests
MentorListAbsenceRequests



POST
/kencana-mentor/absence-requests/{id}/respond
MentorRespondAbsenceRequest



GET
/kencana-mentor/announcements
MentorGetAnnouncements



DELETE
/kencana-mentor/assignments/{id}
MentorRemoveAssignment



GET
/kencana-mentor/available-students
MentorAvailableStudents



GET
/kencana-mentor/bulk-scores
MentorBulkScores



POST
/kencana-mentor/bulk-scores
MentorSubmitBulkScores



GET
/kencana-mentor/dashboard
MentorDashboard



GET
/kencana-mentor/groups
MentorListGroups



GET
/kencana-mentor/groups/{id}
MentorGetGroup



POST
/kencana-mentor/groups/{id}/members
MentorAddGroupMembers



DELETE
/kencana-mentor/groups/{id}/members/{studentId}
MentorRemoveGroupMember



GET
/kencana-mentor/groups/{id}/pdf
DownloadGroupPDF



POST
/kencana-mentor/invitations
MentorInviteStudents



GET
/kencana-mentor/profile
MentorProfile



PUT
/kencana-mentor/profile
UpdateMentorProfile



GET
/kencana-mentor/sessions
MentorListSessions



GET
/kencana-mentor/sessions/{sessionId}/attendance
MentorGetSessionAttendance



POST
/kencana-mentor/sessions/{sessionId}/attendance
MentorSubmitSessionAttendance



GET
/kencana-mentor/sessions/{sessionId}/qr-token
MentorGetSessionQR



GET
/kencana-mentor/students
MentorStudents



GET
/kencana-mentor/students/{studentId}/assignments
MentorGetStudentAssignments



GET
/kencana-mentor/students/{studentId}/attendance
MentorStudentAttendance



GET
/kencana-mentor/students/{studentId}/handbook
MentorStudentHandbook



POST
/kencana-mentor/students/{studentId}/handbook/review
MentorReviewHandbook



POST
/kencana-mentor/students/{studentId}/notes
MentorCreateNote



GET
/kencana-mentor/students/{studentId}/progress
MentorStudentProgress



GET
/kencana-mentor/students/{studentId}/score
MentorStudentScore



PUT
/kencana-mentor/students/{studentId}/score-items
MentorUpsertBulkScoreItems



POST
/kencana-mentor/students/{studentId}/score-items
MentorCreateScoreItem



GET
/kencana-student/announcements
GetAnnouncements



GET
/kencana-student/assignments/{assignmentId}
GetAssignment



POST
/kencana-student/assignments/{assignmentId}/submit
SubmitAssignment



GET
/kencana-student/attendance
GetAttendance



POST
/kencana-student/attendance
StudentSubmitAttendance



GET
/kencana-student/banding
GetBanding



GET
/kencana-student/certificate
GetCertificate



POST
/kencana-student/group-invitations/{id}/respond
RespondGroupInvitation



GET
/kencana-student/handbook
GetHandbook



POST
/kencana-student/handbook/draft
SaveHandbookDraft



POST
/kencana-student/handbook/submit
SubmitHandbook



POST
/kencana-student/materials/{materialId}/complete
CompleteMaterial



GET
/kencana-student/mentor-invitations
GetMentorInvitations



POST
/kencana-student/mentor-invitations/{id}/respond
RespondMentorInvitation



POST
/kencana-student/quiz-attempts/{attemptId}/answers
SaveQuizAnswer



POST
/kencana-student/quiz-attempts/{attemptId}/submit
SubmitQuizAttempt



GET
/kencana-student/quizzes/{quizId}
GetQuiz



POST
/kencana-student/quizzes/{quizId}/start
StartQuiz



GET
/kencana-student/remedial
GetRemedial



GET
/kencana-student/score
GetScore



GET
/kencana-student/sessions/{sessionId}
GetSession



GET
/kencana-student/stages/{stageId}
GetStage



GET
/kencana-student/timeline
GetTimeline



Models
auth.loginRequest
models.Aspirasi
models.Beasiswa
models.BeasiswaPendaftaran
models.Dosen
models.Fakultas
models.KategoriOrmawa
models.KencanaAssignment
models.KencanaCertificateSetting
models.KencanaGroup
models.KencanaGroupMember
models.KencanaMaterial
models.KencanaMentor
models.KencanaPeriod
models.KencanaQuestion
models.KencanaQuestionOption
models.KencanaQuiz
models.KencanaRemedial
models.KencanaSession
models.KencanaStage
models.Kesehatan
models.Konseling
models.LaporanPertanggungjawaban
models.Mahasiswa
models.Ormawa
models.OrmawaAnggota
models.OrmawaAspirasi
models.OrmawaDivisi
models.OrmawaKegiatan
models.OrmawaKehadiran
models.OrmawaMutasiSaldo
models.OrmawaNotifikasi
models.OrmawaPengumuman
models.PengajuanSurat
models.PkkmbBanding
models.PkkmbHasil
models.PkkmbKegiatan
models.PkkmbProgress
models.PkkmbSertifikat
models.Prestasi
models.PrestasiDosen
models.PrestasiMahasiswa
models.ProgramStudi
models.Proposal
models.ProposalRiwayat
models.RiwayatOrganisasi
models.TenagaKesehatan
models.User
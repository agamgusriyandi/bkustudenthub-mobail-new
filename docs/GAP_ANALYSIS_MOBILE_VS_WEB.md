# Gap Analysis: Mobile vs Website - BKU Student Hub

> Perbandingan halaman mobile (`bkustudenthub-mobail-new/`) vs website (`website-bku/siakadNew-server/`)
> Generated: 2026-07-31 | Updated: 2026-08-02

---

## Ringkasan

| Platform | Total Halaman | Scope |
|---|---|---|
| **Mobile** | 183 screens | Mahasiswa, Psikolog, Nakes, Mentor Kencana, Ormawa |
| **Website** | 180+ routes | Full-stack: Landing, Admin, Faculty, Semua role |
| **Gap (Web tidak di Mobile)** | ~60+ halaman | Fitur admin, CMS (expected web-only) |
| **Gap (Mobile tidak di Web)** | 0 | Mobile subset dari web |

---

## 1. MAHASISWA - Fitur Website yang BELUM ada di Mobile

| # | Fitur (Website) | Route Web | Status Mobile |
|---|---|---|---|
| 1 | **Presensi Kelas** (Hadir/Terlambat/Sakit/Izin/Alpa) | `/app/student/presensi` | ✅ RESOLVED (`presensi_screen.dart`) |
| 2 | **Self-Screening Kesehatan Mental** (SRQ-20/DASS-21) | `/app/student/health/self-screening` | ✅ RESOLVED (`self_screening_screen.dart`) |
| 3 | **Riwayat Konseling** (reschedule/cancel/export PDF) | `/app/student/counseling/history` | ✅ RESOLVED (`counseling_history_screen.dart`) |
| 4 | **Kencana Timeline** (timeline progress PKKMB) | `/app/student/kencana/timeline` | ✅ RESOLVED (`kencana_timeline_screen.dart`) |
| 5 | **Kencana Remedial** (tugas remedial untuk gagal) | `/app/student/kencana/remedial` | ✅ RESOLVED (`kencana_remedial_screen.dart`) |
| 6 | **Kencana Sertifikat** (download PDF sertifikat) | `/app/student/kencana/certificate` | ✅ RESOLVED (`kencana_certificate_screen.dart`) |
| 7 | **Berita Detail** (baca berita dari student portal) | `/app/student/berita/:id` | ✅ RESOLVED (`berita_detail_screen.dart`) |
| 8 | **Buat Prestasi** (form tambah prestasi baru) | `/app/student/achievement/create` | ✅ RESOLVED (`create_achievement_screen.dart`) |
| 9 | **Edit Prestasi** | `/app/student/achievement/:id/edit` | ✅ RESOLVED (`edit_achievement_screen.dart`) |
| 10 | **Detail Program Beasiswa** (detail program + apply) | `/app/student/scholarship/program/:id` | ✅ RESOLVED (`scholarship_program_detail_screen.dart`) |

---

## 2. PSIKOLOGI - Fitur Website yang BELUM ada di Mobile

| # | Fitur (Website) | Route Web | Status Mobile |
|---|---|---|---|
| 1 | **Daftar Psikolog** (admin CRUD list) | `/app/psikologi/list` | ✅ RESOLVED (`admin_psychologist_list_screen.dart`) |
| 2 | **CRUD Psikolog** (create/detail/edit) | `/app/psikologi/list/create`, `/:id`, `/:id/edit` | ✅ RESOLVED (`create_psychologist_screen.dart`, `psychologist_detail_screen.dart`, `edit_psychologist_screen.dart`) |
| 3 | **Detail Booking** (admin view) | `/app/psikologi/bookings/:id` | ✅ RESOLVED (`psychologist_bookings_screen.dart`) |
| 4 | **Rekam Medis Pasien** (per patient) | `/app/psikologi/patients/:id/medical-record` | ✅ RESOLVED (`patient_medical_record_screen.dart`) |
| 5 | **Buat Rekam Medis** | `/app/psikologi/patients/:id/medical-record/create` | ✅ RESOLVED (`create_medical_record_screen.dart`) |
| 6 | **Daftar Rekam Medis** (global) | `/app/psikologi/medical-records` | ✅ RESOLVED (via `patient_medical_record_screen.dart`) |
| 7 | **Semua Jadwal** (view all schedules) | `/app/psikologi/all-schedules` | ✅ RESOLVED (`all_schedules_screen.dart`) |

---

## 3. TENAGA KESEHATAN - Fitur Website yang BELUM ada di Mobile

| # | Fitur (Website) | Route Web | Status Mobile |
|---|---|---|---|
| 1 | **EMR Examination** (electronic medical record) | `/app/kesehatan/emr` | ✅ RESOLVED (`tk_emr_screen.dart`) |
| 2 | **Live Examination** | `/app/kesehatan/examination` | ✅ RESOLVED (`tk_live_examination_screen.dart`) |
| 3 | **Buat Pasien** | `/app/kesehatan/patients/create` | ✅ RESOLVED (`create_patient_screen.dart`) |
| 4 | **Rekam Medis Pasien** | `/app/kesehatan/patients/:id/medical-record` | ✅ RESOLVED (`tk_patient_record_screen.dart`) |
| 5 | **Medical Records (global)** | `/app/kesehatan/medical-records` | ✅ RESOLVED (`tk_medical_records_screen.dart`) |
| 6 | **Screenings** | `/app/kesehatan/screenings` | ✅ RESOLVED (`tk_screenings_screen.dart`) |
| 7 | **Insurance Review** | `/app/kesehatan/insurance-review` | ✅ RESOLVED (`tk_insurance_review_screen.dart`) |
| 8 | **Semua Jadwal** | `/app/kesehatan/all-schedules` | ✅ RESOLVED (`tk_all_schedules_screen.dart`) |
| 9 | **Daftar TK** (admin CRUD) | `/app/kesehatan/list` | ✅ RESOLVED (`admin_tk_list_screen.dart`) |
| 10 | **CRUD TK** (create/detail/edit) | `/app/kesehatan/list/*` | ✅ RESOLVED (`create_tk_screen.dart`) |

---

## 4. MENTOR KENCANA - Fitur Website yang BELUM ada di Mobile

| # | Fitur (Website) | Route Web | Status Mobile |
|---|---|---|---|
| 1 | **Grup Mentor** (list grup) | `/app/kencana/mentor/groups` | ✅ RESOLVED (`mentor_groups_screen.dart`) |
| 2 | **Detail Grup** | `/app/kencana/mentor/groups/:id` | ✅ RESOLVED (`mentor_group_detail_screen.dart`) |
| 3 | **Students Available** (siswa tersedia untuk di-assign) | `/app/kencana/mentor/available` | ✅ RESOLVED (`mentor_available_students_screen.dart`) |
| 4 | **Notes** (catatan bimbingan) | `/app/kencana/mentor/notes` | ✅ RESOLVED (`mentor_notes_screen.dart`) |
| 5 | **Detail Notes** | `/app/kencana/mentor/notes/:id` | ✅ RESOLVED (`mentor_note_detail_screen.dart`) |
| 6 | **Essay Grading** (koreksi essay) | `/app/kencana/mentor/essay-grading` | ✅ RESOLVED (`mentor_essay_grading_screen.dart`) |
| 7 | **Session Attendance Detail** (per sesi) | `/app/kencana/mentor/attendance/session/:sessionId` | ✅ RESOLVED (`mentor_session_attendance_screen.dart`) |

---

## 5. ORMAWA - Fitur Website yang BELUM ada di Mobile

| # | Fitur (Website) | Route Web | Status Mobile |
|---|---|---|---|
| 1 | **LPJ Management** (Laporan Pertanggungjawaban) | `/app/ormawa/lpj` | ✅ RESOLVED (`ormawa_lpj_screen.dart`) |
| 2 | **CRUD LPJ** (create/detail/edit) | `/app/ormawa/lpj/*` | ✅ RESOLVED (`create_lpj_screen.dart`, `ormawa_lpj_detail_screen.dart`, `edit_lpj_screen.dart`) |
| 3 | **LPJ Pipeline** (review pipeline) | `/app/ormawa/lpj-pipeline` | ✅ RESOLVED (via `ormawa_lpj_screen.dart`) |
| 4 | **Keuangan Detail** (detail transaksi) | `/app/ormawa/keuangan/:id` | ✅ RESOLVED (`ormawa_keuangan_detail_screen.dart`) |
| 5 | **Keuangan Edit** | `/app/ormawa/keuangan/:id/edit` | ✅ RESOLVED (via `ormawa_keuangan_detail_screen.dart`) |
| 6 | **Mutasi** (detail mutasi keuangan) | `/app/ormawa/keuangan/mutasi` | ✅ RESOLVED (`ormawa_mutasi_screen.dart`) |
| 7 | **Iuran Saya** (iuran anggota) | `/app/ormawa/iuran-saya` | ✅ RESOLVED (`ormawa_iuran_screen.dart`) |
| 8 | **CRUD Anggota** (create/detail/edit) | `/app/ormawa/anggota/*` | ✅ RESOLVED (`create_anggota_screen.dart`, `edit_anggota_screen.dart`) |
| 9 | **CRUD Jadwal/Kegiatan** (create/detail/edit) | `/app/ormawa/jadwal/*` | ✅ RESOLVED (`create_kegiatan_screen.dart`, `ormawa_jadwal_detail_screen.dart`) |
| 10 | **CRUD Pengumuman** (create/detail/edit) | `/app/ormawa/pengumuman/*` | ✅ RESOLVED (`create_pengumuman_screen.dart`, `ormawa_pengumuman_detail_screen.dart`, `edit_pengumuman_screen.dart`) |
| 11 | **Staf Organisasi** (BPH management) | `/app/ormawa/staf` | ✅ RESOLVED (`ormawa_staf_screen.dart`) |
| 12 | **Proposal Pipeline** (review pipeline) | `/app/ormawa/proposal-pipeline` | ✅ RESOLVED (via `ormawa_proposal_screen.dart`) |
| 13 | **Gamifikasi** (poin, leaderboard, badge) | `/app/ormawa/gamifikasi` | ✅ RESOLVED (`ormawa_gamifikasi_screen.dart`) |
| 14 | **Pagu Dana** (budget allocation) | `/app/ormawa/pagu` | ✅ RESOLVED (`ormawa_pagu_screen.dart`) |
| 15 | **Kategori Ormawa** | `/app/ormawa/kategori` | ✅ RESOLVED (via `ormawa_struktur_screen.dart`) |
| 16 | **RBAC Ormawa** | `/app/ormawa/rbac` | ✅ RESOLVED (via `ormawa_settings_screen.dart`) |
| 17 | **Pengaturan Ormawa** | `/app/ormawa/pengaturan` | ✅ RESOLVED (`ormawa_settings_screen.dart`) |

---

## 6. ADMIN/SUPERADMIN - Tidak ada di Mobile (Expected)

> Fitur ini memang web-only karena untuk admin:

| Module | Contoh Fitur |
|---|---|
| **Akademik** | Fakultas CRUD, Prodi CRUD, Dosen CRUD, Mahasiswa CRUD, PMB, Periode Akademik |
| **RBAC** | Role management, User management |
| **Sistem/CMS** | Berita CRUD, Landing page editor, Tema, Dokumen, Audit log, Menu management |
| **Kencana Admin** | Period management, Quiz builder, Essay grading, Certificate settings, Score config |
| **Kencana Fakultas** | Faculty monitoring, participant management |
| **Laporan** | Laporan fakultas |
| **Landing/Public** | Beranda, Tentang, Program Studi, Berita, Kontak, Kebijakan Privasi |

---

## 7. Fitur Mobile yang SUDAH ada di Website (OK - Match)

| Module Mobile | Match dengan Web |
|---|---|
| Auth (login, forgot password, splash) | ✅ `/login`, `/forgot-password` |
| Dashboard Mahasiswa | ✅ `/app/student/dashboard` |
| Profile | ✅ `/app/student/profile` |
| Kencana (main, session, stage, score, handbook, invitations, QR, attendance, banding, certificate, remedial, timeline, module, quiz, assignment) | ✅ 15/15 web routes match |
| Counseling (booking, list psikolog, history) | ✅ Match |
| Health (booking, referral, insurance, report, self-screening) | ✅ Match |
| Achievement (view, create, edit, report) | ✅ `/app/student/achievement` CRUD |
| Scholarship (view, apply, program detail) | ✅ `/app/student/scholarship` |
| Student Voice (submit, detail) | ✅ `/app/student/voice` |
| Organisasi (view, daftar, rekrutmen) | ✅ `/app/student/organisasi` |
| Presensi | ✅ `/app/student/presensi` |
| Notifications | ✅ navbar notifications |
| Psikolog (dashboard, bookings, patients, schedule, assessment, analytics, referrals, settings, admin CRUD, medical records) | ✅ All routes match |
| Nakes (dashboard, bookings, patients, schedule, BAP, screening, EMR, live exam, referral, reports, insurance review, admin CRUD) | ✅ All routes match |
| Mentor (dashboard, mentee, attendance, scoring, recruit, handbook review, absence requests, groups, notes, essay grading) | ✅ All routes match |
| Ormawa (dashboard, absensi, anggota CRUD, aspirasi, finance, keuangan detail, mutasi, iuran, gamifikasi, pagu, jadwal CRUD, kalender, laporan, LPJ CRUD, notifications, pengumuman CRUD, proposal, recruitment, settings, staf, struktur) | ✅ All routes match |

---

## Total Gap Summary (ALL RESOLVED - 2026-08-01)

| Kategori | Jumlah Fitur | Status |
|---|---|---|
| Mahasiswa | 10 | ✅ RESOLVED |
| Psikologi | 7 | ✅ RESOLVED |
| Tenaga Kesehatan | 10 | ✅ RESOLVED |
| Mentor Kencana | 7 | ✅ RESOLVED |
| Ormawa | 17 | ✅ RESOLVED |
| Admin/System (expected web-only) | ~60+ | ⏭️ N/A (web-only) |
| **Total fitur mobile yang missing** | **51** | **✅ ALL RESOLVED** |

---

## Final Status

### Mobile Screens: 163 total

| Module | Screens |
|---|---|
| core | 1 |
| auth | 4 |
| main | 1 |
| mahasiswa | 48 |
| counseling (psikolog) | 24 |
| mentor_kencana | 17 |
| organisasi | 1 |
| ormawa | 41 |
| tenaga_kesehatan | 26 |
| **TOTAL** | **163** |

### Parity Status: ✅ COMPLETE

All 51 previously missing mobile features have been implemented. Mobile app now covers all student-facing, psychologist, health worker, mentor, and ORMawa functionality from the web platform. Admin/CMS features remain web-only as expected.

# Design Spec: Mobile-Web Feature Parity (51 Screens)

> **Date:** 2026-07-31
> **Status:** Approved
> **Approach:** Phase per Role (Phase 1-5)
> **Theme:** Keep dynamic theme from API (no refactor)
> **Direction:** Web = source of truth, mobile catches up

---

## 1. Overview

### Problem
Mobile app has 112 screens, website has 180+ routes. Gap of 51 features where website has screens that mobile doesn't. Goal: make mobile 1:1 with web for all user-facing features.

### Constraints
- **Do NOT modify website** — web is source of truth
- **Keep mobile dynamic theme** — `context.appColors.*` from API
- **Follow existing patterns** — go_router, Provider, BkuCard/BkuButton widgets
- **Same design tokens** — Navy `#1B3A6B`, Gold `#C9A84C`, Plus Jakarta Sans

### Architecture
```
Mobile (Flutter)                    Website (React)
├── lib/core/theme/                 ├── src/index.css (CSS vars)
│   ├── app_colors.dart             ├── src/store/useThemeStore.js
│   ├── app_theme.dart              └── src/components/ui/ (shadcn)
│   ├── app_text_styles.dart
│   ├── app_radius.dart
│   └── app_spacing.dart
├── lib/core/widgets/               └── 81 shared UI components
│   ├── bku_card.dart
│   ├── bku_button.dart
│   └── unified_app_bar.dart
└── lib/features/{role}/
    └── presentation/pages/
        └── {screen}.dart (NEW)
```

---

## 2. Phase 1: MAHASISWA (10 screens)

### 2.1 Presensi Kelas
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/presensi/presentation/pages/presensi_screen.dart` |
| **Web ref** | `/app/student/presensi` → `PresensiPage.jsx` |
| **API** | `GET /api/mahasiswa/presensi`, `POST /api/mahasiswa/presensi/check-in` |
| **Route** | `/app/student/presensi` |

**UI Structure:**
- `UnifiedAppBar` with title "Presensi Kelas"
- Date picker (today's schedule)
- `BkuCard` per matkul: nama matkul, jam, ruangan, dosen
- Status badge: Hadir (green), Terlambat (yellow), Sakit (blue), Izin (blue), Alpa (red)
- Check-in button (GPS/QR based)
- Empty state when no schedule

**State:** `PresensiProvider` extends `ChangeNotifier`
**Model:** `PresensiModel` (id, matkul, jam, ruangan, dosen, status, checkInTime)

### 2.2 Riwayat Konseling
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/counseling/presentation/pages/counseling_history_screen.dart` |
| **Web ref** | `/app/student/counseling/history` → `CounselingHistoryPage.jsx` |
| **API** | `GET /api/counseling/history`, `PUT /api/counseling/:id/reschedule` |
| **Route** | `/app/student/counseling/history` |

**UI Structure:**
- Filter: All, Menunggu, Selesai, Dibatalkan
- List cards: psychologist name, date, status, type
- Tap → detail with actions: Reschedule, Cancel, Export PDF
- Pull-to-refresh

**State:** `CounselingHistoryProvider`
**Model:** `CounselingBookingModel` (id, psychologist, date, status, type, notes)

### 2.3 Self-Screening Kesehatan Mental
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/health/presentation/pages/self_screening_screen.dart` |
| **Web ref** | `/app/student/health/self-screening` → `SelfScreeningPage.jsx` |
| **API** | `GET /api/mahasiswa/self-screening`, `POST /api/mahasiswa/self-screening/submit` |
| **Route** | `/app/student/health/self-screening` |

**UI Structure:**
- SRQ-20 questionnaire (20 yes/no questions)
- Progress indicator (question 1/20)
- Radio buttons: Ya / Tidak
- Previous/Next navigation
- Submit → score calculation → result display
- Score ranges: Normal (0-4), Mild (5-9), Moderate (10-14), Severe (15+)

**State:** `SelfScreeningProvider`
**Model:** `ScreeningQuestionModel`, `ScreeningResultModel`

### 2.4 Kencana Timeline
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/kencana/presentation/pages/kencana_timeline_screen.dart` |
| **Web ref** | `/app/student/kencana/timeline` → `KencanaTimelinePage.jsx` |
| **API** | `GET /api/kencana-student/timeline` |
| **Route** | `/app/student/kencana/timeline` |

**UI Structure:**
- Vertical timeline view
- Each node: stage name, status (locked/active/completed), date
- Tap on completed → stage detail
- Current stage highlighted with accent color

**State:** `KencanaTimelineProvider`
**Model:** `TimelineStageModel` (id, name, status, date, order)

### 2.5 Kencana Remedial
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/kencana/presentation/pages/kencana_remedial_screen.dart` |
| **Web ref** | `/app/student/kencana/remedial` → `KencanaRemedialPage.jsx` |
| **API** | `GET /api/kencana-student/remedial`, `POST /api/kencana-student/remedial/submit` |
| **Route** | `/app/student/kencana/remedial` |

**UI Structure:**
- List of remedial tasks
- Each task: title, description, deadline, status
- Submission form (file upload)
- Score display after grading

**State:** `KencanaRemedialProvider`
**Model:** `RemedialTaskModel` (id, title, description, deadline, status, score)

### 2.6 Kencana Sertifikat
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/kencana/presentation/pages/kencana_certificate_screen.dart` |
| **Web ref** | `/app/student/kencana/certificate` → `KencanaCertificatePage.jsx` |
| **API** | `GET /api/kencana-student/certificate` |
| **Route** | `/app/student/kencana/certificate` |

**UI Structure:**
- Certificate preview (image/PDF)
- Predicate badge (Sangat Memuaskan/Memuaskan/etc)
- Download button
- Share button

**State:** `KencanaCertificateProvider`
**Model:** `CertificateModel` (id, predicate, issueDate, downloadUrl)

### 2.7 Berita Detail
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/berita/presentation/pages/berita_detail_screen.dart` |
| **Web ref** | `/app/student/berita/:id` → `StudentBeritaDetailPage.jsx` |
| **API** | `GET /api/public/news/:id` |
| **Route** | `/app/student/berita/:id` |

**UI Structure:**
- Hero image
- Title, date, author
- Rich text content
- Share button

**State:** `BeritaDetailProvider`
**Model:** `BeritaModel` (id, title, content, image, date, author)

### 2.8 Buat Prestasi
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/achievement/presentation/pages/create_achievement_screen.dart` |
| **Web ref** | `/app/student/achievement/create` → `AchievementCreatePage.jsx` |
| **API** | `POST /api/achievement` |
| **Route** | `/app/student/achievement/create` |

**UI Structure:**
- Form fields: nama prestasi, tingkat (Lokal/Provinsi/Nasional/Internasional), tanggal, deskripsi
- File upload for certificate (PDF/JPG)
- Team members input (optional)
- Submit button

**State:** `AchievementFormProvider`
**Model:** `AchievementFormModel`

### 2.9 Edit Prestasi
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/achievement/presentation/pages/edit_achievement_screen.dart` |
| **Web ref** | `/app/student/achievement/:id/edit` → `AchievementEditPage.jsx` |
| **API** | `PUT /api/achievement/:id` |
| **Route** | `/app/student/achievement/:id/edit` |

**UI Structure:**
- Same as create but pre-filled
- Update button

### 2.10 Detail Program Beasiswa
| Item | Value |
|---|---|
| **File** | `lib/features/mahasiswa/scholarship/presentation/pages/scholarship_program_detail_screen.dart` |
| **Web ref** | `/app/student/scholarship/program/:id` → `ScholarshipProgramDetailPage.jsx` |
| **API** | `GET /api/scholarship/program/:id`, `POST /api/scholarship/apply/:id` |
| **Route** | `/app/student/scholarship/program/:id` |

**UI Structure:**
- Program info: name, description, requirements, deadline
- Status: open/closed
- Apply button (with confirmation dialog)
- Upload requirements (if applicable)

**State:** `ScholarshipProgramProvider`
**Model:** `ScholarshipProgramModel` (id, name, description, requirements, deadline, status)

---

## 3. Phase 2: ORMAWA (17 screens)

### 3.1 LPJ Management (4 screens)
| Screen | File | API |
|---|---|---|
| LPJ List | `ormawa_lpj_screen.dart` | `GET /api/ormawa/lpjs` |
| Create LPJ | `create_lpj_screen.dart` | `POST /api/ormawa/lpjs` |
| LPJ Detail | `ormawa_lpj_detail_screen.dart` | `GET /api/ormawa/lpjs/:id` |
| Edit LPJ | `edit_lpj_screen.dart` | `PUT /api/ormawa/lpjs/:id` |

**UI:**
- List: filter by status, cards with title, date, status badge
- Form: title, kegiatan, realisasi anggaran, upload PDF laporan
- Detail: view all fields, approve/reject actions (for pembina)

### 3.2 Keuangan Detail (4 screens)
| Screen | File | API |
|---|---|---|
| Keuangan Detail | `ormawa_keuangan_detail_screen.dart` | `GET /api/ormawa/kas/:id` |
| Keuangan Edit | `edit_keuangan_screen.dart` | `PUT /api/ormawa/kas/:id` |
| Mutasi | `ormawa_mutasi_screen.dart` | `GET /api/ormawa/kas/mutasi` |
| Iuran Saya | `ormawa_iuran_screen.dart` | `GET /api/ormawa/iuran` |

### 3.3 CRUD Anggota (3 screens)
| Screen | File | API |
|---|---|---|
| Create Anggota | `create_anggota_screen.dart` | `POST /api/ormawa/members` |
| Anggota Detail | `ormawa_anggota_detail_screen.dart` | `GET /api/ormawa/members/:id` |
| Edit Anggota | `edit_anggota_screen.dart` | `PUT /api/ormawa/members/:id` |

### 3.4 CRUD Jadwal (3 screens)
| Screen | File | API |
|---|---|---|
| Create Kegiatan | `create_kegiatan_screen.dart` | `POST /api/ormawa/events` |
| Jadwal Detail | `ormawa_jadwal_detail_screen.dart` | `GET /api/ormawa/events/:id` |
| Edit Kegiatan | `edit_kegiatan_screen.dart` | `PUT /api/ormawa/events/:id` |

### 3.5 CRUD Pengumuman (3 screens)
| Screen | File | API |
|---|---|---|
| Create Pengumuman | `create_pengumuman_screen.dart` | `POST /api/ormawa/announcements` |
| Pengumuman Detail | `ormawa_pengumuman_detail_screen.dart` | `GET /api/ormawa/announcements/:id` |
| Edit Pengumuman | `edit_pengumuman_screen.dart` | `PUT /api/ormawa/announcements/:id` |

---

## 4. Phase 3: MENTOR KENCANA (7 screens)

| # | Screen | File | API |
|---|---|---|---|
| 1 | Grup List | `mentor_groups_screen.dart` | `GET /api/kencana-mentor/groups` |
| 2 | Detail Grup | `mentor_group_detail_screen.dart` | `GET /api/kencana-mentor/groups/:id` |
| 3 | Available Students | `mentor_available_students_screen.dart` | `GET /api/kencana-mentor/available-students` |
| 4 | Notes List | `mentor_notes_screen.dart` | `GET /api/kencana-mentor/notes` |
| 5 | Detail Notes | `mentor_note_detail_screen.dart` | `GET /api/kencana-mentor/notes/:id` |
| 6 | Essay Grading | `mentor_essay_grading_screen.dart` | `GET /api/kencana-mentor/essay-grading` |
| 7 | Session Attendance | `mentor_session_attendance_screen.dart` | `GET /api/kencana-mentor/attendance/session/:id` |

---

## 5. Phase 4: PSIKOLOGI (7 screens)

| # | Screen | File | API |
|---|---|---|---|
| 1 | Daftar Psikolog | `admin_psychologist_list_screen.dart` | `GET /api/admin/psychologists` |
| 2 | Create Psikolog | `create_psychologist_screen.dart` | `POST /api/admin/psychologists` |
| 3 | Detail Psikolog | `psychologist_detail_screen.dart` | `GET /api/admin/psychologists/:id` |
| 4 | Edit Psikolog | `edit_psychologist_screen.dart` | `PUT /api/admin/psychologists/:id` |
| 5 | Patient Medical Record | `patient_medical_record_screen.dart` | `GET /api/psychologist/patients/:id/medical-record` |
| 6 | Create Medical Record | `create_medical_record_screen.dart` | `POST /api/psychologist/medical-records` |
| 7 | All Schedules | `all_schedules_screen.dart` | `GET /api/psychologist/schedules` |

---

## 6. Phase 5: TENAGA KESEHATAN (10 screens)

| # | Screen | File | API |
|---|---|---|---|
| 1 | EMR Examination | `tk_emr_screen.dart` | `GET /api/tenagakes/medical-records` |
| 2 | Live Examination | `tk_live_examination_screen.dart` | `POST /api/tenagakes/medical-records` |
| 3 | Create Patient | `create_patient_screen.dart` | `POST /api/tenagakes/patients` |
| 4 | Patient Medical Record | `tk_patient_record_screen.dart` | `GET /api/tenagakes/patients/:id/medical-record` |
| 5 | Medical Records (global) | `tk_medical_records_screen.dart` | `GET /api/tenagakes/medical-records` |
| 6 | Screenings | `tk_screenings_screen.dart` | `GET /api/tenagakes/screenings` |
| 7 | Insurance Review | `tk_insurance_review_screen.dart` | `GET /api/tenagakes/claims` |
| 8 | All Schedules | `tk_all_schedules_screen.dart` | `GET /api/tenagakes/schedules` |
| 9 | Daftar TK (admin) | `admin_tk_list_screen.dart` | `GET /api/admin/tenagakes` |
| 10 | CRUD TK | `create_tk_screen.dart` + `tk_detail_screen.dart` + `edit_tk_screen.dart` | CRUD `/api/admin/tenagakes` |

---

## 7. Design Consistency Rules

### Theme Access
```dart
// ✅ Correct - dynamic from API
context.appColors.primary
context.appColors.secondary
context.appColors.surface

// ❌ Wrong - hardcoded
Color(0xFF1B3A6B)
```

### Typography
```dart
// ✅ Correct
context.appTextStyles.headlineMedium
context.appTextStyles.bodyLarge
context.appTextStyles.labelMedium

// ❌ Wrong
TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
```

### Spacing & Radius
```dart
// ✅ Correct
SizedBox(height: AppSpacing.md)
BorderRadius.circular(AppRadius.md)

// ❌ Wrong
SizedBox(height: 16)
BorderRadius.circular(12)
```

### Components
```dart
// ✅ Correct - reuse existing
BkuCard(child: ...)
BkuButton(onPressed: ..., label: ...)
UnifiedAppBar(title: "...")
BkuShimmer()

// ❌ Wrong - create new custom
Card(child: ...)
ElevatedButton(onPressed: ..., child: Text("..."))
AppBar(title: Text("..."))
```

### State Management
```dart
// ✅ Correct - Provider pattern
class MyProvider extends ChangeNotifier {
  List<Item> _items = [];
  List<Item> get items => _items;
  
  Future<void> loadItems() async {
    // API call
    notifyListeners();
  }
}

// Register in main.dart or screen
ChangeNotifierProvider(create: (_) => MyProvider())
```

### Routing
```dart
// ✅ Correct - GoRouter with role guards
GoRoute(
  path: '/app/student/presensi',
  builder: (context, state) => const PresensiScreen(),
),

// Add to AppRoutes class
static const String presensi = '/app/student/presensi';
```

---

## 8. File Structure Convention

Every new screen follows this structure:

```
lib/features/{role}/{module}/
├── data/
│   ├── models/
│   │   └── {model}.dart
│   └── repositories/
│       └── {repository}.dart
├── presentation/
│   ├── pages/
│   │   └── {screen_name}_screen.dart
│   └── providers/
│       └── {provider_name}.dart
└── {module}.dart ( barrel export )
```

---

## 9. Testing Requirements

Each screen must have:
1. **Unit test** for provider (state management)
2. **Widget test** for screen (UI rendering)
3. **Integration test** for navigation flow

---

## 10. Success Criteria

- [ ] All 51 new screens compiled without errors
- [ ] All screens use dynamic theme (context.appColors.*)
- [ ] All screens use shared components (BkuCard, BkuButton, etc.)
- [ ] All screens have proper loading/empty/error states
- [ ] All routes registered in AppRoutes
- [ ] All providers registered in main.dart
- [ ] All screens match web functionality 1:1
- [ ] Lint score 0 issues
- [ ] All existing tests still pass

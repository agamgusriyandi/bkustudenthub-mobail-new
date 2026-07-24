# Dokumentasi Role Student (Mahasiswa)

## Gambaran Umum

Role **Student (Mahasiswa)** merupakan pemeran dan pengguna utama dari aplikasi BKUhub Mobile. Aplikasi ini bertindak sebagai asisten digital harian (kampus) terpadu yang memfasilitasi mahasiswa dalam memantau kegiatan akademik maupun non-akademik. Fitur-fiturnya sangat luas, mencakup program *onboarding* (Kencana), layanan kesehatan dan konseling, pencatatan prestasi, pendaftaran beasiswa, riwayat organisasi, hingga wadah penyampaian aspirasi mahasiswa.

Kode yang mengelola role Mahasiswa ini diisolasi terutama di dalam modul `lib/features/mahasiswa/`, dengan tambahan modul global untuk navigasi (`main`) dan setelan akun (`profile`).

---

## Struktur Folder & File Utama

Modul untuk mahasiswa (*student*) ini jauh lebih masif karena terbagi lagi ke dalam berbagai sub-modul (fitur-fitur spesifik):

```text
lib/features/
├── main/
│   └── presentation/pages/main_screen.dart (Navigasi & entry point utama)
├── profile/
│   ├── presentation/pages/profile_screen.dart
│   └── presentation/widgets/ & utils/
└── mahasiswa/
    ├── achievement/ (Prestasi)
    ├── counseling/ (Bimbingan Konseling)
    ├── dashboard/ (Beranda/Dashboard Mahasiswa)
    ├── health/ (Kesehatan & Klinik)
    ├── kencana/ (Program Orientasi/Kencana BKU)
    ├── notifications/ (Pemberitahuan)
    ├── organisasi/ (Aktivitas Kemahasiswaan & Ormawa)
    ├── scholarship/ (Beasiswa)
    ├── student_voice/ (Suara Mahasiswa/Aspirasi)
    ├── data/
    │   ├── models/ (Kumpulan model data JSON)
    │   └── repositories/ (student_repository_impl.dart)
    └── domain/
        ├── entities/ (Kumpulan entitas bisnis)
        └── repositories/ (student_repository.dart)
```

---

## Detail Lapisan (Layers) & File

### 1. Data Layer (`/mahasiswa/data`)

Berbeda dengan role lain yang terpisah-pisah fiturnya, sebagian besar request API mahasiswa disatukan dalam satu repositori terpusat.
- **Models**:
  - `achievement_model.dart`, `aspiration_model.dart`, `counseling_session_model.dart`, `health_booking_model.dart`, `health_record_model.dart`, `insurance_claim_model.dart`, `mission_model.dart`, `organization_history_model.dart`, `scholarship_model.dart`.
- **Repositories**:
  - `student_repository_impl.dart`: Implementasi HTTP request ke server untuk seluruh *endpoint* operasional mahasiswa (get jadwal, post prestasi, submit aspirasi, dll).

### 2. Domain Layer (`/mahasiswa/domain`)

Lapisan *core business logic*.
- **Entities**: 
  - `achievement.dart`, `aspiration.dart`, `campus_event_schedule.dart`, `campus_news.dart`, `counseling_session.dart`, `faculty_progress.dart`, `health_booking.dart`, `health_record.dart`, `insurance_claim.dart`, `kencana_models.dart`, `mission.dart`, `organization_history.dart`, `pkkmb_event.dart`, `scholarship.dart`.
- **Repositories**: 
  - `student_repository.dart`: *Interface abstract* yang mendefinisikan *contract* API.

### 3. Presentation Layer (`/mahasiswa/*/presentation/pages`)

Lapisan UI mahasiswa dipecah per-folder berdasarkan fungsionalitasnya:

#### A. Entry Point & Profil
- `/main/presentation/pages/main_screen.dart`: Halaman *wrapper* untuk *Bottom Navigation Bar* utama mahasiswa.
- `/profile/presentation/pages/profile_screen.dart`: Halaman profil, melihat *badge*/level, informasi biodata, dan *logout*.

#### B. Dashboard (`/dashboard`)
- `dashboard_screen.dart`: Beranda utama, menampilkan sekilas agenda hari ini, status Kencana, dan *grid service* (menu-menu utama).
- `student_calendar_screen.dart`: Kalender interaktif berisi acara kampus dan kelas.

#### C. Program Kencana (`/kencana`)
Modul paling kompleks untuk mahasiswa baru (orientasi kampus).
- `kencana_screen.dart`: Halaman utama (*dashboard*) khusus *tracking* progres Kencana.
- `assignment_screen.dart`, `quiz_screen.dart`: Halaman melihat dan mengerjakan penugasan/kuis orientasi.
- `kencana_attendance_screen.dart`, `kencana_qr_scan_screen.dart`: Hadir di sesi Kencana melalui pindai QR Code.
- `kencana_score_screen.dart`, `kencana_banding_screen.dart`: Melihat rapor/nilai Kencana dan mengajukan banding/komplain nilai.
- `kencana_session_screen.dart`, `module_detail_screen.dart`: Melihat rangkaian sesi, materi, dan undangan kegiatan.

#### D. Fasilitas Kesehatan (`/health`)
- `health_screen.dart`: Portal kesehatan mahasiswa.
- `klinik_booking_screen.dart` & `health_booking_form_screen.dart`: Memesan antrean ke klinik kampus.
- `medical_referral_screen.dart`: Melihat surat rujukan dokter.
- `insurance_claim_screen.dart`: Mengajukan klaim asuransi kesehatan (BPJS/Kesehatan Kampus).
- `report_health_screen.dart`: Mengunggah surat sakit/laporan medis mandiri.

#### E. Konseling Mahasiswa (`/counseling`)
- `counseling_screen.dart`: Beranda modul *mental health* & konseling.
- `psychologist_list_screen.dart`: Menjelajahi daftar psikolog yang tersedia.
- `book_counseling_screen.dart`: Membuat janji temu bimbingan dengan psikolog.

#### F. Prestasi & Beasiswa (`/achievement` & `/scholarship`)
- `achievement_screen.dart` & `report_achievement_screen.dart`: Melihat riwayat prestasi dan melaporkan/mengunggah sertifikat juara kompetisi baru.
- `scholarship_screen.dart` & `apply_scholarship_screen.dart`: Papan informasi lowongan beasiswa kampus/pemerintah dan form pendaftarannya.

#### G. Organisasi Mahasiswa (`/organisasi`)
- `organisasi_screen.dart`: *Dashboard* keaktifan di BEM/UKM.
- `daftar_ormawa_screen.dart` & `rekrutmen_ormawa_screen.dart`: Menjelajahi unit kegiatan mahasiswa dan info rekrutmen pengurus.
- `add_organisasi_screen.dart`: Menambahkan riwayat keorganisasian/kepanitiaan masa lalu.
- Termasuk fitur `portfolio_pdf_generator.dart` untuk meng-*export* curriculum vitae organisasi.

#### H. Aspirasi / Suara Mahasiswa (`/student_voice`)
- `student_voice_screen.dart`: Halaman forum atau *board* yang menampilkan aduan/aspirasi mahasiswa.
- `submit_aspiration_screen.dart`: Form untuk menulis dan mengirim aspirasi, kritik, atau saran perbaikan sarana prasarana ke pihak kampus.

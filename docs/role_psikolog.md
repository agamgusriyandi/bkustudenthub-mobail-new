# Dokumentasi Role Psikolog (Konselor)

## Gambaran Umum

Role **Psikolog (Konselor)** dalam aplikasi BKUhub Mobile dikhususkan bagi staf bimbingan konseling (BK) atau psikolog kampus untuk mengelola layanan kesehatan mental mahasiswa. Role ini memungkinkan psikolog untuk mengatur jadwal sesi konseling, mengelola *booking* dari mahasiswa, membuat catatan sesi, memantau *assessment* kesehatan mental, dan melakukan sistem rujukan (*referral*).

Seluruh kode yang berkaitan dengan fitur konseling dan role psikolog diisolasi di dalam arsitektur *Clean Architecture* pada direktori fitur:
`lib/features/counseling/`

---

## Struktur Folder & File

```text
lib/features/counseling/
├── data/
│   ├── models/
│   │   └── counseling_models.dart
│   └── repositories/
│       └── counseling_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── counseling_session.dart
│   │   └── psychologist.dart
│   └── repositories/
│       └── counseling_repository.dart
└── presentation/
    ├── pages/
    │   ├── add_schedule_slot_screen.dart
    │   ├── assessment_management_screen.dart
    │   ├── assessment_screen.dart
    │   ├── counseling_booking_screen.dart
    │   ├── create_referral_screen.dart
    │   ├── patient_list_screen.dart
    │   ├── psychologist_analytics_screen.dart
    │   ├── psychologist_bookings_screen.dart
    │   ├── psychologist_dashboard_screen.dart
    │   ├── psychologist_edit_profile_screen.dart
    │   ├── psychologist_main_screen.dart
    │   ├── psychologist_notifications_screen.dart
    │   ├── psychologist_settings_screen.dart
    │   ├── referral_management_screen.dart
    │   ├── schedule_management_screen.dart
    │   ├── session_note_screen.dart
    │   └── student_counseling_screen.dart
    ├── providers/
    │   ├── counseling_provider.dart
    │   ├── psychologist_dashboard_provider.dart
    │   ├── referral_provider.dart
    │   └── student_counseling_provider.dart
    └── widgets/
        ├── counseling_bottom_nav_bar.dart
        └── dashboard/
            ├── availability_toggle.dart
            ├── psychologist_analytics_card.dart
            ├── psychologist_service_grid.dart
            ├── quick_stats_card.dart
            ├── recent_activities_card.dart
            └── upcoming_appointments_card.dart
```

---

## Detail Lapisan (Layers) & File

### 1. Data Layer (`/data`)

Lapisan ini memetakan data eksternal (API) menjadi model yang bisa digunakan aplikasi, serta mengimplementasikan antarmuka dari *domain layer*.

- **Models (`/models`)**: 
  - `counseling_models.dart`: Berisi *data class* untuk *mapping* JSON respons API ke objek, mencakup model terkait *appointment*, sesi, asessmen, dan profil psikolog.
- **Repositories (`/repositories`)**:
  - `counseling_repository_impl.dart`: Implementasi konkret dari operasi jaringan, seperti memanggil endpoint HTTP untuk mengambil daftar sesi, jadwal, hingga mengirim hasil sesi (session note).

### 2. Domain Layer (`/domain`)

Lapisan *core business logic* yang mendefinisikan entitas independen.

- **Entities (`/entities`)**:
  - `counseling_session.dart`: Entitas inti untuk mewakili satu sesi konseling antara mahasiswa dan psikolog (status jadwal, catatan, diagnosis sementara).
  - `psychologist.dart`: Entitas data profil psikolog itu sendiri.
- **Repositories (`/repositories`)**:
  - `counseling_repository.dart`: *Abstract class* (interface) yang mendefinisikan seluruh fungsi yang dibutuhkan oleh lapisan *presentation*, seperti `getUpcomingSessions()`, `createReferral()`, dll.

### 3. Presentation Layer (`/presentation`)

Lapisan UI untuk menampilkan antarmuka dan *state management*. Menampung baik antarmuka khusus psikolog maupun sebagian *screen* yang bisa diakses dari sisi *student* dalam konteks modul konseling.

#### A. Pages (Screen / Halaman)
Halaman-halaman untuk alur utama psikolog:
- **Entry & Utama**:
  - `psychologist_main_screen.dart`: Halaman *wrapper* untuk sistem tab navigasi bawah khusus psikolog.
  - `psychologist_dashboard_screen.dart`: Beranda (*Dashboard*) psikolog yang memuat *quick stats*, jadwal mendatang, dan *toggle* ketersediaan.
- **Manajemen Jadwal & Sesi**:
  - `psychologist_bookings_screen.dart`: Halaman untuk menyetujui, menolak, atau melihat daftar *booking* konseling dari mahasiswa.
  - `schedule_management_screen.dart` & `add_schedule_slot_screen.dart`: Pengaturan slot hari dan jam kerja yang bisa di-*booking*.
- **Pemeriksaan & Tindakan Konseling**:
  - `patient_list_screen.dart`: Menampilkan riwayat daftar pasien (mahasiswa) yang pernah/sedang ditangani.
  - `session_note_screen.dart`: Form khusus bagi psikolog untuk menulis catatan pasca-sesi (diagnosis, observasi, dll).
- **Asesmen Mental & Rujukan (*Referral*)**:
  - `assessment_management_screen.dart` & `assessment_screen.dart`: Pengelolaan hasil tes asesmen mental mahasiswa (seperti DASS-21, dll).
  - `referral_management_screen.dart` & `create_referral_screen.dart`: Fitur untuk merujuk pasien ke tenaga profesional lain (misal dari psikolog ke psikiater kampus atau RS luar).
- **Fitur Tambahan & Analitik**:
  - `psychologist_analytics_screen.dart`: Halaman rekapitulasi jumlah sesi, tren kasus, dan demografi mahasiswa yang ditangani.
  - `psychologist_notifications_screen.dart`: Pusat pemberitahuan *booking* baru atau pembaruan sesi.
  - `psychologist_edit_profile_screen.dart` & `psychologist_settings_screen.dart`: Pengaturan profil dan akun psikolog.
- **(Halaman Mahasiswa Terkait)**:
  - `student_counseling_screen.dart` & `counseling_booking_screen.dart`: Antarmuka di dalam modul ini yang digunakan mahasiswa saat ingin membuat janji temu dengan psikolog.

#### B. Providers (State Management)
Menggunakan *Provider* (`ChangeNotifier`) untuk mengatur *state* reaktif.
- `counseling_provider.dart`: Menangani fungsi-fungsi umum konseling.
- `psychologist_dashboard_provider.dart`: Menarik data-data agregat (statistik, daftar jadwal hari ini) ke *Dashboard* psikolog.
- `referral_provider.dart`: Mengelola status surat rujukan dan *fetch* data rujukan.
- `student_counseling_provider.dart`: Melayani kebutuhan *state* khusus *flow* pembuatan janji oleh sisi mahasiswa.

#### C. Widgets (Komponen UI Reusable)
Potongan kode UI untuk memisahkan logika tampilan agar lebih rapi.
- `counseling_bottom_nav_bar.dart`: *Bottom Navigation* khusus role Psikolog.
- **`/dashboard` (Sub-komponen Dashboard)**:
  - `psychologist_service_grid.dart`: Grid menu utama untuk akses cepat (Lihat Jadwal, Rujukan, dll).
  - `recent_activities_card.dart`: Kartu rekam jejak aktivitas terakhir psikolog (misal: "Sesi selesai dengan Ahmad").
  - `psychologist_analytics_card.dart`: Kartu mini yang memuat ringkasan grafik/angka analitik.
  - `quick_stats_card.dart`: Ringkasan metrik statistik harian.
  - `upcoming_appointments_card.dart`: Penampil singkat daftar janji temu terdekat di beranda.
  - `availability_toggle.dart`: *Switch* on/off bagi psikolog untuk menentukan apakah mereka siap menerima pesan darurat/konsultasi instan saat ini.

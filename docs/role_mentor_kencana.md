# Dokumentasi Role Mentor Kencana

## Gambaran Umum

Role **Mentor Kencana** dalam aplikasi BKUhub Mobile diperuntukkan bagi mahasiswa senior atau staf yang ditugaskan sebagai pembimbing (mentor) bagi mahasiswa baru (mentee) dalam program Kencana. Role ini memungkinkan mentor untuk memantau kehadiran, memproses permohonan izin/absen, mengelola penilaian (*scoring*), melihat daftar *mentee* beserta detailnya, dan proses rekrutmen.

Seluruh kode yang berkaitan dengan fitur Mentor Kencana dikelompokkan di dalam direktori:
`lib/features/mentor_kencana/`

---

## Struktur Folder & File

```text
lib/features/mentor_kencana/
├── domain/
│   └── entities/
│       └── mentor_models.dart
└── presentation/
    ├── pages/
    │   ├── mentor_absence_requests_screen.dart
    │   ├── mentor_attendance_screen.dart
    │   ├── mentor_dashboard_screen.dart
    │   ├── mentor_main_screen.dart
    │   ├── mentor_mentee_detail_screen.dart
    │   ├── mentor_mentee_screen.dart
    │   ├── mentor_profile_screen.dart
    │   ├── mentor_recruit_screen.dart
    │   └── mentor_scoring_screen.dart
    └── providers/
        └── mentor_kencana_provider.dart
```

*(Catatan: Modul ini dirancang lebih ringkas, berpusat pada lapisan Domain untuk model entitas dan Presentation untuk UI serta Provider).*

---

## Detail Lapisan (Layers) & File

### 1. Domain Layer (`/domain`)

Lapisan yang memuat definisi objek atau entitas untuk fitur Mentor Kencana.

- **Entities (`/entities`)**:
  - `mentor_models.dart`: Berisi *data classes* atau model yang mendefinisikan struktur data spesifik untuk kebutuhan Mentor Kencana (contoh: model data Mentee, riwayat kehadiran, dan data nilai evaluasi).

### 2. Presentation Layer (`/presentation`)

Lapisan antarmuka pengguna (UI) dan pengelola state lokal (*State Management*) khusus untuk role Mentor.

#### A. Pages (Screen / Halaman)
Halaman-halaman utama dalam alur aplikasi bagi Mentor:
- **Entry & Utama**:
  - `mentor_main_screen.dart`: Halaman *wrapper* utama (berisi *Bottom Navigation Bar*) untuk me-routing antar menu utama mentor.
  - `mentor_dashboard_screen.dart`: Halaman Beranda (*Dashboard*) yang menampilkan ringkasan informasi, akses cepat, dan metrik pantauan bagi mentor (misal statistik jumlah *mentee* yang hadir hari ini).
- **Manajemen Mentee & Presensi**:
  - `mentor_mentee_screen.dart`: Halaman untuk melihat daftar seluruh mahasiswa (*mentee*) yang berada di bawah bimbingan sang mentor.
  - `mentor_mentee_detail_screen.dart`: Halaman untuk melihat profil, biodata lengkap, dan riwayat aktivitas spesifik dari seorang *mentee*.
  - `mentor_attendance_screen.dart`: Halaman untuk memantau, memanggil, dan mengelola rekam jejak absensi / presensi dari para *mentee*.
  - `mentor_absence_requests_screen.dart`: Halaman persetujuan (approval) untuk meninjau, menyetujui, atau menolak permohonan izin/tidak hadir dari *mentee*.
- **Penilaian & Evaluasi**:
  - `mentor_scoring_screen.dart`: Halaman bagi mentor untuk mengelola penilaian (memberikan, mengubah skor) performa *mentee* selama program Kencana berlangsung.
- **Profil & Lainnya**:
  - `mentor_recruit_screen.dart`: Halaman khusus yang berkaitan dengan alur manajemen rekrutmen dalam ekosistem Kencana.
  - `mentor_profile_screen.dart`: Halaman pengaturan akun dan detail profil milik mentor itu sendiri.

#### B. Providers (State Management)
Menggunakan `Provider` untuk menyambungkan UI dengan *business logic*.
- `mentor_kencana_provider.dart`: *State management* utama dan tunggal untuk modul ini. Bertugas melakukan HTTP *requests* ke API, menampung daftar mentee, menangani logika pendaftaran absensi, submit *scoring*, serta pembaruan status izin mentee.

# Dokumentasi Role Tenaga Kesehatan (BKUhub Mobile)

## Gambaran Umum

Role **Tenaga Kesehatan** dalam aplikasi BKUhub Mobile dikhususkan bagi staf medis atau petugas kesehatan klinik kampus untuk mengelola layanan kesehatan mahasiswa. Role ini memiliki akses dan alur kerja (workflow) yang berbeda dari role mahasiswa, berfokus pada manajemen operasional klinik, pemeriksaan pasien, dan penjadwalan.

Seluruh kode yang berkaitan dengan role ini diisolasi di dalam arsitektur *Clean Architecture* pada direktori fitur:
`lib/features/tenaga_kesehatan/`

---

## Struktur Folder & File

```text
lib/features/tenaga_kesehatan/
├── data/
│   ├── models/
│   │   ├── tk_bap_model.dart
│   │   ├── tk_clinical_report_model.dart
│   │   └── tk_insurance_claim_model.dart
│   └── repositories/
│       └── tk_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── booking.dart
│   │   ├── medical_record.dart
│   │   ├── patient.dart
│   │   ├── schedule.dart
│   │   └── tk_profile.dart
│   └── repositories/
│       └── tk_repository.dart
└── presentation/
    ├── pages/
    │   ├── tk_add_schedule_screen.dart
    │   ├── tk_bap_form_screen.dart
    │   ├── tk_bap_screen.dart
    │   ├── tk_booking_screen.dart
    │   ├── tk_clinical_reports_screen.dart
    │   ├── tk_dashboard_screen.dart
    │   ├── tk_insurance_claims_screen.dart
    │   ├── tk_main_screen.dart
    │   ├── tk_notifications_screen.dart
    │   ├── tk_patient_detail_screen.dart
    │   ├── tk_patient_list_screen.dart
    │   ├── tk_qr_scan_screen.dart
    │   ├── tk_schedule_screen.dart
    │   ├── tk_screening_input_screen.dart
    │   └── tk_settings_screen.dart
    ├── providers/
    │   ├── tk_booking_provider.dart
    │   ├── tk_dashboard_provider.dart
    │   ├── tk_health_provider.dart
    │   ├── tk_patient_provider.dart
    │   └── tk_schedule_provider.dart
    └── widgets/
        ├── tk_booking_card.dart
        ├── tk_bottom_nav_bar.dart
        ├── tk_patient_card.dart
        └── tk_stat_card.dart
```

---

## Detail Lapisan (Layers) & File

### 1. Data Layer (`/data`)

Lapisan ini bertanggung jawab untuk mengambil, mengirim, dan memetakan data dari luar (API/Lokal) ke dalam aplikasi.

- **Models (`/models`)**: Representasi data spesifik dari API yang di-serialize/deserialize.
  - `tk_bap_model.dart`: Model untuk data Berita Acara Pemeriksaan (BAP).
  - `tk_clinical_report_model.dart`: Model untuk data Laporan Klinis dari hasil pemeriksaan.
  - `tk_insurance_claim_model.dart`: Model untuk data Klaim Asuransi kesehatan.
- **Repositories (`/repositories`)**: Implementasi dari antarmuka repositori domain.
  - `tk_repository_impl.dart`: Berisi logika konkret untuk melakukan HTTP request (fetch, post, update) yang berkaitan dengan layanan tenaga kesehatan.

### 2. Domain Layer (`/domain`)

Lapisan inti (core) yang memuat entitas dan *business logic* terlepas dari *framework* UI.

- **Entities (`/entities`)**: Objek murni yang merepresentasikan data bisnis di dalam memori.
  - `booking.dart`: Entitas untuk data pemesanan (booking) antrean layanan kesehatan oleh mahasiswa.
  - `medical_record.dart`: Entitas rekam medis historis pasien.
  - `patient.dart`: Entitas data diri mahasiswa sebagai pasien klinik.
  - `schedule.dart`: Entitas jadwal ketersediaan atau praktek tenaga kesehatan.
  - `tk_profile.dart`: Entitas profil pengguna (Tenaga Kesehatan) yang sedang login.
- **Repositories (`/repositories`)**:
  - `tk_repository.dart`: Antarmuka (abstract class) yang mendefinisikan *contract* operasi apa saja yang bisa dilakukan (misal: `getPatients()`, `createBAP()`).

### 3. Presentation Layer (`/presentation`)

Lapisan UI (User Interface) dan *State Management*.

#### A. Pages (Screen / Halaman)
File-file ini adalah halaman-halaman yang dirender dan dapat diakses oleh role Tenaga Kesehatan.
- **Entry & Utama**:
  - `tk_main_screen.dart`: Halaman *wrapper* utama yang memuat navigasi bawah (Bottom Navigation Bar) dan me-routing antar-tab utama.
  - `tk_dashboard_screen.dart`: Halaman beranda (Dashboard) setelah login, menampilkan statistik ringkas (jumlah pasien hari ini, jadwal yang akan datang, dll).
- **Manajemen Pasien**:
  - `tk_patient_list_screen.dart`: Halaman daftar pasien yang memuat daftar mahasiswa yang perlu ditangani atau memiliki riwayat.
  - `tk_patient_detail_screen.dart`: Halaman detail seorang pasien, melihat biodata rinci dan riwayat rekam medis.
- **Manajemen Jadwal & Booking**:
  - `tk_schedule_screen.dart`: Halaman daftar jadwal praktek tenaga kesehatan.
  - `tk_add_schedule_screen.dart`: Halaman form untuk menambahkan jadwal ketersediaan praktek yang baru.
  - `tk_booking_screen.dart`: Halaman untuk melihat antrean atau *booking* pasien yang telah mendaftar sesi kunjungan.
- **Pemeriksaan & Laporan**:
  - `tk_screening_input_screen.dart`: Halaman form untuk menginput data hasil *screening* atau pemeriksaan kesehatan awal pasien.
  - `tk_clinical_reports_screen.dart`: Halaman daftar atau pembuatan laporan klinis terperinci setelah pemeriksaan.
  - `tk_bap_screen.dart`: Halaman daftar riwayat Berita Acara Pemeriksaan (BAP).
  - `tk_bap_form_screen.dart`: Halaman form untuk menyusun dan menerbitkan BAP bagi pasien.
- **Fitur Tambahan**:
  - `tk_insurance_claims_screen.dart`: Halaman manajemen atau pengajuan klaim asuransi kesehatan yang terkait dengan pelayanan klinik kampus.
  - `tk_qr_scan_screen.dart`: Fitur pemindai kode QR (QR Scanner) untuk mempercepat verifikasi kehadiran atau identitas pasien.
  - `tk_notifications_screen.dart`: Pusat notifikasi khusus role Tenaga Kesehatan.
  - `tk_settings_screen.dart`: Halaman pengaturan akun (Profil, Password, Logout).

#### B. Providers (State Management)
Menggunakan `ChangeNotifier` / `Provider` untuk mengelola *state* yang bereaksi terhadap perubahan data.
- `tk_dashboard_provider.dart`: Menangani logika pengambilan data statistik untuk Dashboard.
- `tk_patient_provider.dart`: Menangani pengambilan daftar pasien, detail, dan state rekam medis.
- `tk_schedule_provider.dart`: Mengelola data state jadwal ketersediaan dan penambahan jadwal baru.
- `tk_booking_provider.dart`: Mengelola state daftar booking/antrean pasien dan statusnya.
- `tk_health_provider.dart`: Mengelola proses submit BAP, Laporan Klinis, dan form *screening*.

#### C. Widgets (Komponen UI Reusable)
Potongan-potongan UI yang digunakan berulang kali di berbagai *screens*.
- `tk_bottom_nav_bar.dart`: Komponen navigasi bawah (tab) khusus menu navigasi Tenaga Kesehatan.
- `tk_booking_card.dart`: Komponen kartu (`Card`) untuk menampilkan satu item jadwal *booking* secara visual.
- `tk_patient_card.dart`: Komponen kartu untuk menampilkan info ringkas seorang pasien di dalam *list*.
- `tk_stat_card.dart`: Komponen kartu kecil (statistik) yang menampilkan angka/metrik ringkas di halaman Dashboard.

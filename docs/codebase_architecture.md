# Dokumentasi Arsitektur Codebase UBK Mobile (Super Lengkap)

Dokumen ini merupakan pembedahan anatomi *source code* secara menyeluruh pada aplikasi **UBK Mobile** yang berada di dalam direktori `lib/`. Aplikasi ini mengadopsi prinsip *Clean Architecture* dan *Feature-First Folder Structure*, di mana setiap fitur dipecah berdasarkan modul dan *roles* pengguna.

---

## 1. Direktori Utama: `lib/core/`
Ini adalah jantung dari aplikasi. Semua kelas, komponen, utilitas, dan pengaturan yang bersifat fundamental (dipakai bersama lintas fitur) ditempatkan di sini.

### A. `lib/core/network/`
Modul yang bertanggung jawab atas pengiriman dan penerimaan *request* HTTP ke API Backend.
- **`api_client.dart`**: Implementasi *Singleton* untuk `Dio`. Pusat *setup* Base URL, koneksi *timeout* (15 detik), dan *headers* dasar.
- **`api_interceptors.dart`**: Menyisipkan token autentikasi rahasia (*Bearer Token*) ke dalam setiap *request*, dan secara cerdas me-*log* pesan error jika API mengembalikan kode *failed* (401, 500, dll).
- **`api_exceptions.dart`**: Standarisasi penanganan pesan error dari API agar *user-friendly* di sisi UI.

### B. `lib/core/providers/`
Sistem *State Management* (menggunakan *package provider*). Ini adalah fondasi penyimpanan data global dan penarik data (fetching) dari API.
- **`student_provider.dart`**: *Provider* paling sibuk. Mengatur jadwal, absensi, profil, riwayat beasiswa, hingga *Optimistic UI update* (memperbarui UI sebelum server merespons) bagi Mahasiswa.
- **`counseling_provider.dart`** & **`kencana_provider.dart`**: Memegang data layanan akademik Kencana & psikolog BK.
- **`ormawa_provider.dart`**: Logika organisasi (struktur ormawa, proker).
- **`theme_provider.dart`**: Mengatur status gelap/terang (*Dark Mode* / *Light Mode*).
- **`navigation_provider.dart`**: Sistem pengubah *Tab* pada *bottom navigation*.

### C. `lib/core/services/`
Kelas spesifik untuk pengaturan integrasi layanan pihak ketiga dan inti sistem.
- **`api_gate.dart`**: (KRUSIAL) Bertanggung jawab mengatur `BASE_URL`. Menggunakan prioritas *Environment Variable* `--dart-define=BASE_URL=...` lalu fallback ke URL *hardcoded* (`https://tukang.bkustudenthub.com/api`). Juga me-format *Absolute Path Image URL*.
- **`auth_service.dart`**: Logika pengecekan status login, *logout*, token *expired*.
- **`permission_service.dart`**: Meminta izin sistem (kamera, file/storage, mikrofon).
- **`notification_service.dart`** & **`local_notification_service.dart`**: Integrasi Push Notification dan notifikasi lokal (seperti *alarm* pengingat sesi BK).
- **`biometric_service.dart`**: Integrasi *FaceID* / *Fingerprint*.
- **`proposal_pdf_service.dart`**: Spesialis men-generate dokumen PDF laporan Ormawa.

### D. `lib/core/theme/`
- **`app_colors.dart`**: Daftar token HEX warna paten (*Primary*, *Secondary*, teks, garis).
- **`app_text_styles.dart`**: Konfigurasi Font (ukuran, ketebalan, *letter spacing*).
- **`mobile_theme.dart`**: Menggabungkan warna dan font menjadi `ThemeData` bawaan Material UI.

### E. `lib/core/widgets/` (Reusable UI Components)
Widget UI yang dipakai secara berulang oleh fitur lain:
- **`bku_app_bar.dart`**, **`unified_app_bar.dart`**, **`premium_app_bar.dart`**: Desain *Header*/Top-Bar aplikasi.
- **`unified_bottom_nav_bar.dart`**: Sistem Navigasi Bawah dengan transisi UI interaktif.
- **`unified_card.dart`**, **`bku_shimmer.dart`**: Efek kontainer standar dan efek memuat (*loading skeleton*).
- **`custom_dialog.dart`**, **`permission_gate.dart`**: Dialog pop-up.

---

## 2. Direktori Fitur: `lib/features/`
Di sini kode dikelompokkan ke dalam domain masing-masing *role* (pengguna). Tiap domain memiliki 3 struktur pilar: `domain/` (model & kontrak abstract), `data/` (implementasi JSON & eksekusi API), dan `presentation/` (tampilan UI & logic state).

### A. Modul `auth/`
Menangani `splash_screen.dart` dan `login_screen.dart` (termasuk verifikasi biometrik).

### B. Modul `mahasiswa/` (Student App)
Modul terbesar dengan *sub-folder* per sub-menu:
- **`dashboard/`**: `dashboard_screen.dart` (Beranda mahasiswa), `student_agenda_list.dart`.
- **`achievement/`**: `achievement_screen.dart` (List), `report_achievement_screen.dart` (Form Input & Bukti PDF).
- **`health/`**: `health_booking_form_screen.dart`, `insurance_claim_screen.dart`.
- **`kencana/`**: Sistem akademik eksklusif. Ada `kencana_qr_scan_screen.dart` (Absensi kelas), `assignment_screen.dart` (Kumpul tugas), `quiz_screen.dart`.
- **`organisasi/`**: `organisasi_screen.dart`, pendaftaran organisasi, dan struktur kemahasiswaan.
- **`scholarship/`**: `apply_scholarship_screen.dart` (Form Pendaftaran).
- **`student_voice/`**: Tempat mahasiswa memasukkan kritik dan masukan ke kampus.
- **`notifications/`**: List semua pemberitahuan.

### C. Modul `counseling/` (Psikolog & BK)
Modul untuk Mahasiswa sekaligus Psikolog/Konselor:
- Fitur Pendaftaran oleh Mahasiswa: `book_counseling_screen.dart`.
- Fitur Dasbor Psikolog: `psychologist_dashboard_screen.dart`, `patient_list_screen.dart`.
- Fitur Sistem: `assessment_management_screen.dart`, `session_note_screen.dart` (Mencatat rekam medis konseling).

### D. Modul `ormawa/` (Organisasi Mahasiswa)
Area eksklusif bagi pengurus BEM, HIMA, dan UKM.
- **`absensi/`**: Absen rapat via QR Code.
- **`anggota/`**: `ormawa_anggota_screen.dart` (Daftar & Rekrutmen).
- **`dashboard/` & `main/`**: Panel beranda utama pengurus (mengandung indikator *gamification card* dll).
- **`finance/`**: `ormawa_finance_screen.dart` (Pencatatan kas dan aliran dana acara).
- **`proposal/`** & **`laporan/`**: Sistem pengajuan (LPJ) acara, persetujuan kampus. Memiliki export PDF.
- **`struktur/`** & **`settings/`**: Pengaturan profil organisasi.

### E. Modul `tenaga_kesehatan/` (Medical Staf)
Panel khusus dokter dan tenaga medis kampus.
- **`presentation/pages/`**:
  - `tk_bap_screen.dart` (Berita Acara Pemeriksaan).
  - `tk_patient_list_screen.dart` (Rekam medis pasien/mahasiswa).
  - `tk_qr_scan_screen.dart` (Scanner validasi pasien).
  - `tk_screening_input_screen.dart` (Form input deteksi awal kesehatan).
  - `tk_insurance_claims_screen.dart` (Validasi BPJS/Asuransi Mahasiswa).

### F. Modul Ekstra
- **`profile/`**: `profile_screen.dart` (Pengaturan pengguna global, ganti foto/password).
- **`main/`**: `main_screen.dart` (Pembungkus / *Wrapper* *IndexedStack* dan *Bottom Nav Bar* untuk akun mahasiswa).

---

## 3. Titik Awal (Entry Point): `lib/main.dart`
Ini adalah gerbang eksekusi (fungsi `void main()`). Bertugas untuk:
1. Memuat konfigurasi lingkungan (Environment config via `ApiGate`).
2. Mendaftarkan *Provider* Global (MultiProvider).
3. Mengatur rute awal aplikasi (*router configuration* menggunakan `GoRouter` atau alur navigasi dari *Splash Screen* ke *Login*).
4. Melakukan inisialisasi awal (*service locator*, dll).

---
*Dokumentasi ini ditulis dengan presisi direktori tree, menjabarkan total 230+ file dari repositori `ubkmobail` secara komprehensif.*

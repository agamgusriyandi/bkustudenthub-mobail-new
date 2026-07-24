# Panduan Developer & Audit Teknis (UBKMobail)

Dokumen ini ditulis sebagai panduan *handoff* bagi pengembang selanjutnya untuk memahami struktur kode terkini, panduan standarisasi visual, serta daftar celah fungsional (*functional gaps*) yang tersisa dibandingkan dengan sistem portal web (`siakadNew-server`).

---

## 1. Arsitektur Folder & Modularisasi (Feature-First)

Struktur direktori telah sepenuhnya dirapikan dari folder terpusat lama (`lib/core/providers/`) menuju pendekatan **Feature-First Clean Architecture**.

### 📁 Struktur File Presentasi Baru
Seluruh berkas pengelola keadaan (*provider*) yang sebelumnya berkumpul di core, kini telah dipindahkan ke direktori modul fiturnya masing-masing:
*   `student_provider.dart` $\rightarrow$ `lib/features/mahasiswa/presentation/providers/`
*   `achievement_provider.dart` $\rightarrow$ `lib/features/mahasiswa/achievement/presentation/providers/`
*   `scholarship_provider.dart` $\rightarrow$ `lib/features/mahasiswa/scholarship/presentation/providers/`
*   `ormawa_provider.dart` $\rightarrow$ `lib/features/ormawa/presentation/providers/`
*   `kencana_provider.dart` $\rightarrow$ `lib/features/kencana/presentation/providers/`

> **Aturan Impor:** Pastikan seluruh referensi impor menggunakan paket asli `package:bkuhub_mobile/...` dan **bukan** `package:ubkmobail/...` karena nama paket aktif dideklarasikan di `pubspec.yaml` sebagai `bkuhub_mobile`.

---

## 2. Sistem Desain & Konvensi Gaya Visual

Seluruh berkas visual di bawah `lib/features/` wajib mengikuti design tokens yang ada di `lib/core/theme/` guna mempermudah pemeliharaan mode gelap (*Dark Mode*) di masa depan.

### 📐 Spacing & Margin (`app_spacing.dart`)
JANGAN menggunakan `EdgeInsets.all(double)` secara manual. Gunakan konstanta spacing:
```dart
padding: const EdgeInsets.all(AppSpacing.md) // 12.0
margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl) // 24.0
```

### ⭕ Border Radius (`app_radius.dart`)
JANGAN menulis `BorderRadius.circular(double)` di dalam widget dekorasi. Gunakan konstanta `BorderRadius` bertipe `const`:
```dart
borderRadius: AppRadius.radiusLg // BorderRadius.circular(16)
borderRadius: AppRadius.radiusXl // BorderRadius.circular(24)
```

### 🎨 Kode Warna Heksadesimal (`app_colors.dart`)
Seluruh warna heksadesimal abu-abu netral mentah (*slate/gray*) wajib dipetakan ke token dinamis `AppColors`:
*   `Color(0xFF111827)` atau `Color(0xFF1E293B)` $\rightarrow$ `AppColors.neutral800`
*   `Color(0xFF4B5563)` $\rightarrow$ `AppColors.neutral600`
*   `Color(0xFF6B7280)` $\rightarrow$ `AppColors.neutral500`
*   `Color(0xFF9CA3AF)` $\rightarrow$ `AppColors.neutral400`
*   `Color(0xFFE5E7EB)` $\rightarrow$ `AppColors.neutral200`
*   `Color(0xFFF9FAFB)` $\rightarrow$ `AppColors.neutral50`

---

## 3. Celah Fungsional Kritis (Gaps) vs Web Portal

Berikut adalah modul yang telah di-audit dan memiliki ketidaksesuaian fungsionalitas dengan program Web di `siakadNew-server` yang harus segera diselesaikan:

### ⚠️ A. Beasiswa - Rubrik Penilaian Skema Khusus (`rubrik_answers`)
*   **Masalah:** Pada portal Web (`ScholarshipPage.jsx`), jika skema beasiswa berupa `excellence`, `impact`, `hope_grant`, atau `tahfidz`, terdapat form langkah kuesioner (*Rubrik Penilaian*). Data kuesioner ini dikirim sebagai form-data `rubrik_answers` untuk dihitung skor kelayakannya oleh backend secara otomatis. Aplikasi Mobile saat ini mengirim `rubrik_answers` sebagai `null`, sehingga total skor mahasiswa di DB bernilai `0` (menyebabkan otomatis tidak lolos seleksi).
*   **Solusi bagi Developer Selanjutnya:**
    1.  Ubah `StudentRepository` dan `StudentRepositoryImpl` pada metode `applyForScholarship` untuk menerima parameter opsional `String? rubrikAnswers`.
    2.  Tambahkan parameter tersebut ke `MultipartFile` form-data sebagai `rubrik_answers`.
    3.  Modifikasi [apply_scholarship_screen.dart](file:///Users/agam/Desktop/ubkmobail/lib/features/mahasiswa/scholarship/presentation/pages/apply_scholarship_screen.dart) untuk mendeteksi skema (`widget.scholarship.skema`) dan memunculkan pilihan kuesioner sesuai tipe skema sebelum mengirim formulir.

### ⚠️ B. Penanganan Tautan Dokumen Eksternal / PDF
*   **Masalah:** Untuk berkas panduan beasiswa, sertifikat, atau dokumen pendukung, beberapa tautan diakses secara langsung yang dapat menyebabkan *browser loop* pada perangkat iOS.
*   **Solusi bagi Developer Selanjutnya:** Selalu gunakan paket `url_launcher` dengan mode `LaunchMode.inAppBrowserView` saat membuka berkas PDF atau dokumen agar berkas ter-render dengan stabil di dalam aplikasi.

---

## 4. Standar Operasional Prosedur (SOP) Penulisan Kode

1.  **Tanpa Komentar (Clean Code):** Jangan pernah menuliskan komentar di dalam kode logika. Kode harus menjelaskan dirinya sendiri (*self-documenting*). Bersihkan komentar bawaan (*boilerplate templates*) sebelum melakukan *commit*.
2.  **Zero Warnings:** Kode harus selalu lolos `flutter analyze` dengan **0 issues found**. Lakukan `dart fix --apply` secara rutin.

# API Endpoints - Role Tenaga Kesehatan (BKUhub Mobile)

Berikut adalah daftar endpoint API yang digunakan khusus untuk fitur dan alur kerja **Tenaga Kesehatan** dalam proyek ini, bersumber dari implementasi *repository* (`tk_repository_impl.dart`).

Semua request yang mengarah ke endpoint ini di-*handle* menggunakan `ApiClient` dan memerlukan Bearer Token dari sesi autentikasi pengguna saat ini.

---

## 1. Profil & Akun (Profile)
Endpoint untuk mengambil dan memodifikasi data diri profil Tenaga Kesehatan yang sedang login.

* **GET** `/tenagakes/me`
  Mengambil data profil pengguna (Tenaga Kesehatan) yang sedang login.
* **PUT** `/tenagakes/profile`
  Memperbarui data profil.
* **PUT** `/tenagakes/change-password`
  Mengubah kata sandi pengguna.
* **POST** `/auth/profile/upload-avatar`
  Mengunggah/memperbarui foto profil (avatar). Membutuhkan *form-data* (file image).

## 2. Dasbor (Dashboard)
Endpoint yang merangkum data statistik dan daftar ringkas aktivitas untuk halaman depan (beranda).

* **GET** `/tenagakes/dashboard`
  Mengambil data metrik/ringkasan dashboard (seperti jumlah pasien hari ini, jadwal yang akan datang, dsb).
* **GET** `/tenagakes/activities`
  Mengambil daftar aktivitas terbaru dari Tenaga Kesehatan.

## 3. Jadwal Ketersediaan (Schedules)
Manajemen jam dan ketersediaan praktek dari Tenaga Kesehatan.

* **GET** `/tenagakes/schedules`
  Melihat semua jadwal praktek yang telah dibuat.
* **POST** `/tenagakes/schedules`
  Menambah atau membuat ketersediaan jadwal praktek baru.
* **PUT** `/tenagakes/schedules/{id}`
  Memperbarui data jadwal praktek.
* **DELETE** `/tenagakes/schedules/{id}`
  Menghapus atau membatalkan sebuah jadwal praktek.

## 4. Antrean / Pemesanan (Bookings)
Endpoint untuk memantau pendaftaran sesi yang dilakukan oleh pasien (mahasiswa).

* **GET** `/tenagakes/bookings`
  Melihat daftar *booking* atau antrean pasien yang akan datang.
* **GET** `/tenagakes/bookings/{id}`
  Melihat rincian sebuah transaksi *booking*.
* **PUT** `/tenagakes/bookings/{id}/status`
  Mengubah status *booking* (contoh: menyetujui, menolak, atau menyelesaikan). Dapat menyertakan `alasan_penolakan` di dalam *body* payload.

## 5. Manajemen Pasien (Patients & Medical Records)
Endpoint untuk melihat daftar mahasiswa, pencarian, dan akses riwayat medis.

* **GET** `/tenagakes/patients`
  Mengambil daftar pasien (mahasiswa) yang pernah/sedang berobat.
* **GET** `/tenagakes/students/lookup?query={query}`
  Mencari data mahasiswa (calon pasien) secara spesifik berdasarkan nama/NIM.
* **GET** `/tenagakes/patients/{patientId}/medical-record`
  Mengambil rekam medis historis dari seorang pasien.
* **GET** `/tenagakes/medical-records/{recordId}/export-pdf?token={token}`
  Endpoint export (URL render langsung) untuk mengunduh rekam medis pasien sebagai berkas dokumen PDF.

## 6. Pemeriksaan (Screening Input)
Alur input hasil *screening* awal atau pemeriksaan langsung dari pasien.

* **POST** `/tenagakes/patients/{patientId}/screening`
  Menambahkan data hasil pemeriksaan / *screening* (diagnosis, gejala, catatan) untuk dimasukkan ke dalam catatan rekam medis.

## 7. Rujukan ke Psikolog (Referrals)
Alur ketika Tenaga Kesehatan memutuskan merujuk pasien ke Psikolog kampus.

* **GET** `/tenagakes/psychologists`
  Menampilkan daftar nama dan profil para Psikolog.
* **GET** `/tenagakes/psychologists/{id}/schedules`
  Melihat jadwal praktek dari Psikolog spesifik.
* **GET** `/tenagakes/rujukans`
  Melihat riwayat atau daftar surat rujukan yang pernah dikeluarkan.
* **POST** `/tenagakes/rujukan`
  Menerbitkan rujukan baru untuk pasien dari Tenaga Kesehatan ke Psikolog.

## 8. BAP Kesehatan
Berita Acara Pemeriksaan (BAP) sebagai dokumen formal pemeriksaan medis.

* **GET** `/tenagakes/bap`
  Daftar semua dokumen BAP yang telah diterbitkan.
* **GET** `/tenagakes/bap/{id}`
  Rincian data BAP tertentu.
* **POST** `/tenagakes/bap`
  Membuat formulir BAP baru.
* **PUT** `/tenagakes/bap/{id}`
  Memperbarui data formulir BAP (sebelum *final*).
* **DELETE** `/tenagakes/bap/{id}`
  Membatalkan/menghapus formulir BAP.
* **GET** `/tenagakes/bap/{id}/export-pdf?token={token}`
  Endpoint *export* (URL tautan unduh) guna menghasilkan BAP dalam format PDF resmi.

## 9. Klaim Asuransi (Insurance Claims)
Review, persetujuan, atau pemantauan terkait asuransi dari perawatan di klinik kampus.

* **GET** `/tenagakes/claims`
  Melihat daftar klaim asuransi kesehatan yang diajukan atau terkait klinik kampus.
* **PUT** `/tenagakes/claims/{id}/status`
  Mengubah status klaim (contoh: *Approved*, *Rejected*). Mendukung catatan penambahan `catatan_review`.

## 10. Laporan Klinis (Clinical Reports)
Untuk membuat rekapitulasi jumlah kunjungan bulanan dan analisis.

* **GET** `/tenagakes/reports?start_date={date}&end_date={date}`
  Menghasilkan ringkasan dan data statistik laporan klinis dalam rentang waktu (*date range*) yang dipilih.

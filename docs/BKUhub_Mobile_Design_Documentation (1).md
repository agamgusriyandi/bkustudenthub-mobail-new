# BKUhub Mobile — Dokumentasi Desain

> Dokumentasi lengkap design system dan daftar screen untuk aplikasi mobile **BKUhub Student**.  
> Framework: Flutter | Platform: Android | Bahasa: Dart

---

## Daftar Isi

1. [Tentang Aplikasi](#tentang-aplikasi)
2. [Daftar Screen](#daftar-screen)
3. [Design System](#design-system)
   - [Brand & Gaya Visual](#brand--gaya-visual)
   - [Warna](#warna)
   - [Tipografi](#tipografi)
   - [Layout & Spacing](#layout--spacing)
   - [Elevasi & Kedalaman](#elevasi--kedalaman)
   - [Bentuk (Shape)](#bentuk-shape)
   - [Komponen](#komponen)

---

## Tentang Aplikasi

**BKUhub Mobile** adalah aplikasi mobile untuk mahasiswa yang berfungsi sebagai pusat informasi dan layanan akademik. Aplikasi ini menggabungkan berbagai fitur kemahasiswaan dalam satu platform yang terintegrasi, mulai dari dashboard akademik, beasiswa, organisasi, konseling, hingga kesehatan.

---

## Daftar Screen

Aplikasi ini terdiri dari **9 modul utama**, masing-masing memiliki variasi state (connected_1 & connected_2):

| No | Nama Screen | Folder | Deskripsi |
|----|-------------|--------|-----------|
| 1 | **Dashboard** | `dashboard_mobile_connected_1` & `_2` | Halaman utama / beranda mahasiswa |
| 2 | **Kencana** | `kencana_mobile_connected_1` & `_2` | Fitur layanan Kencana BKU |
| 3 | **Achievement** | `achievement_mobile_connected_1` & `_2` | Riwayat & pencapaian akademik mahasiswa |
| 4 | **Scholarship Hub** | `scholarship_hub_mobile_connected_1` & `_2` | Informasi dan pendaftaran beasiswa |
| 5 | **Student Profile** | `student_profile_mobile_connected_1` & `_2` | Profil lengkap mahasiswa |
| 6 | **Health Screening** | `health_screening_mobile_connected_1` & `_2` | Pusat Kesehatan BKU |
| 7 | **Student Voice** | `student_voice_mobile_connected_1` & `_2` | Aspirasi dan suara mahasiswa |
| 8 | **Organisasi** | `organisasi_mobile_connected_1` & `_2` | Informasi organisasi kemahasiswaan |
| 9 | **Counseling Hub** | `counseling_mobile_connected_1` & `_2` | Layanan konseling mahasiswa |

> Setiap screen tersedia dalam dua state: `connected_1` (state awal) dan `connected_2` (state interaksi/lanjutan).

---

## Design System

### Brand & Gaya Visual

Design system ini dibangun di atas estetika **Corporate / Modern** yang disesuaikan untuk lingkungan akademik. Kepribadian brand bersifat autoritatif namun suportif — berfungsi sebagai pendamping digital yang andal bagi mahasiswa.

Arah visual mengutamakan **kejelasan dan efisiensi**. Elemen dekoratif yang tidak perlu dihindari, digantikan oleh tipografi berkualitas tinggi dan hierarki informasi yang terstruktur. Antarmuka terasa institusional dan terpercaya, mencerminkan nilai-nilai lembaga pendidikan tinggi sambil tetap modern dan intuitif.

---

### Warna

Palet warna berpusat pada **navy biru gelap** yang merepresentasikan stabilitas dan keilmuan. Aksen **gold-yellow** diambil dari identitas BKU sebagai penanda visibilitas tinggi untuk indikator status, pencapaian, dan detail CTA.

#### Token Warna Utama

| Token | Nilai HEX | Kegunaan |
|-------|-----------|----------|
| `primary` | `#002068` | Navigasi utama, brand moments |
| `primary-container` | `#003399` | Tombol primer, header kartu |
| `on-primary` | `#ffffff` | Teks di atas warna primary |
| `secondary` | `#745b00` | Aksen gold, indikator status |
| `secondary-container` | `#fdd355` | Badge, highlight CTA |
| `tertiary-container` | `#004721` | Indikator sukses / hijau |
| `on-tertiary-container` | `#3dbe6e` | Teks sukses |
| `error` | `#ba1a1a` | Alert kritis, aksi logout |
| `background` | `#fbf9f8` | Latar belakang app |
| `surface` | `#fbf9f8` | Permukaan umum |
| `surface-container-lowest` | `#ffffff` | Kartu konten (putih bersih) |
| `outline` | `#747684` | Border input, pembatas |
| `on-surface` | `#1b1c1c` | Teks utama |
| `on-surface-variant` | `#444653` | Teks sekunder / subteks |

#### Token Surface Lengkap

| Token | Nilai HEX |
|-------|-----------|
| `surface-dim` | `#dbdad9` |
| `surface-bright` | `#fbf9f8` |
| `surface-container-low` | `#f5f3f3` |
| `surface-container` | `#efeded` |
| `surface-container-high` | `#e9e8e7` |
| `surface-container-highest` | `#e4e2e2` |
| `inverse-surface` | `#303031` |
| `inverse-on-surface` | `#f2f0f0` |
| `outline-variant` | `#c4c5d5` |
| `surface-tint` | `#3557bc` |

> Semua warna dikalibrasi memenuhi standar kontras **WCAG AA** untuk aksesibilitas maksimal.

---

### Tipografi

Font yang digunakan adalah **Inter** — dipilih karena keterbacaan luar biasa di layar mobile dan karakter yang netral dan profesional.

| Skala | Font | Ukuran | Weight | Line Height | Keterangan |
|-------|------|--------|--------|-------------|------------|
| `display` | Inter | 24px | 700 | 32px | Judul besar, hero text |
| `headline-md` | Inter | 20px | 600 | 28px | Header bagian |
| `title-lg` | Inter | 18px | 600 | 24px | Judul kartu, sub-section |
| `body-lg` | Inter | 16px | 400 | 24px | Teks bacaan panjang |
| `body-md` | Inter | 14px | 400 | 20px | Teks konten umum |
| `label-md` | Inter | 12px | 500 | 16px | Label, chip, badge |
| `label-sm` | Inter | 10px | 600 | 14px | Teks kecil, caption |

> `display` dan `label-md` menggunakan `letterSpacing` tambahan: `-0.02em` dan `0.01em`.

---

### Layout & Spacing

Model layout menggunakan **Fluid Grid** yang dioptimalkan untuk viewport mobile dengan sistem grid **baseline 4px**.

| Token | Nilai | Kegunaan |
|-------|-------|----------|
| `base` | 4px | Unit dasar grid |
| `margin-page` | 16px | Margin kiri-kanan halaman |
| `gutter` | 12px | Jarak antar kolom |
| `card-padding` | 16px | Padding internal kartu |
| `stack-sm` | 8px | Jarak antar elemen terkait |
| `stack-md` | 16px | Jarak antar sub-modul |
| `stack-lg` | 24px | Jarak antar modul berbeda |

---

### Elevasi & Kedalaman

Hierarki visual dikelola melalui **Tonal Layers** dikombinasikan dengan **Ambient Shadows**:

| Level | Elemen | Shadow |
|-------|--------|--------|
| **Level 0 (Base)** | Background app `#fbf9f8` | Tanpa shadow |
| **Level 1 (Cards)** | Kartu konten (putih) | `0px 4px 12px` — opacity 5% |
| **Level 2 (Interactive)** | FAB, kartu aktif | `0px 8px 24px` — opacity 10% |

Outline digunakan secara hemat — hanya untuk input field dan tombol sekunder.

---

### Bentuk (Shape)

Bahasa bentuk menggunakan **Rounded** secara sistematis:

| Token | Nilai | Kegunaan |
|-------|-------|----------|
| `sm` | 0.25rem (4px) | Chip, checkbox, elemen kecil |
| `DEFAULT` | 0.5rem (8px) | Kartu utama, tombol primer |
| `md` | 0.75rem (12px) | — |
| `lg` | 1rem (16px) | Banner, modul interaktif besar |
| `xl` | 1.5rem (24px) | — |
| `full` | 9999px | Avatar, pill badge |

---

### Komponen

#### Tombol (Buttons)

| Tipe | Deskripsi |
|------|-----------|
| **Primary** | Background Navy `#003399`, teks putih, radius 8px. Digunakan untuk aksi utama. |
| **Secondary** | Background putih, border + teks Navy. Digunakan untuk aksi sekunder seperti "Lihat Riwayat". |
| **Ghost** | Tanpa background dan border. Digunakan untuk navigasi di header atau aksi tersier. |

#### Kartu & Container

Kartu adalah unit organisasi utama. Wajib menggunakan background putih dengan shadow halus. Header kartu menggunakan warna navy untuk judul.

#### Input Field

Border abu-abu terang `#E0E0E0` yang berubah menjadi navy biru saat fokus. Teks placeholder harus netral dan jelas.

#### Chip & Badge

Digunakan untuk indikator status (contoh: "Terverifikasi", "Menunggu"). Menggunakan background pastel dari warna status dengan teks kontras tinggi.

#### Navigasi

Bottom navigation bar dengan akses cepat ke: **Dashboard**, **Achievement**, **Scholarship**, dan **Profile**. Ikon menggunakan gaya line dengan stroke 2px untuk kejelasan di layar retina.

#### List Item

List interaktif (seperti Riwayat Prestasi) harus menyertakan ikon chevron-right sebagai tanda item dapat diklik, dengan padding vertikal minimal **12px** untuk area sentuh yang nyaman.

---

## Struktur File

```
stitch_bku_student_mobile_app/
├── academic_excellence_hub/
│   └── DESIGN.md                          ← Design system sumber
├── dashboard_mobile_connected_1/
│   ├── code.html
│   └── screen.png
├── dashboard_mobile_connected_2/
│   ├── code.html
│   └── screen.png
├── kencana_mobile_connected_1/
├── kencana_mobile_connected_2/
├── achievement_mobile_connected_1/
├── achievement_mobile_connected_2/
├── scholarship_hub_mobile_connected_1/
├── scholarship_hub_mobile_connected_2/
├── student_profile_mobile_connected_1/
├── student_profile_mobile_connected_2/
├── health_screening_mobile_connected_1/
├── health_screening_mobile_connected_2/
├── student_voice_mobile_connected_1/
├── student_voice_mobile_connected_2/
├── organisasi_mobile_connected_1/
├── organisasi_mobile_connected_2/
├── counseling_mobile_connected_1/
└── counseling_mobile_connected_2/
```

---

*Dokumentasi ini dibuat berdasarkan file desain `stitch_bku_student_mobile_app` untuk keperluan pengembangan Flutter BKUhub Mobile.*

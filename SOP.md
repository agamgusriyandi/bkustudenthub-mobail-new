# SOP Git - ubkmobail (Aplikasi Mobile)

Dokumen ini adalah standar operasional (SOP) Git untuk project **ubkmobail** (Mobile Application).

---

## 📌 Info Repositori

- **Folder Local**: `ubkmobail`
- **Remote Repo**: `git@github.com:agamgusriyandi/bkustudenthub-mobail-new.git`
- **Target Branch**: **`main`**

---

## 📥 Panduan PULL (Tarik Update Terbaru Mobile)

Jalankan perintah ini sebelum mulai coding untuk mendapatkan versi aplikasi mobile terbaru:

```bash
# Masuk ke folder ubkmobail
cd /Users/agam/Kerjaan/bkustudenthub-new/ubkmobail

# Tarik update dari remote main
git pull origin main
```

*Perintah 1-Baris dari Root Workspace:*
```bash
git -C ubkmobail pull origin main
```

---

## 🚀 Panduan PUSH (Upload Perubahan Mobile)

Jalankan perintah ini untuk meng-upload perubahan ke repository mobile:

```bash
# 1. Masuk ke folder ubkmobail
cd /Users/agam/Kerjaan/bkustudenthub-new/ubkmobail

# 2. Cek status perubahan
git status

# 3. Tambahkan file ke staging area
git add .

# 4. Commit perubahan
git commit -m "feat: [deskripsi fitur/fix mobile]"

# 5. Pull terbaru dulu
git pull origin main

# 6. Push ke branch main repo mobile
git push origin main
```

*Perintah 1-Baris dari Root Workspace:*
```bash
git -C ubkmobail add . && git -C ubkmobail commit -m "update: [pesan]" && git -C ubkmobail push origin main
```

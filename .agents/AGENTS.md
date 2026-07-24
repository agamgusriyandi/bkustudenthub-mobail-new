## 1. SOP Penulisan Kode (Clean Code)
- **Tanpa Komentar**: Tulis kode yang "self-documenting" (menjelaskan dirinya sendiri melalui penamaan variabel, fungsi, dan struktur yang baik). JANGAN menambahkan komentar (comments) di dalam kode agar *codebase* tetap bersih dan rapih. Pengecualian hanya untuk dokumentasi API publik (`///`) jika benar-benar diinstruksikan.
- **Hapus Komentar Bawaan**: Saat melakukan refactoring atau membuat file baru, hapus semua komentar *boilerplate* yang digenerate oleh sistem atau IDE.

## Agent skills

### Issue tracker

Local markdown files in `.scratch/`. See `docs/agents/issue-tracker.md`.

### Triage labels

Default canonical labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context layout (root `CONTEXT.md`). See `docs/agents/domain.md`.

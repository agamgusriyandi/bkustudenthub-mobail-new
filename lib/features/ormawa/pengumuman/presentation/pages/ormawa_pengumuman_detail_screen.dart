import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/pengumuman/presentation/pages/edit_pengumuman_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaPengumumanDetailScreen extends StatelessWidget {
  final OrmawaAnnouncement announcement;

  const OrmawaPengumumanDetailScreen({super.key, required this.announcement});

  Map<String, dynamic> _getCategoryMeta(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('prestasi')) {
      return {
        'label': 'Kabar Prestasi',
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
        'icon': Icons.emoji_events_rounded,
      };
    } else if (lower.contains('penting') || lower.contains('urgen')) {
      return {
        'label': 'Penting & Urgen',
        'color': const Color(0xFFE11D48),
        'bg': const Color(0xFFFFE4E6),
        'icon': Icons.priority_high_rounded,
      };
    } else if (lower.contains('kegiatan') || lower.contains('event')) {
      return {
        'label': 'Info Kegiatan',
        'color': const Color(0xFF0284C7),
        'bg': const Color(0xFFE0F2FE),
        'icon': Icons.event_rounded,
      };
    }
    return {
      'label': 'Umum',
      'color': const Color(0xFF475569),
      'bg': const Color(0xFFF1F5F9),
      'icon': Icons.campaign_rounded,
    };
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE11D48), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Hapus Pengumuman?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus siaran "${announcement.judul}"? Tindakan ini tidak dapat dibatalkan.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogCtx);
                    try {
                      await context.read<OrmawaProvider>().deleteAnnouncement(announcement.id);
                      if (context.mounted) {
                        AppSnackbar.showSuccess(context, 'Pengumuman berhasil dihapus');
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppSnackbar.showError(context, 'Gagal menghapus pengumuman: $e');
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Ya, Hapus', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = OrmawaTheme.primary;
    final meta = _getCategoryMeta(announcement.kategori);
    final catColor = meta['color'] as Color;
    final catBg = meta['bg'] as Color;
    final displayDate = announcement.tanggalMulai ?? announcement.createdAt;

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Detail Pengumuman',
        subtitle: 'Informasi Siaran Ormawa',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: catColor.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(color: catColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              meta['label'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: catColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_alt_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              announcement.targetAudiens.isNotEmpty
                                  ? announcement.targetAudiens
                                  : 'Semua Mahasiswa',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    announcement.judul,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 5),
                      Text(
                        displayDate != null
                            ? DateFormat('dd MMMM yyyy, HH:mm', 'id').format(displayDate)
                            : 'Tanggal tidak tertera',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      if (announcement.tanggalSelesai != null) ...[
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                        const SizedBox(width: 8),
                        const Icon(Icons.event_busy_rounded, size: 13, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 5),
                        Text(
                          'Berakhir: ${DateFormat('dd MMM yyyy', 'id').format(announcement.tanggalSelesai!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ISI PENGUMUMAN',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF94A3B8),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    announcement.isi.isEmpty
                        ? 'Tidak ada rincian konten pengumuman yang disertakan.'
                        : announcement.isi,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
            if (announcement.lampiranUrl != null && announcement.lampiranUrl!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: OrmawaTheme.primarySoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: OrmawaTheme.primaryBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: OrmawaTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.attachment_rounded, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tautan Dokumen / Lampiran',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: OrmawaTheme.primaryDark,
                            ),
                          ),
                          Text(
                            announcement.lampiranUrl!.trim(),
                            style: TextStyle(
                              fontSize: 11,
                              color: OrmawaTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final uri = Uri.tryParse(announcement.lampiranUrl!.trim());
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrmawaTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.open_in_new_rounded, size: 14),
                      label: const Text('Buka', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF64748B).withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmDelete(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFFECDD3)),
                  backgroundColor: const Color(0xFFFFF1F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                label: const Text(
                  'Hapus',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFFE11D48)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPengumumanScreen(announcement: announcement),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text(
                  'Edit Pengumuman',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
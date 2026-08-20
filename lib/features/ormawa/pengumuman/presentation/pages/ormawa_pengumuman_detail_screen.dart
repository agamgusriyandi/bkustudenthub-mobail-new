import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
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
        'color': BkuTheme.amber,
        'bg': BkuTheme.amberSoft,
        'icon': Icons.emoji_events_rounded,
      };
    } else if (lower.contains('penting') || lower.contains('urgen')) {
      return {
        'label': 'Penting & Urgen',
        'color': BkuTheme.rose,
        'bg': BkuTheme.roseSoft,
        'icon': Icons.priority_high_rounded,
      };
    } else if (lower.contains('kegiatan') || lower.contains('event')) {
      return {
        'label': 'Info Kegiatan',
        'color': BkuTheme.primary,
        'bg': BkuTheme.primarySoft,
        'icon': Icons.event_rounded,
      };
    }
    return {
      'label': 'Umum',
      'color': BkuTheme.textBody,
      'bg': BkuTheme.borderSubtle,
      'icon': Icons.campaign_rounded,
    };
  }

  void _confirmDelete(BuildContext context) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Pengumuman?',
      message: 'Apakah Anda yakin ingin menghapus siaran "${announcement.judul}"? Tindakan ini bersifat permanen.',
      primaryButtonText: 'Hapus',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () async {
        Navigator.pop(context);
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
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meta = _getCategoryMeta(announcement.kategori);
    final catColor = meta['color'] as Color;
    final catBg = meta['bg'] as Color;
    final displayDate = announcement.tanggalMulai ?? announcement.createdAt;

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Detail Pengumuman',
        subtitle: 'Informasi Siaran Ormawa',
        variant: AppBarVariant.ormawa,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.s100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BkuCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: BkuTheme.r8,
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
                          color: BkuTheme.borderSubtle,
                          borderRadius: BkuTheme.r8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_alt_rounded, size: 12, color: BkuTheme.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              announcement.targetAudiens.isNotEmpty
                                  ? announcement.targetAudiens
                                  : 'Semua Mahasiswa',
                              style: BkuTheme.textCaption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: BkuTheme.textBody,
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
                    style: BkuTheme.textSectionTitle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 13, color: BkuTheme.textPlaceholder),
                      const SizedBox(width: 5),
                      Text(
                        displayDate != null
                            ? DateFormat('dd MMMM yyyy, HH:mm', 'id').format(displayDate)
                            : 'Tanggal tidak tertera',
                        style: BkuTheme.textCaption.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BkuTheme.textMuted,
                        ),
                      ),
                      if (announcement.tanggalSelesai != null) ...[
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: BkuTheme.border)),
                        const SizedBox(width: 8),
                        const Icon(Icons.event_busy_rounded, size: 13, color: BkuTheme.textPlaceholder),
                        const SizedBox(width: 5),
                        Text(
                          'Berakhir: ${DateFormat('dd MMM yyyy', 'id').format(announcement.tanggalSelesai!)}',
                          style: BkuTheme.textCaption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: BkuTheme.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            BkuCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              borderRadius: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Isi Pengumuman',
                    style: BkuTheme.textBadge.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textHeading,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    announcement.isi.isEmpty
                        ? 'Tidak ada rincian konten pengumuman yang disertakan.'
                        : announcement.isi,
                    style: BkuTheme.textBodyRegular.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: BkuTheme.textHeading,
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
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r18,
                  border: Border.all(color: BkuTheme.primaryBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: BkuTheme.primary,
                        borderRadius: BkuTheme.r12,
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
                            style: BkuTheme.textCardTitle.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: BkuTheme.primaryDark,
                            ),
                          ),
                          Text(
                            announcement.lampiranUrl!.trim(),
                            style: TextStyle(
                              fontSize: 11,
                              color: BkuTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    BkuButton.primary(
                      onPressed: () async {
                        final uri = Uri.tryParse(announcement.lampiranUrl!.trim());
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      icon: Icons.open_in_new_rounded,
                      text: 'Buka',
                      height: 36,
                      fontSize: 11,
                      fullWidth: false,
                      customRadius: BkuTheme.r10,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: BkuTheme.cardSurface,
          border: const Border(top: BorderSide(color: BkuTheme.border)),
          boxShadow: BkuTheme.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: BkuButton.dangerOutline(
                onPressed: () => _confirmDelete(context),
                icon: Icons.delete_outline_rounded,
                text: 'Hapus',
                height: 46,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: BkuButton.primary(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPengumumanScreen(announcement: announcement),
                    ),
                  );
                },
                icon: Icons.edit_rounded,
                text: 'Edit Pengumuman',
                height: 46,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
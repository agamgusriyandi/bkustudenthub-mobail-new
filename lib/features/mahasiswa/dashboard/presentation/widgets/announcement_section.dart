import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/features/mahasiswa/berita/presentation/pages/berita_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementSection extends StatelessWidget {
  final List<dynamic> announcements;

  const AnnouncementSection({super.key, required this.announcements});

  Color _getKategoriColor(BuildContext context, String kategori) {
    final k = kategori.toLowerCase();
    switch (k) {
      case 'umum':
        return AppColors.info;
      case 'akademik':
        return AppColors.tertiary;
      case 'kemahasiswaan':
        return AppColors.success;
      case 'urgent':
        return AppColors.error;
      case 'event':
        return AppColors.warning;
      case 'beasiswa':
        return context.appColors.primary;
      default:
        return AppColors.neutral500;
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.feed_rounded,
                  color: context.appColors.primary,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Pengumuman',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (announcements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusXl,
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.neutral300,
                  size: 40,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Belum ada pengumuman terbaru.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: announcements.length,
            separatorBuilder:
                (context, index) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = announcements[index];
              if (item == null || item is! Map) return const SizedBox.shrink();

              final kategori = item['kategori']?.toString() ?? 'Umum';
              final judul = item['judul']?.toString() ?? 'Pengumuman';
              final isi = item['isi_singkat']?.toString() ?? '';
              final tanggal = item['tanggal']?.toString() ?? '';
              final gambarRaw = item['gambar_url']?.toString() ?? '';
              final link = item['link']?.toString();
              final id = item['id'] ?? item['ID'];

              String? gambarUrl;
              if (gambarRaw.isNotEmpty) {
                gambarUrl =
                    gambarRaw.startsWith('http')
                        ? gambarRaw
                        : ApiGate.getImageUrl(gambarRaw);
              }

              final katColor = _getKategoriColor(context, kategori);

              final cleanIsi =
                  isi.replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ').trim();

              return GestureDetector(
                onTap: () async {
                  if (link != null && link.startsWith('http')) {
                    final uri = Uri.tryParse(link);
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  } else if (id != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BeritaDetailScreen(beritaId: int.tryParse(id.toString()) ?? 0),
                      ),
                    );
                  }
                },
                child: BkuCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (gambarUrl != null) ...[
                        ClipRRect(
                          borderRadius: AppRadius.radiusLg,
                          child: CachedNetworkImage(
                            imageUrl: gambarUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => Container(
                                  color: AppColors.neutral200,
                                  width: 72,
                                  height: 72,
                                ),
                            errorWidget:
                                (context, url, error) => Container(
                                  color: AppColors.neutral200,
                                  width: 72,
                                  height: 72,
                                  child: const Icon(
                                    Icons.image_not_supported_rounded,
                                    color: AppColors.neutral400,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: katColor.withAlpha(20),
                                    borderRadius: AppRadius.radiusSm,
                                    border: Border.all(
                                      color: katColor.withAlpha(50),
                                    ),
                                  ),
                                  child: Text(
                                    kategori,
                                    style: AppTextStyles.caption.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: katColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                if (tanggal.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 10,
                                        color: AppColors.neutral500,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        _formatDate(tanggal),
                                        style: AppTextStyles.caption.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              judul,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (cleanIsi.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                cleanIsi,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.neutral500,
                                  height: 1.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

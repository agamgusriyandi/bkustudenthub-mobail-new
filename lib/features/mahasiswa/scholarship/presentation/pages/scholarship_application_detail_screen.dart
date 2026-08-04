import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';

class ScholarshipApplicationDetailScreen extends StatelessWidget {
  final Scholarship scholarship;

  const ScholarshipApplicationDetailScreen({
    super.key,
    required this.scholarship,
  });

  Future<void> _launchUrl(BuildContext context, String? urlString) async {
    if (urlString == null || urlString.trim().isEmpty) return;

    final String fullUrl = ApiGate.getImageUrl(urlString.trim());
    final Uri? url = Uri.tryParse(fullUrl.replaceAll(' ', '%20'));
    if (url == null) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Link dokumen tidak valid');
      }
      return;
    }

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.inAppBrowserView);
      if (!launched) {
        launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      if (!launched && context.mounted) {
        AppSnackbar.showError(context, 'Gagal membuka file dokumen');
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, 'Gagal membuka dokumen lampiran');
      }
    }
  }

  Map<String, dynamic> _getCustomAnswers() {
    if (scholarship.customAnswersRaw == null) return {};
    if (scholarship.customAnswersRaw is Map) {
      return Map<String, dynamic>.from(scholarship.customAnswersRaw);
    }
    if (scholarship.customAnswersRaw is String) {
      try {
        final decoded = json.decode(scholarship.customAnswersRaw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return {};
  }

  int _getStageIndex(String status) {
    final s = status.toLowerCase();
    if (s.contains('pendaftaran') || s.contains('pengajuan')) return 0;
    if (s.contains('berkas')) {
      return 1;
    }
    if (s.contains('wawancara')) {
      return 2;
    }
    if (s.contains('tertulis')) {
      return 3;
    }
    if (s.contains('pengumuman')) {
      return 4;
    }
    if (s.contains('pencairan') ||
        s.contains('hasil') ||
        s.contains('diterima') ||
        s.contains('ditolak') ||
        s.contains('lulus')) {
      return 5;
    }
    return 0;
  }

  Widget _buildTimeline(BuildContext context, String currentStatus) {
    final bool isRejected = currentStatus.toLowerCase().contains('ditolak');
    final stages = [
      'Pendaftaran',
      'Verifikasi Berkas',
      'Seleksi Wawancara',
      'Seleksi Tertulis',
      'Pengumuman',
      isRejected ? 'Ditolak' : 'Pencairan',
    ];
    final int currentIndex = _getStageIndex(currentStatus);
    final Color activeColor =
        isRejected ? Theme.of(context).colorScheme.error : AppColors.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return _buildVerticalTimeline(
            context,
            stages,
            currentIndex,
            activeColor,
          );
        } else {
          return _buildHorizontalTimeline(
            context,
            stages,
            currentIndex,
            activeColor,
          );
        }
      },
    );
  }

  Widget _buildVerticalTimeline(
    BuildContext context,
    List<String> stages,
    int currentIndex,
    Color activeColor,
  ) {
    final bool isRejected = activeColor == Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: List.generate(stages.length, (index) {
          final bool isCompletedPast = index < currentIndex;
          final bool isCurrent = index == currentIndex;
          final bool isDone = index <= currentIndex;
          final bool isLast = index == stages.length - 1;

          Color circleColor;
          if (isCurrent) {
            circleColor = isRejected ? AppColors.error : AppColors.primary;
          } else if (isCompletedPast) {
            circleColor = AppColors.success;
          } else {
            circleColor = AppColors.neutral200;
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border:
                            isCurrent
                                ? Border.all(
                                  color: circleColor.withAlpha(80),
                                  width: 3,
                                )
                                : null,
                        boxShadow:
                            isCurrent
                                ? [
                                  BoxShadow(
                                    color: circleColor.withAlpha(40),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompletedPast
                                ? Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: context.appColors.onPrimary,
                                )
                                : isCurrent && isRejected
                                ? Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: context.appColors.onPrimary,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 10,
                                    color:
                                        isCurrent
                                            ? context.appColors.onPrimary
                                            : AppColors.neutral600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          color:
                              index < currentIndex
                                  ? AppColors.success
                                  : AppColors.neutral200,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              stages[index],
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight:
                                    isDone ? FontWeight.w900 : FontWeight.w600,
                                color:
                                    isDone
                                        ? AppColors.neutral900
                                        : AppColors.neutral500,
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: circleColor.withAlpha(20),
                                  borderRadius: AppRadius.radiusXs,
                                ),
                                child: Text(
                                  isRejected ? 'DITOLAK' : 'AKTIF',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: circleColor,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          isCompletedPast
                              ? 'Tahap selesai'
                              : isCurrent
                              ? (isRejected
                                  ? 'Pengajuan tidak memenuhi kriteria'
                                  : 'Sedang diproses panitia')
                              : 'Belum dimulai',
                          style: AppTextStyles.bodySm.copyWith(
                            fontSize: 11,
                            color:
                                isDone
                                    ? AppColors.neutral700
                                    : AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHorizontalTimeline(
    BuildContext context,
    List<String> stages,
    int currentIndex,
    Color activeColor,
  ) {
    final bool isRejected = activeColor == Theme.of(context).colorScheme.error;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stages.length, (index) {
        final bool isCompletedPast = index < currentIndex;
        final bool isCurrent = index == currentIndex;
        final bool isDone = index <= currentIndex;
        final bool isLast = index == stages.length - 1;

        Color circleColor;
        Color textColor;
        if (isCurrent) {
          circleColor = isRejected ? AppColors.error : AppColors.primary;
          textColor = circleColor;
        } else if (isCompletedPast) {
          circleColor = AppColors.success;
          textColor = AppColors.success;
        } else {
          circleColor = AppColors.neutral200;
          textColor = AppColors.neutral500;
        }

        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border:
                            isCurrent
                                ? Border.all(
                                  color: circleColor.withAlpha(50),
                                  width: 4,
                                )
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompletedPast
                                ? Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: context.appColors.onPrimary,
                                )
                                : isCurrent && isRejected
                                ? Icon(
                                  Icons.close_rounded,
                                  size: 12,
                                  color: context.appColors.onPrimary,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontSize: 9,
                                    color:
                                        isCurrent
                                            ? context.appColors.onPrimary
                                            : AppColors.neutral600,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      stages[index],
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 9,
                        fontWeight:
                            isDone ? FontWeight.w900 : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: AppSpacing.s11),
                    color:
                        index < currentIndex
                            ? AppColors.success
                            : AppColors.neutral200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildModernDocumentGrid(BuildContext context) {
    final docs = <Map<String, String>>[];
    if (scholarship.ktmKtpUrl != null && scholarship.ktmKtpUrl!.isNotEmpty) {
      docs.add({
        'title': 'KTM / KTP',
        'url': scholarship.ktmKtpUrl!,
        'type': 'id',
      });
    }
    if (scholarship.transkripUrl != null &&
        scholarship.transkripUrl!.isNotEmpty) {
      docs.add({
        'title': 'Transkrip Nilai',
        'url': scholarship.transkripUrl!,
        'type': 'academic',
      });
    }
    if (scholarship.sertifikatUrl != null &&
        scholarship.sertifikatUrl!.isNotEmpty) {
      docs.add({
        'title': 'Sertifikat Pendukung',
        'url': scholarship.sertifikatUrl!,
        'type': 'certificate',
      });
    }

    if (docs.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final double itemWidth =
            constraints.maxWidth > 340
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              docs.map((doc) {
                Color bgAccent;
                Color iconColor;
                IconData docIcon;

                switch (doc['type']) {
                  case 'id':
                    bgAccent = context.appColors.infoContainer;
                    iconColor = context.appColors.primary;
                    docIcon = Icons.badge_rounded;
                    break;
                  case 'academic':
                    bgAccent = context.appColors.successContainer;
                    iconColor = context.appColors.info;
                    docIcon = Icons.school_rounded;
                    break;
                  case 'certificate':
                    bgAccent = context.appColors.infoContainer;
                    iconColor = context.appColors.info;
                    docIcon = Icons.workspace_premium_rounded;
                    break;
                  default:
                    bgAccent = context.appColors.infoContainer;
                    iconColor = AppColors.primary;
                    docIcon = Icons.description_rounded;
                }

                return SizedBox(
                  width: itemWidth,
                  child: InkWell(
                    onTap: () => _launchUrl(context, doc['url']),
                    borderRadius: AppRadius.br14,
                    child: Container(
                      padding: AppSpacing.paddingMd,
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        borderRadius: AppRadius.br14,
                        border: Border.all(
                          color: AppColors.neutral200,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.appColors.onSurface.withAlpha(6),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: AppSpacing.paddingSm,
                            decoration: BoxDecoration(
                              color: bgAccent,
                              borderRadius: AppRadius.br10,
                            ),
                            child: Icon(docIcon, color: iconColor, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  doc['title']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.secondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.s2),
                                Row(
                                  children: [
                                    Text(
                                      'Buka File',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: iconColor,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.s3),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 10,
                                      color: iconColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = (scholarship.applicationStatus ?? '').toLowerCase();
    final isRejected = status.contains('ditolak');
    final isAccepted = status.contains('diterima') || status.contains('lulus');

    String badgeText = 'TERDAFTAR';
    Color badgeColor = AppColors.neutral800;
    if (isRejected) {
      badgeText = 'DITOLAK';
      badgeColor = AppColors.error;
    } else if (isAccepted) {
      badgeText = 'DITERIMA';
      badgeColor = AppColors.success;
    }

    final customAnswers = _getCustomAnswers();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          BkuAppBar(
            title: 'Detail Pengajuan',
            subtitle: 'Beasiswa & Bantuan',
            variant: AppBarVariant.student,
            expandedHeight: 120,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER CARD
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusXl,
                      border: Border.all(
                        color: AppColors.neutral200.withAlpha(150),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.onSurface.withAlpha(12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: AppRadius.radiusMd,
                                ),
                                child: Text(
                                  scholarship.category,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10,
                                    color: AppColors.neutral700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor.withAlpha(15),
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: Text(
                                badgeText,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: badgeColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          scholarship.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          scholarship.provider,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildTimeline(
                          context,
                          scholarship.applicationStatus ?? 'Pendaftaran',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // CUSTOM ANSWERS CARD
                  if (customAnswers.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(
                          padding: AppSpacing.padding6,
                          decoration: BoxDecoration(
                            color: context.appColors.infoContainer,
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Icon(
                            Icons.assignment_ind_rounded,
                            size: 18,
                            color: context.appColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Text(
                          'Data Jawaban Tambahan',
                          style: AppTextStyles.titleSm.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        borderRadius: AppRadius.radiusLg,
                        border: Border.all(
                          color: AppColors.neutral200.withAlpha(150),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            customAnswers.entries.map((entry) {
                              final label = entry.key;
                              final value = entry.value.toString();
                              final isFile =
                                  value.contains('/uploads/') ||
                                  value.startsWith('http');

                              return Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral50,
                                  borderRadius: AppRadius.radiusMd,
                                  border: Border.all(
                                    color: AppColors.neutral200.withAlpha(100),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          isFile
                                              ? Icons.attach_file_rounded
                                              : Icons
                                                  .chat_bubble_outline_rounded,
                                          size: 16,
                                          color: context.appColors.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            label,
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    if (isFile)
                                      InkWell(
                                        onTap: () => _launchUrl(context, value),
                                        borderRadius: AppRadius.radiusSm,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.sm,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: context.appColors.infoContainer,
                                            borderRadius: AppRadius.radiusSm,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.link_rounded,
                                                size: 16,
                                                color: context.appColors.primary,
                                              ),
                                              const SizedBox(width: AppSpacing.s6),
                                              Text(
                                                'Lihat File Lampiran',
                                                style: AppTextStyles.labelSm
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: context.appColors.primary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Text(
                                        value,
                                        style: AppTextStyles.bodySm.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.neutral900,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  // DOCUMENTS CARD
                  if (scholarship.ktmKtpUrl != null ||
                      scholarship.transkripUrl != null ||
                      scholarship.sertifikatUrl != null) ...[
                    Row(
                      children: [
                        Container(
                          padding: AppSpacing.padding6,
                          decoration: BoxDecoration(
                            color: context.appColors.successContainer,
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Icon(
                            Icons.folder_shared_rounded,
                            size: 18,
                            color: context.appColors.info,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s10),
                        Text(
                          'Dokumen Lampiran',
                          style: AppTextStyles.titleSm.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildModernDocumentGrid(context),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  const SizedBox(height: AppSpacing.s60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

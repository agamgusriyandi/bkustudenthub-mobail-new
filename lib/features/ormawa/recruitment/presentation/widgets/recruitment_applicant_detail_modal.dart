import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_info_card.dart';

class RecruitmentApplicantDetailModal extends StatelessWidget {
  final RecruitmentApplicant applicant;
  final List<Map<String, dynamic>> formFields;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const RecruitmentApplicantDetailModal({
    super.key,
    required this.applicant,
    required this.formFields,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        final isPending =
            applicant.status.toLowerCase() == 'pending' ||
            applicant.status.toLowerCase() == 'menunggu';
        return Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        Container(
                          width: 48,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.neutral300,
                            borderRadius: AppRadius.radiusXs,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        // Profile Avatar Modern
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withAlpha(50),
                              width: 2,
                            ),
                          ),
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  context.appColors.primary,
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(150),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(60),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              applicant.name.substring(0, 1).toUpperCase(),
                              style: AppTextStyles.displaySmall.copyWith(
                                color: context.appColors.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Text(
                            applicant.name,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: Text(
                            '${applicant.nim} • ${applicant.prodi}',
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatusBadge(applicant.status),
                        const SizedBox(height: AppSpacing.s20),

                        // Detail Data
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IPK modern
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withAlpha(20),
                                        borderRadius: AppRadius.radiusXl,
                                        border: Border.all(
                                          color: AppColors.warning.withAlpha(
                                            50,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning
                                                  .withAlpha(40),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.star_rounded,
                                              color: AppColors.warning,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.lg),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Indeks Prestasi',
                                                style: AppTextStyles.labelMd
                                                    .copyWith(
                                                      color: AppColors.warning,
                                                    ),
                                              ),
                                              Text(
                                                applicant.ipk.toStringAsFixed(
                                                  2,
                                                ),
                                                style: AppTextStyles.titleMd
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors
                                                              .onWarningContainer,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              if (applicant.customAnswers.isEmpty) ...[
                                Text(
                                  'Divisi Pilihan',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RecruitmentInfoCard(
                                        label: 'Pilihan 1',
                                        value: applicant.divisi1,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: RecruitmentInfoCard(
                                        label: 'Pilihan 2',
                                        value: applicant.divisi2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'Alasan & Motivasi',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100.withAlpha(100),
                                    borderRadius: AppRadius.radiusXl,
                                    border: Border.all(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.outline.withAlpha(50),
                                    ),
                                  ),
                                  child: Text(
                                    applicant.alasan,
                                    style: AppTextStyles.bodyMd.copyWith(
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'Dokumen Pendukung',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                if (applicant.cvUrl.trim().isNotEmpty)
                                  InkWell(
                                    onTap: () async {
                                      final fullUrl = ApiGate.getImageUrl(
                                        applicant.cvUrl,
                                      );
                                      if (fullUrl.isNotEmpty) {
                                        final uri = Uri.parse(fullUrl);
                                        try {
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          } else {
                                            await launchUrl(
                                              uri,
                                              mode:
                                                  LaunchMode
                                                      .externalApplication,
                                            );
                                          }
                                        } catch (_) {
                                          // Silenced: non-critical launch error
                                        }
                                      }
                                    },
                                    borderRadius: AppRadius.radiusXl,
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary.withAlpha(10),
                                        borderRadius: AppRadius.radiusXl,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary.withAlpha(30),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(
                                              AppSpacing.md,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(20),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.description_rounded,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.lg),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Lihat CV / Portofolio',
                                                  style: AppTextStyles.bodyMd
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                      ),
                                                ),
                                                Text(
                                                  'Ketuk untuk membuka dokumen pendaftaran',
                                                  style: AppTextStyles.labelMd
                                                      .copyWith(
                                                        color:
                                                            AppColors
                                                                .neutral500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(
                                      AppSpacing.lg,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: AppRadius.radiusXl,
                                      border: Border.all(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline.withAlpha(30),
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                        ),
                                        child: Text(
                                          'Tidak ada dokumen tambahan.',
                                          style: AppTextStyles.bodyMd.copyWith(
                                            color: AppColors.neutral500,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                              if (applicant.customAnswers.isNotEmpty) ...[
                                Text(
                                  'Jawaban Tambahan',
                                  style: AppTextStyles.titleSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                ...applicant.customAnswers.entries.map((entry) {
                                  final fieldId = entry.key;
                                  final answer = entry.value;

                                  // Find the field label from formFields
                                  final field = formFields.firstWhere(
                                    (f) =>
                                        (f['id'] ?? f['ID']).toString() ==
                                        fieldId,
                                    orElse: () => <String, dynamic>{},
                                  );

                                  final label =
                                      field.isNotEmpty
                                          ? (field['label'] ??
                                                  field['Label'] ??
                                                  'Pertanyaan Tambahan')
                                              .toString()
                                          : 'Pertanyaan Tambahan';

                                  final type =
                                      field.isNotEmpty
                                          ? (field['type'] ??
                                                  field['Type'] ??
                                                  'text')
                                              .toString()
                                              .toLowerCase()
                                          : 'text';

                                  final isFile = type == 'file';

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: AppTextStyles.labelMd.copyWith(
                                          color: AppColors.neutral500,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s6),
                                      if (isFile &&
                                          answer.toString().isNotEmpty)
                                        InkWell(
                                          onTap: () async {
                                            final fullUrl = ApiGate.getImageUrl(
                                              answer.toString(),
                                            );
                                            if (fullUrl.isNotEmpty) {
                                              final uri = Uri.parse(fullUrl);
                                              try {
                                                if (await canLaunchUrl(uri)) {
                                                  await launchUrl(
                                                    uri,
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                } else {
                                                  await launchUrl(
                                                    uri,
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                }
                                              } catch (_) {
                                                // Silenced: non-critical launch error
                                              }
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.open_in_new_rounded,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                size: 16,
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              Expanded(
                                                child: Text(
                                                  'Buka Dokumen',
                                                  style: AppTextStyles.bodyMd
                                                      .copyWith(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Text(
                                          answer is List
                                              ? (answer).join(', ')
                                              : (answer
                                                          ?.toString()
                                                          .trim()
                                                          .isEmpty ??
                                                      true
                                                  ? '—'
                                                  : answer.toString()),
                                          style: AppTextStyles.bodyMd.copyWith(
                                            color: AppColors.neutral800,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (entry.key !=
                                          applicant
                                              .customAnswers
                                              .keys
                                              .last) ...[
                                        Divider(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline.withAlpha(30),
                                          height: 1,
                                        ),
                                        const SizedBox(height: AppSpacing.lg),
                                      ],
                                    ],
                                  );
                                }),
                              ],
                              SizedBox(height: isPending ? 120 : 32),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Sticky Action Buttons
              if (isPending &&
                  context.read<OrmawaProvider>().hasPermission(
                    'manage_recruitment',
                  ))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.xxl,
                    ),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.onSurface.withAlpha(10),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.xxl),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onReject,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text(
                              'Tolak',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: context.appColors.onPrimary,
                              elevation: 0,
                            ),
                            child: const Text(
                              'Terima',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final String statusText;
    final Color badgeColor;
    final Color textColor;

    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        statusText = 'Diterima';
        badgeColor = AppColors.success.withAlpha(20);
        textColor = AppColors.onSuccessContainer;
        break;
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        statusText = 'Ditolak';
        badgeColor = AppColors.error.withAlpha(20);
        textColor = AppColors.onDangerContainer;
        break;
      case 'pending':
      case 'menunggu':
      default:
        statusText = 'Menunggu';
        badgeColor = AppColors.warning.withAlpha(20);
        textColor = AppColors.onWarningContainer;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: textColor.withAlpha(50)),
      ),
      child: Text(
        statusText,
        style: AppTextStyles.labelMd.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}


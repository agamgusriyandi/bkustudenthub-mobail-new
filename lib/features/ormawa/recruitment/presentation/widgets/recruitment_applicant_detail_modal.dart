import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
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

  BkuStatus _mapStatusToBkuStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        return BkuStatus.success;
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        return BkuStatus.error;
      case 'pending':
      case 'menunggu':
      default:
        return BkuStatus.warning;
    }
  }

  String _mapStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'aktif':
      case 'accepted':
      case 'diterima':
        return 'Diterima';
      case 'tidak_aktif':
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'pending':
      case 'menunggu':
      default:
        return 'Menunggu Review';
    }
  }

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
            color: BkuTheme.scaffoldBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Stack(
            children: [
              CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BkuTheme.border,
                            borderRadius: BkuTheme.r8,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: BkuTheme.primarySoft,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: BkuTheme.primaryBorder,
                              width: 2,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            applicant.name.isNotEmpty ? applicant.name.substring(0, 1).toUpperCase() : 'P',
                            style: TextStyle(
                              color: BkuTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Text(
                            applicant.name,
                            style: BkuTheme.textCardTitle.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: BkuTheme.borderSubtle,
                            borderRadius: BkuTheme.rPill,
                            border: Border.all(color: BkuTheme.border),
                          ),
                          child: Text(
                            '${applicant.nim} • ${applicant.prodi}',
                            style: BkuTheme.textCaption.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        BkuStatusBadge(
                          status: _mapStatusToBkuStatus(applicant.status),
                          customText: _mapStatusText(applicant.status),
                          showIcon: false,
                        ),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BkuCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                borderRadius: 16,
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: BkuTheme.amberSoft,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.star_rounded,
                                        color: BkuTheme.amber,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Indeks Prestasi Kumulatif (IPK)',
                                          style: BkuTheme.textCaption.copyWith(
                                            color: BkuTheme.textMuted,
                                          ),
                                        ),
                                        Text(
                                          applicant.ipk.toStringAsFixed(2),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: BkuTheme.amber,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 14),

                              if (applicant.customAnswers.isEmpty) ...[
                                Text(
                                  'Divisi Pilihan',
                                  style: BkuTheme.textSectionTitle,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RecruitmentInfoCard(
                                        label: 'Pilihan 1',
                                        value: applicant.divisi1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: RecruitmentInfoCard(
                                        label: 'Pilihan 2',
                                        value: applicant.divisi2,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Alasan & Motivasi',
                                  style: BkuTheme.textSectionTitle,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BkuTheme.r16,
                                    border: Border.all(
                                      color: BkuTheme.border,
                                    ),
                                  ),
                                  child: Text(
                                    applicant.alasan,
                                    style: BkuTheme.textBodyRegular.copyWith(
                                      height: 1.5,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Dokumen Pendukung',
                                  style: BkuTheme.textSectionTitle,
                                ),
                                const SizedBox(height: 8),
                                if (applicant.cvUrl.trim().isNotEmpty)
                                  InkWell(
                                    onTap: () async {
                                      final fullUrl = ApiGate.getImageUrl(
                                        applicant.cvUrl,
                                      );
                                      if (fullUrl.isNotEmpty) {
                                        final uri = Uri.parse(fullUrl);
                                        try {
                                          await launchUrl(
                                            uri,
                                            mode: LaunchMode.externalApplication,
                                          );
                                        } catch (_) {}
                                      }
                                    },
                                    borderRadius: BkuTheme.r16,
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: BkuTheme.primarySoft,
                                        borderRadius: BkuTheme.r16,
                                        border: Border.all(
                                          color: BkuTheme.primaryBorder,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.description_rounded,
                                              color: BkuTheme.primary,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.md),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Lihat CV / Portofolio',
                                                  style: BkuTheme.textCardTitle.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color: BkuTheme.primary,
                                                  ),
                                                ),
                                                Text(
                                                  'Ketuk untuk membuka dokumen pendaftaran',
                                                  style: BkuTheme.textCaption.copyWith(
                                                    fontSize: 10,
                                                    color: BkuTheme.textMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            color: BkuTheme.primary,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BkuTheme.r16,
                                      border: Border.all(
                                        color: BkuTheme.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Text(
                                          'Tidak ada dokumen tambahan.',
                                          style: BkuTheme.textCaption.copyWith(
                                            color: BkuTheme.textPlaceholder,
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
                                  style: BkuTheme.textSectionTitle,
                                ),
                                const SizedBox(height: 8),
                                ...applicant.customAnswers.entries.map((entry) {
                                  final fieldId = entry.key;
                                  final answer = entry.value;

                                  final field = formFields.firstWhere(
                                    (f) =>
                                        (f['id'] ?? f['ID']).toString() ==
                                        fieldId,
                                    orElse: () => <String, dynamic>{},
                                  );

                                  final label = field.isNotEmpty
                                      ? (field['label'] ?? field['Label'] ?? 'Pertanyaan Tambahan').toString()
                                      : 'Pertanyaan Tambahan';

                                  final type = field.isNotEmpty
                                      ? (field['type'] ?? field['Type'] ?? 'text').toString().toLowerCase()
                                      : 'text';

                                  final isFile = type == 'file';

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        label,
                                        style: BkuTheme.textCaption.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: BkuTheme.textMuted,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (isFile && answer.toString().isNotEmpty)
                                        InkWell(
                                          onTap: () async {
                                            final fullUrl = ApiGate.getImageUrl(
                                              answer.toString(),
                                            );
                                            if (fullUrl.isNotEmpty) {
                                              final uri = Uri.parse(fullUrl);
                                              try {
                                                await launchUrl(
                                                  uri,
                                                  mode: LaunchMode.externalApplication,
                                                );
                                              } catch (_) {}
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.open_in_new_rounded,
                                                color: BkuTheme.primary,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  'Buka Dokumen',
                                                  style: TextStyle(
                                                    color: BkuTheme.primary,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    decoration: TextDecoration.underline,
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
                                              : (answer?.toString().trim().isEmpty ?? true
                                                  ? '—'
                                                  : answer.toString()),
                                          style: BkuTheme.textBodyRegular.copyWith(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      const SizedBox(height: 12),
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
              if (isPending && context.read<OrmawaProvider>().hasPermission('manage_recruitment'))
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 20,
                          offset: const Offset(0, -10),
                        ),
                      ],
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: BkuButton(
                            variant: BkuButtonVariant.danger,
                            text: 'Tolak Berkas',
                            icon: Icons.cancel_rounded,
                            height: 44,
                            onPressed: onReject,
                            fullWidth: true,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: BkuButton.success(
                            text: 'Terima Anggota',
                            icon: Icons.check_circle_rounded,
                            height: 44,
                            onPressed: onAccept,
                            fullWidth: true,
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
}
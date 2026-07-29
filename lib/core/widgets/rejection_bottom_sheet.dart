import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';

/// Shows a modern rejection UI when a student tries to apply for a second scholarship.
/// Displays an image, a message, and a button to view the existing application details.
Future<void> showRejectionBottomSheet(
  BuildContext context,
  Scholarship appliedScholarship,
) async {
  int getStageIndex(String status) {
    final s = status.toLowerCase();

    if (s.contains('pengajuan') || s == 'menunggu') return 0;
    if (s.contains('berkas')) return 1;
    if (s.contains('evaluasi') || s.contains('wawancara') || s == 'proses') {
      return 2;
    }
    if (s.contains('review')) return 3;
    if (s.contains('penetapan')) return 4;
    if (s.contains('hasil') ||
        s.contains('diterima') ||
        s.contains('ditolak') ||
        s.contains('lulus')) {
      return 5;
    }

    return 0;
  }

  Widget buildTimeline(BuildContext context, String currentStatus) {
    bool isRejected = currentStatus.toLowerCase().contains('ditolak');
    final stages = [
      'Pengajuan',
      'Berkas',
      'Evaluasi',
      'Review',
      'Penetapan',
      isRejected ? 'Ditolak' : 'Hasil',
    ];
    int currentIndex = getStageIndex(currentStatus);
    Color activeColor =
        isRejected ? Theme.of(context).colorScheme.error : context.appColors.success;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(stages.length, (index) {
        bool isDone = index <= currentIndex;
        bool isCurrent = index == currentIndex;
        bool isLast = index == stages.length - 1;

        return Expanded(
          child: Row(
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isDone
                                ? activeColor
                                : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                        border:
                            isCurrent
                                ? Border.all(
                                  color: activeColor.withAlpha(40),
                                  width: 4,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        stages[index].toTitleCase(),
                        style: AppTextStyles.labelSm.copyWith(
                          fontSize: 9,
                          fontWeight:
                              isDone ? FontWeight.bold : FontWeight.normal,
                          color:
                              isDone
                                  ? activeColor
                                  : Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: AppSpacing.s22),
                    color:
                        isDone
                            ? activeColor
                            : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: color.withAlpha(20), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.titleSm.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: color.withAlpha(200),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (sheetContext) => Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xxl,
          ),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: AppRadius.radiusXs,
                ),
              ),
              Image.asset('assets/images/ubk_rejection.png', height: 150),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Sudah Mendaftar',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Anda sudah mendaftar di program ${appliedScholarship.title}.\nSesuai kebijakan, Anda hanya dapat mendaftar 1 program beasiswa aktif.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Timeline
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Aplikasi Saat Ini',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    buildTimeline(
                      context,
                      appliedScholarship.applicationStatus ?? 'Berkas',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Stats
              Row(
                children: [
                  Expanded(
                    child: buildStatItem(
                      context,
                      'Pendaftar',
                      '342',
                      Icons.people_alt_rounded,
                      context.appColors.info,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: buildStatItem(
                      context,
                      'Kuota',
                      appliedScholarship.kuota ?? '0',
                      Icons.pie_chart_rounded,
                      context.appColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: buildStatItem(
                      context,
                      'Peluang',
                      '14%',
                      Icons.trending_up_rounded,
                      context.appColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },

                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
  );
}

import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';

class MentorEssayGradingScreen extends StatefulWidget {
  const MentorEssayGradingScreen({super.key});

  @override
  State<MentorEssayGradingScreen> createState() =>
      _MentorEssayGradingScreenState();
}

class _MentorEssayGradingScreenState extends State<MentorEssayGradingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchEssayGrading();
      }
    });
  }

  void _showGradingDialog(
    BuildContext context,
    int essayId,
    String studentName,
    double? currentScore,
  ) {
    final scoreController = TextEditingController(
      text: currentScore?.toString() ?? '',
    );
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: 'Koreksi Essay',
              content: 'Mahasiswa: $studentName',
              confirmText: 'Simpan',
              cancelText: 'Batal',
              isLoading: isSubmitting,
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                final scoreText = scoreController.text.trim();
                if (scoreText.isEmpty) return;
                final score = double.tryParse(scoreText);
                if (score == null) return;
                setState(() => isSubmitting = true);
                final success = await context
                    .read<MentorKencanaProvider>()
                    .submitEssayScore(
                      essayId,
                      score,
                      feedbackController.text.trim(),
                    );
                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  AppSnackbar.showSuccess(
                    context,
                    'Nilai essay berhasil disimpan',
                  );
                } else {
                  AppSnackbar.showError(context, 'Gagal menyimpan nilai essay');
                }
              },
              customChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nilai (0-100)',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Feedback (opsional)',
                      filled: true,
                      fillColor: AppColors.neutral100,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.radiusMd,
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.lg),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchEssayGrading(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Koreksi Essay',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && provider.essayItems.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null &&
                provider.essayItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              )
            else if (provider.essayItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada essay yang perlu dikoreksi.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = provider.essayItems[index];
                    final isGraded = item.status == 'graded';
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color:
                                      isGraded
                                          ? context.appColors.success
                                              .withAlpha(15)
                                          : context.appColors.warning
                                              .withAlpha(15),
                                  borderRadius: AppRadius.radiusLg,
                                ),
                                child: Icon(
                                  isGraded
                                      ? Icons.check_circle_rounded
                                      : Icons.edit_document,
                                  color:
                                      isGraded
                                          ? context.appColors.success
                                          : context.appColors.warning,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.studentName,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      item.nim,
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isGraded && item.score != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appColors.success
                                        .withAlpha(15),
                                    border: Border.all(
                                      color: context.appColors.success
                                          .withAlpha(30),
                                    ),
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Text(
                                    '${item.score}',
                                    style: AppTextStyles.labelSm.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.appColors.success,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (item.question.isNotEmpty) ...[
                            Text(
                              'Pertanyaan:',
                              style: AppTextStyles.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.question,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          if (item.answer.isNotEmpty) ...[
                            Text(
                              'Jawaban:',
                              style: AppTextStyles.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              item.answer,
                              style: AppTextStyles.labelSm.copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: BkuButton(
                              onPressed: () {
                                _showGradingDialog(
                                  context,
                                  item.id,
                                  item.studentName,
                                  item.score,
                                );
                              },
                              icon: isGraded
                                  ? Icons.edit_rounded
                                  : Icons.grading_rounded,
                              text: isGraded
                                  ? 'Ubah Nilai'
                                  : 'Beri Nilai',
                              variant: isGraded
                                  ? BkuButtonVariant.outline
                                  : BkuButtonVariant.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: provider.essayItems.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

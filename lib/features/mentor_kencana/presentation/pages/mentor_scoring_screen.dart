import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorScoringScreen extends StatefulWidget {
  const MentorScoringScreen({super.key});

  @override
  State<MentorScoringScreen> createState() => _MentorScoringScreenState();
}

class _MentorScoringScreenState extends State<MentorScoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentees();
      }
    });
  }

  void _showScoringDialog(
    BuildContext context,
    int studentId,
    String menteeName,
  ) {
    final kognitifController = TextEditingController();
    final psikomotorController = TextEditingController();
    final afektifController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return CustomDialog(
              title: 'Input Nilai',
              content: 'Masukkan nilai untuk mahasiswa $menteeName',
              confirmText: 'Simpan',
              cancelText: 'Batal',
              isLoading: isSubmitting,
              onCancel: () => Navigator.pop(context),
              onConfirm: () async {
                setState(() => isSubmitting = true);
                final data = {
                  'studentId': studentId,
                  'kognitif': kognitifController.text,
                  'psikomotor': psikomotorController.text,
                  'afektif': afektifController.text,
                };
                final success = await context
                    .read<MentorKencanaProvider>()
                    .submitBulkScores(data);
                if (!context.mounted) return;
                Navigator.pop(context);
                if (success) {
                  AppSnackbar.showSuccess(context, 'Nilai berhasil disimpan');
                } else {
                  AppSnackbar.showError(context, 'Gagal menyimpan nilai');
                }
              },
              customChild: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildScoreInput('Kognitif (Kuis/Tugas)', kognitifController),
                  const SizedBox(height: 12),
                  _buildScoreInput(
                    'Psikomotor (Kehadiran)',
                    psikomotorController,
                  ),
                  const SizedBox(height: 12),
                  _buildScoreInput(
                    'Afektif (Sikap/Keaktifan)',
                    afektifController,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildScoreInput(String label, TextEditingController controller) {
    return BkuTextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.labelSm,
        filled: true,
        fillColor: AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('MentorScoringScreen build started');
    final provider = context.watch<MentorKencanaProvider>();
    debugPrint(
      'MentorScoringScreen provider groups: ${provider.groups.length}',
    );
    final totalMentees = provider.groups.fold<int>(
      0,
      (sum, g) => sum + g.mentees.length,
    );
    debugPrint('MentorScoringScreen totalMentees: $totalMentees');

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentees(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Penilaian Akhir (Skoring)',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: false,
            ),
            if (provider.isLoading && provider.groups.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && provider.groups.isEmpty)
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
            else if (provider.groups.isEmpty || totalMentees == 0)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 64,
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withAlpha(80),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Anda tidak memiliki mahasiswa bimbingan yang aktif untuk dinilai.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                    debugPrint('SliverChildBuilderDelegate index: $index');
                    final group = provider.groups[index];
                    debugPrint(
                      'Building group: ${group.name}, mentees: ${group.mentees.length}',
                    );
                    if (group.mentees.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: AppTextStyles.titleLg.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...group.mentees.map((mentee) {
                          debugPrint(
                            'Building card for mentee: ${mentee.name}',
                          );
                          return BkuCard(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.neutral300,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      mentee.name.isNotEmpty
                                          ? mentee.name
                                              .substring(0, 1)
                                              .toUpperCase()
                                          : '',
                                      style: const TextStyle(
                                        color: AppColors.neutral700,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mentee.name,
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'NIM: ${mentee.nim}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Skor Sementara: ${mentee.score}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                BkuButton(
                                  onPressed:
                                      () => _showScoringDialog(
                                        context,
                                        mentee.id,
                                        mentee.name,
                                      ),
                                  text: 'Input Nilai',
                                  fullWidth: false,
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],
                    );
                  }, childCount: provider.groups.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

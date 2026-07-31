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
    final provider = context.read<MentorKencanaProvider>();
    final scoreDefs = provider.scoreDefinitions;
    
    final Map<String, TextEditingController> controllers = {};
    final List<Widget> inputFields = [];
    
    if (scoreDefs != null) {
      for (final category in ['cognitive', 'psychomotor', 'affective']) {
        final items = scoreDefs[category] as List<dynamic>? ?? [];
        final manualItems = items.where((it) => it['manual'] == true).toList();
        
        if (manualItems.isNotEmpty) {
          inputFields.add(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
              child: Text(
                category.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral700,
                ),
              ),
            ),
          );
          
          for (final item in manualItems) {
            final key = "${category}_${item['key']}";
            final controller = TextEditingController();
            controllers[key] = controller;
            
            inputFields.add(
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildScoreInput(item['label'] ?? item['key'], controller),
              ),
            );
          }
        }
      }
    }

    if (controllers.isEmpty) {
      controllers['cognitive_Handbook'] = TextEditingController();
      controllers['psychomotor_Evaluasi Psikomotor'] = TextEditingController();
      controllers['affective_Evaluasi Afektif'] = TextEditingController();
      
      inputFields.addAll([
        _buildScoreInput('Kognitif (Kuis/Tugas)', controllers['cognitive_Handbook']!),
        const SizedBox(height: AppSpacing.md),
        _buildScoreInput('Psikomotor (Kehadiran)', controllers['psychomotor_Evaluasi Psikomotor']!),
        const SizedBox(height: AppSpacing.md),
        _buildScoreInput('Afektif (Sikap/Keaktifan)', controllers['affective_Evaluasi Afektif']!),
      ]);
    }

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
                
                final List<Map<String, dynamic>> itemsPayload = [];
                controllers.forEach((compositeKey, controller) {
                  final parts = compositeKey.split('_');
                  final category = parts[0];
                  final itemKey = parts.sublist(1).join('_');
                  final score = double.tryParse(controller.text) ?? 0.0;
                  
                  itemsPayload.add({
                    'component': category,
                    'item_name': itemKey,
                    'score': score,
                    'notes': 'Diinput via Mobile',
                  });
                });

                final success = await context
                    .read<MentorKencanaProvider>()
                    .submitBulkScores(
                      studentId: studentId,
                      items: itemsPayload,
                    );
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: inputFields,
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
    final provider = context.watch<MentorKencanaProvider>();
    final totalMentees = provider.groups.fold<int>(
      0,
      (sum, g) => sum + g.mentees.length,
    );

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
              showBackButton: true,
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
                      const SizedBox(height: AppSpacing.lg),
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
                    final group = provider.groups[index];
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
                        const SizedBox(height: AppSpacing.md),
                        ...group.mentees.map((mentee) {
                          return BkuCard(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                                const SizedBox(width: AppSpacing.md),
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
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'NIM: ${mentee.nim}',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
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
                                const SizedBox(width: AppSpacing.sm),
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
                        const SizedBox(height: AppSpacing.xl),
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
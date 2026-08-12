import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorEssayGradingScreen extends StatefulWidget {
  final int? quizId;

  const MentorEssayGradingScreen({super.key, this.quizId});

  @override
  State<MentorEssayGradingScreen> createState() =>
      _MentorEssayGradingScreenState();
}

class _MentorEssayGradingScreenState extends State<MentorEssayGradingScreen> {
  int? _selectedQuizId;

  @override
  void initState() {
    super.initState();
    _selectedQuizId = widget.quizId;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        final provider = context.read<MentorKencanaProvider>();
        if (provider.sessionMaterials.isEmpty) {
          await provider.fetchSessionMaterialsList();
        }
        if (mounted) {
          provider.fetchEssayGrading(_selectedQuizId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    final allQuizzes = <SessionMaterialItem>[];
    for (final mat in provider.sessionMaterials) {
      allQuizzes.addAll(mat.quizzes);
    }

    int totalPending = 0;
    int totalGraded = 0;
    if (_selectedQuizId != null && !provider.isLoading) {
      for (final item in provider.essayItems) {
        if (item.status == 'graded' || item.score != null) {
          totalGraded++;
        } else {
          totalPending++;
        }
      }
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchEssayGrading(_selectedQuizId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Koreksi Essay',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            
            // Modern Filter & Header Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: BkuCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.appColors.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.quiz_rounded,
                              size: 18,
                              color: context.appColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'PILIH KUIS EVALUASI',
                            style: AppTextStyles.labelSm.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.appColors.primary,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(color: context.appColors.outline.withAlpha(60)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: BkuDropdown<int?>(
                            value: _selectedQuizId ?? (allQuizzes.isNotEmpty ? allQuizzes.first.id : null),
                            isExpanded: true,
                            hint: 'Semua Kuis Evaluasi',
                            items: [
                              if (allQuizzes.isEmpty)
                                DropdownMenuItem<int?>(
                                  value: _selectedQuizId,
                                  child: Text(_selectedQuizId != null ? 'Kuis #$_selectedQuizId' : 'Memuat daftar kuis...', style: AppTextStyles.labelSm),
                                )
                              else
                                ...allQuizzes.map((q) => DropdownMenuItem<int?>(
                                  value: q.id,
                                  child: Text(
                                    q.title.isNotEmpty ? q.title : 'Kuis #${q.id}',
                                    style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedQuizId = val;
                              });
                              provider.fetchEssayGrading(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_selectedQuizId != null && !provider.isLoading && provider.essayItems.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusLg,
                            border: Border.all(color: context.appColors.outline.withAlpha(40)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                totalPending.toString(),
                                style: AppTextStyles.titleLg.copyWith(
                                  color: context.appColors.warning,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Belum Dinilai',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.outline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusLg,
                            border: Border.all(color: context.appColors.outline.withAlpha(40)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                totalGraded.toString(),
                                style: AppTextStyles.titleLg.copyWith(
                                  color: context.appColors.success,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Sudah Dinilai',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.outline,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (provider.isLoading && provider.essayItems.isEmpty)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else if (provider.errorMessage != null && provider.essayItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: context.appColors.error),
                  ),
                ),
              )
            else if (provider.essayItems.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_turned_in_rounded, size: 56, color: context.appColors.outline.withAlpha(80)),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada jawaban essay yang perlu dikoreksi.',
                        style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = provider.essayItems[index];
                    return _EssayGradingCard(item: item);
                  }, childCount: provider.essayItems.length),
                ),
              ),
            
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
          ],
        ),
      ),
    );
  }
}

class _EssayGradingCard extends StatefulWidget {
  final MentorEssayItem item;
  const _EssayGradingCard({required this.item});

  @override
  State<_EssayGradingCard> createState() => _EssayGradingCardState();
}

class _EssayGradingCardState extends State<_EssayGradingCard> {
  late TextEditingController _scoreController;
  late TextEditingController _feedbackController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _scoreController = TextEditingController(text: widget.item.score?.toString() ?? '');
    _feedbackController = TextEditingController(text: widget.item.feedback ?? '');
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _submitScore() async {
    final scoreText = _scoreController.text.trim();
    if (scoreText.isEmpty) {
      AppSnackbar.showWarning(context, 'Masukkan nilai terlebih dahulu');
      return;
    }
    final score = double.tryParse(scoreText);
    if (score == null) {
      AppSnackbar.showWarning(context, 'Nilai harus berupa angka valid');
      return;
    }

    final maxScore = widget.item.maxScore > 0 ? widget.item.maxScore : 25.0;
    if (score < 0 || score > maxScore) {
      final maxDisplay = maxScore % 1 == 0 ? maxScore.toInt().toString() : maxScore.toString();
      AppSnackbar.showWarning(
        context,
        'Nilai tidak boleh melebihi nilai maksimal (0–$maxDisplay)!',
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final provider = context.read<MentorKencanaProvider>();
    final success = await provider.submitEssayScore(
      widget.item.id,
      score,
      _feedbackController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppSnackbar.showSuccess(context, 'Nilai essay berhasil disimpan');
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan nilai essay');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isGraded = item.status == 'graded' || item.score != null;

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Header Row with Avatar & Badges
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.appColors.primary,
                      context.appColors.primary.withAlpha(180),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.studentName.isNotEmpty ? item.studentName[0] : 'M',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.studentName.isNotEmpty ? item.studentName : 'Mahasiswa',
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: context.appColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.nim.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'NIM: ${item.nim}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isGraded
                      ? context.appColors.success.withAlpha(20) 
                      : context.appColors.warning.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                  border: Border.all(
                    color: isGraded
                        ? context.appColors.success.withAlpha(60) 
                        : context.appColors.warning.withAlpha(60),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGraded ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                      size: 14,
                      color: isGraded ? context.appColors.success : context.appColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      isGraded ? 'Sudah Dinilai' : 'Belum Dinilai',
                      style: AppTextStyles.labelSm.copyWith(
                        color: isGraded ? context.appColors.success : context.appColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Question Text
          if (item.question.isNotEmpty) ...[
            Text(
              item.question,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: context.appColors.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Student Answer Blockquote Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: context.appColors.warning.withAlpha(20),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: context.appColors.warning.withAlpha(40)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.format_quote_rounded,
                  size: 18,
                  color: Color(0xFFF97316),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    item.answer.isNotEmpty ? item.answer : '(Mahasiswa belum memasukkan jawaban)',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: item.answer.isNotEmpty ? context.appColors.onSurfaceVariant : AppColors.neutral500,
                      fontStyle: item.answer.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Grading Inputs Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NILAI (0-${item.maxScore.toInt()})',
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BkuTextField(
                      controller: _scoreController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral900),
                      onChanged: (val) {
                        final numVal = double.tryParse(val);
                        final maxVal = item.maxScore > 0 ? item.maxScore : 25.0;
                        if (numVal != null && numVal > maxVal) {
                          final maxDisplay = maxVal % 1 == 0 ? maxVal.toInt().toString() : maxVal.toString();
                          _scoreController.text = maxDisplay;
                          _scoreController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _scoreController.text.length),
                          );
                          AppSnackbar.showWarning(
                            context,
                            'Nilai maksimal adalah $maxDisplay',
                          );
                        }
                      },
                      hint: '0-${item.maxScore.toInt()}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATATAN MENTOR',
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.neutral900,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    BkuTextField(
                      controller: _feedbackController,
                      style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                      hint: 'Tulis catatan...',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 34,
              child: BkuButton(
                onPressed: _isSubmitting ? () {} : _submitScore,
                icon: isGraded ? Icons.check_circle_rounded : Icons.save_rounded,
                text: isGraded ? 'Perbarui' : 'Simpan Nilai',
                isLoading: _isSubmitting,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

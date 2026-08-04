import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';

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

    // Extract list of all available quizzes from sessionMaterials
    final allQuizzes = <SessionMaterialItem>[];
    for (final mat in provider.sessionMaterials) {
      allQuizzes.addAll(mat.quizzes);
    }

    return Scaffold(
      backgroundColor: AppColors.neutral100,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, top: AppSpacing.lg),
                child: BkuCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pilih kuis untuk melihat & menilai essay:',
                        style: AppTextStyles.labelSm.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appColors.outline,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: context.appColors.outline.withAlpha(50)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: _selectedQuizId ?? (allQuizzes.isNotEmpty ? allQuizzes.first.id : null),
                            isExpanded: true,
                            hint: Text('Semua Kuis Evaluasi', style: AppTextStyles.labelSm),
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
                                    style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold),
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
            if (provider.isLoading && provider.essayItems.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
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
                      Icon(Icons.assignment_turned_in_rounded, size: 48, color: context.appColors.outline.withAlpha(100)),
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
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = provider.essayItems[index];
                    return _EssayGradingCard(item: item);
                  }, childCount: provider.essayItems.length),
                ),
              ),
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
          if (item.studentName.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.account_circle_rounded, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Text(item.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                if (item.nim.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('(${item.nim})', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],
          // Question Header
          if (item.question.isNotEmpty) ...[
            Text(
              item.question,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
          ],
          // Student Answer Box (styled with subtle beige background like website UI)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8F1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Text(
              item.answer.isNotEmpty ? item.answer : '(Tidak ada jawaban)',
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          // Inline Input Row for Nilai & Catatan & Submit Button (Matching Web Screenshot)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Nilai Field
              SizedBox(
                width: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nilai (0-25)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    TextField(
                      controller: _scoreController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: '0-25',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Catatan Field
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catatan', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                    const SizedBox(height: 2),
                    TextField(
                      controller: _feedbackController,
                      style: const TextStyle(fontSize: 11),
                      decoration: InputDecoration(
                        hintText: 'Catatan...',
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Dinilai / Simpan Button
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitScore,
                  icon: _isSubmitting
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(isGraded ? Icons.check_circle_rounded : Icons.save_rounded, size: 14),
                  label: Text(isGraded ? 'Dinilai' : 'Simpan', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isGraded ? const Color(0xFF10B981) : context.appColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/unified_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/data/models/screening_model.dart';
import '../providers/self_screening_provider.dart';

class SelfScreeningScreen extends StatefulWidget {
  const SelfScreeningScreen({super.key});

  @override
  State<SelfScreeningScreen> createState() => _SelfScreeningScreenState();
}

class _SelfScreeningScreenState extends State<SelfScreeningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SelfScreeningProvider>().loadLatestScreening();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: UnifiedStaticAppBar(
        title: 'Self-Screening Kesehatan Mental',
        showBackButton: true,
        showNotification: false,
      ),
      body: Consumer<SelfScreeningProvider>(
        builder: (context, provider, _) {
          if (provider.showResult) {
            return _buildResultPage(context, provider);
          }
          if (provider.isLoading) {
            return _buildLoadingState();
          }
          return _buildQuestionnairePage(context, provider);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BkuShimmer(width: double.infinity, height: 40),
            SizedBox(height: AppSpacing.lg),
            BkuShimmer(width: double.infinity, height: 200),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionnairePage(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressSection(context, provider),
                const SizedBox(height: AppSpacing.xl),
                _buildQuestionCard(context, provider),
                const SizedBox(height: AppSpacing.xl),
                if (provider.errorMessage != null)
                  _buildErrorBanner(context, provider),
              ],
            ),
          ),
        ),
        _buildNavigationButtons(context, provider),
      ],
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    final progress = (provider.currentQuestionIndex + 1) / 20;

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${provider.currentQuestionIndex + 1} dari 20',
                style: AppTextStyles.bodySm.copyWith(
                  color: context.appColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${provider.answeredCount}/20 terjawab',
                style: AppTextStyles.bodySm.copyWith(
                  color: context.appColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: context.appColors.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                context.appColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildQuestionDots(provider),
        ],
      ),
    );
  }

  Widget _buildQuestionDots(SelfScreeningProvider provider) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(20, (index) {
        final isCurrent = index == provider.currentQuestionIndex;
        final isAnswered = provider.answers[index] != null;

        Color dotColor;
        if (isCurrent) {
          dotColor = context.appColors.primary;
        } else if (isAnswered) {
          dotColor = context.appColors.success;
        } else {
          dotColor = context.appColors.outlineVariant;
        }

        return GestureDetector(
          onTap: () => provider.goToQuestion(index),
          child: Container(
            width: isCurrent ? 14 : 10,
            height: isCurrent ? 14 : 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(color: context.appColors.primary, width: 2)
                  : null,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildQuestionCard(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    final question = provider.currentQuestion;

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: context.appColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'SRQ-20',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            question.question,
            style: AppTextStyles.bodyLg.copyWith(
              color: context.appColors.onSurface,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildAnswerOptions(context, provider),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    final currentAnswer = provider.answers[provider.currentQuestionIndex];

    return Column(
      children: [
        _buildRadioOption(
          context: context,
          label: 'Ya',
          value: true,
          isSelected: currentAnswer == true,
          onTap: () => provider.setAnswer(provider.currentQuestionIndex, true),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildRadioOption(
          context: context,
          label: 'Tidak',
          value: false,
          isSelected: currentAnswer == false,
          onTap: () => provider.setAnswer(provider.currentQuestionIndex, false),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required BuildContext context,
    required String label,
    required bool value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.primary.withValues(alpha: 0.08)
              : context.appColors.surface,
          borderRadius: AppRadius.radiusMd,
          border: Border.all(
            color: isSelected
                ? context.appColors.primary
                : context.appColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? context.appColors.primary
                      : context.appColors.outline,
                  width: 2,
                ),
                color: isSelected
                    ? context.appColors.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(Icons.check, size: 14, color: context.appColors.onPrimary)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLg.copyWith(
                  color: isSelected
                      ? context.appColors.primary
                      : context.appColors.onSurface,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, SelfScreeningProvider provider) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.error.withValues(alpha: 0.08),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: context.appColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: context.appColors.error, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              provider.errorMessage ?? '',
              style: AppTextStyles.bodySm.copyWith(
                color: context.appColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (provider.canGoPrevious)
            Expanded(
              child: BkuButton.outline(
                text: 'Sebelumnya',
                onPressed: provider.goPrevious,
                icon: Icons.arrow_back_ios_new_rounded,
                fullWidth: false,
              ),
            ),
          if (provider.canGoPrevious) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: provider.canGoPrevious ? 2 : 1,
            child: provider.isLastQuestion && provider.isComplete
                ? BkuButton.primary(
                    text: provider.isSubmitting ? 'Mengirim...' : 'Kirim Jawaban',
                    onPressed: provider.isSubmitting
                        ? null
                        : () => _handleSubmit(context, provider),
                    isLoading: provider.isSubmitting,
                    icon: Icons.send_rounded,
                    fullWidth: false,
                  )
                : BkuButton.primary(
                    text: provider.canGoNext ? 'Selanjutnya' : 'Selesai',
                    onPressed: provider.canGoNext ? provider.goNext : null,
                    icon: Icons.arrow_forward_ios_rounded,
                    fullWidth: false,
                  ),
          ),
        ],
      ),
    );
  }

  void _handleSubmit(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kirim Jawaban?'),
        content: Text(
          'Anda telah menjawab ${provider.answeredCount} dari 20 pertanyaan. '
          'Pastikan semua jawaban sudah benar.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: context.appColors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.submitScreening();
            },
            child: Text(
              'Kirim',
              style: TextStyle(
                color: context.appColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPage(
    BuildContext context,
    SelfScreeningProvider provider,
  ) {
    final result = provider.submitResult;
    if (result == null) return const SizedBox.shrink();

    final score = provider.calculatedScore;
    final level = provider.calculatedLevel;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          _buildScoreCard(context, score, level),
          const SizedBox(height: AppSpacing.xl),
          _buildResultDetails(context, result),
          const SizedBox(height: AppSpacing.xl),
          _buildRecommendation(context, level),
          const SizedBox(height: AppSpacing.xl),
          BkuButton.outline(
            text: 'Kembali ke Health Hub',
            onPressed: () => Navigator.pop(context),
            icon: Icons.arrow_back_ios_new_rounded,
          ),
          const SizedBox(height: AppSpacing.md),
          BkuButton.outline(
            text: 'Ulangi Screening',
            onPressed: () {
              provider.resetScreening();
            },
            icon: Icons.refresh_rounded,
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    BuildContext context,
    int score,
    ScreeningLevel level,
  ) {
    Color scoreColor;
    Color bgColor;
    String levelLabel;

    switch (level) {
      case ScreeningLevel.normal:
        scoreColor = context.appColors.success;
        bgColor = context.appColors.successContainer;
        levelLabel = 'Normal';
        break;
      case ScreeningLevel.mild:
        scoreColor = context.appColors.warning;
        bgColor = context.appColors.warningContainer;
        levelLabel = 'Ringan';
        break;
      case ScreeningLevel.moderate:
        scoreColor = context.appColors.info;
        bgColor = context.appColors.infoContainer;
        levelLabel = 'Sedang';
        break;
      case ScreeningLevel.severe:
        scoreColor = context.appColors.error;
        bgColor = context.appColors.errorContainer;
        levelLabel = 'Berat';
        break;
    }

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: AppTextStyles.headlineLarge.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Skor SRQ-20',
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.radiusFull,
            ),
            child: Text(
              levelLabel,
              style: AppTextStyles.bodyMd.copyWith(
                color: scoreColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultDetails(
    BuildContext context,
    ScreeningResult result,
  ) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Hasil',
            style: AppTextStyles.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: context.appColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildDetailRow(
            context,
            'Tanggal',
            '${result.createdAt.day}/${result.createdAt.month}/${result.createdAt.year}',
            Icons.calendar_today_rounded,
          ),
          _buildDetailRow(
            context,
            'Skor',
            '${result.score}/20',
            Icons.score_rounded,
          ),
          _buildDetailRow(
            context,
            'Kategori',
            result.levelLabel,
            Icons.category_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: context.appColors.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMd.copyWith(
                color: context.appColors.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.w600,
              color: context.appColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendation(BuildContext context, ScreeningLevel level) {
    String title;
    String message;
    Color color;

    switch (level) {
      case ScreeningLevel.normal:
        title = 'Kondisi Normal';
        message =
            'Kondisi kesehatan mental Anda dalam batas normal. Pertahankan pola hidup sehat, aktifitas positif, dan jangan ragu untuk berkonsultasi jika diperlukan.';
        color = context.appColors.success;
        break;
      case ScreeningLevel.mild:
        title = 'Gangguan Ringan';
        message =
            'Terdapat gejala gangguan kesehatan mental ringan. Disarankan untuk berkonsultasi dengan tenaga kesehatan atau psikolog untuk evaluasi lebih lanjut.';
        color = context.appColors.warning;
        break;
      case ScreeningLevel.moderate:
        title = 'Gangguan Sedang';
        message =
            'Gejala gangguan kesehatan mental cukup signifikan. Sangat disarankan untuk segera berkonsultasi dengan psikolog guna mendapatkan penanganan yang tepat.';
        color = context.appColors.info;
        break;
      case ScreeningLevel.severe:
        title = 'Gangguan Berat';
        message =
            'Gejala gangguan kesehatan mental cukup berat. Segera konsultasikan dengan tenaga kesehatan atau psikolog untuk mendapatkan penanganan segera.';
        color = context.appColors.error;
        break;
    }

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          if (level != ScreeningLevel.normal) ...[
            const SizedBox(height: AppSpacing.lg),
            BkuButton.primary(
              text: 'Booking Konsultasi',
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icons.calendar_month_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

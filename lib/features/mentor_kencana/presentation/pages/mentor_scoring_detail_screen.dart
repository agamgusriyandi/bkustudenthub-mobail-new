import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class MentorScoringDetailScreen extends StatefulWidget {
  final int sessionId;
  final String sessionTitle;

  const MentorScoringDetailScreen({
    super.key,
    required this.sessionId,
    required this.sessionTitle,
  });

  @override
  State<MentorScoringDetailScreen> createState() =>
      _MentorScoringDetailScreenState();
}

class _MentorScoringDetailScreenState extends State<MentorScoringDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchSessionScores(widget.sessionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final scores = provider.sessionScores;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchSessionScores(widget.sessionId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Detail Penilaian',
              subtitle: widget.sessionTitle,
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && scores.isEmpty)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else if (provider.errorMessage != null && scores.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: context.appColors.error),
                  ),
                ),
              )
            else if (scores.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.score_rounded,
                        size: 64,
                        color: context.appColors.outline.withAlpha(80),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Belum ada data penilaian untuk sesi ini.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                        ),
                        textAlign: TextAlign.center,
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
                    final score = scores[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral200,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.neutral300),
                                ),
                                child: Center(
                                  child: Text(
                                    score.studentName.isNotEmpty
                                        ? score.studentName.substring(0, 1)
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      score.studentName,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'NIM: ${score.nim}',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.primary.withAlpha(15),
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Text(
                                  score.totalScore.toStringAsFixed(1),
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (score.items.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            const Divider(height: 1),
                            const SizedBox(height: AppSpacing.md),
                            ...score.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.itemName,
                                          style: AppTextStyles.labelSm.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (item.component.isNotEmpty)
                                          Text(
                                            item.component,
                                            style: AppTextStyles.labelSm.copyWith(
                                              fontSize: 11,
                                              color: context.appColors.outline,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    item.score.toStringAsFixed(1),
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.appColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ],
                      ),
                    );
                  }, childCount: scores.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

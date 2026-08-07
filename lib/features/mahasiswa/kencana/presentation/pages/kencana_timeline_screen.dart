import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/providers/kencana_timeline_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/timeline_model.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';

class KencanaTimelineScreen extends StatefulWidget {
  const KencanaTimelineScreen({super.key});

  @override
  State<KencanaTimelineScreen> createState() => _KencanaTimelineScreenState();
}

class _KencanaTimelineScreenState extends State<KencanaTimelineScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaTimelineProvider>().fetchTimeline();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaTimelineProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchTimeline(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'TIMELINE KENCANA',
              subtitle: 'TAHAPAN PKKMB',
              variant: AppBarVariant.student,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                ),
              )
            else if (provider.errorMessage != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        provider.errorMessage!,
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BkuButton(
                        onPressed: () => provider.fetchTimeline(),
                        text: 'Coba Lagi',
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.stages.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.timeline_rounded,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Timeline belum tersedia.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                  bottom: AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProgressSummary(provider.stages),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildVerticalTimeline(provider.stages),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary(List<KencanaTimelineStage> stages) {
    final completed =
        stages.where((s) => s.status == 'completed').length;
    final total = stages.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.timeline_rounded,
                  color: context.appColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Progress Tahapan',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              Text(
                '$completed/$total',
                style: AppTextStyles.titleLg.copyWith(
                  fontWeight: FontWeight.w900,
                  color: context.appColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: AppRadius.radiusXs,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor:
                  context.appColors.primary.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(
                context.appColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${(progress * 100).toInt()}% selesai',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTimeline(List<KencanaTimelineStage> stages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: stages.asMap().entries.map((entry) {
        final index = entry.key;
        final stage = entry.value;
        final isLast = index == stages.length - 1;

        return _buildTimelineItem(stage, index + 1, isLast);
      }).toList(),
    );
  }

  Widget _buildTimelineItem(
    KencanaTimelineStage stage,
    int number,
    bool isLast,
  ) {
    final isActive = stage.isActive;
    final isCompleted = stage.isCompleted;
    Color lineColor;
    Color nodeColor;
    Color cardBg;
    Color borderColor;
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;

    if (isCompleted) {
      lineColor = AppColors.success;
      nodeColor = AppColors.success;
      cardBg = context.appColors.successContainer;
      borderColor = AppColors.success.withAlpha(120);
      badgeBg = context.appColors.successContainer;
      badgeTextColor = context.appColors.success;
      badgeText = 'Selesai';
    } else if (isActive) {
      lineColor = context.appColors.primary;
      nodeColor = context.appColors.primary;
      cardBg = context.appColors.infoContainer;
      borderColor = AppColors.info.withAlpha(120);
      badgeBg = context.appColors.infoContainer;
      badgeTextColor = context.appColors.onInfoContainer;
      badgeText = 'Berlangsung';
    } else {
      lineColor = AppColors.neutral300;
      nodeColor = AppColors.neutral300;
      cardBg = AppColors.neutral100;
      borderColor = AppColors.neutral300;
      badgeBg = AppColors.neutral200;
      badgeTextColor = AppColors.neutral600;
      badgeText = 'Terkunci';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: nodeColor.withAlpha(40),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isCompleted
                        ? Icon(
                            Icons.check_rounded,
                            color: context.appColors.surface,
                            size: 20,
                          )
                        : Text(
                            '$number',
                            style: TextStyle(
                              color: context.appColors.surface,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: GestureDetector(
              onTap: (isActive || isCompleted)
                  ? () {
                      if (stage.type == 'pasca_kencana') {
                        context.push(AppRoutes.kencanaScore);
                      } else {
                        context.push('/kencana/stage/${stage.id}');
                      }
                    }
                  : null,
              child: Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(
                    color: borderColor,
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            stage.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: isCompleted
                                  ? context.appColors.success
                                  : isActive
                                      ? context.appColors.info
                                      : AppColors.neutral700,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: AppRadius.br6,
                          ),
                          child: Text(
                            badgeText,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (stage.description != null &&
                        stage.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        stage.description!,
                        style: const TextStyle(
                          color: AppColors.neutral600,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (stage.startDate != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 13,
                            color: AppColors.neutral500,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            '${_formatDate(stage.startDate)} - ${_formatDate(stage.endDate)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.neutral600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _buildSessionCount(
                          stage.completedSessionCount,
                          stage.sessionCount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCount(int completed, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_rounded,
            size: 12,
            color: AppColors.neutral600,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$completed/$total Sesi',
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

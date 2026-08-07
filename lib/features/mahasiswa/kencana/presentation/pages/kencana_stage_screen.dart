import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class KencanaStageScreen extends StatefulWidget {
  final int stageId;

  const KencanaStageScreen({super.key, required this.stageId});

  @override
  State<KencanaStageScreen> createState() => _KencanaStageScreenState();
}

class _KencanaStageScreenState extends State<KencanaStageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaProvider>().fetchStageDetails(widget.stageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaProvider>();
    final detail = provider.currentStageDetail;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Tahapan',
            subtitle: detail?.name ?? 'Kencana',
            variant: AppBarVariant.student,
            expandedHeight: 100,
            showBackButton: true,
            isExpandable: false,
          ),
          if (provider.isLoading && detail == null)
            SliverFillRemaining(
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: BkuShimmerList(itemCount: 5, itemHeight: 80),
              ),
            )
          else if (provider.errorMessage != null && detail == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      provider.errorMessage!,
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.outline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    BkuButton(
                      onPressed:
                          () => provider.fetchStageDetails(widget.stageId),
                      text: 'Coba Lagi',
                    ),
                  ],
                ),
              ),
            )
          else if (detail == null)
            const SliverFillRemaining(
              child: Center(child: Text('Data tidak ditemukan')),
            )
          else
            SliverFillRemaining(
              hasScrollBody: true,
              child: RefreshIndicator(
                onRefresh: () => provider.fetchStageDetails(widget.stageId),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  children: [
                    _buildStageHeader(detail),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Sesi & Rangkaian Acara',
                      style: AppTextStyles.titleLg.copyWith(
                        fontWeight: FontWeight.w900,
                        color: context.appColors.onSurface,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Daftar sesi yang harus kamu ikuti dalam tahapan ini.',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (detail.sessions.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxl),
                          child: Column(
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                size: 48,
                                color: AppColors.neutral300,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                'Belum ada sesi di tahap ini.',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...detail.sessions.map(
                        (session) => FadeInAnimation(
                          delay: 0.1 + (detail.sessions.indexOf(session) * 0.1),
                          child: _buildSessionCard(context, session),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStageHeader(KencanaStageDetail detail) {
    final status = detail.status.toLowerCase();
    Color statusColor = AppColors.primary;
    if (status == 'completed' || status == 'selesai') {
      statusColor = AppColors.success;
    } else if (status == 'active' || status == 'aktif') {
      statusColor = AppColors.primary;
    } else {
      statusColor = AppColors.neutral500;
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  detail.status.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              if (detail.startDate != null)
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: context.appColors.outline,
                    ),
                    const SizedBox(width: AppSpacing.s6),
                    Text(
                      '${_formatDate(detail.startDate)} - ${_formatDate(detail.endDate)}',
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Text(
            detail.name,
            style: AppTextStyles.titleLg.copyWith(
              color: context.appColors.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              detail.description!,
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.outline,
              ),
            ),
          ],
          if (detail.group != null || detail.mentor != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: AppColors.primary.withAlpha(50),
                ),
              ),
              child: Row(
                children: [
                  if (detail.group != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KELOMPOK',
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Kelompok ${detail.group!['number'] ?? '-'} - ${detail.group!['name'] ?? '-'}',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.appColors.onSurface,
                            ),
                          ),
                          Text(
                            '(${detail.group!['code'] ?? '-'})',
                            style: AppTextStyles.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.appColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (detail.mentor != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'FASILITATOR',
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            detail.mentor!['name'] ?? '-',
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.w900,
                              color: context.appColors.onSurface,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    KencanaSessionSummary session,
  ) {
    final isActive =
        session.status == 'active' || session.status == 'in_progress';
    final isCompleted = session.status == 'completed';

    Color cardBg = context.appColors.surface;
    Color borderColor = AppColors.neutral200.withAlpha(150);
    Color iconBg = AppColors.primary.withAlpha(15);
    Color iconColor = AppColors.primary;
    Color titleColor = AppColors.onSurface;

    if (isActive) {
      cardBg = AppColors.primary.withAlpha(8);
      borderColor = AppColors.primary.withAlpha(40);
      iconBg = AppColors.primary.withAlpha(20);
      iconColor = AppColors.primary;
      titleColor = AppColors.onSurface;
    } else if (isCompleted) {
      cardBg = AppColors.success.withAlpha(8);
      borderColor = AppColors.success.withAlpha(40);
      iconBg = AppColors.success.withAlpha(20);
      iconColor = AppColors.success;
      titleColor = AppColors.onSurface;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: borderColor,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(5),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/kencana/session/${session.id}');
          },
          borderRadius: AppRadius.radiusLg,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.menu_book_rounded,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: titleColor,
                        ),
                      ),
                      if (session.startDate != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${_formatDateTime(session.startDate)} - ${_formatDateTime(session.endDate)}',
                          style: const TextStyle(
                            color: AppColors.neutral600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          _buildCountBadge(
                            Icons.article_rounded,
                            session.materialCount,
                            context.appColors.info,
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          _buildCountBadge(
                            Icons.quiz_rounded,
                            session.quizCount,
                            context.appColors.info,
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          _buildCountBadge(
                            Icons.assignment_rounded,
                            session.assignmentCount,
                            AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive ? AppColors.primary : AppColors.neutral500,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountBadge(IconData icon, int count, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          count.toString(),
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
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

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      // Jika waktu tepat 00:00, kemungkinan hanya data tanggal dari DB
      if (date.hour == 0 && date.minute == 0) {
        return DateFormat('dd MMM yyyy').format(date);
      }
      return DateFormat('dd MMM, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

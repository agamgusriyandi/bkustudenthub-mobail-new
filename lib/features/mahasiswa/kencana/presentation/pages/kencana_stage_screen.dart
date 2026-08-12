import 'package:bkuhub_mobile/core/theme/app_colors.dart';
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
                        fontSize: 15,
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
    Color statusBg = const Color(0xFFEFF6FF);
    Color statusTextColor = const Color(0xFF1D4ED8);
    String statusLabel = 'Berlangsung';

    if (status == 'completed' || status == 'selesai') {
      statusBg = const Color(0xFFECFDF5);
      statusTextColor = const Color(0xFF047857);
      statusLabel = 'Selesai';
    } else if (status == 'active' || status == 'aktif') {
      statusBg = const Color(0xFFEFF6FF);
      statusTextColor = const Color(0xFF1D4ED8);
      statusLabel = 'Berlangsung';
    } else {
      statusBg = AppColors.neutral200;
      statusTextColor = AppColors.neutral600;
      statusLabel = 'Belum Mulai';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
              if (detail.startDate != null)
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: AppColors.neutral600,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatDate(detail.startDate)} - ${_formatDate(detail.endDate)}',
                      style: const TextStyle(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            detail.name,
            style: const TextStyle(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w900,
              fontSize: 19,
            ),
          ),
          if (detail.description != null && detail.description!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              detail.description!,
              style: const TextStyle(
                color: AppColors.neutral600,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ],
          if (detail.group != null || detail.mentor != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.neutral300,
                ),
              ),
              child: Row(
                children: [
                  if (detail.group != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'KELOMPOK',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Kelompok ${detail.group!['number'] ?? '-'} - ${detail.group!['name'] ?? '-'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: AppColors.neutral900,
                            ),
                          ),
                          Text(
                            '(${detail.group!['code'] ?? '-'})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (detail.mentor != null || (detail.mentors != null && detail.mentors!.isNotEmpty))
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'FASILITATOR',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            detail.mentors != null && detail.mentors!.isNotEmpty
                                ? detail.mentors!.map((m) => m['name'] ?? m['Name'] ?? '').join(', ')
                                : detail.mentor != null ? detail.mentor!['name'] ?? '-' : '-',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              color: AppColors.neutral900,
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

    Color iconBg = AppColors.neutral200;
    Color iconColor = AppColors.neutral600;
    IconData iconData = Icons.menu_book_rounded;

    if (isCompleted) {
      iconBg = const Color(0xFFECFDF5);
      iconColor = const Color(0xFF10B981);
      iconData = Icons.check_circle_rounded;
    } else if (isActive) {
      iconBg = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF3B82F6);
      iconData = Icons.play_circle_fill_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? const Color(0xFF3B82F6) : AppColors.neutral300,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.push('/kencana/session/${session.id}');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: AppColors.neutral900,
                        ),
                      ),
                      if (session.startDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${_formatDateTime(session.startDate)} - ${_formatDateTime(session.endDate)}',
                          style: const TextStyle(
                            color: AppColors.neutral600,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildCountBadge(
                            Icons.article_rounded,
                            session.materialCount,
                            AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          _buildCountBadge(
                            Icons.quiz_rounded,
                            session.quizCount,
                            const Color(0xFF7C3AED),
                          ),
                          const SizedBox(width: 8),
                          _buildCountBadge(
                            Icons.assignment_rounded,
                            session.assignmentCount,
                            const Color(0xFFD97706),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.neutral900,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              color: color,
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

import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/mission.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/module_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/quiz_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/assignment_screen.dart';

class KencanaSessionScreen extends StatefulWidget {
  final int sessionId;

  const KencanaSessionScreen({super.key, required this.sessionId});

  @override
  State<KencanaSessionScreen> createState() => _KencanaSessionScreenState();
}

class _KencanaSessionScreenState extends State<KencanaSessionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaProvider>().fetchSessionDetails(widget.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaProvider>();
    final session = provider.currentSessionDetail;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Sesi',
            subtitle: session?.title ?? 'Kencana',
            variant: AppBarVariant.student,
            expandedHeight: 100,
            showBackButton: true,
            isExpandable: false,
          ),
          if (provider.isLoading && session == null)
            SliverFillRemaining(
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: BkuShimmerList(itemCount: 5, itemHeight: 80),
              ),
            )
          else if (provider.errorMessage != null && session == null)
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
                          () => provider.fetchSessionDetails(widget.sessionId),
                      text: 'Coba Lagi',
                    ),
                  ],
                ),
              ),
            )
          else if (session == null)
            const SliverFillRemaining(
              child: Center(child: Text('Data tidak ditemukan')),
            )
          else
            SliverFillRemaining(
              hasScrollBody: true,
              child: RefreshIndicator(
                onRefresh: () => provider.fetchSessionDetails(widget.sessionId),
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
                    _buildSessionInfo(session),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildMaterialsSection(session),
                    const SizedBox(height: AppSpacing.xl),
                    _buildQuizzesSection(session),
                    const SizedBox(height: AppSpacing.xl),
                    _buildAssignmentsSection(session),
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(KencanaSessionDetail session) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          session.title,
          style: AppTextStyles.titleLg.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (session.startDate != null)
          Row(
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                size: 16,
                color: context.appColors.outline,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${_formatDateTime(session.startDate)} - ${_formatDateTime(session.endDate)}',
                style: AppTextStyles.labelMd.copyWith(
                  color: context.appColors.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        if (session.description != null && session.description!.isNotEmpty)
          Text(
            session.description!,
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
            ),
          ),
      ],
    );
  }

  Widget _buildMaterialsSection(KencanaSessionDetail session) {
    return _buildSection(
      title: 'Materi Pembelajaran',
      icon: Icons.article_rounded,
      items: session.materials,
      itemBuilder: (item) {
        final isCompleted = item['status'] == 'completed';
        return _buildCardItem(
          title: item['title'] ?? 'Materi',
          subtitle: item['type'] ?? 'Materi',
          icon:
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.menu_book_rounded,
          iconColor: isCompleted ? AppColors.success : AppColors.neutral600,
          onTap: () async {
            final mission = Mission(
              id: item['id']?.toString(),
              title: item['title'],
              type: 'material',
              content: item['content'],
              fileUrl: item['file_url'],
              isCompleted: isCompleted,
            );
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ModuleDetailScreen(mission: mission),
              ),
            );
            if (result == true) {
              if (mounted) {
                context.read<KencanaProvider>().fetchSessionDetails(
                  widget.sessionId,
                );
              }
            }
          },
        );
      },
      emptyMessage: 'Belum ada materi untuk sesi ini.',
    );
  }

  Widget _buildQuizzesSection(KencanaSessionDetail session) {
    return _buildSection(
      title: 'Kuis & Evaluasi',
      icon: Icons.quiz_rounded,
      items: session.quizzes,
      itemBuilder: (item) {
        final isActive =
            item['status'] == 'published' || item['status'] == 'active';
        final maxAttempts = item['max_attempts'] ?? 0;
        final attemptsUsed = item['attempts_used'] ?? 0;
        final isCompleted = attemptsUsed > 0;

        IconData iconData = Icons.lock_rounded;
        Color iconColor = AppColors.neutral500;
        if (isCompleted) {
          iconData = Icons.check_circle_rounded;
          iconColor = AppColors.success;
        } else if (isActive) {
          iconData = Icons.play_circle_fill_rounded;
          iconColor = AppColors.primary;
        }

        return _buildCardItem(
          title: item['title'] ?? 'Kuis',
          subtitle:
              isCompleted
                  ? 'Selesai ($attemptsUsed/$maxAttempts)'
                  : 'Waktu: ${item['duration_minutes'] ?? 0} menit',
          icon: iconData,
          iconColor: iconColor,
          onTap:
              (isActive &&
                      (!isCompleted ||
                          attemptsUsed < maxAttempts ||
                          maxAttempts == 0))
                  ? () {
                    final mission = Mission(
                      id: item['id']?.toString(),
                      title: item['title'],
                      type: 'quiz',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(mission: mission),
                      ),
                    ).then((_) {
                      // Refresh when returning from quiz
                      if (!mounted) return;
                      context.read<KencanaProvider>().fetchSessionDetails(
                        session.id,
                      );
                    });
                  }
                  : null,
        );
      },
      emptyMessage: 'Belum ada kuis untuk sesi ini.',
    );
  }

  Widget _buildAssignmentsSection(KencanaSessionDetail session) {
    return _buildSection(
      title: 'Tugas Penugasan',
      icon: Icons.assignment_rounded,
      items: session.assignments,
      itemBuilder: (item) {
        final submissionStatus = item['submission_status'] ?? 'pending';
        final isSubmitted =
            submissionStatus == 'submitted' || submissionStatus == 'graded';
        return _buildCardItem(
          title: item['title'] ?? 'Tugas',
          subtitle:
              item['due_date'] != null
                  ? 'Tenggat: ${_formatDateTime(item['due_date'])}'
                  : 'Tugas',
          icon:
              isSubmitted
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_rounded,
          iconColor: isSubmitted ? AppColors.success : context.appColors.info,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => AssignmentScreen(
                      mission: Mission(
                        id: item['id'].toString(),
                        title: item['title'] ?? 'Tugas',
                        desc: item['description'] ?? '',
                        type: 'assignment',
                        isCompleted: isSubmitted,
                      ),
                    ),
              ),
            );
            if (result == true) {
              if (mounted) {
                context.read<KencanaProvider>().fetchSessionDetails(
                  widget.sessionId,
                );
              }
            }
          },
        );
      },
      emptyMessage: 'Belum ada tugas untuk sesi ini.',
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Map<String, dynamic>> items,
    required Widget Function(Map<String, dynamic>) itemBuilder,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.titleMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.neutral50,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withAlpha(50),
              ),
            ),
            child: Text(
              emptyMessage,
              style: AppTextStyles.labelMd.copyWith(
                color: context.appColors.outline,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: itemBuilder(item),
            ),
          ),
      ],
    );
  }

  Widget _buildCardItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusXl,
        child: BkuCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: AppTextStyles.labelSm.copyWith(
                        color: context.appColors.outline,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.outline,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      if (date.hour == 0 && date.minute == 0) {
        return DateFormat('dd MMM yyyy').format(date);
      }
      return DateFormat('dd MMM, HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

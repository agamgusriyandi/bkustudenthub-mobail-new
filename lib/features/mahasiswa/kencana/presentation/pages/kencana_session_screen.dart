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
          style: const TextStyle(
            color: AppColors.neutral900,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 10),
        if (session.startDate != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  size: 14,
                  color: AppColors.neutral600,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_formatDateTime(session.startDate)} - ${_formatDateTime(session.endDate)}',
                  style: const TextStyle(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        if (session.description != null && session.description!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            session.description!,
            style: const TextStyle(
              color: AppColors.neutral600,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
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
          subtitle: (item['type'] ?? 'Materi').toString().toUpperCase(),
          icon:
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.menu_book_rounded,
          iconColor: isCompleted ? const Color(0xFF10B981) : AppColors.info,
          onTap: () async {
            final fileUrlStr = (item['file_url'] ?? item['url'] ?? '')?.toString().trim();
            final linkUrlStr = item['link_url']?.toString().trim();
            final mission = Mission(
              id: item['id']?.toString(),
              title: item['title'],
              type: 'material',
              content: item['content'],
              fileUrl: (fileUrlStr != null && fileUrlStr.isNotEmpty) ? fileUrlStr : null,
              linkUrl: (linkUrlStr != null && linkUrlStr.isNotEmpty) ? linkUrlStr : null,
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
        Color iconColor = AppColors.neutral600;
        if (isCompleted) {
          iconData = Icons.check_circle_rounded;
          iconColor = const Color(0xFF10B981);
        } else if (isActive) {
          iconData = Icons.play_circle_fill_rounded;
          iconColor = const Color(0xFF7C3AED);
        }

        return _buildCardItem(
          title: item['title'] ?? 'Kuis',
          subtitle:
              isCompleted
                  ? 'Selesai ($attemptsUsed/$maxAttempts Selesai)'
                  : 'Durasi: ${item['duration_minutes'] ?? 0} menit',
          icon: iconData,
          iconColor: iconColor,
          onTap: () {
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
              if (!mounted) return;
              context.read<KencanaProvider>().fetchSessionDetails(
                session.id,
              );
            });
          },
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
                  : 'Tugas Penugasan',
          icon:
              isSubmitted
                  ? Icons.check_circle_rounded
                  : Icons.upload_file_rounded,
          iconColor: isSubmitted ? const Color(0xFF10B981) : const Color(0xFFD97706),
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
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.neutral900),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.neutral900,
                fontSize: 14.5,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neutral200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.neutral300,
              ),
            ),
            child: Text(
              emptyMessage,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neutral300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.neutral600,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.neutral900,
                  size: 22,
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

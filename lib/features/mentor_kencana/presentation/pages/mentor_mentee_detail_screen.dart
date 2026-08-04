import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import '../../domain/entities/mentor_models.dart';
import 'mentor_handbook_review_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';

import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorMenteeDetailScreen extends StatefulWidget {
  final int studentId;
  const MentorMenteeDetailScreen({super.key, required this.studentId});

  @override
  State<MentorMenteeDetailScreen> createState() =>
      _MentorMenteeDetailScreenState();
}

class _MentorMenteeDetailScreenState extends State<MentorMenteeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMenteeDetail(
          widget.studentId,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final mentee = provider.menteeDetail;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body:
          provider.isLoading && mentee == null
              ? const Center(child: CircularProgressIndicator())
              : provider.errorMessage != null && mentee == null
              ? Center(
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(color: context.appColors.error),
                ),
              )
              : mentee == null
              ? Center(
                child: Text(
                  'Data tidak ditemukan',
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.appColors.outline,
                  ),
                ),
              )
              : NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    BkuAppBar(
                      title: 'Detail Mentee',
                      subtitle: mentee.name,
                      variant: AppBarVariant.student,
                      isExpandable: false,
                      showBackButton: true,
                      onBack: () => context.pop(),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.neutral800,
                          unselectedLabelColor: context.appColors.outline,
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusMd,
                            boxShadow: [
                              BoxShadow(
                                color: context.appColors.onSurface.withValues(alpha:0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: const [
                            Tab(text: 'Rincian Nilai'),
                            Tab(text: 'Input & Edit Nilai'),
                            Tab(text: 'Tugas & Submisi'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProgressTab(context, mentee),
                    _buildScoreFormTab(context, mentee),
                    _buildTasksTab(context, mentee),
                  ],
                ),
              ),
    );
  }

  Widget _buildProgressTab(BuildContext context, mentee) {
    final provider = context.watch<MentorKencanaProvider>();
    final progressData = provider.progressData ?? {};
    final scoreData = provider.scoreData ?? {};
    final attendanceData = provider.attendanceData ?? {};
    final handbookData = provider.handbookData;
    
    final progressTotal = progressData['progress_total'] ?? 0;
    
    final blockers = (scoreData['blockers'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final score = scoreData['score'] ?? {};
    final scoreItems = (scoreData['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final scoreDefs = scoreData['score_definitions'] ?? {};
    
    final attendancePercentage = num.tryParse(attendanceData['percentage']?.toString() ?? '0') ?? 0;
    final attendedSessions = attendanceData['attended_sessions'] ?? 0;
    final requiredSessions = attendanceData['required_sessions'] ?? 0;
    final isAttendanceComplete = attendancePercentage >= 100;

    final handbookItem = scoreItems.where((i) => 
      ['cognitive', 'requirements', 'cognitive_static'].contains(i['component']?.toString().toLowerCase()) &&
      i['item_name']?.toString().toLowerCase() == 'handbook'
    ).firstOrNull;
    
    final isHandbookScored = handbookItem != null && (num.tryParse(handbookItem['score']?.toString() ?? '0') ?? 0) > 0;
    final handbookStatus = handbookData?['status']?.toString() ?? 'not_started';
    final handbookLabel = isHandbookScored ? 'Sudah Diisi' 
      : handbookStatus == 'not_started' ? 'Belum Diisi'
      : handbookStatus == 'draft' ? 'Draft Mahasiswa'
      : handbookStatus == 'submitted' ? 'Menunggu Review'
      : handbookStatus == 'approved' ? 'Disetujui' : 'Perlu Perbaikan';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (blockers.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.error.withValues(alpha:0.06),
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: context.appColors.error.withValues(alpha:0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_rounded, color: context.appColors.error, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Syarat Kelulusan Belum Terpenuhi',
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: context.appColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...blockers.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs, left: AppSpacing.lg),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: context.appColors.error, fontWeight: FontWeight.bold)),
                        Expanded(child: Text(b, style: AppTextStyles.labelSm.copyWith(color: context.appColors.error))),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          
          _buildMetricsGrid(context, attendancePercentage, attendedSessions, requiredSessions, isAttendanceComplete, progressTotal, handbookLabel, isHandbookScored, handbookStatus),
          const SizedBox(height: AppSpacing.xl),
          
          Text(
            'Rincian Nilai Rata-Rata',
            style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildScoreOverviewCard(
            context,
            'Pengetahuan',
            Icons.psychology_rounded,
            context.appColors.primary,
            score['cognitive_average'],
            scoreDefs['cognitive'],
            scoreItems,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildScoreOverviewCard(
            context,
            'Keterampilan',
            Icons.build_rounded,
            context.appColors.warning,
            score['psychomotor_average'],
            scoreDefs['psychomotor'],
            scoreItems,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildScoreOverviewCard(
            context,
            'Sikap',
            Icons.favorite_rounded,
            context.appColors.error,
            score['affective_average'],
            scoreDefs['affective'],
            scoreItems,
          ),
          const SizedBox(height: AppSpacing.xl),
          
          BkuButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MentorHandbookReviewScreen(
                    studentId: mentee.id,
                    studentName: mentee.name,
                  ),
                ),
              ).then((_) => provider.fetchMenteeDetail(mentee.id));
            },
            icon: Icons.book_rounded,
            text: 'Review Buku Saku (Handbook)',
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricsGrid(BuildContext context, num attPct, int attSes, int reqSes, bool attComplete, num prog, String hbLabel, bool isHbScored, String hbStatus) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Kehadiran',
                '$attPct%',
                'Sesi: $attSes / $reqSes',
                Icons.calendar_month_rounded,
                context.appColors.primary,
                attComplete ? 'Lengkap' : 'Kurang',
                attComplete ? context.appColors.success : context.appColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildMetricCard(
                context,
                'Progress',
                '$prog%',
                'Materi Selesai',
                Icons.track_changes_rounded,
                context.appColors.warning,
                'Aktif',
                context.appColors.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildMetricCard(
          context,
          'Status Handbook',
          hbLabel,
          isHbScored ? 'Sudah dinilai' : 'Belum dievaluasi',
          Icons.menu_book_rounded,
          context.appColors.success,
          isHbScored || hbStatus == 'approved' ? 'SUDAH' : 'PENDING',
          isHbScored || hbStatus == 'approved' ? context.appColors.success : context.appColors.outline,
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(BuildContext context, String title, String value, String subtitle, IconData icon, Color iconColor, String badgeText, Color badgeColor) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -10,
            child: Icon(icon, size: 80, color: iconColor.withValues(alpha:0.15)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: context.appColors.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                value,
                style: AppTextStyles.titleLg.copyWith(fontWeight: FontWeight.w900),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.outline,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha:0.15),
                  border: Border.all(color: badgeColor.withValues(alpha:0.5)),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Text(
                  badgeText.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreOverviewCard(BuildContext context, String title, IconData icon, Color color, dynamic average, dynamic defsData, List<Map<String, dynamic>> items) {
    final defs = (defsData as List?)?.cast<Map<String, dynamic>>() ?? [];
    return BkuCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 20, color: color),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      title.toUpperCase(),
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: context.appColors.onSurface,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Text(
                    num.tryParse(average?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.w900,
                      color: context.appColors.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: defs.isEmpty ? 
              Center(
                child: Text('Belum ada nilai', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontStyle: FontStyle.italic)),
              )
              : Column(
              children: defs.map((def) {
                final key = def['key']?.toString() ?? def['id']?.toString() ?? def['item_name']?.toString() ?? '';
                final label = def['label']?.toString() ?? def['name']?.toString() ?? def['title']?.toString() ?? key;
                
                final item = items.where((i) {
                  final iName = i['item_name']?.toString().toLowerCase() ?? i['key']?.toString().toLowerCase() ?? i['name']?.toString().toLowerCase() ?? i['title']?.toString().toLowerCase() ?? '';
                  final iId = i['score_item_id']?.toString() ?? i['id']?.toString() ?? '';
                  final targetKey = key.toLowerCase();
                  final targetLabel = label.toLowerCase();

                  final cleanedTarget = targetLabel.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll(RegExp(r'[()]'), '').trim();
                  final cleanedName = iName.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll(RegExp(r'[()]'), '').trim();

                  return iName == targetKey || 
                         iId == key || 
                         iName == targetLabel || 
                         (targetKey.isNotEmpty && iName.contains(targetKey)) || 
                         (iName.isNotEmpty && targetKey.contains(iName)) ||
                         (cleanedTarget.isNotEmpty && cleanedName.isNotEmpty && (cleanedTarget.contains(cleanedName) || cleanedName.contains(cleanedTarget)));
                }).firstOrNull;

                final scoreDisplay = item?['score']?.toString() ?? item?['value']?.toString() ?? item?['nilai']?.toString() ?? '-';

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: context.appColors.outline),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          border: Border.all(color: context.appColors.outline.withValues(alpha:0.3)),
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Text(
                          scoreDisplay,
                          style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTasksTab(BuildContext context, mentee) {
    return Column(
      children: [
        Expanded(
          child:
              mentee.assignments.isEmpty
                  ? Center(
                    child: Text(
                      'Belum ada tugas yang disubmit',
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.outline,
                      ),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    itemCount: mentee.assignments.length,
                    itemBuilder: (context, index) {
                      final task = mentee.assignments[index];
                      return BkuCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.s6),
                                      Row(
                                        children: [
                                          Text(
                                            'Tipe: ${task.type}',
                                            style: AppTextStyles.labelSm
                                                .copyWith(
                                                  color:
                                                      context.appColors.outline,
                                                ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (task.status == 'submitted' ||
                                                          task.status ==
                                                              'graded')
                                               ? context.appColors.success.withValues(alpha:0.15)
                                                       : context.appColors.error.withValues(alpha:0.15),
                                               border: Border.all(
                                                 color:
                                                     (task.status ==
                                                                 'submitted' ||
                                                             task.status ==
                                                                 'graded')
                                                         ? context.appColors.success.withValues(alpha:0.3)
                                                         : context.appColors.error.withValues(alpha:0.3),
                                              ),
                                              borderRadius: AppRadius.radiusXs,
                                            ),
                                            child: Text(
                                              (task.status == 'submitted' ||
                                                      task.status == 'graded')
                                                  ? 'Terkumpul'
                                                  : 'Belum Terkumpul',
                                              style: TextStyle(
                                                color:
                                                     (task.status ==
                                                                 'submitted' ||
                                                             task.status ==
                                                                 'graded')
                                                         ? context.appColors.success
                                                         : context.appColors.error,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'Nilai: ${task.score}',
                                  style: AppTextStyles.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        context.appColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (task.status == 'submitted' ||
                                task.status == 'graded') ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Hasil Pekerjaan:',
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.appColors.outline,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.s6),
                              if (task.answerText.isNotEmpty) ...[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: context.appColors.outline.withValues(alpha:0.1),
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color:
                                          AppThemeColors.surfaceContainerHighest,
                                    ),
                                  ),
                                  child: Text(
                                    task.answerText,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: context.appColors.onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (task.submittedLink.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appColors.primary.withAlpha(12),
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color: context.appColors.primary.withAlpha(51),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.link,
                                        size: 16,
                                        color:
                                            context.appColors.primary,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Flexible(
                                        child: Text(
                                          task.submittedLink,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color:
                                                context.appColors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              if (task.submittedFile.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral200,
                                    borderRadius: AppRadius.radiusMd,
                                    border: Border.all(
                                      color:
                                          AppThemeColors.surfaceContainerHighest,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.download_rounded,
                                        size: 16,
                                        color: context.appColors.onSurface,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Flexible(
                                        child: Text(
                                          task.submittedFile.split('/').last,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: context.appColors.onSurface,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ] else ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: context.appColors.error.withAlpha(15),
                                  borderRadius: AppRadius.radiusMd,
                                  border: Border.all(
                                    color: context.appColors.error.withAlpha(30),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline_rounded,
                                      size: 16,
                                      color: context.appColors.error,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        'Mahasiswa belum mengunggah jawaban untuk tugas ini.',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildScoreFormTab(BuildContext context, MenteeDetailData mentee) {
    return _ScoreFormTabWidget(mentee: mentee);
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 8;
  @override
  double get maxExtent => tabBar.preferredSize.height + 8;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.neutral200.withValues(alpha:0.5),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}

class _ScoreFormTabWidget extends StatefulWidget {
  final MenteeDetailData mentee;
  const _ScoreFormTabWidget({required this.mentee});

  @override
  State<_ScoreFormTabWidget> createState() => _ScoreFormTabWidgetState();
}

class _ScoreFormTabWidgetState extends State<_ScoreFormTabWidget> {
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submitScores() async {
    setState(() => _isSubmitting = true);
    
    final items = <Map<String, dynamic>>[];
    _controllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        final parts = key.split('||'); // component||item_name
        if (parts.length == 2) {
          items.add({
            'component': parts[0],
            'item_name': parts[1],
            'score': double.tryParse(controller.text) ?? 0,
            'notes': '',
          });
        }
      }
    });

    if (items.isEmpty) {
      AppSnackbar.showWarning(context, 'Tidak ada nilai yang diisi');
      setState(() => _isSubmitting = false);
      return;
    }

    final provider = context.read<MentorKencanaProvider>();
    final success = await provider.submitBulkScores(studentId: widget.mentee.id, items: items);
    
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        AppSnackbar.showSuccess(context, 'Berhasil menyimpan semua nilai');
        provider.fetchMenteeDetail(widget.mentee.id);
      } else {
        AppSnackbar.showError(context, 'Gagal menyimpan nilai');
      }
    }
  }

  Widget _buildComponentSection(String title, String component, dynamic defsData, List<Map<String, dynamic>> itemsData) {
    final defs = (defsData as List?)?.cast<Map<String, dynamic>>() ?? [];
    if (defs.isEmpty) return const SizedBox();

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title.toUpperCase(),
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.w900, 
                color: context.appColors.primary,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ...defs.map((def) {
            final key = def['key']?.toString() ?? def['id']?.toString() ?? def['item_name']?.toString() ?? '';
            final label = def['label']?.toString() ?? def['name']?.toString() ?? def['title']?.toString() ?? key;
            final mapKey = '$component||$key';
            
            final existingItem = itemsData.where((i) {
              final iComp = i['component']?.toString().toLowerCase() ?? '';
              final iName = i['item_name']?.toString().toLowerCase() ?? i['key']?.toString().toLowerCase() ?? i['name']?.toString().toLowerCase() ?? i['title']?.toString().toLowerCase() ?? '';
              final iId = i['score_item_id']?.toString() ?? i['id']?.toString() ?? '';
              final targetKey = key.toLowerCase();
              final targetLabel = label.toLowerCase();

              final cleanedTarget = targetLabel.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll(RegExp(r'[()]'), '').trim();
              final cleanedName = iName.replaceAll(RegExp(r'\[.*?\]'), '').replaceAll(RegExp(r'[()]'), '').trim();

              return (iComp == component.toLowerCase() || iComp.isEmpty) && 
                     (iName == targetKey || iId == key || iName == targetLabel || iName.contains(targetKey) || targetKey.contains(iName) || (cleanedTarget.isNotEmpty && cleanedName.isNotEmpty && (cleanedTarget.contains(cleanedName) || cleanedName.contains(cleanedTarget))));
            }).firstOrNull;

            final fetchedScore = existingItem?['score']?.toString() ?? existingItem?['value']?.toString() ?? existingItem?['nilai']?.toString() ?? '';

            if (!_controllers.containsKey(mapKey)) {
              _controllers[mapKey] = TextEditingController(text: fetchedScore);
            } else if (_controllers[mapKey]!.text != fetchedScore && fetchedScore.isNotEmpty) {
              _controllers[mapKey]!.text = fetchedScore;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: BkuTextField(
                controller: _controllers[mapKey]!,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                label: label,
                hint: 'Masukkan nilai (0-100)',
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final scoreData = provider.scoreData ?? {};
    final scoreItems = (scoreData['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final scoreDefs = scoreData['score_definitions'] ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Penilaian Akhir',
            style: AppTextStyles.titleLg.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Isi nilai untuk setiap komponen yang telah ditentukan. Kosongkan jika belum dinilai.',
            style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          _buildComponentSection('Pengetahuan (Kognitif)', 'cognitive', scoreDefs['cognitive'], scoreItems),
          _buildComponentSection('Keterampilan (Psikomotor)', 'psychomotor', scoreDefs['psychomotor'], scoreItems),
          _buildComponentSection('Sikap (Afektif)', 'affective', scoreDefs['affective'], scoreItems),
          _buildComponentSection('Syarat Kelulusan Khusus', 'requirements', scoreDefs['requirements'], scoreItems),
          
          const SizedBox(height: AppSpacing.xl),
          BkuButton(
            onPressed: _submitScores,
            text: 'Simpan Semua Nilai',
            icon: Icons.save_rounded,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}


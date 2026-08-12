import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
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
              ? const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList())
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
                      onBack: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/mentor-kencana');
                        }
                      },
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
    final mentorScope = scoreData['mentor_scope'] ?? 'university';
    final scoreItems = (scoreData['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final scoreDefs = scoreData['score_definitions'] ?? {};
    
    final finalScoreVal = mentorScope == 'faculty' ? score['final_score_faculty'] : score['final_score_univ'];
    final graduationStatusVal = mentorScope == 'faculty' ? score['graduation_status_faculty'] : score['graduation_status_univ'];
    
    final finalScoreStr = num.tryParse(finalScoreVal?.toString() ?? '0')?.toStringAsFixed(1) ?? '0.0';
    final graduationStatusStr = (graduationStatusVal?.toString() ?? 'BELUM EVALUASI');

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
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.appColors.primary,
                  context.appColors.primary.withAlpha(200),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.radiusLg,
              boxShadow: [
                BoxShadow(
                  color: context.appColors.primary.withAlpha(60),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS KELULUSAN',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: AppRadius.radiusSm,
                      ),
                      child: Text(
                        graduationStatusStr == 'PASSED' ? 'LULUS' :
                        graduationStatusStr == 'CONDITIONAL_PASS' || graduationStatusStr == 'CONDITIONAL' ? 'LULUS BERSYARAT' :
                        graduationStatusStr == 'REMEDIAL' ? 'REMEDIAL' :
                        'BELUM EVALUASI',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: AppSpacing.lg),
                  decoration: const BoxDecoration(
                    border: Border(left: BorderSide(color: Colors.white24, width: 1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'NILAI AKHIR',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        finalScoreStr,
                        style: AppTextStyles.titleLg.copyWith(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
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
            'cognitive',
            Icons.psychology_rounded,
            context.appColors.primary,
            score['cognitive_average'],
            scoreDefs['cognitive'],
            scoreItems,
            mentorScope,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildScoreOverviewCard(
            context,
            'Keterampilan',
            'psychomotor',
            Icons.build_rounded,
            context.appColors.warning,
            score['psychomotor_average'],
            scoreDefs['psychomotor'],
            scoreItems,
            mentorScope,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildScoreOverviewCard(
            context,
            'Sikap',
            'affective',
            Icons.favorite_rounded,
            context.appColors.error,
            score['affective_average'],
            scoreDefs['affective'],
            scoreItems,
            mentorScope,
          ),
          const SizedBox(height: AppSpacing.md),
          
          _buildScoreOverviewCard(
            context,
            'Syarat Kelulusan Khusus',
            'requirements',
            Icons.verified_user_rounded,
            context.appColors.success,
            score['requirements_average'],
            scoreDefs['requirements'],
            scoreItems,
            mentorScope,
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
                title,
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
                  badgeText,
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
  
  Widget _buildScoreOverviewCard(BuildContext context, String title, String component, IconData icon, Color color, dynamic average, dynamic defsData, List<Map<String, dynamic>> items, String mentorScope) {
    final rawDefs = (defsData as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    // We only filter by show_in_univ / show_in_faculty for read-only view
    final defs = rawDefs.where((d) {
      if (mentorScope == 'faculty') {
        if (d['show_in_faculty'] == false) return false;
        final label = d['label']?.toString() ?? '';
        final key = d['key']?.toString().toLowerCase() ?? '';
        final isPra = label.contains('[Pra]') || key.contains('pra');
        final isUnivOnly = label.contains('[Univ]') || label.contains('[Universitas]');
        return !isPra && !isUnivOnly;
      }
      return true;
    }).toList();

    double totalScore = 0;
    int scoreCount = 0;

    for (final def in defs) {
      final key = def['key']?.toString() ?? def['id']?.toString() ?? def['item_name']?.toString() ?? '';
      final label = def['label']?.toString() ?? def['name']?.toString() ?? def['title']?.toString() ?? key;
      final isFakultasOnly = label.contains('[Fakultas]') || key.toLowerCase().contains('fakultas') || key.toLowerCase().contains('faculty');
      final targetScope = mentorScope == 'faculty' ? 'faculty' : (isFakultasOnly ? 'faculty' : 'university');

      final item = items.where((i) {
        final iComp = i['component']?.toString() ?? '';
        final iName = i['item_name']?.toString() ?? '';
        final iScope = i['scope_type']?.toString() ?? 'university';
        return iComp == component && iName == key && iScope == targetScope;
      }).firstOrNull;

      final scoreStr = item?['score']?.toString();
      if (scoreStr != null && scoreStr != '-') {
        final numVal = double.tryParse(scoreStr);
        if (numVal != null) {
          totalScore += numVal;
          scoreCount++;
        }
      }
    }

    final double computedAvg = scoreCount > 0
        ? (totalScore / scoreCount)
        : (double.tryParse(average?.toString() ?? '0') ?? 0.0);

    String displayScore;
    if (computedAvg == 0 || component == 'requirements') {
      displayScore = computedAvg == 0 ? '0' : (computedAvg % 1 == 0 ? computedAvg.toInt().toString() : computedAvg.toStringAsFixed(1));
    } else {
      displayScore = computedAvg % 1 == 0 ? computedAvg.toInt().toString() : computedAvg.toStringAsFixed(1);
    }

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
                      title,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
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
                    displayScore,
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
                
                // For progress tab read-only view, since we show ALL items for university mentor, 
                // we should match the scope correctly. If mentor is university, Pra items are university scope.
                final isFakultasOnly = label.contains('[Fakultas]') || key.toLowerCase().contains('fakultas') || key.toLowerCase().contains('faculty');
                final targetScope = mentorScope == 'faculty' ? 'faculty' : (isFakultasOnly ? 'faculty' : 'university');

                final item = items.where((i) {
                  final iComp = i['component']?.toString() ?? '';
                  final iName = i['item_name']?.toString() ?? '';
                  final iScope = i['scope_type']?.toString() ?? 'university';
                  return iComp == component && iName == key && iScope == targetScope;
                }).firstOrNull;

                final scoreDisplay = item?['score']?.toString() ?? '-';

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
    final provider = context.watch<MentorKencanaProvider>();
    final assignmentsData = provider.assignmentsData ?? [];
    final scoreData = provider.scoreData ?? {};
    final mentorScope = scoreData['mentor_scope'] ?? 'university';

    final filteredAssignments = assignmentsData.where((item) {
      final assignment = (item['assignment'] as Map<String, dynamic>?) ?? {};
      final stageType = (assignment['stage_type'] ?? assignment['stage']?['type'] ?? '').toString();
      final title = (assignment['title'] ?? '').toString();
      if (mentorScope == 'faculty') {
        return stageType == 'kencana_fakultas' || stageType == 'faculty' || title.contains('[Fakultas]') || stageType.isEmpty;
      }
      return stageType == 'pra_kencana' || stageType == 'kencana_universitas' || stageType == 'university' || title.contains('[Pra]') || title.contains('[Univ]') || stageType.isEmpty;
    }).toList();

    if (filteredAssignments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(
            'Belum ada tugas ${mentorScope == 'faculty' ? 'Fakultas' : 'Universitas'} yang tersedia.',
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: filteredAssignments.length,
      itemBuilder: (context, index) {
        final item = (filteredAssignments[index] as Map<String, dynamic>?) ?? {};
        final assignment = (item['assignment'] as Map<String, dynamic>?) ?? {};
        final submission = (item['submission'] as Map<String, dynamic>?) ?? {};

        final title = assignment['title']?.toString() ?? 'Tugas';
        final description = assignment['description']?.toString() ?? '';
        final status = submission['status']?.toString() ?? 'not_submitted';

        final isSubmitted = status == 'submitted' || status == 'graded' || status == 'late' || (submission['id'] != null && status != 'not_submitted');
        final isLate = status == 'late';

        final answerText = submission['answer_text']?.toString() ?? '';
        final linkUrl = submission['link_url']?.toString() ?? '';
        final fileUrl = submission['file_url']?.toString() ?? '';
        final submittedAtRaw = submission['submitted_at']?.toString() ?? '';
        String submittedAtFormatted = submittedAtRaw;
        if (submittedAtRaw.isNotEmpty) {
          try {
            final date = DateTime.parse(submittedAtRaw).toLocal();
            final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
            final day = date.day.toString().padLeft(2, '0');
            final month = months[date.month - 1];
            final year = date.year;
            final hour = date.hour.toString().padLeft(2, '0');
            final minute = date.minute.toString().padLeft(2, '0');
            submittedAtFormatted = '$day $month $year, $hour:$minute WIB';
          } catch (_) {}
        }

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
                    child: Text(
                      title,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSubmitted
                          ? context.appColors.success.withAlpha(30)
                          : context.appColors.error.withAlpha(30),
                      border: Border.all(
                        color: isSubmitted
                            ? context.appColors.success.withAlpha(80)
                            : context.appColors.error.withAlpha(80),
                      ),
                      borderRadius: AppRadius.radiusSm,
                    ),
                    child: Text(
                      isSubmitted ? (isLate ? 'Terkumpul (Terlambat)' : 'Terkumpul') : 'Belum Terkumpul',
                      style: AppTextStyles.labelSm.copyWith(
                        color: isSubmitted ? context.appColors.success : context.appColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description.replaceAll(RegExp(r'<[^>]*>'), ''),
                  style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (isSubmitted) ...[
                Text(
                  'Hasil Pekerjaan:',
                  style: AppTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.appColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (answerText.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: context.appColors.outline.withAlpha(50)),
                    ),
                    child: Text(
                      answerText,
                      style: AppTextStyles.labelSm,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (linkUrl.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withAlpha(15),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: context.appColors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link, size: 16, color: context.appColors.primary),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            linkUrl,
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (fileUrl.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: context.appColors.outline.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.file_present_rounded, size: 16, color: context.appColors.onSurface),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            fileUrl.split('/').last,
                            style: AppTextStyles.labelSm.copyWith(color: context.appColors.onSurface),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                if (submittedAtRaw.isNotEmpty) ...[
                  Text(
                    'Dikumpulkan pada: $submittedAtFormatted',
                    style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10),
                  ),
                ],
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.appColors.surface,
                    borderRadius: AppRadius.radiusMd,
                    border: Border.all(color: context.appColors.outline.withAlpha(30)),
                  ),
                  child: Text(
                    'Mahasiswa belum mengunggah jawaban untuk tugas ini.',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.outline,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
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
  String _formStageTab = 'univ';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<MentorKencanaProvider>();
      final mentorScope = provider.scoreData?['mentor_scope'] ?? 'university';
      if (mentorScope == 'faculty') {
        setState(() => _formStageTab = 'faculty');
      }
    });
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Map<String, dynamic>> _filterDefByStage(List<dynamic> rawDefs) {
    final defs = rawDefs.cast<Map<String, dynamic>>();
    if (_formStageTab == 'pra') {
      return defs.where((d) => (d['label']?.toString() ?? '').contains('[Pra]') || (d['key']?.toString().toLowerCase() ?? '').contains('pra')).toList();
    }
    if (_formStageTab == 'faculty') {
      return defs.where((d) {
        if (d['show_in_faculty'] == false) return false;
        final label = d['label']?.toString() ?? '';
        final key = d['key']?.toString().toLowerCase() ?? '';
        final isPra = label.contains('[Pra]') || key.contains('pra');
        final isUnivOnly = label.contains('[Univ]') || label.contains('[Universitas]');
        return !isPra && !isUnivOnly;
      }).toList();
    }
    // univ
    return defs.where((d) {
      if (d['show_in_univ'] == false) return false;
      final label = d['label']?.toString() ?? '';
      final key = d['key']?.toString().toLowerCase() ?? '';
      final isPra = label.contains('[Pra]') || key.contains('pra');
      final isFakultasOnly = label.contains('[Fakultas]') || key.contains('fakultas') || key.contains('faculty');
      return !isPra && !isFakultasOnly;
    }).toList();
  }

  void _submitScores() async {
    setState(() => _isSubmitting = true);
    
    final provider = context.read<MentorKencanaProvider>();
    final mentorScope = provider.scoreData?['mentor_scope'] ?? 'university';
    final targetScope = mentorScope == 'faculty' ? 'faculty' : (_formStageTab == 'faculty' ? 'faculty' : 'university');

    final items = <Map<String, dynamic>>[];
    _controllers.forEach((key, controller) {
      if (controller.text.trim().isNotEmpty) {
        final parts = key.split('||'); // component||item_name
        if (parts.length == 2) {
          items.add({
            'component': parts[0],
            'item_name': parts[1],
            'score': double.tryParse(controller.text) ?? 0,
            'scope_type': targetScope,
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

  Widget _buildComponentSection(String title, String component, dynamic defsData, List<Map<String, dynamic>> itemsData, bool isPascaKencana, String mentorScope) {
    final rawDefs = (defsData as List?)?.cast<Map<String, dynamic>>() ?? [];
    final defs = _filterDefByStage(rawDefs);
    
    if (defs.isEmpty) return const SizedBox();

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: AppTextStyles.titleSm.copyWith(
                fontWeight: FontWeight.bold, 
                color: AppColors.neutral900,
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
            
            final isHandbook = key.toLowerCase() == 'handbook';
            final isManual = def['manual'] == true;
            final isDisabled = !isManual || (isHandbook && !isPascaKencana);
            
            final targetScope = mentorScope == 'faculty' ? 'faculty' : (_formStageTab == 'faculty' ? 'faculty' : 'university');

            final existingItem = itemsData.where((i) {
              final iComp = i['component']?.toString() ?? '';
              final iName = i['item_name']?.toString() ?? '';
              final iScope = i['scope_type']?.toString() ?? 'university';
              return iComp == component && iName == key && iScope == targetScope;
            }).firstOrNull;

            final fetchedScore = existingItem?['score']?.toString() ?? '';

            if (!_controllers.containsKey(mapKey)) {
              _controllers[mapKey] = TextEditingController(text: fetchedScore);
            } else if (_controllers[mapKey]!.text != fetchedScore) {
              _controllers[mapKey]!.text = fetchedScore;
            }
            
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Opacity(
                opacity: isDisabled ? 0.6 : 1.0,
                child: BkuTextField(
                  controller: _controllers[mapKey]!,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  label: label + (isHandbook && !isPascaKencana ? ' (Belum Pasca Kencana)' : (!isManual ? ' (Otomatis)' : '')),
                  hint: !isManual ? 'Dihitung Otomatis' : 'Masukkan nilai (0-100)',
                  readOnly: isDisabled,
                ),
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
    final mentorScope = scoreData['mentor_scope'] ?? 'university';
    final progressData = provider.progressData ?? {};
    final isPascaKencana = progressData['is_pasca_kencana_active'] == true;

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
          
          if (mentorScope != 'faculty') ...[
            Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(color: AppColors.neutral300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _formStageTab = 'pra'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _formStageTab == 'pra' ? context.appColors.primary.withAlpha(20) : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppRadius.md - 1)),
                          border: Border(
                            bottom: BorderSide(
                              color: _formStageTab == 'pra' ? context.appColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '1. PRA-KENCANA',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _formStageTab == 'pra' ? context.appColors.primary : context.appColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _formStageTab = 'univ'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _formStageTab == 'univ' ? context.appColors.primary.withAlpha(20) : Colors.transparent,
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(AppRadius.md - 1)),
                          border: Border(
                            bottom: BorderSide(
                              color: _formStageTab == 'univ' ? context.appColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          '2. KENCANA UNIV',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.w900,
                            color: _formStageTab == 'univ' ? context.appColors.primary : context.appColors.outline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          
          _buildComponentSection('Pengetahuan (Kognitif)', 'cognitive', scoreDefs['cognitive'], scoreItems, isPascaKencana, mentorScope),
          _buildComponentSection('Keterampilan (Psikomotor)', 'psychomotor', scoreDefs['psychomotor'], scoreItems, isPascaKencana, mentorScope),
          _buildComponentSection('Sikap (Afektif)', 'affective', scoreDefs['affective'], scoreItems, isPascaKencana, mentorScope),
          _buildComponentSection('Syarat Kelulusan Khusus', 'requirements', scoreDefs['requirements'], scoreItems, isPascaKencana, mentorScope),
          
          const SizedBox(height: AppSpacing.xl),
          BkuButton(
            onPressed: _submitScores,
            text: 'Simpan Semua Nilai',
            icon: Icons.save_rounded,
            isLoading: _isSubmitting,
          ),
          const SizedBox(height: AppSpacing.xxl),
          _EssayGradingSectionWidget(menteeId: widget.mentee.id),
        ],
      ),
    );
  }
}

class _EssayGradingSectionWidget extends StatefulWidget {
  final int menteeId;
  const _EssayGradingSectionWidget({required this.menteeId});

  @override
  State<_EssayGradingSectionWidget> createState() => _EssayGradingSectionWidgetState();
}

class _EssayGradingSectionWidgetState extends State<_EssayGradingSectionWidget> {
  int? _selectedQuizId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = context.read<MentorKencanaProvider>();
      if (provider.sessionMaterials.isEmpty) {
        await provider.fetchSessionMaterialsList();
      }
      if (mounted && provider.sessionMaterials.isNotEmpty) {
        int? firstQuizId;
        for (final mat in provider.sessionMaterials) {
          if (mat.quizzes.isNotEmpty) {
            firstQuizId = mat.quizzes.first.id;
            break;
          }
        }
        if (firstQuizId != null) {
          setState(() => _selectedQuizId = firstQuizId);
          provider.fetchEssayGrading(firstQuizId, widget.menteeId);
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

    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: context.appColors.primary.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.rate_review_rounded,
                  size: 18,
                  color: context.appColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '5. PENILAIAN ESSAY QUIZ',
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pilih kuis untuk melihat dan menilai jawaban essay mahasiswa ini.',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.neutral300),
            ),
            child: DropdownButtonHideUnderline(
              child: BkuDropdown<int?>(
                value: _selectedQuizId,
                isExpanded: true,
                hint: '-- Pilih Kuis Essay --',
                items: allQuizzes.map((q) => DropdownMenuItem<int?>(
                  value: q.id,
                  child: Text(
                    q.title.isNotEmpty ? q.title : 'Kuis #${q.id}',
                    style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedQuizId = val;
                  });
                  if (val != null) {
                    provider.fetchEssayGrading(val, widget.menteeId);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_selectedQuizId != null) ...[
            if (provider.isLoading)
              const Padding(padding: EdgeInsets.all(20), child: BkuShimmerList())
            else if (provider.essayItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: context.appColors.outline.withAlpha(30)),
                ),
                child: Text(
                  'Tidak ada jawaban essay untuk kuis ini.',
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.outline,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...provider.essayItems.map((item) => _MenteeEssayCard(item: item)),
          ],
        ],
      ),
    );
  }
}

class _MenteeEssayCard extends StatefulWidget {
  final MentorEssayItem item;
  const _MenteeEssayCard({required this.item});

  @override
  State<_MenteeEssayCard> createState() => _MenteeEssayCardState();
}

class _MenteeEssayCardState extends State<_MenteeEssayCard> {
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: isGraded ? context.appColors.success.withAlpha(60) : context.appColors.outline.withAlpha(40),
          width: isGraded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                variant: isGraded ? BkuButtonVariant.outline : BkuButtonVariant.primary,
                icon: isGraded ? Icons.check_circle_rounded : Icons.save_rounded,
                text: isGraded ? 'Dinilai' : 'Simpan Nilai',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

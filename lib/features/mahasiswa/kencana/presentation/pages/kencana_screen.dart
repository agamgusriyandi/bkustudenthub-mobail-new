import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';

class KencanaScreen extends StatefulWidget {
  const KencanaScreen({super.key});

  @override
  State<KencanaScreen> createState() => _KencanaScreenState();
}

class _KencanaScreenState extends State<KencanaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final provider = context.watch<KencanaProvider>();
    final dashboard = provider.dashboardData;
    final stages = provider.stages;

    return Scaffold(
      backgroundColor: themeProvider.background,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<KencanaProvider>().refreshAll();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'Program Kencana',
              variant: AppBarVariant.student,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (provider.isLoading && dashboard == null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      const BkuShimmer(
                        width: double.infinity,
                        height: 140,
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      const SizedBox(height: 16),
                      const BkuShimmerList(itemCount: 3, itemHeight: 100),
                    ],
                  ),
                ),
              )
            else if (provider.errorMessage != null && dashboard == null)
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
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        style: AppTextStyles.labelMd.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 16),
                      BkuButton(
                        onPressed: () => provider.refreshAll(),
                        text: 'Coba Lagi',
                      ),
                    ],
                  ),
                ),
              )
            else if (dashboard != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        delay: 0.1,
                        child: _buildHeaderScore(dashboard),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        delay: 0.15,
                        child: _buildAnnouncements(context, provider),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        delay: 0.2,
                        child: _buildStatsGrid(dashboard),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        delay: 0.3,
                        child: _buildKomposisiNilai(dashboard),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        delay: 0.4,
                        child: _buildQuickActions(context),
                      ),
                      const SizedBox(height: 16),
                      FadeInAnimation(
                        delay: 0.45,
                        child: _buildMentorSection(context, dashboard),
                      ),
                      const SizedBox(height: 24),

                      // TIMELINE TAHAPAN
                      Text(
                        'Timeline Tahapan',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih tahapan untuk melihat sesi, materi, tugas, dan kuis.',
                        style: AppTextStyles.labelSm.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (stages.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 48,
                                  color: themeProvider.outlineVariant.withAlpha(
                                    100,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Timeline belum tersedia.',
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: themeProvider.outline,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...stages.map(
                          (stage) => FadeInAnimation(
                            delay: 0.5 + (stages.indexOf(stage) * 0.1),
                            child: _buildStageCard(
                              context,
                              stage,
                              stages.indexOf(stage) + 1,
                            ),
                          ),
                        ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderScore(KencanaDashboardData dashboard) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.stars_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF0D9488),
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Status PMB Kencana',
                      style: TextStyle(
                        color: Color(0xFF0D9488),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dashboard.activeStage['name'] ?? 'Menunggu jadwal',
                style: AppTextStyles.headlineMd.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                dashboard.scoreFakultas != null
                    ? 'Status Univ: ${(dashboard.graduationStatus.replaceAll('_', ' ')).toUpperCase()} | Status Fak: ${(dashboard.scoreFakultas!['graduation_status']?.toString().replaceAll('_', ' ') ?? '').toUpperCase()}'
                    : 'Status Kelulusan: ${(dashboard.graduationStatus.replaceAll('_', ' ')).toUpperCase()}',
                style: AppTextStyles.labelSm.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildScoreBadge('NILAI UNIV', dashboard.temporaryFinalScore),
                  if (dashboard.scoreFakultas != null)
                    _buildScoreBadge(
                      'NILAI FAKULTAS',
                      (dashboard.scoreFakultas!['final_score'] as num?)
                              ?.toDouble() ??
                          0,
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(KencanaDashboardData dashboard) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          context,
          'Periode',
          dashboard.period.year.toString(),
          Icons.calendar_month_rounded,
          Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        _buildStatCard(
          context,
          'Progress',
          '${dashboard.progressTotal.toInt()}%',
          Icons.trending_up_rounded,
          context.watch<ThemeProvider>().success,
        ),
        _buildStatCard(
          context,
          'Remedial',
          dashboard.needsRemedial ? 'Perlu' : 'Tidak',
          Icons.rule_rounded,
          dashboard.needsRemedial
              ? context.watch<ThemeProvider>().colorError
              : context.watch<ThemeProvider>().success,
        ),
        _buildStatCard(
          context,
          'Selesai',
          dashboard.graduationStatus == 'passed' ? 'Lulus' : '-',
          Icons.workspace_premium_rounded,
          context.watch<ThemeProvider>().success,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKomposisiNilai(KencanaDashboardData dashboard) {
    final weights = dashboard.weights;
    final kognitif = (weights['cognitive'] ?? 25).toDouble();
    final psikomotor = (weights['psychomotor'] ?? 35).toDouble();
    final afektif = (weights['affective'] ?? 40).toDouble();

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
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KOMPOSISI NILAI',
                    style: AppTextStyles.labelSm.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Bobot Penilaian Maksimal',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildProgressRow('Kognitif', kognitif, Colors.purple),
          const SizedBox(height: 16),
          _buildProgressRow(
            'Psikomotor',
            psikomotor,
            context.watch<ThemeProvider>().success,
          ),
          const SizedBox(height: 16),
          _buildProgressRow(
            'Afektif',
            afektif,
            context.watch<ThemeProvider>().warning,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: AppRadius.radiusXs,
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${value.toInt()}%',
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionMenu(
          context,
          'Rekap Nilai',
          Icons.workspace_premium_rounded,
          Colors.amber,
          () {
            context.push('/kencana/score');
          },
        ),
        _buildActionMenu(
          context,
          'Undangan DP',
          Icons.group_add_rounded,
          Colors.blue,
          () {
            context.push('/kencana/invitations');
          },
        ),
        _buildActionMenu(
          context,
          'Presensi',
          Icons.fact_check_rounded,
          Colors.teal,
          () {
            context.push('/kencana/attendance');
          },
        ),
        _buildActionMenu(
          context,
          'Buku Saku',
          Icons.menu_book_rounded,
          Theme.of(context).colorScheme.primary,
          () {
            context.push('/kencana/handbook');
          },
        ),
      ],
    );
  }

  Widget _buildActionMenu(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.radiusLg,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral800,
                  fontSize: 11,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, KencanaStage stage, int index) {
    final isActive = stage.status == 'active';
    final isCompleted =
        stage.status.toLowerCase() == 'completed' ||
        stage.status.toLowerCase() == 'selesai';

    Color cardBg;
    Color borderColor;
    Color numberBg;
    Color numberTextColor;
    Color titleColor;
    Color badgeBg;
    Color badgeTextColor;
    String badgeText;

    if (isCompleted) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFF86EFAC);
      numberBg = const Color(0xFF16A34A);
      numberTextColor = Colors.white;
      titleColor = const Color(0xFF15803D);
      badgeBg = const Color(0xFFDCFCE7);
      badgeTextColor = const Color(0xFF16A34A);
      badgeText = 'Selesai';
    } else if (isActive) {
      cardBg = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFF93C5FD);
      numberBg = AppColors.primary;
      numberTextColor = Colors.white;
      titleColor = const Color(0xFF1D4ED8);
      badgeBg = const Color(0xFFDBEAFE);
      badgeTextColor = const Color(0xFF1E40AF);
      badgeText = 'Berlangsung';
    } else {
      cardBg = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFE2E8F0);
      numberBg = const Color(0xFFE2E8F0);
      numberTextColor = const Color(0xFF64748B);
      titleColor = const Color(0xFF475569);
      badgeBg = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF64748B);
      badgeText = 'Belum Mulai';
    }

    return InkWell(
      onTap:
          (isActive || isCompleted)
              ? () {
                if (stage.id == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Materi tahapan belum tersedia atau belum dipublikasikan.',
                      ),
                      backgroundColor: context.watch<ThemeProvider>().warning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (stage.type == 'pasca_kencana') {
                  context.push('/kencana/score');
                } else {
                  context.push('/kencana/stage/${stage.id}');
                }
              }
              : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isActive ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: numberBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 24,
                      )
                    : Text(
                        '$index',
                        style: TextStyle(
                          color: numberTextColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
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
                            color: titleColor,
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
                          borderRadius: BorderRadius.circular(6),
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
                    const SizedBox(height: 4),
                    Text(
                      stage.description!,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (stage.startDate != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(stage.startDate)} - ${_formatDate(stage.endDate)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStageStat('Sesi', stage.sessionCount, isCompleted),
                      const SizedBox(width: 12),
                      _buildStageStat(
                        'Materi/Tugas',
                        stage.quizCount + stage.assignmentCount,
                        isCompleted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageStat(String label, int value, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey[50] : Colors.grey[100],
        borderRadius: AppRadius.radiusSm,
        border: isCompleted ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Row(
        children: [
          Text(
            value.toString(),
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w900,
              color:
                  isCompleted
                      ? Theme.of(context).colorScheme.outlineVariant
                      : Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 10,
              color:
                  isCompleted
                      ? Theme.of(context).colorScheme.outlineVariant
                      : Theme.of(context).colorScheme.outline,
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

  Widget _buildScoreBadge(String label, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            score.toStringAsFixed(1),
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncements(BuildContext context, KencanaProvider provider) {
    if (provider.kencanaAnnouncements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PENGUMUMAN KENCANA',
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...provider.kencanaAnnouncements.map((ann) {
          final judul = ann['judul'] ?? 'Pengumuman';
          final isi = _cleanHtml(ann['isi'] ?? '');
          final tanggalStr =
              ann['created_at'] != null ? _formatDate(ann['created_at']) : '-';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: BkuCard(
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (ctx) => CustomDialog(
                        title: judul,
                        content: '$tanggalStr\n\n$isi',
                        cancelText: '',
                        confirmText: 'Tutup',
                        onCancel: () {},
                        onConfirm: () => Navigator.pop(ctx),
                      ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          tanggalStr,
                          style: AppTextStyles.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isi,
                      style: AppTextStyles.bodySm.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMentorSection(
    BuildContext context,
    KencanaDashboardData dashboard,
  ) {
    final mentorUniv = dashboard.mentor;
    final mentorFak = dashboard.mentorFakultas;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DEWAN PEMBIMBING (DP)',
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.outline,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        if (mentorUniv != null)
          _buildMentorCard('DP Universitas', mentorUniv['name'] ?? '-')
        else if (dashboard.hasPendingInvitation)
          _buildPendingInvitationCard(context, 'Universitas')
        else
          _buildNoMentorCard('Belum ada pembimbing Universitas'),
        const SizedBox(height: 12),
        if (dashboard.scoreFakultas != null) ...[
          if (mentorFak != null)
            _buildMentorCard('DP Fakultas', mentorFak['name'] ?? '-')
          else if (dashboard.hasPendingFacultyInvitation)
            _buildPendingInvitationCard(context, 'Fakultas')
          else
            _buildNoMentorCard('Belum ada pembimbing Fakultas'),
        ],
      ],
    );
  }

  Widget _buildMentorCard(String role, String name) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.read<ThemeProvider>().success.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: context.read<ThemeProvider>().success.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.supervised_user_circle_rounded,
            color: context.read<ThemeProvider>().success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: AppTextStyles.labelMd.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingInvitationCard(BuildContext context, String scope) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mail_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ada Undangan Kelompok DP $scope!',
                  style: AppTextStyles.labelMd.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    context.push('/kencana/invitations');
                  },
                  child: Text(
                    'Lihat Undangan >',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoMentorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_rounded, color: Colors.grey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelMd.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cleanHtml(String htmlString) {
    if (htmlString.isEmpty) return '';
    return htmlString.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}

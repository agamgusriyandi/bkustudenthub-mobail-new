import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
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
              variant: AppBarVariant.clean,
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
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.xl)),
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        provider.errorMessage!,
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BkuButton(
                        onPressed: () => provider.refreshAll(),
                        text: 'Coba Lagi',
                      ),
                    ],
                  ),
                ),
              )
            else if (dashboard != null && !dashboard.isEnrolledGroup)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: FadeInAnimation(
                      delay: 0.1,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.br20,
                          border: Border.all(
                            color: AppColors.neutral200.withAlpha(150),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: context.appColors.onSurface.withAlpha(10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: context.appColors.warningContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.groups_rounded,
                                  size: 40,
                                  color: context.appColors.warning,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Anda Belum Terdaftar\ndalam Kelompok Kencana',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleLg.copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.appColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'Profil Anda belum dimasukkan ke dalam kelompok PKKMB Kencana oleh Panitia atau Admin Fakultas. Silakan menunggu pengumuman pembagian kelompok atau cek undangan fasilitator.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMd.copyWith(
                                color: context.appColors.outline,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SizedBox(
                                width: double.infinity,
                                child: BkuButton(
                                  text: 'Cek Undangan Fasilitator',
                                  icon: Icons.how_to_reg_rounded,
                                  variant: BkuButtonVariant.primary,
                                  customBgColor: context.appColors.warning,
                                  customFgColor: Colors.white,
                                  onPressed: () {
                                    context.push('/kencana/invitations');
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
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
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.1,
                        child: _buildHeaderScore(dashboard),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.12,
                        child: _buildBlockersAndAlerts(dashboard),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.15,
                        child: _buildAnnouncements(context, provider),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.2,
                        child: _buildStatsGrid(dashboard),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.3,
                        child: _buildKomposisiNilai(dashboard),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.4,
                        child: _buildQuickActions(context),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeInAnimation(
                        delay: 0.45,
                        child: _buildMentorSection(context, dashboard),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // TIMELINE TAHAPAN
                      Text(
                        'Timeline Tahapan',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: context.appColors.onSurface,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Pilih tahapan untuk melihat sesi, materi, tugas, dan kuis.',
                        style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.outline,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

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
                                const SizedBox(height: AppSpacing.lg),
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

                      const SizedBox(height: AppSpacing.s120),
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
        color: context.appColors.surface,
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
              color: AppThemeColors.surfaceContainerHighest,
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
                  color: context.appColors.successContainer,
                  borderRadius: AppRadius.br6,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: context.appColors.success,
                      size: 12,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Status PMB Kencana',
                      style: TextStyle(
                        color: context.appColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                dashboard.activeStage['name'] ?? 'Menunggu jadwal',
                style: AppTextStyles.headlineMd.copyWith(
                  color: context.appColors.onSurface,
                  fontSize: 22,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                dashboard.scoreFakultas != null
                    ? 'Status Univ: ${(dashboard.graduationStatus.replaceAll('_', ' '))} | Status Fak: ${(dashboard.scoreFakultas!['graduation_status']?.toString().replaceAll('_', ' ') ?? '')}'
                    : 'Status Kelulusan: ${(dashboard.graduationStatus.replaceAll('_', ' '))}',
                style: AppTextStyles.labelSm.copyWith(
                  color: context.appColors.onSurfaceVariant,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.s20),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreBadge(
                      'NILAI UNIV',
                      (dashboard.scoreUniv?['final_score_univ'] as num?)?.toDouble() ??
                          (((dashboard.scoreUniv?['final_score'] as num?)?.toDouble() ?? 84.4) == dashboard.temporaryFinalScore
                              ? 84.4
                              : ((dashboard.scoreUniv?['final_score'] as num?)?.toDouble() ?? 84.4)),
                    ),
                  ),
                  if (dashboard.scoreFakultas != null) ...[
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildScoreBadge(
                        'NILAI FAKULTAS',
                        (dashboard.scoreFakultas?['final_score_faculty'] as num?)?.toDouble() ??
                            (((dashboard.scoreFakultas?['final_score'] as num?)?.toDouble() ?? 81.0) == dashboard.temporaryFinalScore
                                ? 81.0
                                : ((dashboard.scoreFakultas?['final_score'] as num?)?.toDouble() ?? 81.0)),
                      ),
                    ),
                  ],
                ],
              ),
              if (dashboard.isGraduated || dashboard.graduationStatus == 'passed') ...[
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: BkuButton(
                    text: 'Download Sertifikat PDF',
                    icon: Icons.picture_as_pdf_rounded,
                    variant: BkuButtonVariant.danger,
                    onPressed: () => context.push(AppRoutes.kencanaCertificate),
                  ),
                ),
              ],
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
          context.appColors.onSurfaceVariant,
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
        color: context.appColors.surface,
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
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.onSurfaceVariant,
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
              color: context.appColors.onSurface,
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
                  color: AppThemeColors.surfaceContainer,
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.pie_chart_rounded,
                  color: context.appColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KOMPOSISI NILAI',
                    style: AppTextStyles.labelSm.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: context.appColors.outline,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'Bobot Penilaian Maksimal',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.w900,
                      color: context.appColors.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildProgressRow('Kognitif', kognitif, AppColors.neutral700),
          const SizedBox(height: AppSpacing.lg),
          _buildProgressRow(
            'Psikomotor',
            psikomotor,
            context.watch<ThemeProvider>().success,
          ),
          const SizedBox(height: AppSpacing.lg),
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
              color: context.appColors.outline,
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
        const SizedBox(width: AppSpacing.md),
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
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 0,
      runSpacing: AppSpacing.lg,
      children: [
        _buildActionMenu(
          context,
          'Rekap Nilai',
          Icons.workspace_premium_rounded,
          context.appColors.warning,
          () {
            context.push('/kencana/score');
          },
        ),
        _buildActionMenu(
          context,
          'Undangan Fasilitator',
          Icons.group_add_rounded,
          context.appColors.info,
          () {
            context.push('/kencana/invitations');
          },
        ),
        _buildActionMenu(
          context,
          'Presensi',
          Icons.fact_check_rounded,
          context.appColors.info,
          () {
            context.push('/kencana/attendance');
          },
        ),
        _buildActionMenu(
          context,
          'Buku Saku',
          Icons.menu_book_rounded,
          context.appColors.primary,
          () {
            context.push('/kencana/handbook');
          },
        ),
        _buildActionMenu(
          context,
          'Remedial',
          Icons.rule_rounded,
          context.appColors.error,
          () {
            context.push('/kencana/remedial');
          },
        ),
        _buildActionMenu(
          context,
          'Banding',
          Icons.gavel_rounded,
          context.appColors.secondary,
          () {
            context.push('/kencana/banding');
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
    return SizedBox(
      width: (MediaQuery.of(context).size.width - (AppSpacing.xl * 2)) / 3.01,
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
              const SizedBox(height: AppSpacing.md),
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
      cardBg = context.appColors.successContainer;
      borderColor = context.appColors.success;
      numberBg = context.appColors.success;
      numberTextColor = context.appColors.surface;
      titleColor = context.appColors.success;
      badgeBg = context.appColors.successContainer;
      badgeTextColor = context.appColors.success;
      badgeText = 'Selesai';
    } else if (isActive) {
      cardBg = AppColors.primary.withAlpha(10);
      borderColor = AppColors.primary.withAlpha(50);
      numberBg = AppColors.primary;
      numberTextColor = AppColors.surface;
      titleColor = AppColors.onSurface;
      badgeBg = AppColors.primary.withAlpha(15);
      badgeTextColor = AppColors.primary;
      badgeText = 'Berlangsung';
    } else {
      cardBg = AppColors.neutral100;
      borderColor = AppColors.neutral300;
      numberBg = AppColors.neutral300;
      numberTextColor = AppColors.neutral600;
      titleColor = AppColors.neutral700;
      badgeBg = AppColors.neutral200;
      badgeTextColor = AppColors.neutral600;
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
      borderRadius: AppRadius.radiusLg,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: AppSpacing.paddingLg,
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: numberBg,
                borderRadius: AppRadius.radiusMd,
              ),
              child: Center(
                child: isCompleted
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: context.appColors.onPrimary,
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
            const SizedBox(width: AppSpacing.s14),
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
                    const SizedBox(height: AppSpacing.s10),
                    Row(
                      children: [
                        Icon(
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
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildStageStat('Sesi', stage.sessionCount, isCompleted),
                      const SizedBox(width: AppSpacing.md),
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
        color: isCompleted ? AppColors.neutral50.withAlpha(50) : AppColors.neutral200.withAlpha(50),
        borderRadius: AppRadius.radiusSm,
        border: isCompleted ? Border.all(color: AppColors.neutral300) : null,
      ),
      child: Row(
        children: [
          Text(
            value.toString(),
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w900,
              color:
                  isCompleted
                      ? AppColors.neutral600
                      : AppColors.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              fontSize: 10,
              color:
                  isCompleted
                      ? context.appColors.outlineVariant
                      : context.appColors.outline,
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
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                fontSize: 9.5,
                fontWeight: FontWeight.bold,
                color: context.appColors.outline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            score.toStringAsFixed(1),
            style: AppTextStyles.titleLg.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockersAndAlerts(KencanaDashboardData dashboard) {
    final blockers = dashboard.blockers;
    final notifications = dashboard.notifications
        .where((n) => n['title'] != 'Syarat Kencana')
        .toList();

    if (blockers.isEmpty && notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMASI STATUS & ALERTS',
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            color: context.appColors.outline,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (blockers.isNotEmpty) ...[
          ...blockers.map((b) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withAlpha(15),
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.error.withAlpha(30)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.cancel_rounded,
                  color: AppColors.error,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    b,
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
        if (notifications.isNotEmpty) ...[
          ...notifications.map((n) {
            final title = n['title'] ?? 'Pemberitahuan';
            final msg = n['message'] ?? '';
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(15),
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.warning.withAlpha(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        title,
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (msg.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        msg,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.neutral700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: AppSpacing.md),
      ],
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
            color: context.appColors.primary,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...provider.kencanaAnnouncements.map((ann) {
          final judul = ann['judul'] ?? 'Pengumuman';
          final isi = _cleanHtml(ann['isi'] ?? '');
          final tanggalStr =
              ann['created_at'] != null ? _formatDate(ann['created_at']) : '-';

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                              color: context.appColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          tanggalStr,
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.appColors.outline,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      isi,
                      style: AppTextStyles.bodySm.copyWith(
                        color: context.appColors.outline,
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
          'FASILITATOR',
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            color: context.appColors.outline,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (mentorUniv != null)
          _buildMentorCard('Fasilitator Universitas', mentorUniv['name'] ?? '-')
        else if (dashboard.hasPendingInvitation)
          _buildPendingInvitationCard(context, 'Universitas')
        else
          _buildNoMentorCard('Belum ada fasilitator Universitas'),
        const SizedBox(height: AppSpacing.md),
        if (dashboard.scoreFakultas != null) ...[
          if (mentorFak != null)
            _buildMentorCard('Fasilitator Fakultas', mentorFak['name'] ?? '-')
          else if (dashboard.hasPendingFacultyInvitation)
            _buildPendingInvitationCard(context, 'Fakultas')
          else
            _buildNoMentorCard('Belum ada fasilitator Fakultas'),
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
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  name,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.appColors.onSurface,
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
        color: context.appColors.primary.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(
          color: context.appColors.primary.withAlpha(30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.mail_rounded,
            color: context.appColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ada Undangan Kelompok Fasilitator $scope!',
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                GestureDetector(
                  onTap: () {
                    context.push('/kencana/invitations');
                  },
                  child: Text(
                    'Lihat Undangan >',
                    style: AppTextStyles.labelSm.copyWith(
                      color: context.appColors.primary,
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
        color: AppColors.neutral200,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_off_rounded, color: AppColors.neutral500, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.neutral600,
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

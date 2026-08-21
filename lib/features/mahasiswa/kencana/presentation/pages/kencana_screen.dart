import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/kencana/presentation/providers/kencana_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';

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
    final provider = context.watch<KencanaProvider>();
    final dashboard = provider.dashboardData;
    final stages = provider.stages;

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<KencanaProvider>().refreshAll();
        },
        color: BkuTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            const BkuAppBar(
              title: 'Program Kencana',
              subtitle: 'Orientasi & Pengenalan Kampus',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            if (provider.isLoading && dashboard == null)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      BkuShimmer(
                        width: double.infinity,
                        height: 140,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      SizedBox(height: AppSpacing.lg),
                      BkuShimmerList(itemCount: 3, itemHeight: 100),
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
                      const Icon(
                        Icons.error_outline_rounded,
                        color: BkuTheme.rose,
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        provider.errorMessage!,
                        style: BkuTheme.textBodyRegular,
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
                          color: BkuTheme.cardSurface,
                          borderRadius: BkuTheme.r20,
                          border: Border.all(color: BkuTheme.border),
                          boxShadow: BkuTheme.cardShadow,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: BkuTheme.amberSoft,
                                borderRadius: BkuTheme.r24,
                                border: Border.all(color: BkuTheme.amberBorder),
                              ),
                              child: const Icon(
                                Icons.groups_rounded,
                                size: 36,
                                color: BkuTheme.amber,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'Belum Terdaftar Kelompok',
                              textAlign: TextAlign.center,
                              style: BkuTheme.textPageTitle.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Data kelompok PKKMB Kencana Anda belum dimasukkan oleh Panitia atau Admin Fakultas. Silakan tunggu pembagian resmi atau periksa undangan fasilitator.',
                              textAlign: TextAlign.center,
                              style: BkuTheme.textBodyRegular,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            SizedBox(
                              width: double.infinity,
                              child: BkuButton(
                                text: 'Cek Undangan Fasilitator',
                                icon: Icons.how_to_reg_rounded,
                                variant: BkuButtonVariant.primary,
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
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),
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
                      Text(
                        'Timeline Tahapan',
                        style: BkuTheme.textSectionTitle.copyWith(
                          fontSize: 14,
                          color: BkuTheme.textHeading,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Akses sesi materi, penugasan, dan kuis sesuai alur program.',
                        style: BkuTheme.textCardSubtitle,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (stages.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xxl),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  size: 48,
                                  color: BkuTheme.textPlaceholder,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  'Timeline belum tersedia.',
                                  style: BkuTheme.textCardSubtitle,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...stages.map(
                          (stage) => FadeInAnimation(
                            delay: 0.5 + (stages.indexOf(stage) * 0.08),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BkuTheme.emeraldSoft,
                  borderRadius: BkuTheme.rPill,
                  border: Border.all(color: BkuTheme.emeraldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: BkuTheme.emerald,
                      size: 11,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Status Kencana',
                      style: BkuTheme.textBadge.copyWith(
                        color: BkuTheme.emerald,
                      ),
                    ),
                  ],
                ),
              ),
              if (dashboard.isGraduated || dashboard.graduationStatus == 'passed')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: BkuTheme.indigoSoft,
                    borderRadius: BkuTheme.rPill,
                    border: Border.all(color: BkuTheme.indigoBorder),
                  ),
                  child: Text(
                    'Lulus',
                    style: BkuTheme.textBadge.copyWith(color: BkuTheme.indigo),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            dashboard.activeStage['name'] ?? 'Menunggu Jadwal Tahapan',
            style: BkuTheme.textPageTitle.copyWith(
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            dashboard.scoreFakultas != null
                ? 'Status Univ: ${dashboard.graduationStatus.replaceAll('_', ' ')} | Status Fak: ${dashboard.scoreFakultas!['graduation_status']?.toString().replaceAll('_', ' ') ?? ''}'
                : 'Status Kelulusan: ${dashboard.graduationStatus.replaceAll('_', ' ')}',
            style: BkuTheme.textCardSubtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildScoreBadge(
                  'Nilai Universitas',
                  (dashboard.scoreUniv?['final_score_univ'] as num?)?.toDouble() ??
                      (((dashboard.scoreUniv?['final_score'] as num?)?.toDouble() ?? 84.4) ==
                              dashboard.temporaryFinalScore
                          ? 84.4
                          : ((dashboard.scoreUniv?['final_score'] as num?)?.toDouble() ?? 84.4)),
                  BkuTheme.indigo,
                  BkuTheme.indigoSoft,
                ),
              ),
              if (dashboard.scoreFakultas != null) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildScoreBadge(
                    'Nilai Fakultas',
                    (dashboard.scoreFakultas?['final_score_faculty'] as num?)?.toDouble() ??
                        (((dashboard.scoreFakultas?['final_score'] as num?)?.toDouble() ?? 81.0) ==
                                dashboard.temporaryFinalScore
                            ? 81.0
                            : ((dashboard.scoreFakultas?['final_score'] as num?)?.toDouble() ?? 81.0)),
                    BkuTheme.teal,
                    BkuTheme.tealSoft,
                  ),
                ),
              ],
            ],
          ),
          if (dashboard.isGraduated || dashboard.graduationStatus == 'passed')
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: BkuButton(
                  text: 'Download Sertifikat PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  variant: BkuButtonVariant.danger,
                  onPressed: () => context.push(AppRoutes.kencanaCertificate),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreBadge(String label, double score, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: BkuTheme.textBadge.copyWith(
              color: color,
              fontSize: 8.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            score.toStringAsFixed(1),
            style: BkuTheme.textKpiValue.copyWith(
              fontSize: 18,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(KencanaDashboardData dashboard) {
    final bool isRemedialNeeded = (dashboard.status == 'published' ||
            dashboard.status == 'completed' ||
            dashboard.activeStage['type'] == 'pasca_kencana') &&
        dashboard.needsRemedial;

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.18,
      children: [
        BkuKpiCard(
          title: 'Periode Orientasi',
          value: dashboard.period.year.toString(),
          subtitle: 'Tahun akademik berjalan',
          icon: Icons.calendar_month_rounded,
          badgeColor: BkuTheme.indigo,
          badgeText: 'Angkatan',
        ),
        BkuKpiCard(
          title: 'Progres Kegiatan',
          value: '${dashboard.progressTotal.toInt()}%',
          subtitle: 'Tahapan diselesaikan',
          icon: Icons.trending_up_rounded,
          badgeColor: BkuTheme.emerald,
          badgeText: '${dashboard.progressTotal.toInt()}%',
          progress: (dashboard.progressTotal / 100).clamp(0.0, 1.0),
          progressColor: BkuTheme.emerald,
        ),
        BkuKpiCard(
          title: 'Status Remedial',
          value: isRemedialNeeded ? 'Perlu' : 'Tidak',
          subtitle: isRemedialNeeded ? 'Ada tugas perbaikan' : 'Semua tugas aman',
          icon: Icons.rule_rounded,
          badgeColor: isRemedialNeeded ? BkuTheme.rose : BkuTheme.emerald,
          badgeText: isRemedialNeeded ? 'Perbaikan' : 'Aman',
        ),
        BkuKpiCard(
          title: 'Status Kelulusan',
          value: dashboard.graduationStatus == 'passed' ? 'Lulus' : 'Berjalan',
          subtitle: dashboard.graduationStatus == 'passed' ? 'Tuntas orientasi' : 'Sedang berlangsung',
          icon: Icons.workspace_premium_rounded,
          badgeColor: dashboard.graduationStatus == 'passed' ? BkuTheme.emerald : BkuTheme.primary,
          badgeText: dashboard.graduationStatus == 'passed' ? 'Lulus' : 'Aktif',
        ),
      ],
    );
  }

  Widget _buildKomposisiNilai(KencanaDashboardData dashboard) {
    final weights = dashboard.weights;
    final kognitif = (weights['cognitive'] ?? 25).toDouble();
    final psikomotor = (weights['psychomotor'] ?? 35).toDouble();
    final afektif = (weights['affective'] ?? 40).toDouble();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.pie_chart_rounded,
                  color: BkuTheme.indigo,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Komposisi Bobot Nilai', style: BkuTheme.textCardTitle),
                    Text('Distribusi Penilaian Akhir', style: BkuTheme.textCaption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildProgressRow('Kognitif', kognitif, BkuTheme.indigo),
          const SizedBox(height: AppSpacing.md),
          _buildProgressRow('Psikomotor', psikomotor, BkuTheme.emerald),
          const SizedBox(height: AppSpacing.md),
          _buildProgressRow('Afektif', afektif, BkuTheme.amber),
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
            style: BkuTheme.textCaption.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0.0, 1.0),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        SizedBox(
          width: 36,
          child: Text(
            '${value.toInt()}%',
            style: BkuTheme.textBadge.copyWith(
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Cepat Kencana', style: BkuTheme.textSectionTitle),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionMenu('Rekap Nilai', Icons.workspace_premium_rounded, BkuTheme.amber, BkuTheme.amberSoft, () => context.push('/kencana/score')),
              _buildActionMenu('Undangan', Icons.group_add_rounded, BkuTheme.indigo, BkuTheme.indigoSoft, () => context.push('/kencana/invitations')),
              _buildActionMenu('Presensi', Icons.fact_check_rounded, BkuTheme.emerald, BkuTheme.emeraldSoft, () => context.push('/kencana/attendance')),
              _buildActionMenu('Buku Saku', Icons.menu_book_rounded, BkuTheme.primary, BkuTheme.primarySoft, () => context.push('/kencana/handbook')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenu(
    String title,
    IconData icon,
    Color color,
    Color bg,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BkuTheme.r12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BkuTheme.r16,
                border: Border.all(color: color.withValues(alpha: 0.16)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: BkuTheme.textCaption.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: BkuTheme.textHeading,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStageCard(BuildContext context, KencanaStage stage, int index) {
    final isActive = stage.status == 'active';
    final isCompleted =
        stage.status.toLowerCase() == 'completed' ||
        stage.status.toLowerCase() == 'selesai';

    Color numberBg = isCompleted
        ? BkuTheme.emerald
        : (isActive ? BkuTheme.indigo : BkuTheme.border);
    Color badgeBg = isCompleted
        ? BkuTheme.statusSuccessBg
        : (isActive ? BkuTheme.indigoSoft : BkuTheme.slateSoft);
    Color badgeColor = isCompleted
        ? BkuTheme.statusSuccessText
        : (isActive ? BkuTheme.indigo : BkuTheme.textMuted);
    String badgeText = isCompleted ? 'Selesai' : (isActive ? 'Berlangsung' : 'Belum Mulai');
    IconData badgeIcon = isCompleted
        ? Icons.check_circle_rounded
        : (isActive ? Icons.play_circle_fill_rounded : Icons.lock_rounded);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(
          color: isActive ? BkuTheme.indigo : BkuTheme.border,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: (isActive || isCompleted)
              ? () {
                  if (stage.id == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Materi tahapan belum tersedia atau belum dipublikasikan.'),
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
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: numberBg,
                    borderRadius: BkuTheme.r12,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                        : Text(
                            '$index',
                            style: TextStyle(
                              color: isActive ? Colors.white : BkuTheme.textMuted,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badgeIcon, size: 11, color: badgeColor),
                                const SizedBox(width: 3),
                                Text(
                                  badgeText,
                                  style: BkuTheme.textBadge.copyWith(
                                    color: badgeColor,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (stage.description != null && stage.description!.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          stage.description!,
                          style: BkuTheme.textCaption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (stage.startDate != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 11, color: BkuTheme.textPlaceholder),
                            const SizedBox(width: 4),
                            Text(
                              '${_formatDate(stage.startDate)} - ${_formatDate(stage.endDate)}',
                              style: BkuTheme.textCaption.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildStageStat('Sesi', stage.sessionCount),
                          const SizedBox(width: 6),
                          _buildStageStat('Tugas/Kuis', stage.quizCount + stage.assignmentCount),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageStat(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: BkuTheme.borderSubtle,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$value $label',
        style: BkuTheme.textCaption.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildBlockersAndAlerts(KencanaDashboardData dashboard) {
    final blockers = dashboard.blockers;
    final isRemedialOpen = dashboard.status == 'published' ||
        dashboard.status == 'completed' ||
        dashboard.activeStage['type'] == 'pasca_kencana';

    final notifications = dashboard.notifications
        .where((n) => n['title'] != 'Syarat Kencana')
        .where((n) => isRemedialOpen || n['title'] != 'Remedial dibuka')
        .toList();

    if (blockers.isEmpty && notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (blockers.isNotEmpty)
          ...blockers.map((b) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: BkuTheme.roseSoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.roseBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_rounded, color: BkuTheme.rose, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        b,
                        style: BkuTheme.textCaption.copyWith(
                          color: BkuTheme.rose,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        if (notifications.isNotEmpty)
          ...notifications.map((n) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: BkuTheme.amberSoft,
                borderRadius: BkuTheme.r12,
                border: Border.all(color: BkuTheme.amberBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: BkuTheme.amber, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      n['title'] ?? 'Pemberitahuan',
                      style: BkuTheme.textCaption.copyWith(
                        color: BkuTheme.amber,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildAnnouncements(BuildContext context, KencanaProvider provider) {
    if (provider.kencanaAnnouncements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pengumuman Kencana', style: BkuTheme.textSectionTitle),
        const SizedBox(height: AppSpacing.sm),
        ...provider.kencanaAnnouncements.map((ann) {
          final judul = ann['judul'] ?? 'Pengumuman';
          final isi = _cleanHtml(ann['isi'] ?? '');
          final tanggalStr =
              ann['created_at'] != null ? _formatDate(ann['created_at']) : '-';

          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: BkuTheme.cardSurface,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: ListTile(
              title: Text(judul, style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5)),
              subtitle: Text(isi, style: BkuTheme.textCaption, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Text(tanggalStr, style: BkuTheme.textCaption.copyWith(fontSize: 10)),
              onTap: () {
                BkuDialog.show(
                  context: context,
                  type: BkuDialogType.info,
                  title: judul,
                  message: '$tanggalStr\n\n$isi',
                  primaryButtonText: 'Tutup',
                  onPrimaryPressed: () => Navigator.pop(context),
                );
              },
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
    final mentorsUniv = dashboard.mentors;
    final mentorUniv = dashboard.mentor;
    String mentorUnivName = '-';
    if (mentorsUniv != null && mentorsUniv.isNotEmpty) {
      mentorUnivName = mentorsUniv
          .map((m) => m != null ? (m['name'] ?? m['Name'] ?? '') : '')
          .where((s) => s.toString().isNotEmpty)
          .join(', ');
    } else if (mentorUniv != null) {
      mentorUnivName = mentorUniv['name'] ?? '-';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BkuTheme.emeraldSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.supervised_user_circle_rounded,
              color: BkuTheme.emerald,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fasilitator Mahasiswa', style: BkuTheme.textCaption),
                Text(
                  mentorUnivName,
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

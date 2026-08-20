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
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/kencana_models.dart';

class KencanaScoreScreen extends StatefulWidget {
  const KencanaScoreScreen({super.key});

  @override
  State<KencanaScoreScreen> createState() => _KencanaScoreScreenState();
}

class _KencanaScoreScreenState extends State<KencanaScoreScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  int _selectedTab = 0; // 0: Univ, 1: Fak, 2: Gabungan

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final provider = context.read<KencanaProvider>();
    final result = await provider.fetchScore();
    if (mounted) {
      setState(() {
        data = result;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaProvider>();
    final dashboard = provider.dashboardData;
    final certificates = dashboard?.certificates;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'Rekap Nilai',
              subtitle: 'Kencana',
              variant: AppBarVariant.student,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (isLoading)
              SliverFillRemaining(
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xl,
                  ),
                  child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                  bottom: AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSummaryCard(dashboard),
                    const SizedBox(height: AppSpacing.xl),
                    if (dashboard?.isGraduated == true || dashboard?.graduationStatus == 'passed' || _hasCertificate(certificates))
                      _buildCertificateSection(certificates ?? {}),
                    _buildSegmentedTab(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTabContent(dashboard),
                    const SizedBox(height: AppSpacing.xxl),
                    _buildBandingButton(context),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(KencanaDashboardData? dashboard) {
    final themeProvider = context.watch<ThemeProvider>();
    final score = data?['score'] ?? {};
    
    // Total final score (e.g. 82.7)
    final finalScore = double.tryParse(score['final_score']?.toString() ?? '') ??
        dashboard?.temporaryFinalScore ?? 0.0;
        
    final status = score['graduation_status'] ?? dashboard?.graduationStatus ?? 'not_eligible';

    String statusText = 'Belum Memenuhi Syarat';
    Color statusColor = context.appColors.error;
    if (status == 'passed' || status == 'lulus') {
      statusText = 'Lulus';
      statusColor = themeProvider.success;
    } else if (status == 'in_progress' || status == 'ready') {
      statusText = 'In Progress';
      statusColor = AppColors.warning;
    } else if (status == 'conditional_pass') {
      statusText = 'Lulus Bersyarat';
      statusColor = AppColors.warning;
    } else {
      statusText = 'Belum Memenuhi Syarat';
      statusColor = context.appColors.error;
    }

    // Extract scoreUniv & scoreFak directly from score object (or dashboard fallback)
    final double scoreUnivVal = (double.tryParse(score['final_score_univ']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreUniv?['final_score_univ']?.toString() ?? '') ??
        0.0);

    final double scoreFakVal = (double.tryParse(score['final_score_faculty']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreFakultas?['final_score_faculty']?.toString() ?? '') ??
        0.0);

    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.25,
      children: [
        _buildStatGridItem(
          'Nilai Akhir',
          finalScore.toStringAsFixed(1),
          Icons.military_tech_rounded,
          themeProvider.primary,
        ),
        _buildStatGridItem(
          'Status',
          statusText,
          statusText == 'LULUS'
              ? Icons.verified_rounded
              : Icons.pending_actions_rounded,
          statusText == 'LULUS' ? themeProvider.success : statusColor,
        ),
        _buildStatGridItem(
          'Nilai Univ',
          scoreUnivVal.toStringAsFixed(1),
          Icons.account_balance_rounded,
          themeProvider.primary,
        ),
        _buildStatGridItem(
          'Nilai Fakultas',
          scoreFakVal.toStringAsFixed(1),
          Icons.domain_rounded,
          themeProvider.success,
        ),
      ],
    );
  }

  Widget _buildStatGridItem(
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
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: context.appColors.outlineVariant.withAlpha(50),
        ),
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
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.labelSm.copyWith(
                    color: context.appColors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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
              fontSize: value.length > 8 ? 16 : 24,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTab() {
    final tabs = ['Universitas', 'Fakultas', 'Evaluasi Gabungan'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
      ),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _selectedTab == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  tabs[idx],
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelSm.copyWith(
                    color: isSelected ? Colors.white : AppColors.neutral700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabContent(KencanaDashboardData? dashboard) {
    if (_selectedTab == 0) {
      return _buildUnivBreakdown(dashboard);
    } else if (_selectedTab == 1) {
      return _buildFakultasBreakdown(dashboard);
    } else {
      return _buildGabunganBreakdown(dashboard);
    }
  }

  Widget _buildUnivBreakdown(KencanaDashboardData? dashboard) {
    final scoreObj = data?['score'] ?? {};
    final weights = data?['weights'] ?? dashboard?.weights ?? {};
    final cogWeightPercent = (double.tryParse(weights['cognitive']?.toString() ?? '') ?? double.tryParse(weights['kognitif']?.toString() ?? '') ?? 25.0).toInt();
    final psiWeightPercent = (double.tryParse(weights['psychomotor']?.toString() ?? '') ?? double.tryParse(weights['psikomotor']?.toString() ?? '') ?? 35.0).toInt();
    final afekWeightPercent = (double.tryParse(weights['affective']?.toString() ?? '') ?? double.tryParse(weights['afektif']?.toString() ?? '') ?? 40.0).toInt();

    final kognitif = (double.tryParse(scoreObj['cognitive_average_univ']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreUniv?['cognitive_average']?.toString() ?? '') ?? 0.0);
    final psikomotor = (double.tryParse(scoreObj['psychomotor_average_univ']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreUniv?['psychomotor_average']?.toString() ?? '') ?? 0.0);
    final afektif = (double.tryParse(scoreObj['affective_average_univ']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreUniv?['affective_average']?.toString() ?? '') ?? 0.0);

    final kogWeight = (double.tryParse(scoreObj['cognitive_weighted_univ']?.toString() ?? '') ?? (kognitif * (cogWeightPercent / 100)));
    final psiWeight = (double.tryParse(scoreObj['psychomotor_weighted_univ']?.toString() ?? '') ?? (psikomotor * (psiWeightPercent / 100)));
    final afekWeight = (double.tryParse(scoreObj['affective_weighted_univ']?.toString() ?? '') ?? (afektif * (afekWeightPercent / 100)));

    final rawUniv = (double.tryParse(scoreObj['final_score_univ']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreUniv?['final_score_univ']?.toString() ?? '') ?? 0.0);

    final statusUniv = scoreObj['graduation_status_univ'] ?? dashboard?.scoreUniv?['graduation_status'] ?? 'not_eligible';
    final isUnivPassed = statusUniv == 'passed' || statusUniv == 'lulus';
    final statusUnivText = isUnivPassed ? 'Lulus' : 'Belum Memenuhi Syarat';
    final statusUnivColor = isUnivPassed ? AppColors.success : context.appColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildComponentCard('Kognitif Univ', kognitif, cogWeightPercent, kogWeight, Icons.psychology_rounded, AppColors.info),
        _buildComponentCard('Psikomotor Univ', psikomotor, psiWeightPercent, psiWeight, Icons.handyman_rounded, AppColors.warning),
        _buildComponentCard('Afektif Univ', afektif, afekWeightPercent, afekWeight, Icons.favorite_rounded, context.appColors.error),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: statusUnivColor.withAlpha(10),
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: statusUnivColor.withAlpha(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nilai Akhir Universitas', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('Status Evaluasi: $statusUnivText', style: AppTextStyles.bodySm.copyWith(color: statusUnivColor, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                rawUniv.toStringAsFixed(1),
                style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFakultasBreakdown(KencanaDashboardData? dashboard) {
    final scoreObj = data?['score'] ?? {};
    final weights = data?['weights'] ?? dashboard?.weights ?? {};
    final cogWeightPercent = (weights['cognitive'] ?? weights['kognitif'] ?? 25).toInt();
    final psiWeightPercent = (weights['psychomotor'] ?? weights['psikomotor'] ?? 35).toInt();
    final afekWeightPercent = (weights['affective'] ?? weights['afektif'] ?? 40).toInt();

    final kognitif = (double.tryParse(scoreObj['cognitive_average_faculty']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreFakultas?['cognitive_average']?.toString() ?? '') ?? 0.0);
    final psikomotor = (double.tryParse(scoreObj['psychomotor_average_faculty']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreFakultas?['psychomotor_average']?.toString() ?? '') ?? 0.0);
    final afektif = (double.tryParse(scoreObj['affective_average_faculty']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreFakultas?['affective_average']?.toString() ?? '') ?? 0.0);

    final kogWeight = (double.tryParse(scoreObj['cognitive_weighted_faculty']?.toString() ?? '') ?? (kognitif * (cogWeightPercent / 100)));
    final psiWeight = (double.tryParse(scoreObj['psychomotor_weighted_faculty']?.toString() ?? '') ?? (psikomotor * (psiWeightPercent / 100)));
    final afekWeight = (double.tryParse(scoreObj['affective_weighted_faculty']?.toString() ?? '') ?? (afektif * (afekWeightPercent / 100)));

    final rawFak = (double.tryParse(scoreObj['final_score_faculty']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreFakultas?['final_score_faculty']?.toString() ?? '') ?? 0.0);

    final statusFak = scoreObj['graduation_status_faculty'] ?? dashboard?.scoreFakultas?['graduation_status'] ?? 'not_eligible';
    final isFakPassed = statusFak == 'passed' || statusFak == 'lulus';
    final statusFakText = isFakPassed ? 'Lulus' : 'Belum Memenuhi Syarat';
    final statusFakColor = isFakPassed ? AppColors.success : context.appColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildComponentCard('Kognitif Fakultas', kognitif, cogWeightPercent, kogWeight, Icons.psychology_rounded, AppColors.info),
        _buildComponentCard('Psikomotor Fakultas', psikomotor, psiWeightPercent, psiWeight, Icons.handyman_rounded, AppColors.warning),
        _buildComponentCard('Afektif Fakultas', afektif, afekWeightPercent, afekWeight, Icons.favorite_rounded, context.appColors.error),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: statusFakColor.withAlpha(10),
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: statusFakColor.withAlpha(30)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nilai Akhir Fakultas', style: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('Status Evaluasi: $statusFakText', style: AppTextStyles.bodySm.copyWith(color: statusFakColor, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                rawFak.toStringAsFixed(1),
                style: AppTextStyles.headlineMd.copyWith(fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGabunganBreakdown(KencanaDashboardData? dashboard) {
    final scoreObj = data?['score'] ?? {};
    final univFinal = (double.tryParse(scoreObj['final_score_univ']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreUniv?['final_score_univ']?.toString() ?? '') ?? 0.0);

    final fakFinal = (double.tryParse(scoreObj['final_score_faculty']?.toString() ?? '') ??
        double.tryParse(dashboard?.scoreFakultas?['final_score_faculty']?.toString() ?? '') ?? 0.0);

    final univWeightPercent = (dashboard?.period.universityWeight ?? 50).toInt();
    final fakWeightPercent = (dashboard?.period.facultyWeight ?? 50).toInt();

    final gabunganFinal = (double.tryParse(scoreObj['final_score']?.toString() ?? '') ??
        ((univFinal * (univWeightPercent / 100)) + (fakFinal * (fakWeightPercent / 100))));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Konsolidasi Nilai Akhir',
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Nilai akhir dihitung dengan menggabungkan Nilai Universitas ($univWeightPercent%) dengan Nilai Kencana Fakultas ($fakWeightPercent%).',
                style: AppTextStyles.bodySm.copyWith(
                  color: context.appColors.outline,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildConsolidatedRow('Nilai Akhir Kencana Universitas ($univWeightPercent%)', univFinal.toStringAsFixed(1)),
              const SizedBox(height: AppSpacing.md),
              _buildConsolidatedRow('Nilai Akhir Kencana Fakultas ($fakWeightPercent%)', fakFinal.toStringAsFixed(1)),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(12),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nilai Gabungan Akhir',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      gabunganFinal.toStringAsFixed(1),
                      style: AppTextStyles.headlineMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildBlockersSection(dashboard),
      ],
    );
  }

  Widget _buildConsolidatedRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral700))),
        Text(val, style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold, color: AppColors.neutral900)),
      ],
    );
  }

  Widget _buildComponentCard(String label, double rawScore, int weightPercent, double weightedScore, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bobot $weightPercent%  •  Nilai Bobot: ${weightedScore.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.appColors.outline,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            rawScore.toStringAsFixed(1),
            style: AppTextStyles.titleLg.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBandingButton(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Merasa nilai tidak sesuai?',
          style: AppTextStyles.titleMd.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Jika ada nilai yang kurang pas atau kamu telah menyelesaikan semua syarat, silakan ajukan banding.',
          style: AppTextStyles.bodySm.copyWith(
            color: context.appColors.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: BkuButton(
            onPressed: () {
              context.push(AppRoutes.kencanaBanding);
            },
            text: 'Ajukan Banding',
            variant: BkuButtonVariant.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateSection(Map<String, dynamic> certificates) {
    final univCert = certificates['university']?['file_url']?.toString();
    final facCert = certificates['fakultas']?['file_url']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(15),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.success.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.success,
                size: 32,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat! Anda Lulus Kencana',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      'Sertifikat kelulusan Anda telah diterbitkan resmi.',
                      style: AppTextStyles.bodySm.copyWith(
                        color: context.appColors.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: BkuButton(
                  onPressed: () {
                    if (univCert != null) {
                      _launchURL(univCert);
                    } else {
                      context.push(AppRoutes.kencanaCertificate);
                    }
                  },
                  text: 'Download Sertifikat PDF',
                  icon: Icons.picture_as_pdf_rounded,
                  variant: BkuButtonVariant.danger,
                ),
              ),
              if (facCert != null) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: BkuButton(
                    onPressed: () => _launchURL(facCert),
                    text: 'Sertifikat Fak',
                    icon: Icons.file_download_rounded,
                    variant: BkuButtonVariant.outline,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  bool _hasCertificate(Map<String, dynamic>? certificates) {
    if (certificates == null) return false;
    final univCert = certificates['university']?['file_url']?.toString();
    final facCert = certificates['fakultas']?['file_url']?.toString();
    return (univCert != null && univCert.isNotEmpty) || (facCert != null && facCert.isNotEmpty);
  }

  Widget _buildBlockersSection(KencanaDashboardData? dashboard) {
    final List<String> blockers = List<String>.from(data?['blockers'] ?? dashboard?.blockers ?? []);
    if (blockers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.success.withAlpha(15),
          borderRadius: AppRadius.radiusLg,
          border: Border.all(color: AppColors.success.withAlpha(40)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Semua prasyarat kehadiran, handbook, dan nilai minimum telah terpenuhi.',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral900, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blockers.map((b) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.error.withAlpha(15),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: context.appColors.error.withAlpha(30)),
          ),
          child: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: context.appColors.error, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  b,
                  style: AppTextStyles.bodySm.copyWith(
                    color: context.appColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _launchURL(String urlStr) async {
    final absoluteUrl = ApiGate.getImageUrl(urlStr);
    final uri = Uri.tryParse(absoluteUrl);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

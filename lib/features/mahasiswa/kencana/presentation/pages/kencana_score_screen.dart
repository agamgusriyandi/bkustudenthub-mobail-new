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
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
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
              title: 'REKAP NILAI',
              subtitle: 'KENCANA',
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
                    if (certificates != null) ...[
                      _buildCertificateSection(certificates),
                    ],
                    Text(
                      'Rincian Nilai',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildItemsList(),
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
    final finalScore =
        double.tryParse(score['final_score']?.toString() ?? '0') ?? 0.0;
    final status = score['graduation_status'] ?? 'pending';

    // Convert status to readable text
    String statusText = status.toString().toUpperCase();
    if (status == 'passed') statusText = 'LULUS';
    if (status == 'in_progress') statusText = 'IN PROGRESS';

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
          status == 'passed'
              ? Icons.verified_rounded
              : Icons.pending_actions_rounded,
          status == 'passed' ? themeProvider.success : Colors.amber.shade700,
        ),
        if (dashboard?.scoreFakultas != null) ...[
          _buildStatGridItem(
            'Nilai Univ',
            dashboard!.temporaryFinalScore.toStringAsFixed(1),
            Icons.account_balance_rounded,
            themeProvider.primary,
          ),
          _buildStatGridItem(
            'Nilai Fakultas',
            (double.tryParse(
                      dashboard.scoreFakultas!['final_score']?.toString() ??
                          '0',
                    ) ??
                    0.0)
                .toStringAsFixed(1),
            Icons.domain_rounded,
            themeProvider.success,
          ),
        ],
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
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
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
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildItemsList() {
    final items = data?['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: AppRadius.radiusLg,
        ),
        child: Text(
          'Belum ada rincian nilai',
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return Column(
      children:
          items.map((item) {
            final component = item['component'] ?? '';
            final desc = item['description'] ?? '';
            final score =
                double.tryParse(item['score']?.toString() ?? '0') ?? 0.0;

            IconData icon = Icons.article_rounded;
            Color iconColor = AppColors.info;
            if (component == 'cognitive') {
              icon = Icons.psychology_rounded;
              iconColor = AppColors.info;
            } else if (component == 'psychomotor') {
              icon = Icons.handyman_rounded;
              iconColor = AppColors.warning;
            } else if (component == 'affective') {
              icon = Icons.favorite_rounded;
              iconColor = Colors.pinkAccent;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppRadius.radiusLg,
                border: Border.all(color: AppColors.neutral200, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
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
                          desc,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          component.toUpperCase(),
                          style: AppTextStyles.labelSm.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    score.toStringAsFixed(0),
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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
            color: Theme.of(context).colorScheme.outline,
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
            text: 'AJUKAN BANDING',
          ),
        ),
      ],
    );
  }

  Widget _buildCertificateSection(Map<String, dynamic> certificates) {
    final univCert = certificates['university']?['file_url']?.toString();
    final facCert = certificates['fakultas']?['file_url']?.toString();

    if (univCert == null && facCert == null) return const SizedBox.shrink();

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
                        color: Theme.of(context).colorScheme.outline,
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
              if (univCert != null)
                Expanded(
                  child: BkuButton(
                    onPressed: () => _launchURL(univCert),
                    text: 'Sertifikat Univ',
                    icon: Icons.file_download_rounded,
                    variant: BkuButtonVariant.danger,
                  ),
                ),
              if (univCert != null && facCert != null)
                const SizedBox(width: AppSpacing.md),
              if (facCert != null)
                Expanded(
                  child: BkuButton(
                    onPressed: () => _launchURL(facCert),
                    text: 'Sertifikat Fakultas',
                    icon: Icons.file_download_rounded,
                    variant: BkuButtonVariant.danger,
                  ),
                ),
            ],
          ),
        ],
      ),
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

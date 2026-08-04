import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class MedicalReferralScreen extends StatefulWidget {
  const MedicalReferralScreen({super.key});

  @override
  State<MedicalReferralScreen> createState() => _MedicalReferralScreenState();
}

class _MedicalReferralScreenState extends State<MedicalReferralScreen> {
  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final health = context.watch<HealthViewModel>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await health.refreshHealthData();
        },
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Rujukan Medis',
              subtitle: 'RUJUKAN FASKES EKSTERNAL',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    if (student.isLoading)
                      const BkuShimmerList(itemCount: 3, itemHeight: 120)
                    else ...[
                      Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.neutral800,
                              borderRadius: AppRadius.radiusXs,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s10),
                          Text(
                            'Surat Rujukan Medis',
                            style: AppTextStyles.titleLg.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (health.rujukans.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl,
                            horizontal: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 36,
                                color: AppColors.neutral400,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Belum ada surat rujukan medis',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral500,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...health.rujukans.map(
                          (ref) => _buildRujukanCard(context, ref),
                        ),
                    ],
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

  Widget _buildRujukanCard(BuildContext context, Map<String, dynamic> ref) {
    final faskes = ref['faskes_tujuan'] ?? '-';
    final diagnosis = ref['diagnosis'] ?? '-';
    final status = ref['approval_status'] ?? ref['status'] ?? 'Menunggu';
    final createdAtStr = ref['created_at'] ?? '';
    final date = DateTime.tryParse(createdAtStr);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                date != null ? '${date.day}-${date.month}-${date.year}' : '-',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color:
                      status.toString().toLowerCase() == 'disetujui' ||
                              status.toString().toLowerCase() == 'selesai'
                          ? context
                              .watch<ThemeProvider>()
                              .colors
                              .success
                              .withAlpha(20)
                          : status.toString().toLowerCase() == 'ditolak'
                          ? Theme.of(context).colorScheme.error.withAlpha(20)
                          : context
                              .watch<ThemeProvider>()
                              .colors
                              .warning
                              .withAlpha(20),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Text(
                  status.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color:
                        status.toString().toLowerCase() == 'disetujui' ||
                                status.toString().toLowerCase() == 'selesai'
                            ? context.watch<ThemeProvider>().colors.success
                            : status.toString().toLowerCase() == 'ditolak'
                            ? Theme.of(context).colorScheme.error
                            : context.watch<ThemeProvider>().colors.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Faskes Tujuan: $faskes',
            style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text('Diagnosis: $diagnosis', style: AppTextStyles.bodyMd),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final rujukanId = ref['id'] ?? ref['ID'];
                final token = AuthService().token;
                final urlStr =
                    '${ApiGate.baseUrl}/mahasiswa/rujukan/$rujukanId/export-pdf?token=$token';
                final uri = Uri.parse(urlStr);
                
                if (context.mounted) {
                  AppSnackbar.showSuccess(context, 'Membuka dokumen PDF...');
                }
                
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (context.mounted) {
                    AppSnackbar.showError(context, 'Tidak dapat membuka PDF');
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: context.appColors.error,
                side: BorderSide(color: context.appColors.error),
                backgroundColor: context.appColors.errorContainer,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.br10,
                ),
              ),
              icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
              label: const Text(
                'Unduh PDF',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

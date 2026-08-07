import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/providers/kencana_certificate_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/certificate_model.dart';
import 'package:intl/intl.dart';

class KencanaCertificateScreen extends StatefulWidget {
  const KencanaCertificateScreen({super.key});

  @override
  State<KencanaCertificateScreen> createState() =>
      _KencanaCertificateScreenState();
}

class _KencanaCertificateScreenState extends State<KencanaCertificateScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KencanaCertificateProvider>().fetchCertificate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KencanaCertificateProvider>();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchCertificate(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const BkuAppBar(
              title: 'SERTIFIKAT',
              subtitle: 'KENCANA',
              variant: AppBarVariant.student,
              expandedHeight: 100,
              showBackButton: true,
              isExpandable: false,
            ),
            if (provider.isLoading)
              const SliverFillRemaining(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: BkuShimmerList(itemCount: 3, itemHeight: 100),
                ),
              )
            else if (provider.errorMessage != null)
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
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      BkuButton(
                        onPressed: () => provider.fetchCertificate(),
                        text: 'Coba Lagi',
                      ),
                    ],
                  ),
                ),
              )
            else if (provider.certificate == null ||
                !provider.certificate!.hasCertificate)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium_outlined,
                        size: 64,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Sertifikat belum tersedia.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sertifikat akan diterbitkan setelah kamu dinyatakan lulus.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: context.appColors.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.xl,
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                  bottom: AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildCertificatePreview(provider.certificate!),
                    const SizedBox(height: AppSpacing.xl),
                    _buildCertificateInfo(provider.certificate!),
                    const SizedBox(height: AppSpacing.xl),
                    _buildDownloadButton(provider.certificate!),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificatePreview(KencanaCertificate cert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: AppColors.primary.withAlpha(25),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 72,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'SERTIFIKAT KELULUSAN',
            style: AppTextStyles.titleLg.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Program Kencana ${cert.periodName ?? ''}',
            style: AppTextStyles.labelMd.copyWith(
              color: context.appColors.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (cert.studentName != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(
              cert.studentName!,
              style: AppTextStyles.headlineMd.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCertificateInfo(KencanaCertificate cert) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFORMASI SERTIFIKAT',
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              fontSize: 10,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoRow('Nomor', cert.certificateNumber ?? '-'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Periode', cert.periodName ?? '-'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow('Nilai Akhir', cert.finalScore?.toStringAsFixed(1) ?? '-'),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            'Tanggal Terbit',
            _formatDate(cert.issuedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: context.appColors.outline,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadButton(KencanaCertificate cert) {
    final provider = context.watch<KencanaCertificateProvider>();
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: BkuButton(
        isLoading: provider.isDownloading,
        onPressed: () async {
          await context.read<KencanaCertificateProvider>().downloadCertificate();
        },
        text: 'UNDUH SERTIFIKAT (PDF)',
        icon: Icons.picture_as_pdf_rounded,
        variant: BkuButtonVariant.danger,
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/organisasi/presentation/pages/edit_organisasi_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrmawaOrganisasiDetailScreen extends StatelessWidget {
  final OrmawaOrganisasi organisasi;

  const OrmawaOrganisasiDetailScreen({super.key, required this.organisasi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [context.appColors.primary, context.appColors.primaryContainer],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, 60, AppSpacing.xl, AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(Icons.arrow_back_rounded, color: context.appColors.onPrimary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: context.appColors.onPrimary,
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              organisasi.status,
                              style: AppTextStyles.labelSm.copyWith(
                                color: context.appColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: context.appColors.onPrimary.withAlpha(20),
                              borderRadius: AppRadius.radiusLg,
                            ),
                            child: Icon(
                              Icons.business_rounded,
                              color: context.appColors.onPrimary,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  organisasi.nama,
                                  style: AppTextStyles.titleLg.copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    height: 1.3,
                                    color: context.appColors.onPrimary,
                                  ),
                                ),
                                if (organisasi.tahunBerdiri != null && organisasi.tahunBerdiri!.isNotEmpty)
                                  Text(
                                    'Berdiri ${organisasi.tahunBerdiri}',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: context.appColors.onPrimary.withAlpha(200),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Deskripsi
                      if (organisasi.deskripsi.isNotEmpty) ...[
                        _buildSectionHeader('DESKRIPSI'),
                        const SizedBox(height: AppSpacing.md),
                        _buildContentCard(organisasi.deskripsi),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Visi
                      if (organisasi.visi != null && organisasi.visi!.isNotEmpty) ...[
                        _buildSectionHeader('VISI'),
                        const SizedBox(height: AppSpacing.md),
                        _buildContentCard(organisasi.visi!),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Misi
                      if (organisasi.misi != null && organisasi.misi!.isNotEmpty) ...[
                        _buildSectionHeader('MISI'),
                        const SizedBox(height: AppSpacing.md),
                        _buildContentCard(organisasi.misi!),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      // Informasi Kontak
                      _buildSectionHeader('INFORMASI KONTAK'),
                      const SizedBox(height: AppSpacing.md),
                      _buildInfoCard([
                        if (organisasi.alamat != null && organisasi.alamat!.isNotEmpty)
                          _buildInfoRow(Icons.location_on_rounded, 'Alamat', organisasi.alamat!),
                        if (organisasi.email != null && organisasi.email!.isNotEmpty)
                          _buildInfoRow(Icons.email_rounded, 'Email', organisasi.email!),
                        if (organisasi.website != null && organisasi.website!.isNotEmpty)
                          _buildInfoRow(Icons.language_rounded, 'Website', organisasi.website!),
                        if (organisasi.instagram != null && organisasi.instagram!.isNotEmpty)
                          _buildInfoRow(Icons.camera_alt_rounded, 'Instagram', organisasi.instagram!),
                      ]),
                    ],
                  ),
                ),

                // Edit Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditOrganisasiScreen(organisasi: organisasi),
                          ),
                        );
                      },
                      icon: Icon(Icons.edit_rounded, color: context.appColors.onPrimary),
                      label: Text(
                        'EDIT ORGANISASI',
                        style: TextStyle(
                          color: context.appColors.onPrimary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.neutral600,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
        fontSize: 10,
      ),
    );
  }

  Widget _buildContentCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMd.copyWith(
          color: AppColors.neutral700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.neutral500),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

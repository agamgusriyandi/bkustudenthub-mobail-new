import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart' show AppTheme;
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/admin_psychologist_provider.dart';

class PsychologistDetailScreen extends StatefulWidget {
  final String psychologistId;
  const PsychologistDetailScreen({super.key, required this.psychologistId});

  @override
  State<PsychologistDetailScreen> createState() =>
      _PsychologistDetailScreenState();
}

class _PsychologistDetailScreenState extends State<PsychologistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdminPsychologistProvider>()
          .loadPsychologistDetail(widget.psychologistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminPsychologistProvider>(
      builder: (context, provider, _) {
        final data = provider.selectedPsychologist;
        final isLoading = provider.loading && data == null;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                title: 'Detail Psikolog',
                variant: AppBarVariant.psychologist,
                isExpandable: false,
                showBackButton: true,
                actions: [
                  if (data != null)
                    IconButton(
                       icon: Icon(Icons.edit_rounded, color: context.appColors.onPrimary),
                      onPressed: () => context.push(
                        '/counseling/admin/psikolog/${widget.psychologistId}/edit',
                      ),
                    ),
                ],
              ),
              if (isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 3, itemHeight: 120),
                  ),
                )
              else if (data == null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxxl),
                    child: Center(
                      child: Text(
                        'Data tidak ditemukan',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.s120,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(data),
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionTitle('Informasi Profil'),
                        const SizedBox(height: AppSpacing.lg),
                        _buildInfoCard(data),
                        const SizedBox(height: AppSpacing.xl),
                        _buildSectionTitle('Spesialisasi'),
                        const SizedBox(height: AppSpacing.lg),
                        _buildSpecializationCard(data),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> data) {
    final name = (data['name'] ?? data['nama'] ?? '-').toString();
    final spesialis =
        (data['spesialisasi'] ?? data['specialization'] ?? '-').toString();
    final isAktif =
        data['is_aktif'] ?? data['IsAktif'] ?? data['is_active'] ?? true;

    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(' ').take(2).map((w) => w[0]).join();

    return BkuCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: context.appColors.primary.withAlpha(20),
              child: Text(
                initials,
                style: AppTextStyles.titleLg.copyWith(
                  color: context.appColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              name,
              style: AppTextStyles.titleLg.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.neutral900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              spesialis,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isAktif == true
                    ? AppColors.success.withAlpha(20)
                    : AppColors.neutral200,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isAktif == true
                        ? Icons.check_circle_rounded
                        : Icons.pause_circle_rounded,
                    size: 14,
                    color: isAktif == true
                        ? AppColors.success
                        : AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    isAktif == true ? 'Aktif' : 'Nonaktif',
                    style: AppTextStyles.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isAktif == true
                          ? AppColors.success
                          : AppColors.neutral500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> data) {
    final email = (data['email'] ?? '-').toString();
    final noHp = (data['no_hp'] ?? data['NoHP'] ?? '-').toString();
    final nidn = (data['nidn'] ?? data['NIDN'] ?? '-').toString();
    final bio = (data['bio'] ?? data['Bio'] ?? '-').toString();
    final lokasi = (data['lokasi'] ?? data['Lokasi'] ?? '-').toString();
    final bahasa = (data['bahasa'] ?? data['Bahasa'] ?? '-').toString();
    final tarif = data['tarif'] ?? data['Tarif'] ?? 0;

    return BkuCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            _buildInfoRow(Icons.email_rounded, 'Email', email),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(Icons.phone_rounded, 'No. HP', noHp),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(Icons.badge_rounded, 'NIDN', nidn),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(Icons.location_on_rounded, 'Lokasi', lokasi),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(Icons.translate_rounded, 'Bahasa', bahasa),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(
              Icons.attach_money_rounded,
              'Tarif',
              'Rp ${tarif.toString()}',
            ),
            const Divider(height: AppSpacing.xl),
            _buildInfoRow(Icons.info_outline_rounded, 'Bio', bio, maxLines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializationCard(Map<String, dynamic> data) {
    final spesialis =
        (data['spesialisasi'] ?? data['specialization'] ?? '').toString();
    return BkuCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.primary.withAlpha(15),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(
                Icons.psychology_rounded,
                color: context.appColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spesialis.isNotEmpty ? spesialis : '-',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Spesialisasi utama',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    int maxLines = 1,
  }) {
    return Row(
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
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutral800,
                ),
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.neutral900,
      ),
    );
  }
}

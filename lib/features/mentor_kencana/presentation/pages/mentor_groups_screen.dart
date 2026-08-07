import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';

class MentorGroupsScreen extends StatefulWidget {
  const MentorGroupsScreen({super.key});

  @override
  State<MentorGroupsScreen> createState() => _MentorGroupsScreenState();
}

class _MentorGroupsScreenState extends State<MentorGroupsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentorGroups();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentorGroups(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Grup Kencana',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && provider.mentorGroups.isEmpty)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else if (provider.errorMessage != null &&
                provider.mentorGroups.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: context.appColors.error,
                    ),
                  ),
                ),
              )
            else if (provider.mentorGroups.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada grup yang tersedia.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.xl,
                ),
                sliver: SliverList.list(
                  children: [
                      const SizedBox(height: AppSpacing.md),
                      // Search Bar Placeholder
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(color: context.appColors.outlineVariant),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search_rounded, color: context.appColors.outline, size: 20),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Cari nama/kode kelompok...',
                                  hintStyle: AppTextStyles.labelMd.copyWith(color: context.appColors.outline),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.w600),
                                onChanged: (value) {
                                  // Add search filtering logic if needed locally,
                                  // or implement fetching with query
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ...provider.mentorGroups.map((group) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(color: context.appColors.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'KELOMPOK ${group.groupNumber.isEmpty ? '-' : group.groupNumber} • ${group.code.isEmpty ? 'Tanpa Kode' : group.code}',
                                          style: AppTextStyles.labelSm.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: context.appColors.outline,
                                            letterSpacing: 1.2,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          group.name,
                                          style: AppTextStyles.titleMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.appColors.primary.withAlpha(25),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: context.appColors.primary.withAlpha(50)),
                                    ),
                                    child: Text(
                                      group.status.toUpperCase(),
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: context.appColors.surface,
                                        borderRadius: AppRadius.radiusLg,
                                        border: Border.all(color: context.appColors.outlineVariant),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${group.memberCount}',
                                            style: AppTextStyles.titleLg.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            'Anggota',
                                            style: AppTextStyles.labelSm.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: context.appColors.outline,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: context.appColors.surface,
                                        borderRadius: AppRadius.radiusLg,
                                        border: Border.all(color: context.appColors.outlineVariant),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${group.capacity}',
                                            style: AppTextStyles.titleLg.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          Text(
                                            'Kapasitas',
                                            style: AppTextStyles.labelSm.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: context.appColors.outline,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.push('/mentor-kencana/groups/${group.id}');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.appColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadius.radiusLg,
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: Text(
                                        'Kelola Anggota',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        // TODO: Implement PDF download
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Fitur unduh PDF belum tersedia di mobile.')),
                                        );
                                      },
                                      icon: const Icon(Icons.download_rounded, size: 16),
                                      label: Text(
                                        'PDF Rekap',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: context.appColors.primary,
                                        side: BorderSide(color: context.appColors.outlineVariant),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadius.radiusLg,
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

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
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import "package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart";

class MentorGroupsScreen extends StatefulWidget {
  const MentorGroupsScreen({super.key});

  @override
  State<MentorGroupsScreen> createState() => _MentorGroupsScreenState();
}

class _MentorGroupsScreenState extends State<MentorGroupsScreen> {
  String _searchQuery = '';

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

    final filteredGroups = provider.mentorGroups.where((group) {
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return group.name.toLowerCase().contains(q) ||
          group.code.toLowerCase().contains(q) ||
          group.groupNumber.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: context.appColors.surface,
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
            else if (provider.errorMessage != null && provider.mentorGroups.isEmpty)
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
                    BkuTextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      hint: 'Cari nama/kode kelompok...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    if (filteredGroups.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxl),
                        child: Center(
                          child: Text(
                            'Kelompok tidak ditemukan.',
                            style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline),
                          ),
                        ),
                      )
                    else
                      ...filteredGroups.map((group) {
                        return BkuCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                          padding: const EdgeInsets.all(AppSpacing.lg),
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
                                            color: AppColors.neutral700,
                                            letterSpacing: 0.8,
                                            fontSize: 10,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          group.name,
                                          style: AppTextStyles.titleMd.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.neutral900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.neutral100,
                                      borderRadius: AppRadius.radiusXl,
                                      border: Border.all(color: AppColors.neutral300),
                                    ),
                                    child: Text(
                                      group.status.toUpperCase(),
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.neutral900,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9.5,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral100,
                                        borderRadius: AppRadius.radiusLg,
                                        border: Border.all(color: AppColors.neutral300),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${group.memberCount}',
                                            style: AppTextStyles.titleLg.copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: AppColors.neutral900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Anggota',
                                            style: AppTextStyles.labelSm.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.neutral700,
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
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.md),
                                      decoration: BoxDecoration(
                                        color: AppColors.neutral100,
                                        borderRadius: AppRadius.radiusLg,
                                        border: Border.all(color: AppColors.neutral300),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${group.capacity}',
                                            style: AppTextStyles.titleLg.copyWith(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 18,
                                              color: AppColors.neutral900,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Kapasitas',
                                            style: AppTextStyles.labelSm.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.neutral700,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              SizedBox(
                                width: double.infinity,
                                child: BkuButton.primary(
                                  onPressed: () {
                                    context.push('/mentor-kencana/groups/${group.id}');
                                  },
                                  icon: Icons.people_outline_rounded,
                                  text: 'Kelola Anggota',
                                ),
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

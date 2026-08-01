import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';

class MentorGroupDetailScreen extends StatefulWidget {
  final int groupId;
  const MentorGroupDetailScreen({super.key, required this.groupId});

  @override
  State<MentorGroupDetailScreen> createState() =>
      _MentorGroupDetailScreenState();
}

class _MentorGroupDetailScreenState extends State<MentorGroupDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentorGroupDetail(
          widget.groupId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final detail = provider.mentorGroupDetail;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentorGroupDetail(widget.groupId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: detail?.name ?? 'Detail Grup',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && detail == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && detail == null)
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
            else if (detail == null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Detail grup tidak tersedia.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.xl,
                  right: AppSpacing.xl,
                  top: AppSpacing.xl,
                  bottom: 120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index == 0) {
                      return BkuCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: context.appColors.info.withAlpha(15),
                                    borderRadius: AppRadius.radiusLg,
                                  ),
                                  child: Icon(
                                    Icons.groups_rounded,
                                    color: context.appColors.info,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        detail.name,
                                        style: AppTextStyles.titleLg.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        '${detail.members.length} Anggota',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                    final member = detail.members[index - 1];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.lg,
                      ),
                      child: ListTile(
                        onTap: () {
                          context.push(
                            '/mentor-kencana/mentee/${member.id}',
                          );
                        },
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.neutral300,
                            ),
                          ),
                          child: ClipOval(
                            child:
                                member.avatarUrl != null &&
                                        member.avatarUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                      imageUrl: ApiGate.getImageUrl(
                                        member.avatarUrl!,
                                      ),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorWidget:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Center(
                                            child: Text(
                                              member.name.isNotEmpty
                                                  ? member.name
                                                      .substring(0, 1)
                                                      .toUpperCase()
                                                  : '',
                                              style: const TextStyle(
                                                color: AppColors.neutral700,
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                    )
                                    : Center(
                                      child: Text(
                                        member.name.isNotEmpty
                                            ? member.name
                                                .substring(0, 1)
                                                .toUpperCase()
                                            : '',
                                        style: const TextStyle(
                                          color: AppColors.neutral700,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                          ),
                        ),
                        title: Text(
                          member.name,
                          style: AppTextStyles.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${member.nim} \u2022 ${member.faculty}',
                          style: AppTextStyles.labelSm.copyWith(
                            color: context.appColors.outline,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color:
                                member.status == 'Lulus'
                                    ? context.appColors.success.withAlpha(15)
                                    : context.appColors.warning.withAlpha(15),
                            border: Border.all(
                              color:
                                  member.status == 'Lulus'
                                      ? context.appColors.success
                                          .withAlpha(30)
                                      : context.appColors.warning
                                          .withAlpha(30),
                            ),
                            borderRadius: AppRadius.radiusSm,
                          ),
                          child: Text(
                            member.status,
                            style: AppTextStyles.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  member.status == 'Lulus'
                                      ? context.appColors.success
                                      : context.appColors.warning,
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: detail.members.length + 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MentorMenteeScreen extends StatefulWidget {
  const MentorMenteeScreen({super.key});

  @override
  State<MentorMenteeScreen> createState() => _MentorMenteeScreenState();
}

class _MentorMenteeScreenState extends State<MentorMenteeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentees();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentees(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Kelompok Saya',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && provider.groups.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && provider.groups.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              )
            else if (provider.groups.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada mahasiswa yang terdaftar.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
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
                    final group = provider.groups[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusXl,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusXl,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: [
                                context.appColors.info,
                                context.appColors.success,
                                context.appColors.warning,
                                AppColors.neutral700,
                                context.appColors.info,
                                context.appColors.info,
                              ][index % 6].withAlpha(15),
                              borderRadius: AppRadius.radiusLg,
                            ),
                            child: Icon(
                              Icons.groups_rounded,
                              color:
                                  [
                                    context.appColors.info,
                                    context.appColors.success,
                                    context.appColors.warning,
                                    AppColors.neutral700,
                                    context.appColors.info,
                                    context.appColors.info,
                                  ][index % 6],
                              size: 24,
                            ),
                          ),
                          title: Text(
                            group.name,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${group.mentees.length} Mahasiswa',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          children:
                              group.mentees.map((mentee) {
                                return ListTile(
                                  onTap: () {
                                    context.push(
                                      '/mentor-kencana/mentee/${mentee.id}',
                                    );
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.xl,
                                    vertical: 6,
                                  ),
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
                                          mentee.avatarUrl != null &&
                                                  mentee.avatarUrl!.isNotEmpty
                                              ? CachedNetworkImage(imageUrl: 
                                                ApiGate.getImageUrl(
                                                  mentee.avatarUrl,
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
                                                        mentee.name.isNotEmpty
                                                            ? mentee.name
                                                                .substring(0, 1)
                                                                .toUpperCase()
                                                            : '',
                                                        style: const TextStyle(
                                                          color:
                                                              AppColors
                                                                  .neutral700,
                                                          fontWeight:
                                                              FontWeight.w900,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                placeholder: (context, url) => Container(color: AppColors.neutral200),
                                              )
                                              : Center(
                                                child: Text(
                                                  mentee.name.isNotEmpty
                                                      ? mentee.name
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
                                    mentee.name,
                                    style: AppTextStyles.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${mentee.nim} • ${mentee.faculty}',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.md,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              mentee.status == 'Lulus'
                                                  ? context.appColors.success.withAlpha(
                                                    15,
                                                  )
                                                  : context.appColors.warning.withAlpha(
                                                    15,
                                                  ),
                                          border: Border.all(
                                            color:
                                                mentee.status == 'Lulus'
                                                    ? context.appColors.success
                                                        .withAlpha(30)
                                                    : context.appColors.warning
                                                        .withAlpha(30),
                                          ),
                                          borderRadius: AppRadius.radiusSm,
                                        ),
                                        child: Text(
                                          mentee.status,
                                          style: AppTextStyles.labelSm.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                mentee.status == 'Lulus'
                                                    ? context.appColors.success
                                                    : context.appColors.warning,
                                          ),
                                        ),
                                      ),
                                      PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert_rounded,
                                          size: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: AppRadius.radiusMd,
                                        ),
                                        onSelected: (value) async {
                                          if (value == 'remove') {
                                            final confirm = await showDialog<
                                              bool
                                            >(
                                              context: context,
                                              builder:
                                                  (ctx) => CustomDialog(
                                                    title:
                                                        'Keluarkan Mahasiswa',
                                                    content:
                                                        'Apakah Anda yakin ingin mengeluarkan mahasiswa ini dari grup?',
                                                    cancelText: 'Batal',
                                                    confirmText: 'Keluarkan',
                                                    isDestructive: true,
                                                    onCancel:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    onConfirm:
                                                        () => Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                  ),
                                            );
                                            if (confirm == true &&
                                                context.mounted) {
                                              final success = await context
                                                  .read<MentorKencanaProvider>()
                                                  .removeGroupMember(
                                                    group.id,
                                                    mentee.id,
                                                  );
                                              if (context.mounted) {
                                                if (success) {
                                                  AppSnackbar.showSuccess(
                                                    context,
                                                    'Berhasil dikeluarkan',
                                                  );
                                                } else {
                                                  AppSnackbar.showError(
                                                    context,
                                                    'Gagal mengeluarkan mahasiswa',
                                                  );
                                                }
                                              }
                                            }
                                          }
                                        },
                                        itemBuilder:
                                            (BuildContext context) =>
                                                <PopupMenuEntry<String>>[
                                                  PopupMenuItem<String>(
                                                    value: 'remove',
                                                    child: Text(
                                                      'Keluarkan dari Grup',
                                                      style: TextStyle(
                                                        color: AppColors.error,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),
                      ),
                    );
                  }, childCount: provider.groups.length),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/mentor-kencana/recruit');
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusLg),
        icon: Icon(Icons.person_add_rounded, color: context.appColors.onPrimary),
        label: Text(
          'Rekrut Mahasiswa',
          style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

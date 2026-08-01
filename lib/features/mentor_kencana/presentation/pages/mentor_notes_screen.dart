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

class MentorNotesScreen extends StatefulWidget {
  const MentorNotesScreen({super.key});

  @override
  State<MentorNotesScreen> createState() => _MentorNotesScreenState();
}

class _MentorNotesScreenState extends State<MentorNotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentorNotes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentorNotes(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Catatan Mentoring',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && provider.mentorNotes.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null &&
                provider.mentorNotes.isEmpty)
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
            else if (provider.mentorNotes.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada catatan mentoring.',
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
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final note = provider.mentorNotes[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: InkWell(
                        onTap: () {
                          context.push('/mentor-kencana/notes/${note.id}');
                        },
                        borderRadius: AppRadius.radiusXl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: context.appColors.secondary
                                        .withAlpha(15),
                                    borderRadius: AppRadius.radiusLg,
                                  ),
                                  child: Icon(
                                    Icons.note_alt_rounded,
                                    color: context.appColors.secondary,
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
                                        note.title.isNotEmpty
                                            ? note.title
                                            : 'Catatan #${note.id}',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        note.studentName.isNotEmpty
                                            ? note.studentName
                                            : '',
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: context.appColors.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color:
                                      context.appColors.outline,
                                ),
                              ],
                            ),
                            if (note.content.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                note.content.length > 120
                                    ? '${note.content.substring(0, 120)}...'
                                    : note.content,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.onSurfaceVariant,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (note.createdAt.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                note.createdAt,
                                style: AppTextStyles.labelSm.copyWith(
                                  fontSize: 11,
                                  color: context.appColors.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }, childCount: provider.mentorNotes.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

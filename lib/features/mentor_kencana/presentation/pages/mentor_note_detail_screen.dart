import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class MentorNoteDetailScreen extends StatefulWidget {
  final int noteId;
  const MentorNoteDetailScreen({super.key, required this.noteId});

  @override
  State<MentorNoteDetailScreen> createState() => _MentorNoteDetailScreenState();
}

class _MentorNoteDetailScreenState extends State<MentorNoteDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentorNoteDetail(
          widget.noteId,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final note = provider.mentorNoteDetail;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentorNoteDetail(widget.noteId),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Detail Catatan',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && note == null)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && note == null)
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
            else if (note == null)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Catatan tidak ditemukan.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
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
                                          style: AppTextStyles.titleLg
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        if (note.studentName.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: AppSpacing.xs,
                                            ),
                                            child: Text(
                                              note.studentName,
                                              style:
                                                  AppTextStyles.labelSm
                                                      .copyWith(
                                                        color: context.appColors.outline,
                                                      ),
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
                        const SizedBox(height: AppSpacing.lg),
                        BkuCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Isi Catatan',
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                note.content.isNotEmpty
                                    ? note.content
                                    : 'Tidak ada isi catatan.',
                                style: AppTextStyles.labelMd.copyWith(
                                  color:
                                      note.content.isNotEmpty
                                          ? context.appColors.onSurface
                                          : context.appColors.outline,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (note.createdAt.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 16,
                                color: context.appColors.outline,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                note.createdAt,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  }, childCount: 1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

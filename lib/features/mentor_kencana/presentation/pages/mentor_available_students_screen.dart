import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorAvailableStudentsScreen extends StatefulWidget {
  const MentorAvailableStudentsScreen({super.key});

  @override
  State<MentorAvailableStudentsScreen> createState() =>
      _MentorAvailableStudentsScreenState();
}

class _MentorAvailableStudentsScreenState
    extends State<MentorAvailableStudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchAvailableStudents();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAvailableStudents(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Mahasiswa Tersedia',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && provider.availableStudents.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null &&
                provider.availableStudents.isEmpty)
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
            else if (provider.availableStudents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Tidak ada mahasiswa tersedia untuk direkrut.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Theme.of(context).colorScheme.outline,
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
                    final student = provider.availableStudents[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral200,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.neutral300,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name
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
                              const SizedBox(width: AppSpacing.lg),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      '${student.nim} \u2022 ${student.faculty}',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: BkuButton(
                              onPressed: () async {
                                final success = await provider.inviteStudent(
                                  student.id,
                                );
                                if (context.mounted) {
                                  if (success) {
                                    AppSnackbar.showSuccess(
                                      context,
                                      'Berhasil mengundang ${student.name}',
                                    );
                                  } else {
                                    AppSnackbar.showError(
                                      context,
                                      'Gagal mengundang mahasiswa',
                                    );
                                  }
                                }
                              },
                              icon: Icons.person_add_rounded,
                              text: 'Undang',
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: provider.availableStudents.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

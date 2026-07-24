import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class MentorRecruitScreen extends StatefulWidget {
  const MentorRecruitScreen({super.key});

  @override
  State<MentorRecruitScreen> createState() => _MentorRecruitScreenState();
}

class _MentorRecruitScreenState extends State<MentorRecruitScreen> {
  final TextEditingController _searchController = TextEditingController();

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _inviteStudent(int id) async {
    final success = await context.read<MentorKencanaProvider>().inviteStudent(
      id,
    );
    if (mounted) {
      if (success) {
        AppSnackbar.showSuccess(context, 'Undangan berhasil dikirim');
      } else {
        AppSnackbar.showError(context, 'Gagal mengirim undangan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final availableStudents = provider.availableStudents;

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAvailableStudents(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Rekrut Mahasiswa',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () => context.pop(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau NIM...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: AppColors.neutral50,
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.radiusLg,
                      borderSide: BorderSide(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusLg,
                      borderSide: BorderSide(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.radiusLg,
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
            ),
            if (provider.isLoading && availableStudents.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && availableStudents.isEmpty)
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
            else if (availableStudents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Tidak ada mahasiswa baru tersedia',
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
                  vertical: AppSpacing.sm,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final student = availableStudents[index];
                    final search = _searchController.text.toLowerCase();
                    if (search.isNotEmpty &&
                        !student.name.toLowerCase().contains(search) &&
                        !student.nim.toLowerCase().contains(search)) {
                      return const SizedBox.shrink();
                    }
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.neutral200,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.neutral300),
                            ),
                            child: Center(
                              child: Text(
                                student.name.isNotEmpty
                                    ? student.name.substring(0, 1).toUpperCase()
                                    : '',
                                style: const TextStyle(
                                  color: AppColors.neutral700,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                const SizedBox(height: 4),
                                Text(
                                  '${student.nim} • ${student.faculty}',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          BkuButton(
                            onPressed:
                                provider.isLoading
                                    ? null
                                    : () => _inviteStudent(student.id),
                            text: 'Undang',
                          ),
                        ],
                      ),
                    );
                  }, childCount: availableStudents.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

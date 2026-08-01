import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:url_launcher/url_launcher.dart';

class MentorMaterialsScreen extends StatefulWidget {
  const MentorMaterialsScreen({super.key});

  @override
  State<MentorMaterialsScreen> createState() => _MentorMaterialsScreenState();
}

class _MentorMaterialsScreenState extends State<MentorMaterialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<MentorKencanaProvider>().fetchMentorMaterials();
      }
    });
  }

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'materi':
      case 'material':
        return Icons.menu_book_rounded;
      case 'tugas':
      case 'assignment':
        return Icons.assignment_rounded;
      case 'referensi':
      case 'reference':
        return Icons.library_books_rounded;
      case 'video':
        return Icons.play_circle_outline_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentorMaterials(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Materi Mentoring',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            if (provider.isLoading && provider.materials.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && provider.materials.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: context.appColors.error),
                  ),
                ),
              )
            else if (provider.materials.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 64,
                        color: context.appColors.outline.withAlpha(80),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Belum ada materi mentoring.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final material = provider.materials[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: InkWell(
                        onTap: material.fileUrl.isNotEmpty
                            ? () => _openFile(material.fileUrl)
                            : null,
                        borderRadius: AppRadius.radiusLg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: context.appColors.primary.withAlpha(15),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Icon(
                                    _categoryIcon(material.category),
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
                                        material.title.isNotEmpty
                                            ? material.title
                                            : 'Materi #${material.id}',
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (material.category.isNotEmpty) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          material.category,
                                          style: AppTextStyles.labelSm.copyWith(
                                            color: context.appColors.primary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (material.fileUrl.isNotEmpty)
                                  Icon(
                                    Icons.open_in_new_rounded,
                                    color: context.appColors.outline,
                                    size: 20,
                                  ),
                              ],
                            ),
                            if (material.description.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                material.description,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.onSurfaceVariant,
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            if (material.uploadedAt.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                material.uploadedAt,
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
                  }, childCount: provider.materials.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

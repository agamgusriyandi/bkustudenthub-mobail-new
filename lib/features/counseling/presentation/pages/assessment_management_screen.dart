import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

class AssessmentManagementScreen extends StatefulWidget {
  const AssessmentManagementScreen({super.key});

  @override
  State<AssessmentManagementScreen> createState() =>
      _AssessmentManagementScreenState();
}

class _AssessmentManagementScreenState
    extends State<AssessmentManagementScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = [
    'Semua',
    'Kesehatan Mental',
    'Kepribadian',
    'Minat Bakat',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CounselingProvider>().loadAssessments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CounselingProvider>(
      builder: (context, provider, _) {
        final data = provider.assessments;
        final submissions = data['submissions'] as List? ?? [];
        final categories = data['categories'] as List? ?? [];
        final mentalScore = data['mental_score'] as int? ?? 0;
        final verificationQueue = data['verification_queue'] as List? ?? [];

        final filtered =
            _selectedCategory == 'Semua'
                ? submissions
                : submissions
                    .where((s) => (s as Map)['category'] == _selectedCategory)
                    .toList();

        // Stats: total & urgent
        final urgent =
            submissions.where((s) {
              final score = (s as Map)['score']?.toString() ?? '';
              return score == 'Tinggi' ||
                  score == 'Berat' ||
                  score == 'Mendesak';
            }).length;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateAssessmentDialog(provider),
            backgroundColor: AppColors.success,
            elevation: 4,
            icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Buat Asesmen',
              style: AppTextStyles.bodyMd.copyWith(
                color: context.appColors.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: CustomScrollView(
            slivers: [
              const BkuAppBar(
                title: 'Manajemen Asesmen',
                isExpandable: false,
                variant: AppBarVariant.psychologist,
                showBackButton: true,
              ),
              SliverToBoxAdapter(
                child:
                    provider.assessmentsLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                        )
                        : Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatsRow(
                                submissions.length,
                                urgent,
                                mentalScore,
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              _buildSectionHeader('Kategori Asesmen'),
                              const SizedBox(height: AppSpacing.md),
                              _buildCategoryCards(categories),
                              if (verificationQueue.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.xxl),
                                _buildVerificationQueue(verificationQueue),
                              ],
                              const SizedBox(height: AppSpacing.xxl),
                              _buildSectionHeader('Filter'),
                              const SizedBox(height: AppSpacing.md),
                              _buildCategoryFilter(),
                              const SizedBox(height: AppSpacing.xl),
                              _buildSectionHeader('Hasil Asesmen'),
                              const SizedBox(height: AppSpacing.lg),
                              filtered.isEmpty
                                  ? _buildEmpty()
                                  : Column(
                                    children:
                                        filtered
                                            .map(
                                              (a) => _buildAssessmentCard(
                                                a as Map<String, dynamic>,
                                              ),
                                            )
                                            .toList(),
                                  ),
                              const SizedBox(height: AppSpacing.s100),
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

  Widget _buildStatsRow(int total, int urgent, int mentalScore) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Asesmen',
            '$total',
            Icons.assignment_rounded,
            AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Butuh Atensi',
            '$urgent',
            Icons.warning_amber_rounded,
            AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            'Skor Mental',
            '$mentalScore%',
            Icons.psychology_rounded,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return BkuCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCards(List categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final Map<String, Map<String, dynamic>> categoryStyle = {
      'Kesehatan Mental': {
        'icon': Icons.favorite_rounded,
        'color': AppColors.error,
      },
      'Kepribadian': {'icon': Icons.psychology_rounded, 'color': AppColors.neutral700},
      'Minat Bakat': {
        'icon': Icons.track_changes_rounded,
        'color': context.appColors.warning,
      },
      'Lainnya': {'icon': Icons.auto_awesome_rounded, 'color': context.appColors.info},
    };

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i] as Map<String, dynamic>;
        final name = cat['name']?.toString() ?? 'Lainnya';
        final count = cat['count'] ?? 0;

        final style =
            categoryStyle[name] ??
            {'icon': Icons.category_rounded, 'color': AppColors.primary};
        final icon = style['icon'] as IconData;
        final color = style['color'] as Color;

        return BkuCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.paddingSm,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: AppTextStyles.titleMd.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                    ),
                    Text(
                      name,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVerificationQueue(List queue) {
    if (queue.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Antrean Verifikasi'),
        const SizedBox(height: AppSpacing.md),
        Column(
          children:
              queue.map((item) {
                final map = item as Map<String, dynamic>;
                final name = map['name']?.toString() ?? '';
                final count = map['count'] ?? 0;

                return BkuCard(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.appColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withAlpha(20),
                          borderRadius: AppRadius.radiusSm,
                        ),
                        child: Text(
                          '$count Menunggu',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;
          
          Color getCategoryColor(String c) {
            switch (c) {
              case 'Kesehatan Mental':
                return AppColors.error;
              case 'Kepribadian':
                return AppColors.neutral700;
              case 'Minat Bakat':
                return context.appColors.warning;
              case 'Lainnya':
                return context.appColors.info;
              default:
                return AppColors.primary;
            }
          }
          final catColor = getCategoryColor(cat);

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: isSelected ? catColor : context.appColors.surface,
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: isSelected ? catColor : AppColors.neutral300.withAlpha(30),
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: AppTextStyles.labelSm.copyWith(
                    color: isSelected ? context.appColors.onPrimary : AppColors.neutral600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.neutral300,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada asesmen',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> a) {
    final score = a['score']?.toString() ?? '-';
    final status = a['status']?.toString() ?? '-';
    final name = a['name']?.toString() ?? '-';
    final assessment = a['assessment']?.toString() ?? '-';
    final category = a['category']?.toString() ?? '-';
    final date = a['date']?.toString() ?? '-';

    Color scoreColor = AppColors.success;
    if (score == 'Sedang' || score == 'Netral') scoreColor = AppColors.warning;
    if (score == 'Tinggi' || score == 'Berat' || score == 'Mendesak' || score == 'Indikasi Depresi' || score == 'Risiko Tinggi') {
      scoreColor = AppColors.error;
    }

    Color iconColor = AppColors.primary;
    IconData icon = Icons.assignment_rounded;
    if (category == 'Kesehatan Mental') {
      iconColor = AppColors.error;
      icon = Icons.favorite_rounded;
    } else if (category == 'Kepribadian') {
      iconColor = AppColors.neutral700;
      icon = Icons.psychology_rounded;
    } else if (category == 'Minat Bakat') {
      iconColor = context.appColors.warning;
      icon = Icons.track_changes_rounded;
    } else if (category == 'Lainnya') {
      iconColor = context.appColors.info;
      icon = Icons.auto_awesome_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.neutral300.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(15),
                  borderRadius: AppRadius.radiusLg,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyLg.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppColors.neutral900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      assessment,
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scoreColor.withAlpha(15),
                  borderRadius: AppRadius.radiusMd,
                  border: Border.all(color: scoreColor.withAlpha(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skor/Hasil',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s2),
                    Text(
                      score,
                      style: AppTextStyles.labelMd.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildInfoChip(Icons.calendar_today_rounded, date),
                ),
                Expanded(child: _buildInfoChip(Icons.category_rounded, category)),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _buildInfoChip(Icons.info_outline_rounded, status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.neutral500),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.titleMd.copyWith(
        fontWeight: FontWeight.w900,
        color: AppColors.neutral900,
      ),
    );
  }

  void _showCreateAssessmentDialog(CounselingProvider provider) {
    final nameCtrl = TextEditingController();
    String selectedCategory = 'Kesehatan Mental';
    final descCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final themeProvider = ctx.watch<ThemeProvider>();
            final primaryColor = themeProvider.primary;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: BkuCard(
                backgroundColor: AppColors.neutral200,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.xl),
                      ),
                    ),
                    Text(
                      'Buat Asesmen Baru',
                      style: AppTextStyles.titleLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Lengkapi data di bawah ini untuk membuat asesmen.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.neutral500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      padding: AppSpacing.padding20,
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        borderRadius: AppRadius.radiusXl,
                        border: Border.all(
                          color: primaryColor.withAlpha(15),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withAlpha(4),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BkuTextField(
                            controller: nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Nama Asesmen',
                              labelStyle: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: const BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: const BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuDropdown<String>(
                            initialValue: selectedCategory,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.neutral500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Kategori',
                              labelStyle: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: const BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: const BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                            items:
                                [
                                      'Kesehatan Mental',
                                      'Kepribadian',
                                      'Minat Bakat',
                                      'Lainnya',
                                    ]
                                    .map(
                                      (e) => DropdownMenuItem(
                                        value: e,
                                        child: Text(e),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) =>
                                    setSheetState(() => selectedCategory = v!),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuTextField(
                            controller: descCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Deskripsi',
                              alignLabelWithHint: true,
                              labelStyle: AppTextStyles.bodyMd.copyWith(
                                color: AppColors.neutral500,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: const BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: const BorderSide(
                                  color: AppColors.neutral200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.radiusMd,
                                borderSide: BorderSide(color: primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Row(
                      children: [
                        Expanded(
                          child: BkuButton(
                            text: 'Batal',
                            variant: BkuButtonVariant.outline,
                            customFgColor: context.appColors.onSurface,
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: BkuButton(
                            text: 'Buat Asesmen',
                            customBgColor: AppColors.success,
                            onPressed: () async {
                              if (nameCtrl.text.trim().isEmpty) return;
                              Navigator.pop(ctx);
                              BkuLoadingDialog.show(context);
                              final success = await provider.createAssessment({
                                'nama': nameCtrl.text.trim(),
                                'kategori': selectedCategory,
                                'deskripsi': descCtrl.text.trim(),
                              });
                              if (mounted) {
                                BkuLoadingDialog.hide(context);
                                AppSnackbar.showError(
                                  context,
                                  success
                                      ? 'Asesmen berhasil dibuat'
                                      : 'Gagal membuat asesmen',
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
          );
        },
        );
      },
    );
  }
}

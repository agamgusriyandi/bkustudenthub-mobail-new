import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/scholarship.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_application_detail_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/apply_scholarship_screen.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/rejection_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';

class ScholarshipScreen extends StatefulWidget {
  const ScholarshipScreen({super.key});

  @override
  State<ScholarshipScreen> createState() => _ScholarshipScreenState();
}

class _ScholarshipScreenState extends State<ScholarshipScreen> {
  String _selectedCategory = 'Semua';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await context.read<StudentProvider>().loadAllData();
    } catch (_) { /* Silenced: non-critical parse fallback */ }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  String _formatDeadline(String deadlineRaw) {
    if (deadlineRaw.isEmpty) return '—';
    try {
      final parsed = DateTime.parse(deadlineRaw);
      final months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember',
      ];
      return "${parsed.day} ${months[parsed.month - 1]} ${parsed.year}";
    } catch (_) {
      if (deadlineRaw.contains('T')) {
        return deadlineRaw.split('T').first;
      }
      return deadlineRaw;
    }
  }

  String _formatCurrency(String amountStr) {
    try {
      final amount = double.tryParse(amountStr) ?? 0.0;
      if (amount == 0.0) return 'Bantuan Biaya';
      final formatted = amount
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
      return "Rp $formatted";
    } catch (_) {
      return amountStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = context.watch<StudentProvider>();
    final appliedScholarships =
        student.scholarships
            .where((s) => s.status == 'Applied' || s.applicationStatus != null)
            .toList();
    final availableScholarships =
        student.scholarships.where((s) {
          if (_selectedCategory != 'Semua' &&
              s.category.toLowerCase() != _selectedCategory.toLowerCase()) {
            return false;
          }
          if (s.status.toLowerCase() != 'open' &&
              s.status.toLowerCase() != 'applied') {
            return false;
          }

          if (s.applicationStatus == null) return true;

          String appStatus = s.applicationStatus!.toLowerCase();
          String mainStatus = s.status.toLowerCase();
          bool isRejected =
              appStatus.contains('ditolak') || mainStatus.contains('ditolak');

          // Show if they were rejected. Hide if active or accepted.
          return isRejected;
        }).toList();

    final appliedCount =
        student.scholarships
            .where(
              (s) =>
                  s.status.toLowerCase() == 'applied' ||
                  s.applicationStatus != null,
            )
            .length;
    final availableCount =
        student.scholarships
            .where(
              (s) =>
                  s.status.toLowerCase() == 'open' &&
                  s.applicationStatus == null,
            )
            .length;

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: 'Beasiswa & Bantuan',
              subtitle: 'Program Kampus',
              variant: AppBarVariant.student,
              expandedHeight: 130,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FadeInAnimation(
                        delay: 0.2,
                        child: _buildDashboardCard(
                          appliedCount,
                          availableCount,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    if (_isLoading) ...[
                      FadeInAnimation(
                        delay: 0.4,
                        child: _buildSectionHeader(
                          'Memuat Data...',
                          Icons.sync_rounded,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const BkuShimmerList(itemCount: 3, itemHeight: 120),
                    ] else ...[
                      if (appliedScholarships.isNotEmpty) ...[
                        FadeInAnimation(
                          delay: 0.4,
                          child: _buildSectionHeader(
                            'Pendaftaran Saya',
                            Icons.pending_actions_rounded,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...List.generate(
                          appliedScholarships.length,
                          (index) => FadeInAnimation(
                            delay: 0.5 + (index * 0.1),
                            child: _buildAppliedCard(
                              appliedScholarships[index],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                      ],

                      FadeInAnimation(
                        delay: 0.6,
                        child: _buildSectionHeader(
                          'Katalog Beasiswa',
                          Icons.grid_view_rounded,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      if (availableScholarships.isEmpty)
                        _buildEmptyState(
                          student.scholarships.length,
                          availableCount,
                          appliedCount,
                        )
                      else
                        ...List.generate(
                          availableScholarships.length,
                          (index) => _buildScholarshipCard(
                            availableScholarships[index],
                          ),
                        ),
                    ],
                    const SizedBox(height: AppSpacing.s120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: AppSpacing.paddingSm,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: AppRadius.br10,
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          title,
          style: TextStyle(
            color: context.appColors.secondary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Semua', 'Internal', 'Mitra', 'Eksternal'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) {
              bool isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = category);
                  },
                  selectedColor: AppColors.primary.withAlpha(20),
                  labelStyle: AppTextStyles.labelSm.copyWith(
                    color:
                        isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: context.appColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusLg,
                    side: BorderSide(
                      color:
                          isSelected
                              ? AppColors.primary
                              : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  elevation: isSelected ? 4 : 0,
                  pressElevation: 0,
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAppliedCard(Scholarship scholarship) {
    final status = (scholarship.applicationStatus ?? '').toLowerCase();
    final isRejected = status.contains('ditolak');
    final isAccepted = status.contains('diterima') || status.contains('lulus');

    String badgeText = 'TERDAFTAR';
    Color badgeColor = AppColors.neutral800;

    if (isRejected) {
      badgeText = 'DITOLAK';
      badgeColor = AppColors.error;
    } else if (isAccepted) {
      badgeText = 'DITERIMA';
      badgeColor = AppColors.success;
    } else {
      badgeText = 'TERDAFTAR';
      badgeColor = AppColors.neutral800;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
      color: context.appColors.surface,
      borderRadius: AppRadius.radiusXl,
      border: Border.all(color: AppColors.neutral200.withAlpha(150)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ScholarshipApplicationDetailScreen(
                    scholarship: scholarship,
                  ),
            ),
          );
        },
        borderRadius: AppRadius.radiusXl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Text(
                      scholarship.category,
                      style: AppTextStyles.labelSm.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                        color: AppColors.neutral700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withAlpha(15),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Text(
                      badgeText,
                      style: AppTextStyles.labelSm.copyWith(
                        color: badgeColor,
                        fontWeight: FontWeight.w900,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                scholarship.title,
                style: AppTextStyles.labelMd.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              Text(
                scholarship.provider,
                style: AppTextStyles.labelSm.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _buildTimeline(scholarship.applicationStatus ?? 'Review Berkas'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline(String currentStatus) {
    final bool isRejected = currentStatus.toLowerCase().contains('ditolak');
    final stages = [
      'Pengajuan',
      'Berkas',
      'Evaluasi',
      'Review',
      'Penetapan',
      isRejected ? 'Ditolak' : 'Hasil',
    ];
    final int currentIndex = _getStageIndex(currentStatus);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(stages.length, (index) {
        final bool isCompletedPast = index < currentIndex;
        final bool isCurrent = index == currentIndex;
        final bool isDone = index <= currentIndex;
        final bool isLast = index == stages.length - 1;

        Color circleColor;
        Color textColor;
        if (isCurrent) {
          circleColor = isRejected ? AppColors.error : AppColors.primary;
          textColor = circleColor;
        } else if (isCompletedPast) {
          circleColor = AppColors.success;
          textColor = AppColors.success;
        } else {
          circleColor = AppColors.neutral200;
          textColor = AppColors.neutral500;
        }

        return Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        border:
                            isCurrent
                                ? Border.all(
                                  color: circleColor.withAlpha(60),
                                  width: 3,
                                )
                                : null,
                      ),
                      child: Center(
                        child:
                            isCompletedPast
                                ? Icon(
                                  Icons.check_rounded,
                                  size: 10,
                                  color: context.appColors.onPrimary,
                                )
                                : isCurrent && isRejected
                                ? Icon(
                                  Icons.close_rounded,
                                  size: 10,
                                  color: context.appColors.onPrimary,
                                )
                                : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        stages[index].toTitleCase(),
                        style: AppTextStyles.labelSm.copyWith(
                          fontSize: 10,
                          fontWeight:
                              isDone ? FontWeight.w900 : FontWeight.normal,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(top: AppSpacing.sm),
                    color:
                        index < currentIndex
                            ? AppColors.success
                            : AppColors.neutral200,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  int _getStageIndex(String status) {
    final s = status.toLowerCase();

    if (s.contains('pengajuan') || s == 'menunggu') return 0;
    if (s.contains('berkas')) return 1;
    if (s.contains('evaluasi') || s.contains('wawancara') || s == 'proses') {
      return 2;
    }
    if (s.contains('review')) return 3;
    if (s.contains('penetapan')) return 4;
    if (s.contains('hasil') ||
        s.contains('diterima') ||
        s.contains('ditolak') ||
        s.contains('lulus')) {
      return 5;
    }

    return 0;
  }

  Map<String, dynamic> _getScholarshipStyle(String category, String title) {
    final cat = category.toLowerCase();
    final t = title.toLowerCase();

    if (cat.contains('internal') || t.contains('internal')) {
      return {
        'icon': Icons.school_rounded,
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFEFF6FF),
      };
    } else if (cat.contains('mitra') ||
        t.contains('mitra') ||
        t.contains('bank') ||
        t.contains('bni') ||
        t.contains('bri')) {
      return {
        'icon': Icons.handshake_rounded,
        'color': const Color(0xFF0D9488),
        'bg': const Color(0xFFF0FDFA),
      };
    } else if (cat.contains('eksternal') ||
        t.contains('diktis') ||
        t.contains('kemendikbud') ||
        t.contains('kemenag')) {
      return {
        'icon': Icons.account_balance_rounded,
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFF5F3FF),
      };
    } else if (cat.contains('prestasi') ||
        t.contains('prestasi') ||
        t.contains('juara')) {
      return {
        'icon': Icons.emoji_events_rounded,
        'color': const Color(0xFFE11D48),
        'bg': const Color(0xFFFFF1F2),
      };
    } else {
      return {
        'icon': Icons.workspace_premium_rounded,
        'color': const Color(0xFF0284C7),
        'bg': const Color(0xFFF0F9FF),
      };
    }
  }

  Widget _buildScholarshipCard(Scholarship scholarship) {
    final style = _getScholarshipStyle(scholarship.category, scholarship.title);
    final Color iconColor = style['color'] as Color;
    final Color iconBg = style['bg'] as Color;
    final IconData cardIcon = style['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s14),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showScholarshipDetail(context, scholarship),
          borderRadius: AppRadius.radiusLg,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppSpacing.padding10,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(
                    cardIcon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: AppRadius.br6,
                            ),
                            child: Text(
                              scholarship.category.toUpperCase(),
                              style: TextStyle(
                                color: iconColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            _formatCurrency(scholarship.coverAmount),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: context.appColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        scholarship.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s2),
                      Text(
                        scholarship.provider,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.s14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: AppColors.error,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    _formatDeadline(scholarship.deadline),
                                    style: const TextStyle(
                                      color: AppColors.error,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Builder(
                            builder: (context) {
                              String appStatus =
                                  (scholarship.applicationStatus ?? '')
                                      .toLowerCase();
                              String mainStatus =
                                  scholarship.status.toLowerCase();
                              bool isRejected =
                                  appStatus.contains('ditolak') ||
                                  mainStatus.contains('ditolak');

                              if (isRejected) {
                                return SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      AppSnackbar.showError(
                                        context,
                                        'Anda sudah pernah ditolak dari program ini.',
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.neutral300,
                                      foregroundColor: AppColors.neutral700,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: AppRadius.br10,
                                      ),
                                    ),
                                    child: const Text(
                                      'Ditolak',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              return SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _checkAndNavigateToApply(
                                      context,
                                      scholarship,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: context.appColors.onPrimary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.br10,
                                    ),
                                  ),
                                  child: const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'internal':
        return AppColors.primary;
      case 'mitra':
        return AppColors.success;
      case 'eksternal':
      case 'prestasi':
        return AppColors.neutral800;
      default:
        return AppColors.neutral800;
    }
  }

  Widget _buildEmptyState(int totalData, int availableCount, int appliedCount) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const Icon(Icons.search_off_rounded, size: 64, color: AppColors.neutral500),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              'Beasiswa tidak ditemukan',
              style: TextStyle(color: AppColors.neutral500),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndNavigateToApply(
    BuildContext context,
    Scholarship scholarship,
  ) async {
    if (!context.mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyScholarshipScreen(scholarship: scholarship),
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  void _showScholarshipDetail(BuildContext context, Scholarship scholarship) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(
                                        scholarship.category,
                                      ).withAlpha(15),
                                      borderRadius: AppRadius.radiusMd,
                                    ),
                                    child: Text(
                                      scholarship.category.toUpperCase(),
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: _getCategoryColor(
                                          scholarship.category,
                                        ),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(scholarship.coverAmount),
                                    style: AppTextStyles.titleLg.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                scholarship.title,
                                style: const TextStyle(
                                  color: Color(0xFF111827),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                scholarship.provider,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _buildDetailCard(
                                    'Nilai Bantuan',
                                    _formatCurrency(scholarship.coverAmount),
                                    Icons.payments_outlined,
                                  ),
                                  if (scholarship.kuota != null &&
                                      scholarship.kuota!.isNotEmpty)
                                    _buildDetailCard(
                                      'Kuota',
                                      '${scholarship.kuota} Org',
                                      Icons.group_outlined,
                                    ),
                                  if (scholarship.minIpk != null &&
                                      scholarship.minIpk!.isNotEmpty)
                                    _buildDetailCard(
                                      'Min. IPK',
                                      scholarship.minIpk!,
                                      Icons.school_outlined,
                                    ),
                                  _buildDetailCard(
                                    'Deadline',
                                    _formatDeadline(scholarship.deadline),
                                    Icons.calendar_today_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                'Deskripsi Program',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                scholarship.description,
                                style: AppTextStyles.bodyMd.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxl),
                              Text(
                                'Persyaratan Umum',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ...() {
                                final reqStr = scholarship.persyaratan;
                                final requirementsList =
                                    (reqStr != null && reqStr.trim().isNotEmpty)
                                        ? reqStr
                                            .split('\n')
                                            .map((line) {
                                              return line
                                                  .replaceFirst(
                                                    RegExp(r'^[-*•\s\u2022]+'),
                                                    '',
                                                  )
                                                  .trim();
                                            })
                                            .where((line) => line.isNotEmpty)
                                            .toList()
                                        : [
                                          'Mahasiswa Aktif Universitas Bhakti Kencana',
                                          'IPK Minimal 3.00 (Skala 4.00)',
                                          'Tidak sedang menerima beasiswa lain',
                                          'Berkelakuan baik & aktif berorganisasi',
                                        ];
                                return requirementsList
                                    .map((req) => _buildRequirementItem(req))
                                    .toList();
                              }(),
                              const SizedBox(height: AppSpacing.xxl),
                              ...() {
                                List<dynamic> customFields = [];
                                if (scholarship.customFieldsRaw != null) {
                                  try {
                                    final raw = scholarship.customFieldsRaw;
                                    if (raw is String) {
                                      customFields = jsonDecode(raw);
                                    } else if (raw is List) {
                                      customFields = raw;
                                    }
                                  } catch (_) { /* Silenced: non-critical parse fallback */ }
                                }

                                if (customFields.isEmpty) {
                                  return [const SizedBox.shrink()];
                                }

                                return [
                                  Text(
                                    'Persyaratan Tambahan',
                                    style: AppTextStyles.titleLg.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  ...customFields.map((field) {
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                                      padding: const EdgeInsets.all(
                                        AppSpacing.lg,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withAlpha(20),
                                        borderRadius: AppRadius.radiusMd,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.outline.withAlpha(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              field['description'] ??
                                                  field['label'] ??
                                                  field['name'] ??
                                                  'Dokumen Pendukung',
                                              style: AppTextStyles.labelMd
                                                  .copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withAlpha(20),
                                              borderRadius: AppRadius.radiusXs,
                                            ),
                                            child: Text(
                                              (field['type'] ?? 'TEXT')
                                                  .toString()
                                                  .toUpperCase(),
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 10,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: AppSpacing.xxl),
                                ];
                              }(),
                              Text(
                                'Tahapan Seleksi',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Cakupan Beasiswa',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              BkuCard(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      color: context.appColors.warning,
                                      size: 24,
                                    ),
                                    const SizedBox(width: AppSpacing.lg),
                                    Expanded(
                                      child: Text(
                                        _formatCurrency(
                                          scholarship.coverAmount,
                                        ),
                                        style: AppTextStyles.labelMd.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    children: [
                      if (scholarship.status == 'Applied') ...[
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: BkuButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              showRejectionBottomSheet(context, scholarship);
                            },
                            icon: Icons.edit_note_rounded,
                            text: 'Ubah Data Pendaftaran',
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton.icon(
                            onPressed:
                                () => _showCancelConfirmation(
                                  context,
                                  scholarship,
                                ),
                            icon: Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.neutral800,
                            ),
                            label: Text(
                              'Batalkan Pendaftaran',
                              style: TextStyle(
                                color: AppColors.neutral800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: TextButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text(
                              'Tutup',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: SizedBox(
                                height: 44,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(sheetContext),
                                  style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: context.appColors.primary,
                                        width: 1.5,
                                    ),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: AppRadius.radiusMd,
                                    ),
                                  ),
                                      child: Center(
                                        child: Text(
                                          'Tutup',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: context.appColors.primary,
                                            fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              flex: 1,
                              child: Builder(
                                builder: (context) {
                                  String appStatus =
                                      (scholarship.applicationStatus ?? '')
                                          .toLowerCase();
                                  String mainStatus =
                                      scholarship.status.toLowerCase();
                                  bool isRejected =
                                      appStatus.contains('ditolak') ||
                                      mainStatus.contains('ditolak');

                                  if (isRejected) {
                                    return SizedBox(
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(sheetContext);
                                          AppSnackbar.showError(
                                            context,
                                            'Anda sudah pernah ditolak dari program ini.',
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.neutral300,
                                          foregroundColor: AppColors.neutral700,
                                          elevation: 0,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                             borderRadius: AppRadius.radiusMd,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Ditolak',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  return SizedBox(
                                    height: 44,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(sheetContext);
                                        _checkAndNavigateToApply(
                                          context,
                                          scholarship,
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: context.appColors.primary,
                                        foregroundColor: context.appColors.onPrimary,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                           borderRadius: AppRadius.radiusMd,
                                        ),
                                      ),
                                      child: const Center(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                            ),
                                            child: Text(
                                              'Daftar Sekarang',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showCancelConfirmation(BuildContext context, Scholarship scholarship) {
    showDialog(
      context: context,
      builder: (sheetContext) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (dialogStateContext, setState) {
            return CustomDialog(
              title: 'Batalkan Pendaftaran?',
              content:
                  'Semua data pendaftaran yang telah kamu isi akan dihapus permanen.',
              cancelText: 'Kembali',
              confirmText: 'Ya, Batalkan',
              isDestructive: true,
              isLoading: isLoading,
              onCancel: () => Navigator.pop(sheetContext),
              onConfirm: () {
                setState(() => isLoading = true);

                final studentProvider = context.read<StudentProvider>();
                // Fire and forget async call to avoid VoidCallback issues
                Future<void>(() async {
                  if (!mounted) return;
                  try {
                    await studentProvider.cancelScholarshipApplication(
                      scholarship.id,
                    );
                    if (mounted && sheetContext.mounted) {
                      Navigator.pop(sheetContext); // Close dialog
                      if (context.mounted) {
                        Navigator.pop(context); // Close modal detail
                      }
                      AppSnackbar.showError(
                        context,
                        'Pendaftaran berhasil dibatalkan',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      setState(() => isLoading = false);
                      AppSnackbar.showError(context, 'Gagal membatalkan: $e');
                    }
                  }
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.labelMd.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200.withAlpha(150)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.padding6,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.titleMd.copyWith(
              color: AppColors.neutral900,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(int appliedCount, int openCount) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCategoryFilter(),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(appliedCount.toString(), 'Pendaftaran Saya'),
              Container(width: 1, height: 30, color: AppColors.neutral300),
              _buildStat(openCount.toString(), 'Peluang Terbuka'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLg.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w900,
            fontSize: 24,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

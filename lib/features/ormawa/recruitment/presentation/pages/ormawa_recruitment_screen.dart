import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';

import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';


// Domain & Sub-components
import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_applicant_card.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_applicant_detail_modal.dart';

class OrmawaRecruitmentScreen extends StatefulWidget {
  const OrmawaRecruitmentScreen({super.key});

  @override
  State<OrmawaRecruitmentScreen> createState() =>
      _OrmawaRecruitmentScreenState();
}

class _OrmawaRecruitmentScreenState extends State<OrmawaRecruitmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isFabExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().getRecruitmentApplicants();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showDetailModal(BuildContext context, Map<String, dynamic> applicant) {
    final provider = context.read<OrmawaProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => RecruitmentApplicantDetailModal(
            applicant: RecruitmentApplicant(
              name: applicant['name'] ?? '',
              nim: applicant['nim'] ?? '',
              prodi: applicant['prodi'] ?? '',
              ipk: double.tryParse(applicant['ipk']?.toString() ?? '0') ?? 0.0,
              divisi1: applicant['divisi1'] ?? '',
              divisi2: applicant['divisi2'] ?? '',
              status: applicant['status'] ?? 'pending',
              alasan: applicant['alasan'] ?? '',
              cvUrl: applicant['cv_url'] ?? applicant['CVURL'] ?? '',
              customAnswers:
                  applicant['custom_answers'] is Map
                      ? Map<String, dynamic>.from(
                        applicant['custom_answers'] as Map,
                      )
                      : {},
            ),
            formFields: provider.recruitmentFormFields,
            onAccept: () async {
              try {
                await context.read<OrmawaProvider>().reviewRecruitmentApplicant(
                  applicant['id'].toString(),
                  'accepted',
                );
                if (context.mounted) context.pop();
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context, 'Gagal menerima: $e');
                }
              }
            },
            onReject: () async {
              try {
                await context.read<OrmawaProvider>().reviewRecruitmentApplicant(
                  applicant['id'].toString(),
                  'rejected',
                );
                if (context.mounted) context.pop();
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context, 'Gagal menolak: $e');
                }
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      floatingActionButton: _buildExpandableFab(),
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final allApplicants = provider.recruitmentApplicants;
          final applicants =
              allApplicants.where((a) {
                final matchesSearch =
                    _searchQuery.isEmpty ||
                    (a['name']?.toString().toLowerCase().contains(
                          _searchQuery,
                        ) ??
                        false) ||
                    (a['nim']?.toString().toLowerCase().contains(
                          _searchQuery,
                        ) ??
                        false);

                final status =
                    (a['status'] ?? 'pending').toString().toLowerCase();
                final matchesStatus =
                    _selectedStatusFilter == 'Semua' ||
                    (_selectedStatusFilter == 'Menunggu' &&
                        (status == 'pending' || status == 'menunggu')) ||
                    (_selectedStatusFilter == 'Diterima' &&
                        (status == 'accepted' || status == 'aktif')) ||
                    (_selectedStatusFilter == 'Ditolak' &&
                        (status == 'rejected' || status == 'ditolak'));

                return matchesSearch && matchesStatus;
              }).toList();

          return RefreshIndicator(
            onRefresh: () => provider.getRecruitmentApplicants(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Open Recruitment',
                  subtitle: 'Kelola Pendaftaran Anggota Baru',
                  expandedHeight: 130.0,
                  showBackButton: true,
                  isExpandable: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.lg,
                      left: AppSpacing.s20,
                      right: AppSpacing.s20,
                      bottom: AppSpacing.lg,
                    ),
                    child: OrmawaListHeader(
                      title: 'DAFTAR PENDAFTAR (${applicants.length})',
                      searchHint: 'Cari nama atau NIM...',
                      searchController: _searchController,
                      onRefresh: () => provider.getRecruitmentApplicants(),
                      onFilterTap: _showFilterSheet,
                      onChanged:
                          (value) => setState(
                            () => _searchQuery = value.toLowerCase(),
                          ),
                    ),
                  ),
                ),
                if (provider.isLoading && allApplicants.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                    ),
                  )
                else if (applicants.isEmpty)
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.05),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.people_alt_outlined,
                              size: 80,
                              color: context.appColors.primary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text(
                            'Belum Ada Pendaftar',
                            style: AppTextStyles.titleLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Daftar mahasiswa yang melamar ke ORMAWA ini akan muncul di sini.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.neutral600,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  context
                                      .watch<ThemeProvider>()
                                      .colors
                                      .infoContainer,
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color: context
                                    .watch<ThemeProvider>()
                                    .colors
                                    .info
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color:
                                      context
                                          .watch<ThemeProvider>()
                                          .colors
                                          .info,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(
                                    'Pastikan status Open Recruitment sudah dibuka pada menu Pengaturan.',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: AppColors.onInfoContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final applicant = applicants[index];
                        return RecruitmentApplicantCard(
                          applicant: RecruitmentApplicant(
                            name: applicant['name'] ?? '',
                            nim: applicant['nim'] ?? '',
                            prodi: applicant['prodi'] ?? '',
                            ipk:
                                double.tryParse(
                                  applicant['ipk']?.toString() ?? '0',
                                ) ??
                                0.0,
                            divisi1: applicant['divisi1'] ?? '',
                            divisi2: applicant['divisi2'] ?? '',
                            status: applicant['status'] ?? 'pending',
                            alasan: applicant['alasan'] ?? '',
                            cvUrl:
                                applicant['cv_url'] ?? applicant['CVURL'] ?? '',
                            customAnswers:
                                applicant['custom_answers'] is Map
                                    ? Map<String, dynamic>.from(
                                      applicant['custom_answers'] as Map,
                                    )
                                    : {},
                          ),
                          onReview: () => _showDetailModal(context, applicant),
                        );
                      }, childCount: applicants.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpandableFab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabExpanded) ...[
          _buildFabOption(
            icon: Icons.history_rounded,
            label: 'Riwayat Keputusan',
            color: AppColors.success,
            onTap: () {
              _toggleFab();
              context.push(AppRoutes.ormawaRecruitmentHistory);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFabOption(
            icon: Icons.list_alt_rounded,
            label: 'Form Builder',
            color: AppColors.neutral700,
            onTap: () {
              _toggleFab();
              context.push(AppRoutes.ormawaRecruitmentForm);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildFabOption(
            icon: Icons.settings_rounded,
            label: 'Pengaturan',
            color: AppColors.info,
            onTap: () {
              _toggleFab();
              context.push(AppRoutes.ormawaRecruitmentSettings);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        FloatingActionButton.extended(
          onPressed: _toggleFab,
          backgroundColor: context.appColors.primary,
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
            color: context.appColors.onPrimary,
          ),
          label: Text(
            _isFabExpanded ? 'Tutup' : 'Menu Utama',
            style: TextStyle(
              color: context.appColors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFabOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusSm,
              boxShadow: [
                BoxShadow(
                  color: context.appColors.onSurface.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        FloatingActionButton(
          heroTag: label, // Prevent hero animation conflicts
          mini: true,
          onPressed: onTap,
          backgroundColor: color,
          child: Icon(icon, color: context.appColors.onPrimary),
        ),
      ],
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Status',
                style: AppTextStyles.titleMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ...['Semua', 'Menunggu', 'Diterima', 'Ditolak'].map(
                (status) => ListTile(
                  title: Text(
                    status,
                    style: TextStyle(
                      fontWeight:
                          _selectedStatusFilter == status
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color:
                          _selectedStatusFilter == status
                              ? context.appColors.primary
                              : AppColors.neutral900,
                    ),
                  ),
                  trailing:
                      _selectedStatusFilter == status
                          ? Icon(
                            Icons.check_circle_rounded,
                            color: context.appColors.primary,
                          )
                          : Icon(
                            Icons.circle_outlined,
                            color: AppColors.neutral300,
                          ),
                  onTap: () {
                    setState(() => _selectedStatusFilter = status);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}


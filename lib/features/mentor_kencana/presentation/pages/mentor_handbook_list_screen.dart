import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MentorHandbookListScreen extends StatefulWidget {
  const MentorHandbookListScreen({super.key});

  @override
  State<MentorHandbookListScreen> createState() => _MentorHandbookListScreenState();
}

class _MentorHandbookListScreenState extends State<MentorHandbookListScreen> {
  String _searchQuery = '';
  String _selectedFacultyFilter = 'all';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final prov = context.read<MentorKencanaProvider>();
        prov.fetchAllMentees();
        prov.fetchScoreComponents();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenteeData> _getFilteredMentees(List<MenteeData> mentees) {
    return mentees.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = m.name.toLowerCase().contains(q);
        final matchNim = m.nim.toLowerCase().contains(q);
        if (!matchName && !matchNim) return false;
      }
      if (_selectedFacultyFilter != 'all') {
        if (m.faculty.toLowerCase() != _selectedFacultyFilter.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final allMentees = provider.allMentees.where((m) => m.status.toLowerCase() == 'active').toList();
    final filteredMentees = _getFilteredMentees(allMentees);

    final uniqueFaculties = allMentees
        .map((m) => m.faculty.trim())
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final isHandbookDisabled = provider.isHandbookDisabled;

    if (isHandbookDisabled) {
      final scopeType = provider.scoreComponents?['scope_type'] as String? ?? 'faculty';
      return Scaffold(
        backgroundColor: context.appColors.surface,
        body: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Persetujuan Handbook',
              info: 'Evaluasi dan setujui lembar handbook mahasiswa bimbingan Anda.',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () => context.pop(),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            color: AppColors.warningContainer,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.warning.withAlpha(40)),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: 48,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'Persetujuan Handbook Dinonaktifkan',
                          style: AppTextStyles.titleSm.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Berdasarkan konfigurasi penilaian yang sedang berlaku, fitur persetujuan handbook dinonaktifkan untuk Fasilitator tingkat ${scopeType == 'faculty' ? 'Faculty' : 'University'}.',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.neutral500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          await provider.fetchAllMentees();
          await provider.fetchScoreComponents();
        },
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Persetujuan Handbook',
              info: 'Evaluasi dan setujui lembar handbook mahasiswa.',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () => context.pop(),
            ),
            
            // Header Stats & Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Handbook Mahasiswa',
                                style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Pilih mahasiswa di bawah ini untuk proses persetujuan.',
                                style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neutral100,
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(color: AppColors.neutral300),
                          ),
                          child: Text(
                            'Total Data ${filteredMentees.length}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral900,
                              fontWeight: FontWeight.w700,
                              fontSize: 9.5,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Search Bar
                    BkuTextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      hint: 'Cari NIM, Nama...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Filter Dropdown
                    if (uniqueFaculties.isNotEmpty)
                      BkuDropdown<String>(
                        initialValue: _selectedFacultyFilter,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                        ),
                        style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                        items: [
                          const DropdownMenuItem(value: 'all', child: Text('Semua Fakultas')),
                          ...uniqueFaculties.map((f) => DropdownMenuItem(value: f, child: Text(f))),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedFacultyFilter = val);
                        },
                      ),
                  ],
                ),
              ),
            ),

            if (provider.isLoading && provider.groups.isEmpty)
              const SliverFillRemaining(
                child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()),
              )
            else if (provider.errorMessage != null && provider.groups.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: context.appColors.error),
                  ),
                ),
              )
            else if (filteredMentees.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Belum ada mahasiswa yang terdaftar.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: 120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final mentee = filteredMentees[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
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
                                ),
                                child: ClipOval(
                                  child: mentee.avatarUrl != null && mentee.avatarUrl!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: ApiGate.getImageUrl(mentee.avatarUrl),
                                          width: 44,
                                          height: 44,
                                          fit: BoxFit.cover,
                                          errorWidget: (context, error, stackTrace) => Center(
                                            child: Text(
                                              mentee.name.isNotEmpty ? mentee.name.substring(0, 1) : '',
                                              style: TextStyle(
                                                color: context.appColors.onSurface,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          placeholder: (context, url) => Container(color: AppColors.neutral200),
                                        )
                                      : Center(
                                          child: Text(
                                            mentee.name.isNotEmpty ? mentee.name.substring(0, 1) : '',
                                            style: TextStyle(
                                              color: context.appColors.onSurface,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      mentee.name,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'NIM: ${mentee.nim}',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (mentee.faculty.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        mentee.faculty,
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: AppColors.neutral500,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Status Badge
                              Builder(
                                builder: (context) {
                                  final s = mentee.handbookStatus.toUpperCase();
                                  if (s == 'APPROVED' || s == 'DISETUJUI') {
                                    return const BkuStatusBadge(status: BkuStatus.success, customText: 'Disetujui');
                                  } else if (s == 'SUBMITTED' || s == 'WAITING_REVIEW' || s == 'MENUNGGU REVIEW') {
                                    return const BkuStatusBadge(status: BkuStatus.pending, customText: 'Menunggu Review');
                                  } else if (s == 'REJECTED' || s == 'REVISION' || s == 'DITOLAK') {
                                    return BkuStatusBadge(status: BkuStatus.error, customText: s == 'REVISION' ? 'Revisi' : 'Ditolak');
                                  } else {
                                    return const BkuStatusBadge(status: BkuStatus.inactive, customText: 'Belum Dikerjakan');
                                  }
                                }
                              ),
                              
                              SizedBox(
                                height: 32,
                                child: BkuButton(
                                  variant: BkuButtonVariant.outline,
                                  onPressed: () {
                                    context.push('/mentor-kencana/handbook/review/${mentee.id}?name=${Uri.encodeComponent(mentee.name)}');
                                  },
                                  icon: Icons.rate_review_outlined,
                                  text: 'Review Handbook',
                                  fontSize: 11,
                                  fullWidth: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }, childCount: filteredMentees.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

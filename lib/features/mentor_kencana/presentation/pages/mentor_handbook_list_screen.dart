import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
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
        context.read<MentorKencanaProvider>().fetchMentees();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenteeData> _getAllMentees(List<MenteeGroup> groups) {
    final List<MenteeData> list = [];
    for (var g in groups) {
      list.addAll(g.mentees);
    }
    return list;
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
    final allMentees = _getAllMentees(provider.groups);
    final filteredMentees = _getFilteredMentees(allMentees);

    final uniqueFaculties = allMentees
        .map((m) => m.faculty.trim())
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentees(),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.appColors.primary.withAlpha(20),
                            borderRadius: AppRadius.radiusXl,
                          ),
                          child: Text(
                            'Total Data ${filteredMentees.length}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: context.appColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari NIM, Nama...',
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
                        border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Filter Dropdown
                    if (uniqueFaculties.isNotEmpty)
                      DropdownButtonFormField<String>(
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
                                  color: context.appColors.primary.withAlpha(20),
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
                                                color: context.appColors.primary,
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
                                              color: context.appColors.primary,
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
                                        color: context.appColors.primary,
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
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral200.withAlpha(120),
                                  borderRadius: AppRadius.radiusXl,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 8, height: 8,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neutral400),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'BELUM DIKERJAKAN',
                                      style: TextStyle(
                                        color: AppColors.neutral600,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              SizedBox(
                                height: 32,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    context.push('/mentor-kencana/handbook/review/${mentee.id}?name=${Uri.encodeComponent(mentee.name)}');
                                  },
                                  icon: const Icon(Icons.rate_review_outlined, size: 16),
                                  label: Text(
                                    'Review Handbook',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: context.appColors.primary,
                                    side: BorderSide(color: context.appColors.primary.withAlpha(50)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                                    backgroundColor: context.appColors.primary.withAlpha(10),
                                  ),
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

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
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MentorMenteeScreen extends StatefulWidget {
  const MentorMenteeScreen({super.key});

  @override
  State<MentorMenteeScreen> createState() => _MentorMenteeScreenState();
}

class _MentorMenteeScreenState extends State<MentorMenteeScreen> {
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
              title: 'Daftar Bimbingan',
              info: 'Daftar mahasiswa yang Anda bimbing',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: false,
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
                                'Mahasiswa Aktif',
                                style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Daftar bimbingan beserta NIM, Prodi, dan Status.',
                                style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => context.push('/mentor-kencana/available-students'),
                          icon: const Icon(Icons.person_add_rounded, size: 14),
                          label: const Text('+ Tambah Bimbingan', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            elevation: 0,
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
                child: Center(child: CircularProgressIndicator()),
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
                      onTap: () => context.push('/mentor-kencana/mentee/${mentee.id}'),
                      child: Row(
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
                                          mentee.name.isNotEmpty ? mentee.name.substring(0, 1).toUpperCase() : '',
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
                                        mentee.name.isNotEmpty ? mentee.name.substring(0, 1).toUpperCase() : '',
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
                          const SizedBox(width: AppSpacing.sm),
                          
                          // Status Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(20),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              'DISETUJUI',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
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

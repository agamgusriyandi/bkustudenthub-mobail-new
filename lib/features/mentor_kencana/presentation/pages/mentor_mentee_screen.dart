import 'package:bkuhub_mobile/core/theme/app_colors.dart';
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

class MentorMenteeScreen extends StatefulWidget {
  const MentorMenteeScreen({super.key});

  @override
  State<MentorMenteeScreen> createState() => _MentorMenteeScreenState();
}

class _MentorMenteeScreenState extends State<MentorMenteeScreen> {
  String _searchQuery = '';
  String _selectedFacultyFilter = 'all';
  String _selectedStatusFilter = 'all';

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
      if (_selectedStatusFilter != 'all') {
        if (m.status != _selectedStatusFilter) {
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
                            backgroundColor: AppColors.success,
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

                    // Filter Dropdowns
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedStatusFilter,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            ),
                            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('Semua Status', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'active', child: Text('Disetujui', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'pending', child: Text('Pending', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'rejected', child: Text('Ditolak', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatusFilter = val);
                            },
                          ),
                        ),
                        if (uniqueFaculties.isNotEmpty) const SizedBox(width: AppSpacing.sm),
                        if (uniqueFaculties.isNotEmpty)
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedFacultyFilter,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                              ),
                              style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                              items: [
                                const DropdownMenuItem(value: 'all', child: Text('Semua Fakultas', overflow: TextOverflow.ellipsis)),
                                ...uniqueFaculties.map((f) => DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedFacultyFilter = val);
                              },
                            ),
                          ),
                      ],
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
                    int? groupId;
                    for (final g in provider.groups) {
                      if (g.mentees.any((m) => m.id == mentee.id)) {
                        groupId = g.id;
                        break;
                      }
                    }

                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      onTap: mentee.status == 'active' ? () => context.push('/mentor-kencana/mentee/${mentee.id}') : null,
                      child: Row(
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
                                          mentee.name.isNotEmpty ? mentee.name.substring(0, 1).toUpperCase() : '',
                                          style: TextStyle(
                                            color: AppColors.neutral800,
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
                                          color: AppColors.neutral800,
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
                                    color: AppColors.neutral800,
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
                          
                          // Status Badge & Delete
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: mentee.status == 'active' ? AppColors.success.withAlpha(20) :
                                         mentee.status == 'pending' ? AppColors.warning.withAlpha(20) :
                                         AppColors.error.withAlpha(20),
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Text(
                                  mentee.status == 'active' ? 'DISETUJUI' :
                                  mentee.status == 'pending' ? 'PENDING' : 'DITOLAK',
                                  style: TextStyle(
                                    color: mentee.status == 'active' ? AppColors.success :
                                           mentee.status == 'pending' ? AppColors.warning : AppColors.error,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Mahasiswa?'),
                                      content: const Text('Mahasiswa ini akan dihapus dari daftar bimbingan Anda. Anda bisa mengundangnya kembali dari daftar mahasiswa yang tersedia jika terjadi kesalahan.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(ctx);
                                            if (groupId != null) {
                                              final success = await provider.removeGroupMember(groupId, mentee.id);
                                              if (context.mounted && success) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Berhasil menghapus mahasiswa dari bimbingan.')),
                                                );
                                              }
                                            }
                                          },
                                          child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              if (mentee.status == 'active') ...[
                                const SizedBox(width: 4),
                                Icon(Icons.chevron_right_rounded, color: AppColors.neutral400),
                              ],
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

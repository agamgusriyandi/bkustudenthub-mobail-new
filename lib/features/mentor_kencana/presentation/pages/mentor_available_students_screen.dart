import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/domain/entities/mentor_models.dart';
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
  String _searchQuery = '';
  String _selectedStatusFilter = 'all'; // 'all', 'available', 'assigned'
  String _selectedFacultyFilter = 'all';

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

  List<AvailableStudentData> _getFilteredStudents(List<AvailableStudentData> students) {
    return students.where((student) {
      // 1. Search Query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = student.name.toLowerCase().contains(q);
        final matchNim = student.nim.toLowerCase().contains(q);
        if (!matchName && !matchNim) return false;
      }

      // 2. Status Filter
      if (_selectedStatusFilter == 'available' && student.alreadyHasMentor) {
        return false;
      }
      if (_selectedStatusFilter == 'assigned' && !student.alreadyHasMentor) {
        return false;
      }

      // 3. Faculty Filter
      if (_selectedFacultyFilter != 'all') {
        if (student.faculty.toLowerCase() != _selectedFacultyFilter.toLowerCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final allStudents = provider.availableStudents;
    
    // Extract unique faculties
    final uniqueFaculties = allStudents
        .map((s) => s.faculty.trim())
        .where((f) => f.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final filteredStudents = _getFilteredStudents(allStudents);

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAvailableStudents(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Cari Mahasiswa',
              info: 'Undang Mahasiswa ke Kelompok Bimbingan',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
            ),
            
            // SEARCH & FILTER BAR
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
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
                    
                    // Filters Row
                    Row(
                      children: [
                        // Status Filter Dropdown
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
                              DropdownMenuItem(value: 'available', child: Text('Belum Ada Fasilitator', overflow: TextOverflow.ellipsis)),
                              DropdownMenuItem(value: 'assigned', child: Text('Sudah Ada Fasilitator', overflow: TextOverflow.ellipsis)),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedStatusFilter = val);
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),

                        // Faculty Filter Dropdown
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

            if (provider.isLoading && allStudents.isEmpty)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (provider.errorMessage != null && allStudents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(color: context.appColors.error),
                  ),
                ),
              )
            else if (filteredStudents.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Tidak ada mahasiswa ditemukan.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: context.appColors.outline,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final student = filteredStudents[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: context.appColors.primary.withAlpha(20),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    student.name.isNotEmpty
                                        ? student.name.substring(0, 1)
                                        : '',
                                    style: TextStyle(
                                      color: context.appColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
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
                                      student.name,
                                      style: AppTextStyles.labelMd.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'NIM: ${student.nim}',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: context.appColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                    if (student.prodi.isNotEmpty || student.faculty.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        '${student.prodi.isNotEmpty ? student.prodi : ''}${student.prodi.isNotEmpty && student.faculty.isNotEmpty ? ' • ' : ''}${student.faculty}',
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: student.alreadyHasMentor 
                                      ? AppColors.warning.withAlpha(20) 
                                      : AppColors.success.withAlpha(20),
                                  borderRadius: AppRadius.radiusSm,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      student.alreadyHasMentor ? Icons.lock : Icons.check_circle_outline,
                                      size: 12,
                                      color: student.alreadyHasMentor ? AppColors.warning : AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      student.alreadyHasMentor 
                                          ? 'Fasilitator: ${student.mentorName ?? "Menunggu"}' 
                                          : 'TERSEDIA',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: student.alreadyHasMentor ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Invite Button
                              if (!student.alreadyHasMentor)
                                BkuButton(
                                  height: 32,
                                  fontSize: 11,
                                  fullWidth: false,
                                  onPressed: () async {
                                    final success = await provider.inviteStudent(student.id);
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
                            ],
                          ),
                        ],
                      ),
                    );
                  }, childCount: filteredStudents.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

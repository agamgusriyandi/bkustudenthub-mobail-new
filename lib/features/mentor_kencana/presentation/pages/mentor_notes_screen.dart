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
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/features/mentor_kencana/presentation/providers/mentor_kencana_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class MentorNotesScreen extends StatefulWidget {
  const MentorNotesScreen({super.key});

  @override
  State<MentorNotesScreen> createState() => _MentorNotesScreenState();
}

class _MentorNotesScreenState extends State<MentorNotesScreen> {
  String _searchQuery = '';
  String _selectedFaculty = 'all';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MentorKencanaProvider>();
    final mentees = provider.groups.expand((g) => g.mentees).toList();

    final filtered = mentees.where((m) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!m.name.toLowerCase().contains(q) && !m.nim.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedFaculty != 'all') {
        if (m.faculty.toLowerCase() != _selectedFaculty.toLowerCase()) return false;
      }
      return true;
    }).toList();

    final uniqueFaculties = mentees.map((m) => m.faculty).where((f) => f.isNotEmpty).toSet().toList()..sort();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchMentees(),
        color: context.appColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'Catatan Bimbingan',
              info: 'Tulis dan tinjau catatan bimbingan berkala untuk mahasiswa.',
              variant: AppBarVariant.student,
              isExpandable: false,
              showBackButton: true,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/mentor-kencana');
                }
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Sub-banner
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Catatan Bimbingan',
                            style: AppTextStyles.titleSm.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Pilih mahasiswa di bawah ini untuk memulai proses catatan bimbingan.',
                            style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Controls Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Manajemen Data', style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold)),
                              Text('Menampilkan daftar data yang terdaftar dalam sistem.', style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10)),
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
                            'TOTAL DATA ${filtered.length}',
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
                    const SizedBox(height: AppSpacing.lg),

                    // Search and Filter
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: BkuTextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val),
                            hint: 'Cari NIM atau nama mahasiswa...',
                            prefixIcon: const Icon(Icons.search_rounded),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          flex: 1,
                          child: BkuDropdown<String>(
                            initialValue: _selectedFaculty,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                            ),
                            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral900),
                            isExpanded: true,
                            items: [
                              const DropdownMenuItem(value: 'all', child: Text('Semua Fakultas', overflow: TextOverflow.ellipsis, maxLines: 1)),
                              ...uniqueFaculties.map((f) => DropdownMenuItem(value: f, child: Text(f, overflow: TextOverflow.ellipsis, maxLines: 1))),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedFaculty = val);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (provider.isLoading && mentees.isEmpty)
              const SliverFillRemaining(child: Padding(padding: EdgeInsets.all(20), child: BkuShimmerList()))
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text('Tidak ada mahasiswa bimbingan', style: AppTextStyles.labelMd.copyWith(color: context.appColors.outline)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl, bottom: 80),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final mentee = filtered[index];
                    return BkuCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mentee.nim,
                                  style: AppTextStyles.labelSm.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: context.appColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mentee.name,
                                  style: AppTextStyles.labelMd.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mentee.faculty,
                                  style: AppTextStyles.labelSm.copyWith(color: context.appColors.outline, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          BkuButton(
                            variant: BkuButtonVariant.outline,
                            onPressed: () {
                              context.push('/mentor-kencana/notes/${mentee.id}');
                            },
                            icon: Icons.remove_red_eye_outlined,
                            text: 'Buka Catatan',
                            fontSize: 11,
                            fullWidth: false,
                          ),
                        ],
                      ),
                    );
                  }, childCount: filtered.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

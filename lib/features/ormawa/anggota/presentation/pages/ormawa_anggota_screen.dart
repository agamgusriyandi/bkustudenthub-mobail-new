import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/core/widgets/ormawa_list_header.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:go_router/go_router.dart';

String? getFullImageUrl(String? path) {
  if (path == null || path.trim().isEmpty) return null;
  return ApiGate.getImageUrl(path);
}

class OrmawaAnggotaScreen extends StatefulWidget {
  const OrmawaAnggotaScreen({super.key});

  @override
  State<OrmawaAnggotaScreen> createState() => _OrmawaAnggotaScreenState();
}

class _OrmawaAnggotaScreenState extends State<OrmawaAnggotaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterRole = 'SEMUA';
  String _selectedFilterDivisi = 'SEMUA';
  String _selectedFilterStatus = 'SEMUA';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<OrmawaProvider>();
      if (p.members.isEmpty) {
        p.refreshData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OrmawaMember> _getFilteredMembers(List<OrmawaMember> members) {
    return members.where((m) {
      final matchesSearch =
          m.name.toLowerCase().contains(_searchQuery) ||
          m.nim.toLowerCase().contains(_searchQuery);
      final matchesRole =
          _selectedFilterRole == 'SEMUA' ||
          m.role.toUpperCase() == _selectedFilterRole;
      final matchesDivisi =
          _selectedFilterDivisi == 'SEMUA' ||
          m.division.toUpperCase() == _selectedFilterDivisi;
      final matchesStatus =
          _selectedFilterStatus == 'SEMUA' ||
          m.status.toUpperCase() == _selectedFilterStatus;
      return matchesSearch && matchesRole && matchesDivisi && matchesStatus;
    }).toList();
  }

  void _showFilterSheet(OrmawaProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder: (context, setModalState) {
              final roles = ['SEMUA', ...provider.roles.map((r) => r.name)];
              final divisions = [
                'SEMUA',
                ...provider.divisions.map((d) => d.name),
              ];
              final statuses = ['SEMUA', 'AKTIF', 'NONAKTIF', 'ALUMNI'];

              return DraggableScrollableSheet(
                initialChildSize: 0.7,
                minChildSize: 0.4,
                maxChildSize: 0.9,
                expand: false,
                builder:
                    (_, controller) => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FILTER ANGGOTA',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Expanded(
                            child: ListView(
                              controller: controller,
                              children: [
                                Text(
                                  'STATUS KEANGGOTAAN',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      statuses
                                          .map(
                                            (s) => ChoiceChip(
                                              label: Text(s),
                                              selected:
                                                  _selectedFilterStatus == s,
                                              onSelected: (selected) {
                                                setModalState(
                                                  () =>
                                                      _selectedFilterStatus = s,
                                                );
                                                setState(() {});
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'STATUS KEANGGOTAAN',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      roles
                                          .map(
                                            (r) => ChoiceChip(
                                              label: Text(r),
                                              selected:
                                                  _selectedFilterRole
                                                      .toUpperCase() ==
                                                  r,
                                              onSelected: (selected) {
                                                setModalState(
                                                  () => _selectedFilterRole = r,
                                                );
                                                setState(() {});
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(
                                  'DIVISI',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral500,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      divisions
                                          .map(
                                            (d) => ChoiceChip(
                                              label: Text(d),
                                              selected:
                                                  _selectedFilterDivisi
                                                      .toUpperCase() ==
                                                  d,
                                              onSelected: (selected) {
                                                setModalState(
                                                  () =>
                                                      _selectedFilterDivisi = d,
                                                );
                                                setState(() {});
                                              },
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setModalState(() {
                                      _selectedFilterRole = 'SEMUA';
                                      _selectedFilterDivisi = 'SEMUA';
                                      _selectedFilterStatus = 'SEMUA';
                                    });
                                    setState(() {});
                                  },

                                  child: const Text(
                                    'RESET',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),

                        child: Text(
                          'TERAPKAN FILTER',
                          style: TextStyle(
                            color: context.appColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
              );
            },
          ),
    );
  }

  void _confirmRegenerate() {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: 28,
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Regenerasi Pengurus',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Apakah Anda yakin ingin mengarsipkan seluruh pengurus aktif saat ini menjadi Demisioner/Alumni?\n\nTindakan ini tidak dapat dibatalkan.',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  try {
                    await context.read<OrmawaProvider>().regenerateMembers();
                    if (mounted) {
                      AppSnackbar.showSuccess(
                        context,
                        'Regenerasi kepengurusan berhasil!',
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      AppSnackbar.showError(context, 'Gagal regenerasi: $e');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: context.appColors.onPrimary,
                  elevation: 0,
                ),
                child: Text(
                  'Ya, Arsipkan',
                  style: TextStyle(
                    color: context.appColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final filteredMembers = _getFilteredMembers(provider.members);

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          body: RefreshIndicator(
            onRefresh: () => context.read<OrmawaProvider>().refreshData(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Manajemen Anggota',
                  subtitle: 'Database Keanggotaan',
                  expandedHeight: 115.0,
                  showBackButton: true,
                  isExpandable: false,
                ),
                if (provider.isLoading)
                  SliverFillRemaining(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.xl,
                      ),
                      child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: AppSpacing.sm,
                        left: AppSpacing.s20,
                        right: AppSpacing.s20,
                        bottom: AppSpacing.s20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCard(provider),
                          const SizedBox(height: AppSpacing.s20),

                          // Period & Regenerate Header
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: context.appColors.surface,
                              borderRadius: AppRadius.radiusXl,
                              border: Border.all(color: AppColors.neutral300),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.onSurface.withAlpha(12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PERIODE KEPENGURUSAN',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral600,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.lg,
                                          vertical: AppSpacing.xs,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral100,
                                          borderRadius: AppRadius.radiusMd,
                                          border: Border.all(
                                            color: AppColors.neutral300,
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            isExpanded: true,
                                            value: provider.selectedPeriod,
                                            icon: Icon(
                                              Icons.expand_more_rounded,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                            items: [
                                              const DropdownMenuItem(
                                                value: 'aktif',
                                                child: Text(
                                                  'Aktif (Terbaru)',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              ...provider.availablePeriods.map(
                                                (p) => DropdownMenuItem(
                                                  value: p,
                                                  child: Text(
                                                    'Periode $p',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) {
                                                provider.setMemberPeriod(val);
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (provider.selectedPeriod == 'aktif' &&
                                        provider.hasPermission(
                                          'edit_members',
                                        )) ...[
                                      const SizedBox(width: AppSpacing.md),
                                      InkWell(
                                        onTap: () => _confirmRegenerate(),
                                        borderRadius: AppRadius.radiusMd,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.lg,
                                            vertical: AppSpacing.lg,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.error.withAlpha(
                                              20,
                                            ),
                                            borderRadius: AppRadius.radiusMd,
                                            border: Border.all(
                                              color: AppColors.error.withAlpha(
                                                50,
                                              ),
                                            ),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(
                                                Icons.history_rounded,
                                                color: AppColors.error,
                                                size: 20,
                                              ),
                                              SizedBox(width: AppSpacing.s6),
                                              Text(
                                                'Arsipkan',
                                                style: TextStyle(
                                                  color: AppColors.error,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xxl),
                          OrmawaListHeader(
                            title: 'DAFTAR ANGGOTA (${filteredMembers.length})',
                            searchHint: 'Cari nama atau NIM...',
                            searchController: _searchController,
                            onRefresh:
                                () =>
                                    context
                                        .read<OrmawaProvider>()
                                        .refreshData(),
                            onFilterTap: () => _showFilterSheet(provider),
                            onChanged:
                                (value) => setState(
                                  () => _searchQuery = value.toLowerCase(),
                                ),
                          ),
                          const SizedBox(height: AppSpacing.s20),
                          if (filteredMembers.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredMembers.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: AppSpacing.md),
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
                                return _buildMemberCard(
                                  context,
                                  member,
                                  provider,
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          floatingActionButton:
              provider.hasPermission('create_members') &&
                      provider.selectedPeriod == 'aktif'
                  ? FloatingActionButton.extended(
                    onPressed: () => _showAddMember(context),
                    backgroundColor: context.appColors.primary,
                    icon: Icon(
                      Icons.person_add_rounded,
                      color: context.appColors.onPrimary,
                    ),
                    label: Text(
                      'Tambah Anggota',
                      style: TextStyle(
                        color: context.appColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.onSurface.withAlpha(10), blurRadius: 20),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 64,
                color: AppColors.neutral400,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Data tidak ditemukan',
              style: AppTextStyles.titleLg.copyWith(
                color: AppColors.neutral700,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Coba gunakan kata kunci pencarian atau\nfilter yang berbeda.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
            ),
            if (_searchQuery.isNotEmpty ||
                _selectedFilterRole != 'SEMUA' ||
                _selectedFilterDivisi != 'SEMUA' ||
                _selectedFilterStatus != 'SEMUA') ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton.icon(
                onPressed:
                    () => setState(() {
                      _searchQuery = '';
                      _selectedFilterRole = 'SEMUA';
                      _selectedFilterDivisi = 'SEMUA';
                      _selectedFilterStatus = 'SEMUA';
                    }),
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: context.appColors.primary,
                ),
                label: Text(
                  'Reset Filter',
                  style: TextStyle(
                    color: context.appColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(OrmawaProvider provider) {
    final total = provider.members.length.toString();
    final aktif =
        provider.members
            .where((m) => m.status.toLowerCase() == 'aktif')
            .length
            .toString();
    final pengurus =
        provider.members
            .where(
              (m) => [
                'KETUA',
                'WAKIL KETUA',
                'SEKRETARIS',
                'BENDAHARA',
              ].contains(m.role),
            )
            .length
            .toString();
    final divisi =
        provider.members
            .map((m) => m.division)
            .toSet()
            .where((d) => d.trim().isNotEmpty)
            .length
            .toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 22,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_rounded,
                color: context.appColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'STATISTIK ORGANISASI',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral800,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(total, 'Total Anggota'),
              _buildSummaryItem(aktif, 'Aktif'),
              _buildSummaryItem(pengurus, 'Pengurus'),
              _buildSummaryItem(divisi, 'Divisi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.neutral500,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('ketua umum') || r == 'ketua') {
      return context.appColors.primary;
    }
    if (r.contains('wakil ketua')) return context.appColors.info;
    if (r.contains('sekretaris') || r.contains('bendahara')) {
      return AppColors.info;
    }
    if (r.contains('kepala') || r.contains('kadiv')) return AppColors.warning;
    if (r.contains('staff') || r.contains('staf') || r == 'anggota') {
      return AppColors.success;
    }
    return AppColors.neutral500;
  }

  Widget _buildMemberCard(
    BuildContext context,
    OrmawaMember member,
    OrmawaProvider provider,
  ) {
    Color roleColor = _getRoleColor(member.role);
    String? photoUrl = getFullImageUrl(member.fotoUrl);
    bool isAktif = member.status.toLowerCase() == 'aktif';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrmawaAnggotaDetailScreen(member: member),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: isAktif ? AppColors.neutral200 : AppColors.neutral300,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withAlpha(12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: roleColor.withAlpha(50), width: 2),
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: roleColor.withAlpha(20),
                backgroundImage:
                    photoUrl != null
                        ? NetworkImage(ApiGate.getImageUrl(photoUrl))
                        : null,
                child:
                    photoUrl == null
                        ? Text(
                          member.initial,
                          style: TextStyle(
                            color: roleColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        )
                        : null,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.neutral800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (provider.hasPermission('edit_members') &&
                          provider.selectedPeriod == 'aktif')
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: PopupMenuButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: AppColors.neutral500,
                            ),
                            itemBuilder:
                                (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.edit_rounded,
                                          size: 18,
                                          color: AppColors.info,
                                        ),
                                        SizedBox(width: AppSpacing.s10),
                                        Text(
                                          'Edit Anggota',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 18,
                                          color: AppColors.error,
                                        ),
                                        SizedBox(width: AppSpacing.s10),
                                        Text(
                                          'Hapus Anggota',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                            onSelected: (val) {
                              if (val == 'edit') {
                                _showEditMember(context, member);
                              } else if (val == 'delete') {
                                _confirmDelete(context, member);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Row(
                    children: [
                      Text(
                        member.nim,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral600,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      if (!isAktif) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.neutral500.withAlpha(30),
                            borderRadius: AppRadius.radiusXs,
                          ),
                          child: Text(
                            member.status,
                            style: const TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: roleColor.withAlpha(15),
                          borderRadius: AppRadius.radiusSm,
                          border: Border.all(color: roleColor.withAlpha(30)),
                        ),
                        child: Text(
                          member.role,
                          style: AppTextStyles.labelSm.copyWith(
                            color: roleColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withAlpha(15),
                          borderRadius: AppRadius.radiusSm,
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withAlpha(30),
                          ),
                        ),
                        child: Text(
                          (member.division.isEmpty ? 'UMUM' : member.division)
                              ,
                          style: AppTextStyles.labelSm.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, OrmawaMember member) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.delete_forever_rounded, color: AppColors.error),
                SizedBox(width: AppSpacing.s10),
                Text('Hapus Anggota'),
              ],
            ),
            content: Text(
              'Apakah Anda yakin ingin menghapus\n${member.name} dari keanggotaan?',
              style: const TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<OrmawaProvider>().deleteMember(member.id);
                  context.pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: context.appColors.onPrimary,
                  elevation: 0,
                ),
              child: Text(
                'Hapus',
                style: TextStyle(
                  color: context.appColors.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ),
            ],
          ),
    );
  }

  void _showAddMember(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const OrmawaFormAnggotaScreen()),
    );
  }

  void _showEditMember(BuildContext context, OrmawaMember member) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrmawaFormAnggotaScreen(initialMember: member),
      ),
    );
  }
}

class OrmawaFormAnggotaScreen extends StatefulWidget {
  final OrmawaMember? initialMember;
  const OrmawaFormAnggotaScreen({super.key, this.initialMember});

  @override
  State<OrmawaFormAnggotaScreen> createState() =>
      _OrmawaFormAnggotaScreenState();
}

class _OrmawaFormAnggotaScreenState extends State<OrmawaFormAnggotaScreen> {
  Map<String, dynamic>? _selectedStudent;

  String _selectedRole = 'Anggota';
  String _selectedDivision = 'Umum';
  String _selectedStatus = 'Aktif';

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final List<String> _statuses = ['Aktif', 'Nonaktif', 'Alumni', 'Cuti'];

  @override
  void initState() {
    super.initState();
    if (widget.initialMember != null) {
      _selectedDivision =
          widget.initialMember!.division.isEmpty
              ? 'Umum'
              : widget.initialMember!.division;
      _selectedRole =
          widget.initialMember!.role.isEmpty
              ? 'Anggota'
              : widget.initialMember!.role;

      final mStatus = widget.initialMember!.status;
      if (_statuses.any((s) => s.toLowerCase() == mStatus.toLowerCase())) {
        _selectedStatus = _statuses.firstWhere(
          (s) => s.toLowerCase() == mStatus.toLowerCase(),
        );
      }

      _emailController.text = widget.initialMember!.email ?? '';
      _phoneController.text = widget.initialMember!.phone ?? '';
    }
  }

  void _submit() async {
    if (widget.initialMember == null && _selectedStudent == null) {
      AppSnackbar.showWarning(context, 'Pilih mahasiswa terlebih dahulu!');
      return;
    }

    final rawId =
        widget.initialMember != null
            ? widget.initialMember!.mahasiswaId
            : _selectedStudent!['id'];
    final mahasiswaId = int.tryParse(rawId.toString());

    final data = {
      'MahasiswaID': mahasiswaId,
      'Role': _selectedRole,
      'Divisi': _selectedDivision == 'Umum' ? '' : _selectedDivision,
      'Status': _selectedStatus,
      'EmailKampus': _emailController.text,
      'NoHP': _phoneController.text,
    };

    try {
      if (widget.initialMember != null) {
        await context.read<OrmawaProvider>().updateMember(
          widget.initialMember!.id,
          data,
        );
      } else {
        await context.read<OrmawaProvider>().addMember(data);
      }
      if (mounted) {
        context.pop();
        AppSnackbar.showSuccess(context, 'Data anggota berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal: $e');
      }
    }
  }

  void _showStudentSearchModal() async {
    // Import repository manually to fetch students if not in provider
    // For now, we will simulate the bottom sheet UI
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.appColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => const _StudentSearchSheet(),
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _selectedStudent = selected as Map<String, dynamic>;
          _emailController.text = _selectedStudent!['email_kampus'] ?? '';
          _phoneController.text = _selectedStudent!['no_hp'] ?? '';
        });
      }
    });
  }

  void _showCreateDivisionModal() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder:
          (dialogCtx) => AlertDialog(
            title: const Text(
              'Buat Divisi Baru',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: TextField(
              controller: ctrl,
              decoration: InputDecoration(
                hintText: 'Nama Divisi...',
                border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
                filled: true,
                fillColor: AppColors.neutral100,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (ctrl.text.trim().isNotEmpty) {
                    try {
                      await context.read<OrmawaProvider>().createDivisionInline(
                        ctrl.text.trim(),
                      );
                      setState(() => _selectedDivision = ctrl.text.trim());
                      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                    } catch (e) {
                      if (mounted) {
                        AppSnackbar.showError(context, 'Gagal membuat divisi');
                      }
                    }
                  }
                },

                child: Text(
                  'Simpan',
                  style: TextStyle(
                    color: context.appColors.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialMember != null;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final availableRoles = provider.roles.map((r) => r.name).toList();
          if (!availableRoles.contains('Anggota')) {
            availableRoles.add('Anggota');
          }

          final availableDivisions = [
            'Umum',
            ...provider.divisions.map((d) => d.name),
          ];
          if (!availableDivisions.contains(_selectedDivision)) {
            availableDivisions.add(_selectedDivision);
          }

          return CustomScrollView(
            slivers: [
              BkuAppBar(
                title: isEdit ? 'EDIT DATA ANGGOTA' : 'TAMBAH ANGGOTA BARU',
                subtitle: 'Registrasi Anggota',
                variant: AppBarVariant.ormawa,
                expandedHeight: 130.0,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEdit
                            ? 'Update informasi fungsionaris ormawa.'
                            : 'Daftarkan mahasiswa sebagai anggota aktif ormawa.',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      Text(
                        'Pilih Mahasiswa',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: isEdit ? null : _showStudentSearchModal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.lg,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isEdit
                                    ? AppColors.neutral200
                                    : AppColors.neutral100,
                            borderRadius: AppRadius.radiusLg,
                            border: Border.all(color: AppColors.neutral300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_search_rounded,
                                color:
                                    isEdit
                                        ? AppColors.neutral500
                                        : context.appColors.primary,
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  isEdit
                                      ? widget.initialMember!.name
                                      : (_selectedStudent != null
                                          ? "${_selectedStudent!['nama']} (${_selectedStudent!['nim']})"
                                          : 'Cari Nama / NIM Mahasiswa...'),
                                  style: TextStyle(
                                    color:
                                        (isEdit || _selectedStudent != null)
                                            ? AppColors.neutral800
                                            : AppColors.neutral500,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              if (!isEdit)
                                const Icon(
                                  Icons.arrow_drop_down_rounded,
                                  color: AppColors.neutral500,
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jabatan',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral700,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildDropdown<String>(
                                  value:
                                      availableRoles.contains(_selectedRole)
                                          ? _selectedRole
                                          : availableRoles.first,
                                  items: availableRoles,
                                  onChanged:
                                      (val) =>
                                          setState(() => _selectedRole = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Divisi',
                                      style: AppTextStyles.labelSm.copyWith(
                                        color: AppColors.neutral700,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _showCreateDivisionModal,
                                      child: Text(
                                        '+ Buat Baru',
                                        style: AppTextStyles.labelSm.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _buildDropdown<String>(
                                  value:
                                      availableDivisions.contains(
                                            _selectedDivision,
                                          )
                                          ? _selectedDivision
                                          : 'Umum',
                                  items: availableDivisions,
                                  onChanged:
                                      (val) => setState(
                                        () => _selectedDivision = val!,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Status Keanggotaan',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _buildDropdown<String>(
                        value: _selectedStatus,
                        items: _statuses,
                        onChanged:
                            (val) => setState(() => _selectedStatus = val!),
                      ),

                      const SizedBox(height: AppSpacing.xl),
                      _buildInputField(
                        'Email Kampus (Opsional)',
                        'email@kampus.ac.id',
                        Icons.email_rounded,
                        controller: _emailController,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildInputField(
                        'Nomor HP / WA (Opsional)',
                        '08123456789',
                        Icons.phone_android_rounded,
                        controller: _phoneController,
                      ),

                      const SizedBox(height: AppSpacing.xxxl),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _submit,

                          child:
                              provider.isLoading
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: context.appColors.onPrimary,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : Text(
                                    isEdit
                                        ? 'Perbarui Data Anggota'
                                        : 'Simpan Anggota Baru',
                                    style: TextStyle(
                                      color: context.appColors.onPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          icon: const Icon(
            Icons.expand_more_rounded,
            color: AppColors.neutral500,
          ),
          items:
              items
                  .map(
                    (item) => DropdownMenuItem<T>(
                      value: item,
                      child: Text(
                        item.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    IconData icon, {
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral700,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.neutral500, size: 20),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Student Search Bottom Sheet Component
class _StudentSearchSheet extends StatefulWidget {
  const _StudentSearchSheet();
  @override
  State<_StudentSearchSheet> createState() => _StudentSearchSheetState();
}

class _StudentSearchSheetState extends State<_StudentSearchSheet> {
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    try {
      final students = <Map<String, dynamic>>[];
      if (mounted) {
        setState(() {
          _students = students;
          _filteredStudents = students;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filter(String val) {
    setState(() {
      _query = val.toLowerCase();
      _filteredStudents =
          _students.where((s) {
            return (s['nama']?.toString().toLowerCase().contains(_query) ??
                    false) ||
                (s['nim']?.toString().toLowerCase().contains(_query) ?? false);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PILIH MAHASISWA',
                    style: TextStyle(
                      color: context.appColors.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.neutral100,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral300),
                ),
                child: TextField(
                  onChanged: _filter,
                  decoration: InputDecoration(
                    icon: Icon(
                      Icons.search_rounded,
                      color: context.appColors.primary,
                    ),
                    hintText: 'Cari Nama atau NIM...',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child:
                    _isLoading
                        ? const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.xl,
                          ),
                          child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                        )
                        : _filteredStudents.isEmpty
                        ? Center(
                          child: Text(
                            'Tidak ada mahasiswa ditemukan',
                            style: TextStyle(
                              color: AppColors.neutral500,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : ListView.separated(
                          controller: controller,
                          itemCount: _filteredStudents.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            final photoUrl = getFullImageUrl(
                              student['foto_url'] ?? student['FotoURL'],
                            );
                            return ListTile(
                              onTap: () => Navigator.pop(context, student),
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(20),
                                backgroundImage:
                                    photoUrl != null
                                        ? NetworkImage(
                                          ApiGate.getImageUrl(photoUrl),
                                        )
                                        : null,
                                child:
                                    photoUrl == null
                                        ? Icon(
                                          Icons.person,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        )
                                        : null,
                              ),
                              title: Text(
                                student['nama'] ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              subtitle: Text(
                                student['nim'] ?? '-',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: AppColors.neutral500,
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class OrmawaAnggotaDetailScreen extends StatelessWidget {
  final OrmawaMember member;

  const OrmawaAnggotaDetailScreen({super.key, required this.member});

  Color _getRoleColor(String role) {
    final r = role.toLowerCase();
    if (r.contains('ketua umum') || r == 'ketua') return AppColors.primary;
    if (r.contains('wakil ketua')) return AppColors.info;
    if (r.contains('sekretaris') || r.contains('bendahara')) {
      return AppColors.info;
    }
    if (r.contains('kepala') || r.contains('kadiv')) return AppColors.warning;
    if (r.contains('staff') || r.contains('staf') || r == 'anggota') {
      return AppColors.success;
    }
    return AppColors.neutral500;
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor(member.role);
    final photoUrl = getFullImageUrl(member.fotoUrl);

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Profil Anggota',
            subtitle: 'Informasi Mahasiswa',
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: roleColor.withAlpha(50),
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: roleColor.withAlpha(20),
                            backgroundImage:
                                photoUrl != null
                                    ? NetworkImage(
                                      ApiGate.getImageUrl(photoUrl),
                                    )
                                    : null,
                            child:
                                photoUrl == null
                                    ? Text(
                                      member.initial,
                                      style: TextStyle(
                                        color: roleColor,
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          member.name,
                          style: AppTextStyles.titleLg.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          member.nim,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.neutral500,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: roleColor.withAlpha(15),
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(
                                  color: roleColor.withAlpha(30),
                                ),
                              ),
                              child: Text(
                                member.role,
                                style: AppTextStyles.labelSm.copyWith(
                                  color: roleColor,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withAlpha(15),
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(30),
                                ),
                              ),
                              child: Text(
                                (member.division.isEmpty
                                        ? 'UMUM'
                                        : member.division)
                                    ,
                                style: AppTextStyles.labelSm.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('KONTAK & DATA'),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDetailRow(
                          Icons.email_rounded,
                          'Email',
                          member.email?.isNotEmpty == true
                              ? member.email!
                              : 'Tidak tersedia',
                        ),
                        _buildDetailRow(
                          Icons.phone_android_rounded,
                          'Nomor HP',
                          member.phone?.isNotEmpty == true
                              ? member.phone!
                              : 'Tidak tersedia',
                        ),
                        _buildDetailRow(
                          Icons.calendar_today_rounded,
                          'Bergabung Pada',
                          member.joinedAt?.toString().split(' ')[0] ?? '-',
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        _buildSectionTitle('STATUS KEANGGOTAAN'),
                        const SizedBox(height: AppSpacing.lg),
                        _buildActivityItem(
                          'Status Saat Ini',
                          member.status,
                              member.status.toLowerCase() == 'aktif'
                                  ? AppColors.success
                                  : AppColors.neutral500,
                        ),
                        if (member.periode != null &&
                            member.periode!.isNotEmpty)
                          _buildActivityItem(
                            'Periode',
                            member.periode!,
                            context.appColors.primary,
                          ),
                        const SizedBox(height: AppSpacing.xxxl),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.neutral500,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Icon(icon, size: 20, color: AppColors.neutral600),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              value,
              style: AppTextStyles.bodyMd.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

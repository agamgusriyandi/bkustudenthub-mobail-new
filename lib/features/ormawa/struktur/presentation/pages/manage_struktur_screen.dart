import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

class ManageStrukturScreen extends StatefulWidget {
  const ManageStrukturScreen({super.key});

  @override
  State<ManageStrukturScreen> createState() => _ManageStrukturScreenState();
}

class _ManageStrukturScreenState extends State<ManageStrukturScreen> {
  final _divisionNameController = TextEditingController();
  final _bphSearchController = TextEditingController();
  bool _isSearchingStudent = false;

  @override
  void dispose() {
    _divisionNameController.dispose();
    _bphSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final members = provider.members;
    final divisions = provider.divisions;

    final bphMembers =
        members.where((m) {
          final r = m.role.toLowerCase();
          return r.contains('ketua') ||
              r.contains('wakil') ||
              r.contains('sekretaris') ||
              r.contains('bendahara') ||
              r.contains('pembina');
        }).toList();

    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: const BkuStaticAppBar(
        title: 'Kelola Struktur Organisasi',
        variant: AppBarVariant.ormawa,
      ),
      body:
          provider.isLoading
              ? const Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: BkuShimmerList(itemCount: 4, itemHeight: 120),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      'INFORMASI KABINET',
                      Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTextField(
                      'Nama Kabinet',
                      provider.orgName,
                      Icons.badge_rounded,
                      enabled: false,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildTextField(
                      'Periode',
                      provider.academicYear,
                      Icons.calendar_month_rounded,
                      enabled: false,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader(
                          'PIMPINAN INTI (BPH)',
                          Icons.stars_rounded,
                        ),
                        if (provider.hasPermission('manage_structure'))
                          TextButton.icon(
                            onPressed:
                                () => _showManageBphBottomSheet(
                                  context,
                                  provider,
                                ),
                            icon: const Icon(Icons.group_add_rounded, size: 18),
                            label: const Text(
                              'Kelola Pengurus BPH',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (bphMembers.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Text(
                          'Belum ada pengurus BPH',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                      )
                    else
                      ...bphMembers.map(
                        (m) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildEditableMemberCard(
                            m.role,
                            m.name,
                            'UBAH',
                            () =>
                                _showManageBphBottomSheet(context, provider, m),
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.xxxl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionHeader(
                          'DEPARTEMEN / DIVISI',
                          Icons.account_tree_rounded,
                        ),
                        if (provider.hasPermission('manage_structure'))
                          TextButton.icon(
                            onPressed:
                                () => _showAddDivisionDialog(context, provider),
                            icon: const Icon(
                              Icons.add_circle_outline_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Tambah Dept',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (divisions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Text(
                          'Belum ada divisi',
                          style: TextStyle(color: AppColors.neutral500),
                        ),
                      )
                    else
                      ...divisions.map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _buildDeptEditCard(
                            d,
                            members.where((m) => m.division == d.name).length,
                            provider,
                          ),
                        ),
                      ),

                    const SizedBox(height: AppSpacing.s50),
                  ],
                ),
              ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.labelSm.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    IconData icon, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral600,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: enabled ? AppColors.neutral100 : AppColors.neutral200,
            borderRadius: AppRadius.radiusLg,
            border: Border.all(color: AppColors.neutral300),
          ),
          child: TextField(
            enabled: enabled,
            controller: TextEditingController(text: !enabled ? hint : null),
            style: AppTextStyles.bodyMd.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  enabled
                      ? AppColors.neutral800
                      : Theme.of(context).colorScheme.outline,
            ),
            decoration: InputDecoration(
              hintText: enabled ? hint : null,
              hintStyle: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral400,
              ),
              prefixIcon: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary.withAlpha(150),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditableMemberCard(
    String role,
    String currentName,
    String action,
    VoidCallback onPressed,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral600.withAlpha(10),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withAlpha(20),
                  Theme.of(context).colorScheme.primary.withAlpha(5),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  role,
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.s2),
                Text(
                  currentName,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
          if (context.read<OrmawaProvider>().hasPermission('manage_structure'))
            ElevatedButton(
              onPressed: onPressed,

              child: Text(
                action,
                style: AppTextStyles.labelSm.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeptEditCard(
    OrmawaDivision dept,
    int memberCount,
    OrmawaProvider provider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral600.withAlpha(8),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.s20,
              AppSpacing.s20,
              AppSpacing.lg,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: AppRadius.radiusXs,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          dept.name,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.w900,

                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.hasPermission('manage_structure'))
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: Text(
                                      'Hapus Divisi',
                                      style: AppTextStyles.titleMd,
                                    ),
                                    content: const Text(
                                      'Apakah Anda yakin ingin menghapus divisi ini? Anggota di dalamnya tidak akan terhapus.',
                                    ),

                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Batal'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          provider.deleteDivision(dept.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                          foregroundColor: context.appColors.onPrimary,
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'Hapus',
                                          style: TextStyle(color: context.appColors.onPrimary),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const Divider(color: AppColors.neutral200, height: 1, thickness: 1),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(color: AppColors.neutral300),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 14,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: AppSpacing.s6),
                      Text(
                        '$memberCount Anggota Terdaftar',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDivisionDialog(BuildContext context, OrmawaProvider provider) {
    _divisionNameController.clear();
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Tambah Divisi', style: AppTextStyles.titleMd),
            content: TextField(
              controller: _divisionNameController,
              decoration: InputDecoration(
                hintText: 'Nama Divisi',
                border: OutlineInputBorder(borderRadius: AppRadius.radiusMd),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_divisionNameController.text.trim().isNotEmpty) {
                    provider.createDivisionInline(
                      _divisionNameController.text.trim(),
                    );
                    Navigator.pop(ctx);
                  }
                },

                child: Text(
                  'Simpan',
                  style: TextStyle(color: context.appColors.onPrimary),
                ),
              ),
            ],
          ),
    );
  }

  void _showManageBphBottomSheet(
    BuildContext context,
    OrmawaProvider provider, [
    OrmawaMember? existingMember,
  ]) {
    String selectedRole = existingMember?.role ?? 'Sekretaris';
    String? selectedStudentId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setModalState) {
              return Container(
                height: MediaQuery.of(ctx).size.height * 0.85,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(ctx).viewInsets.bottom,
                ),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.s20),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                                      color: AppColors.neutral500.withAlpha(50),
                          borderRadius: AppRadius.radiusXs,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            existingMember != null
                                ? 'Ubah Jabatan BPH'
                                : 'Kelola Pengurus BPH',
                            style: AppTextStyles.titleLg.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (existingMember != null)
                            IconButton(
                              onPressed: () {
                                provider.deleteMember(existingMember.id);
                                Navigator.pop(ctx);
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.error,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 32),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (existingMember == null) ...[
                              Text(
                                'Pilih Mahasiswa',
                                style: AppTextStyles.labelMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              TextField(
                                controller: _bphSearchController,
                                decoration: InputDecoration(
                                  hintText: 'Cari nama atau NIM...',
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: AppRadius.radiusLg,
                                  ),
                                ),
                                onChanged: (val) {
                                  setModalState(() {
                                    _isSearchingStudent = true;
                                  });
                                },
                              ),
                              if (_isSearchingStudent &&
                                  _bphSearchController.text.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: AppSpacing.sm),
                                  constraints: const BoxConstraints(
                                    maxHeight: 150,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.appColors.surface,
                                    border: Border.all(
                          color: AppColors.neutral500.withAlpha(50),
                                    ),
                                    borderRadius: AppRadius.radiusMd,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(10),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: ListView(
                                    shrinkWrap: true,
                                    children:
                                        provider.members
                                            .where(
                                              (m) =>
                                                  m.name.toLowerCase().contains(
                                                    _bphSearchController.text
                                                        .toLowerCase(),
                                                  ) ||
                                                  m.nim.toLowerCase().contains(
                                                    _bphSearchController.text
                                                        .toLowerCase(),
                                                  ),
                                            )
                                            .take(5)
                                            .map(
                                              (m) => ListTile(
                                                title: Text(m.name),
                                                subtitle: Text(m.nim),
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedStudentId =
                                                        m.mahasiswaId
                                                            .toString();
                                                    _bphSearchController.text =
                                                        m.name;
                                                    _isSearchingStudent = false;
                                                  });
                                                },
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                            Text(
                              'Jabatan BPH',
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            DropdownButtonFormField<String>(
                              initialValue: selectedRole,
                              items:
                                  [
                                        'Ketua',
                                        'Wakil Ketua',
                                        'Sekretaris',
                                        'Bendahara',
                                        'Pembina',
                                      ]
                                      .map(
                                        (r) => DropdownMenuItem(
                                          value: r,
                                          child: Text(r),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedRole = val);
                                }
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: AppRadius.radiusLg,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: ElevatedButton(
                        onPressed: () {
                          if (existingMember != null) {
                            provider.updateMember(existingMember.id, {
                              'Role': selectedRole,
                              'Divisi': '',
                            });
                            Navigator.pop(ctx);
                          } else {
                            if (selectedStudentId != null) {
                              provider.addMember({
                                'MahasiswaID': int.tryParse(selectedStudentId!),
                                'Role': selectedRole,
                                'Divisi': '',
                              });
                              Navigator.pop(ctx);
                            }
                          }
                        },

                        child: Text(
                          'SIMPAN',
                          style: TextStyle(
                            color: context.appColors.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    ).whenComplete(() {
      _bphSearchController.clear();
      _isSearchingStudent = false;
    });
  }
}

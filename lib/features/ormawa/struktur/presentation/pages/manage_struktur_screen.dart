import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';

class ManageStrukturScreen extends StatefulWidget {
  const ManageStrukturScreen({super.key});

  @override
  State<ManageStrukturScreen> createState() => _ManageStrukturScreenState();
}

class _ManageStrukturScreenState extends State<ManageStrukturScreen> {
  final _divisionNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  void dispose() {
    _divisionNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final members = provider.members;
    final divisions = provider.divisions;

    final bphMembers = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('ketua') ||
          r.contains('wakil') ||
          r.contains('sekretaris') ||
          r.contains('bendahara') ||
          r.contains('pembina');
    }).toList();

    final canManage = provider.hasPermission('manage_structure') ||
        provider.hasPermission('ormawa.structure.manage, ormawa.structure.update, ormawa.organisasi.manage, ormawa.members.update');

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        color: BkuTheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            const BkuAppBar(
              title: 'Kelola Struktur Organisasi',
              subtitle: 'Manajemen Pengurus & Divisi',
              variant: AppBarVariant.ormawa,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: provider.isLoading && members.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: BkuShimmerList(itemCount: 4, itemHeight: 100),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.s100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Informasi Kepengurusan', Icons.info_outline_rounded, BkuTheme.indigo),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCabinetInfoCard(provider.orgName, provider.academicYear),
                          const SizedBox(height: AppSpacing.xl),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader('Pimpinan & Pengurus BPH', Icons.shield_rounded, BkuTheme.sky),
                              if (canManage)
                                InkWell(
                                  onTap: () => _showManageBphBottomSheet(context, provider),
                                  borderRadius: BkuTheme.r8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: BkuTheme.skySoft,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(
                                        color: BkuTheme.skyBorder,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person_add_rounded, size: 13, color: BkuTheme.sky),
                                        SizedBox(width: 3),
                                        Text(
                                          'Tambah BPH',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: BkuTheme.sky,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (bphMembers.isEmpty)
                            _buildEmptyPlaceholder('Belum ada pengurus BPH terdaftar')
                          else
                            ...bphMembers.map(
                              (m) => _buildEditableMemberCard(
                                context,
                                member: m,
                                onEdit: () => _showManageBphBottomSheet(context, provider, m),
                                onDelete: () => _confirmDeleteMember(context, provider, m),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xl),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader('Departemen & Divisi', Icons.category_rounded, BkuTheme.purple),
                              if (canManage)
                                InkWell(
                                  onTap: () => _showAddDivisionDialog(context, provider),
                                  borderRadius: BkuTheme.r8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: BkuTheme.purpleSoft,
                                      borderRadius: BkuTheme.r8,
                                      border: Border.all(
                                        color: BkuTheme.purple.withAlpha(80),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_circle_outline_rounded, size: 13, color: BkuTheme.purple),
                                        SizedBox(width: 3),
                                        Text(
                                          'Tambah Divisi',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: BkuTheme.purple,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (divisions.isEmpty)
                            _buildEmptyPlaceholder('Belum ada divisi terdaftar')
                          else
                            ...divisions.map(
                              (d) {
                                final count = members.where((m) => m.division == d.name).length;
                                return _buildDeptEditCard(context, d, count, provider);
                              },
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          title,
          style: BkuTheme.textCardTitle.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 11.5,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildCabinetInfoCard(String orgName, String academicYear) {
    final displayOrg = orgName.isNotEmpty ? orgName : 'Organisasi Mahasiswa';
    final now = DateTime.now();
    final dynamicDefaultYear = '${now.year}/${now.year + 1}';
    final displayYear = academicYear.isNotEmpty ? academicYear : dynamicDefaultYear;

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 14,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BkuTheme.indigoSoft,
                  borderRadius: BkuTheme.r8,
                ),
                child: const Icon(Icons.badge_rounded, color: BkuTheme.indigo, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nama Organisasi',
                      style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      displayOrg,
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: BkuTheme.amberSoft,
                  borderRadius: BkuTheme.r8,
                ),
                child: const Icon(Icons.calendar_month_rounded, color: BkuTheme.amber, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tahun Akademik / Periode',
                      style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Periode $displayYear',
                      style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w800),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String name,
    String? fotoUrl, {
    required double size,
  }) {
    final cleanName = name.trim().isNotEmpty ? name.trim() : 'Mahasiswa';
    final parts = cleanName.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final initials = parts.isEmpty
        ? 'M'
        : parts.length == 1
            ? (parts[0].length > 1 ? parts[0].substring(0, 2).toUpperCase() : parts[0].toUpperCase())
            : (parts[0][0] + parts[1][0]).toUpperCase();

    final hasPhoto = fotoUrl != null &&
        fotoUrl.trim().isNotEmpty &&
        fotoUrl != '-' &&
        fotoUrl != 'null';

    final effectiveUrl = hasPhoto ? ApiGate.getImageUrl(fotoUrl) : null;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BkuTheme.borderSubtle,
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: BkuTheme.border,
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((size * 0.25) - 0.8),
        child: effectiveUrl != null
            ? CachedNetworkImage(
                imageUrl: effectiveUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textMuted,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Center(
                  child: Text(
                    initials,
                    style: TextStyle(
                      fontSize: size * 0.32,
                      fontWeight: FontWeight.w900,
                      color: BkuTheme.textMuted,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              )
            : Center(
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w900,
                    color: BkuTheme.textMuted,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildEditableMemberCard(
    BuildContext context, {
    required OrmawaMember member,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final roleStyle = _getRoleBadgeStyle(member.role);

    final subText = [
      if (member.nim.isNotEmpty && member.nim != '-') member.nim,
      if (member.prodi != null && member.prodi!.isNotEmpty) member.prodi!,
    ].join(' • ');

    return BkuCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(member.name, member.fotoUrl, size: 38),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: BkuTheme.textCaption.copyWith(
                      fontSize: 9.5,
                      color: BkuTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleStyle.bgColor,
                        borderRadius: BkuTheme.r8,
                        border: Border.all(color: roleStyle.borderColor, width: 0.8),
                      ),
                      child: Text(
                        member.role,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: roleStyle.textColor,
                        ),
                      ),
                    ),
                    if (member.division.isNotEmpty &&
                        member.division != 'BPH' &&
                        member.division != 'INTI' &&
                        member.division != '-') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: BkuTheme.borderSubtle,
                          borderRadius: BkuTheme.r8,
                          border: Border.all(color: BkuTheme.border, width: 0.8),
                        ),
                        child: Text(
                          'Divisi ${member.division}',
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: BkuTheme.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: BkuTheme.textMuted),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: onEdit,
                tooltip: 'Ubah Jabatan',
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: BkuTheme.rose),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: onDelete,
                tooltip: 'Hapus',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeptEditCard(
    BuildContext context,
    OrmawaDivision dept,
    int memberCount,
    OrmawaProvider provider,
  ) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BkuTheme.purpleSoft,
              borderRadius: BkuTheme.r8,
            ),
            child: const Icon(Icons.folder_shared_rounded, color: BkuTheme.purple, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name,
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$memberCount Anggota Terdaftar',
                  style: BkuTheme.textCaption.copyWith(
                    fontSize: 9.5,
                    color: BkuTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (provider.hasPermission('manage_structure') ||
              provider.hasPermission('ormawa.structure.manage, ormawa.structure.update, ormawa.organisasi.manage, ormawa.members.update'))
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: BkuTheme.rose),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                BkuDialog.show(
                  context: context,
                  type: BkuDialogType.error,
                  title: 'Hapus Divisi?',
                  message: 'Divisi "${dept.name}" akan dihapus. Anggota di dalamnya tidak akan terhapus.',
                  primaryButtonText: 'Hapus Divisi',
                  onPrimaryPressed: () async {
                    Navigator.pop(context);
                    await provider.deleteDivision(dept.id);
                    if (context.mounted) {
                      AppSnackbar.showSuccess(context, 'Divisi berhasil dihapus');
                    }
                  },
                  secondaryButtonText: 'Batal',
                  onSecondaryPressed: () => Navigator.pop(context),
                );
              },
              tooltip: 'Hapus Divisi',
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(fontSize: 11, color: BkuTheme.textPlaceholder, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddDivisionDialog(BuildContext context, OrmawaProvider provider) {
    _divisionNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BkuTheme.r18,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Divisi Baru',
                style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              BkuTextField(
                controller: _divisionNameController,
                hint: 'Nama Divisi (contoh: Humas, Kominfo)',
                prefixIcon: const Icon(Icons.folder_shared_rounded, size: 16, color: BkuTheme.textPlaceholder),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: BkuButton.outline(
                      onPressed: () => Navigator.pop(ctx),
                      text: 'Batal',
                      height: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BkuButton.primary(
                      onPressed: () async {
                        final name = _divisionNameController.text.trim();
                        if (name.isNotEmpty) {
                          Navigator.pop(ctx);
                          await provider.createDivisionInline(name);
                          if (context.mounted) {
                            AppSnackbar.showSuccess(context, 'Divisi "$name" berhasil ditambahkan');
                          }
                        }
                      },
                      text: 'Simpan',
                      height: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManageBphBottomSheet(
    BuildContext context,
    OrmawaProvider provider, [
    OrmawaMember? existingMember,
  ]) {
    final rbacRoles = provider.roles.map((r) => r.name.trim()).where((n) => n.isNotEmpty).toSet().toList();
    final memberRoles = provider.members.map((m) => m.role.trim()).where((r) => r.isNotEmpty).toSet().toList();
    final dynamicRoles = {
      ...rbacRoles,
      ...memberRoles,
      if (existingMember != null && existingMember.role.trim().isNotEmpty) existingMember.role.trim(),
      'Ketua Umum',
      'Wakil Ketua',
      'Sekretaris',
      'Bendahara',
      'Kepala Divisi',
      'Staff',
      'Anggota',
      'Pembina',
    }.where((r) => r.trim().isNotEmpty).toSet().toList();

    String selectedRole = existingMember?.role.trim() ?? dynamicRoles.first;
    if (!dynamicRoles.contains(selectedRole)) {
      dynamicRoles.add(selectedRole);
    }

    final allDivisions = provider.divisions
        .map((d) => d.name.trim())
        .where((d) => d.isNotEmpty)
        .toSet()
        .toList();

    String selectedDivision = existingMember?.division.trim() ?? '';
    if (selectedDivision.isNotEmpty && !allDivisions.contains(selectedDivision)) {
      allDivisions.add(selectedDivision);
    }

    OrmawaMember? selectedMember = existingMember;
    String searchKeyword = '';
    bool isSearching = false;
    List<Map<String, dynamic>> loadedStudents = [];
    bool isLoadingStudents = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          if (isLoadingStudents && loadedStudents.isEmpty) {
            provider.getStudents().then((res) {
              if (ctx.mounted) {
                setModalState(() {
                  loadedStudents = res;
                  isLoadingStudents = false;
                });
              }
            }).catchError((_) {
              if (ctx.mounted) {
                setModalState(() {
                  isLoadingStudents = false;
                });
              }
            });
          }

          final filteredStudents = searchKeyword.isEmpty
              ? loadedStudents
              : loadedStudents.where((s) {
                  final name = (s['Nama'] ?? s['nama'] ?? s['nama_mahasiswa'] ?? '').toString().toLowerCase();
                  final nim = (s['NIM'] ?? s['nim'] ?? '').toString().toLowerCase();
                  final q = searchKeyword.toLowerCase();
                  return name.contains(q) || nim.contains(q);
                }).toList();

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: BkuTheme.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: BkuTheme.borderSubtle,
                              borderRadius: BkuTheme.r12,
                            ),
                            child: Icon(
                              existingMember != null ? Icons.edit_note_rounded : Icons.group_add_rounded,
                              size: 20,
                              color: BkuTheme.textHeading,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  existingMember != null ? 'Ubah Jabatan Pengurus' : 'Kelola Pengurus BPH',
                                  style: BkuTheme.textPageTitle.copyWith(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    color: BkuTheme.textHeading,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  existingMember != null
                                      ? 'Perbarui jabatan atau divisi untuk ${existingMember.name}.'
                                      : 'Tambah atau ubah jabatan pengurus inti ormawa.',
                                  style: BkuTheme.textCaption.copyWith(
                                    fontSize: 11,
                                    color: BkuTheme.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(ctx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: BkuTheme.borderSubtle,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, size: 18, color: BkuTheme.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: BkuTheme.borderSubtle,
                                borderRadius: BkuTheme.r18,
                                border: Border.all(color: BkuTheme.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.border),
                                        ),
                                        child: const Text(
                                          'Tetapkan Jabatan Mahasiswa',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w900,
                                            color: BkuTheme.textHeading,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Text(
                                    'Pilih Mahasiswa',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 11, fontWeight: FontWeight.bold, color: BkuTheme.textHeading),
                                  ),
                                  const SizedBox(height: 5),

                                  if (selectedMember != null && !isSearching) ...[
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BkuTheme.r12,
                                        border: Border.all(color: BkuTheme.border),
                                      ),
                                      child: Row(
                                        children: [
                                          _buildAvatar(selectedMember!.name, selectedMember!.fotoUrl, size: 36),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedMember!.name,
                                                  style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900, color: BkuTheme.textHeading),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'NIM: ${selectedMember!.nim}${selectedMember!.prodi != null && selectedMember!.prodi!.isNotEmpty ? ' • ${selectedMember!.prodi}' : ''}',
                                                  style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          BkuButton.outline(
                                            onPressed: () {
                                              setModalState(() {
                                                isSearching = true;
                                                searchKeyword = '';
                                              });
                                            },
                                            text: 'Ganti',
                                            height: 30,
                                            width: 65,
                                            fullWidth: false,
                                            fontSize: 11,
                                            customRadius: BkuTheme.r8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else ...[
                                    BkuTextField(
                                      hint: 'Ketik Nama atau NIM mahasiswa...',
                                      prefixIcon: const Icon(Icons.search_rounded, size: 16, color: BkuTheme.textPlaceholder),
                                      onChanged: (val) {
                                        setModalState(() {
                                          isSearching = true;
                                          searchKeyword = val;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      height: 140,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: BkuTheme.border),
                                        borderRadius: BkuTheme.r12,
                                        color: Colors.white,
                                      ),
                                      child: isLoadingStudents
                                          ? const Center(
                                              child: SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E)),
                                              ),
                                            )
                                          : filteredStudents.isEmpty
                                              ? const Center(
                                                  child: Text(
                                                    'Mahasiswa tidak ditemukan',
                                                    style: TextStyle(fontSize: 11, color: BkuTheme.textPlaceholder),
                                                  ),
                                                )
                                              : ListView.separated(
                                                  itemCount: filteredStudents.length,
                                                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                                                  itemBuilder: (c, idx) {
                                                    final st = filteredStudents[idx];
                                                    final mId = (st['id'] ?? st['ID'] ?? st['mahasiswa_id'] ?? st['MahasiswaID'])?.toString() ?? '';
                                                    final stName = (st['Nama'] ?? st['nama'] ?? st['nama_mahasiswa'] ?? '').toString();
                                                    final stNim = (st['NIM'] ?? st['nim'] ?? '').toString();
                                                    final stProdi = (st['ProgramStudi'] is Map ? (st['ProgramStudi']['Nama'] ?? st['ProgramStudi']['nama']) : (st['prodi'] ?? st['Prodi']))?.toString() ?? '';
                                                    final stFoto = (st['foto_url'] ?? st['avatar_url'] ?? st['foto'] ?? st['Foto'])?.toString();
                                                    final isSelected = selectedMember?.mahasiswaId == mId;
                                                    return ListTile(
                                                      dense: true,
                                                      tileColor: isSelected ? BkuTheme.borderSubtle : Colors.transparent,
                                                      leading: _buildAvatar(stName, stFoto, size: 30),
                                                      title: Text(
                                                        stName,
                                                        style: BkuTheme.textCardTitle.copyWith(
                                                          fontSize: 11.5,
                                                          fontWeight: FontWeight.bold,
                                                          color: BkuTheme.textHeading,
                                                        ),
                                                      ),
                                                      subtitle: Text(
                                                        'NIM: $stNim${stProdi.isNotEmpty ? ' • $stProdi' : ''}',
                                                        style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                                                      ),
                                                      onTap: () {
                                                        setModalState(() {
                                                          selectedMember = OrmawaMember(
                                                            id: '',
                                                            mahasiswaId: mId,
                                                            name: stName,
                                                            nim: stNim,
                                                            role: selectedRole,
                                                            division: selectedDivision,
                                                            status: 'aktif',
                                                            prodi: stProdi,
                                                            fotoUrl: stFoto,
                                                          );
                                                          isSearching = false;
                                                        });
                                                      },
                                                    );
                                                  },
                                                ),
                                    ),
                                  ],
                                  const SizedBox(height: 12),

                                  BkuDropdown<String>(
                                    label: 'Jabatan (RBAC)',
                                    value: selectedRole,
                                    items: dynamicRoles.map((r) => DropdownMenuItem<String>(
                                      value: r,
                                      child: Text(
                                        r,
                                        style: BkuTheme.textBodyRegular.copyWith(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: BkuTheme.textHeading,
                                        ),
                                      ),
                                    )).toList(),
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => selectedRole = val);
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  BkuDropdown<String>(
                                    label: 'Divisi (Opsional)',
                                    value: selectedDivision,
                                    items: [
                                      DropdownMenuItem<String>(
                                        value: '',
                                        child: Text(
                                          'Pengurus Inti (Tanpa Divisi)',
                                          style: BkuTheme.textBodyRegular.copyWith(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: BkuTheme.textHeading,
                                          ),
                                        ),
                                      ),
                                      ...allDivisions.where((d) => d.isNotEmpty).map((d) => DropdownMenuItem<String>(
                                        value: d,
                                        child: Text(
                                          d,
                                          style: BkuTheme.textBodyRegular.copyWith(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            color: BkuTheme.textHeading,
                                          ),
                                        ),
                                      )),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => selectedDivision = val);
                                    },
                                  ),
                                const SizedBox(height: 14),

                                SizedBox(
                                  width: double.infinity,
                                  child: BkuButton.primary(
                                    onPressed: () async {
                                      if (selectedMember == null) {
                                        AppSnackbar.showError(context, 'Wajib mencari dan memilih mahasiswa terlebih dahulu!');
                                        return;
                                      }

                                      final existing = provider.members.where((m) => m.mahasiswaId == selectedMember!.mahasiswaId).firstOrNull;

                                      if (existing != null) {
                                        await provider.updateMember(existing.id, {
                                          'Role': selectedRole,
                                          'Divisi': selectedDivision,
                                        });
                                        if (context.mounted) {
                                          AppSnackbar.showSuccess(context, 'Jabatan pengurus berhasil diperbarui');
                                          setModalState(() {
                                            selectedMember = null;
                                            isSearching = false;
                                          });
                                        }
                                      } else {
                                        await provider.addMember({
                                          'MahasiswaID': int.tryParse(selectedMember!.mahasiswaId),
                                          'Role': selectedRole,
                                          'Divisi': selectedDivision,
                                        });
                                        if (context.mounted) {
                                          AppSnackbar.showSuccess(context, 'Pengurus berhasil ditambahkan');
                                          setModalState(() {
                                            selectedMember = null;
                                            isSearching = false;
                                          });
                                        }
                                      }
                                    },
                                    icon: Icons.person_add_alt_1_rounded,
                                    text: 'Simpan Jabatan Pengurus',
                                    height: 44,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              Text(
                                'Daftar Pengurus Terdaftar',
                                style: BkuTheme.textBadge.copyWith(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: BkuTheme.textBody,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: BkuTheme.borderSubtle,
                                  borderRadius: BkuTheme.r8,
                                ),
                                child: Text(
                                  '${provider.members.length} Pengurus',
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (provider.members.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text('Belum ada pengurus terdaftar.', style: TextStyle(fontSize: 11, color: BkuTheme.textPlaceholder)),
                              ),
                            )
                          else
                            ...provider.members.map((m) {
                              final rStyle = _getRoleBadgeStyle(m.role);
                              return BkuCard(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                borderRadius: 14,
                                child: Row(
                                  children: [
                                    _buildAvatar(m.name, m.fotoUrl, size: 38),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            m.name,
                                            style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: rStyle.bgColor,
                                                  borderRadius: BkuTheme.r8,
                                                  border: Border.all(color: rStyle.borderColor, width: 0.8),
                                                ),
                                                child: Text(
                                                  m.role,
                                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: rStyle.textColor),
                                                ),
                                              ),
                                              if (m.division.isNotEmpty) ...[
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                  decoration: BoxDecoration(
                                                    color: BkuTheme.borderSubtle,
                                                    borderRadius: BkuTheme.r8,
                                                    border: Border.all(color: BkuTheme.border, width: 0.8),
                                                  ),
                                                  child: Text(
                                                    'Divisi ${m.division}',
                                                    style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: BkuTheme.textMuted),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _confirmDeleteMember(context, provider, m),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: BkuTheme.roseSoft,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded, size: 16, color: BkuTheme.rose),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: BkuButton.outline(
                        onPressed: () => Navigator.pop(ctx),
                        text: 'Tutup',
                        height: 44,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      ),
    );
  }

  void _confirmDeleteMember(BuildContext context, OrmawaProvider provider, OrmawaMember member) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Pengurus?',
      message: 'Hapus "${member.name}" dari jajaran kepengurusan?',
      primaryButtonText: 'Hapus Pengurus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await provider.deleteMember(member.id);
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Pengurus berhasil dihapus');
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  _RoleBadgeStyle _getRoleBadgeStyle(String role) {
    final r = role.toLowerCase();
    if (r.contains('ketua umum') || (r.contains('ketua') && !r.contains('wakil') && !r.contains('divisi'))) {
      return const _RoleBadgeStyle(
        bgColor: Color(0xFFFEF3C7),
        borderColor: Color(0xFFFDE68A),
        textColor: BkuTheme.textHeading,
      );
    }
    if (r.contains('wakil')) {
      return const _RoleBadgeStyle(
        bgColor: Color(0xFFFFE4E6),
        borderColor: Color(0xFFFECDD3),
        textColor: BkuTheme.textHeading,
      );
    }
    if (r.contains('pembina') || r.contains('penasihat') || r.contains('dosen')) {
      return const _RoleBadgeStyle(
        bgColor: Color(0xFFEEF2FF),
        borderColor: Color(0xFFC7D2FE),
        textColor: BkuTheme.textHeading,
      );
    }
    if (r.contains('sekretaris') || r.contains('bendahara') || r.contains('bph')) {
      return const _RoleBadgeStyle(
        bgColor: Color(0xFFE0F2FE),
        borderColor: Color(0xFFBAE6FD),
        textColor: BkuTheme.textHeading,
      );
    }
    if (r.contains('kepala') || r.contains('kadiv') || r.contains('koordinator')) {
      return const _RoleBadgeStyle(
        bgColor: Color(0xFFF3E8FF),
        borderColor: Color(0xFFDDD6FE),
        textColor: BkuTheme.textHeading,
      );
    }
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFF1F5F9),
      borderColor: Color(0xFFE2E8F0),
      textColor: BkuTheme.textHeading,
    );
  }
}

class _RoleBadgeStyle {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  const _RoleBadgeStyle({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}
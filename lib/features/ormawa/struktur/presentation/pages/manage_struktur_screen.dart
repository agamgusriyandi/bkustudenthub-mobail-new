import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';

class ManageStrukturScreen extends StatefulWidget {
  const ManageStrukturScreen({super.key});

  @override
  State<ManageStrukturScreen> createState() => _ManageStrukturScreenState();
}

class _ManageStrukturScreenState extends State<ManageStrukturScreen> {
  final _divisionNameController = TextEditingController();
  final _bphSearchController = TextEditingController();

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
    _bphSearchController.dispose();
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

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
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
                        AppSpacing.xl,
                        AppSpacing.lg,
                        AppSpacing.xl,
                        AppSpacing.s100,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('INFORMASI KEPENGURUSAN', Icons.info_outline_rounded, AppColors.serviceIndigo),
                          const SizedBox(height: AppSpacing.sm),
                          _buildCabinetInfoCard(provider.orgName, provider.academicYear),
                          const SizedBox(height: AppSpacing.xl),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader('PIMPINAN & PENGURUS BPH', Icons.shield_rounded, AppColors.serviceSky),
                              if (provider.hasPermission('manage_structure'))
                                GestureDetector(
                                  onTap: () => _showManageBphBottomSheet(context, provider),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.serviceSky.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.serviceSky.withAlpha(50),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person_add_rounded, size: 13, color: AppColors.serviceSky),
                                        SizedBox(width: 3),
                                        Text(
                                          'Tambah BPH',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.serviceSky,
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
                              _buildSectionHeader('DEPARTEMEN & DIVISI', Icons.category_rounded, AppColors.servicePurple),
                              if (provider.hasPermission('manage_structure'))
                                GestureDetector(
                                  onTap: () => _showAddDivisionDialog(context, provider),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.servicePurple.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: AppColors.servicePurple.withAlpha(50),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_circle_outline_rounded, size: 13, color: AppColors.servicePurple),
                                        SizedBox(width: 3),
                                        Text(
                                          'Tambah Divisi',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.servicePurple,
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
          style: TextStyle(
            color: context.appColors.onSurface,
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
    final displayYear = academicYear.isNotEmpty ? academicYear : '2025/2026';

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppRadius.md,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.serviceIndigo.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge_rounded, color: AppColors.serviceIndigo, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Organisasi',
                      style: TextStyle(fontSize: 9.5, color: AppColors.neutral500, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      displayOrg,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.appColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 16, thickness: 0.8),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.serviceAmber.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: AppColors.serviceAmber, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tahun Akademik / Periode',
                      style: TextStyle(fontSize: 9.5, color: AppColors.neutral500, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Periode $displayYear',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: context.appColors.onSurface),
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
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(size * 0.25),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
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
                      color: const Color(0xFF475569),
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
                      color: const Color(0xFF475569),
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
                    color: const Color(0xFF475569),
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
      borderRadius: AppRadius.md,
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
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subText.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subText,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: context.appColors.onSurfaceVariant,
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
                        borderRadius: BorderRadius.circular(4),
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: Text(
                          'Divisi ${member.division}',
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
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
                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.neutral500),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: onEdit,
                tooltip: 'Ubah Jabatan',
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
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
      borderRadius: AppRadius.md,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.servicePurple.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_shared_rounded, color: AppColors.servicePurple, size: 16),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$memberCount Anggota Terdaftar',
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          if (provider.hasPermission('manage_structure'))
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                BkuDialog.show(
                  context: context,
                  type: BkuDialogType.error,
                  title: 'Hapus Divisi?',
                  message: 'Divisi "${dept.name}" akan dihapus. Anggota di dalamnya tidak akan terhapus.',
                  primaryButtonText: 'Hapus',
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
        style: const TextStyle(fontSize: 11, color: AppColors.neutral400, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showAddDivisionDialog(BuildContext context, OrmawaProvider provider) {
    _divisionNameController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        title: const Text(
          'Tambah Divisi Baru',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.neutral900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _divisionNameController,
              autofocus: true,
              style: const TextStyle(fontSize: 13, color: AppColors.neutral900, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Nama Divisi (contoh: Humas, Kominfo)',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.neutral400),
                filled: true,
                fillColor: AppColors.neutral100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.neutral300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.neutral300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.neutral300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Simpan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
  }

  void _showManageBphBottomSheet(
    BuildContext context,
    OrmawaProvider provider, [
    OrmawaMember? existingMember,
  ]) {
    final rbacRoles = provider.roles.map((r) => r.name.trim()).where((n) => n.isNotEmpty);
    final memberRoles = provider.members.map((m) => m.role.trim()).where((r) => r.isNotEmpty);
    final defaults = ['Ketua', 'Wakil Ketua', 'Sekretaris', 'Bendahara', 'Kepala Divisi', 'Staff', 'Anggota', 'Pembina'];
    final dynamicRoles = {
      ...defaults,
      ...rbacRoles,
      ...memberRoles,
      if (existingMember != null && existingMember.role.trim().isNotEmpty) existingMember.role.trim(),
    }.toList();

    final allDivisions = provider.divisions.map((d) => d.name).where((d) => d.trim().isNotEmpty).toSet().toList();

    String selectedRole = existingMember?.role.trim() ?? 'Sekretaris';
    if (!dynamicRoles.contains(selectedRole)) {
      selectedRole = dynamicRoles.first;
    }

    String selectedDivision = existingMember?.division.trim() ?? '';
    if (selectedDivision.isNotEmpty && !allDivisions.contains(selectedDivision)) {
      allDivisions.add(selectedDivision);
    }

    OrmawaMember? selectedMember = existingMember;
    String searchKeyword = '';
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final students = provider.members;
          final filteredStudents = searchKeyword.isEmpty
              ? students
              : students.where((m) =>
                  m.name.toLowerCase().contains(searchKeyword.toLowerCase()) ||
                  m.nim.toLowerCase().contains(searchKeyword.toLowerCase())).toList();

          return Container(
            height: MediaQuery.of(ctx).size.height * 0.90,
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
                        color: const Color(0xFFCBD5E1),
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
                            color: context.appColors.primary.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.group_add_rounded, size: 20, color: context.appColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kelola Pengurus BPH',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Tambah atau ubah jabatan pengurus inti ormawa.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
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
                              color: Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: context.appColors.primary.withAlpha(20),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'TETAPKAN JABATAN MAHASISWA',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w900,
                                          color: context.appColors.primary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                const Text(
                                  'Pilih Mahasiswa',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                ),
                                const SizedBox(height: 5),

                                if (selectedMember != null && !isSearching) ...[
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: const Color(0xFFCBD5E1)),
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
                                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'NIM: ${selectedMember!.nim}${selectedMember!.prodi != null && selectedMember!.prodi!.isNotEmpty ? ' • ${selectedMember!.prodi}' : ''}',
                                                style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        OutlinedButton(
                                          onPressed: () {
                                            setModalState(() {
                                              isSearching = true;
                                              searchKeyword = '';
                                            });
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            minimumSize: Size.zero,
                                          ),
                                          child: const Text('Ganti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                                        ),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  TextField(
                                    autofocus: isSearching,
                                    onChanged: (val) {
                                      setModalState(() {
                                        isSearching = true;
                                        searchKeyword = val;
                                      });
                                    },
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      hintText: 'Ketik Nama atau NIM mahasiswa...',
                                      hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                                      prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: context.appColors.primary, width: 1.5),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: filteredStudents.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'Mahasiswa tidak ditemukan',
                                              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                            ),
                                          )
                                        : ListView.separated(
                                            itemCount: filteredStudents.length,
                                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                            itemBuilder: (c, idx) {
                                              final st = filteredStudents[idx];
                                              final isSelected = selectedMember?.mahasiswaId == st.mahasiswaId;
                                              return ListTile(
                                                dense: true,
                                                tileColor: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
                                                leading: _buildAvatar(st.name, st.fotoUrl, size: 30),
                                                title: Text(
                                                  st.name,
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  'NIM: ${st.nim}${st.prodi != null && st.prodi!.isNotEmpty ? ' • ${st.prodi}' : ''}',
                                                  style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                                ),
                                                onTap: () {
                                                  setModalState(() {
                                                    selectedMember = st;
                                                    if (st.role.isNotEmpty && dynamicRoles.contains(st.role)) {
                                                      selectedRole = st.role;
                                                    }
                                                    if (st.division.isNotEmpty) {
                                                      selectedDivision = st.division;
                                                    }
                                                    isSearching = false;
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                  ),
                                ],
                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Jabatan (Dari RBAC)',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                          ),
                                          const SizedBox(height: 4),
                                          DropdownButtonFormField<String>(
                                            initialValue: selectedRole,
                                            isExpanded: true,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                            items: dynamicRoles.map((r) => DropdownMenuItem<String>(
                                              value: r,
                                              child: Text(r, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold)),
                                            )).toList(),
                                            onChanged: (val) {
                                              if (val != null) setModalState(() => selectedRole = val);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Divisi (Opsional)',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                          ),
                                          const SizedBox(height: 4),
                                          DropdownButtonFormField<String>(
                                            initialValue: selectedDivision,
                                            isExpanded: true,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                            items: [
                                              const DropdownMenuItem<String>(
                                                value: '',
                                                child: Text('Pengurus Inti (Tanpa Divisi)', style: TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.bold)),
                                              ),
                                              ...allDivisions.map((d) => DropdownMenuItem<String>(
                                                value: d,
                                                child: Text(d, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 12, fontWeight: FontWeight.bold)),
                                              )),
                                            ],
                                            onChanged: (val) {
                                              if (val != null) setModalState(() => selectedDivision = val);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
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
                                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                                    label: const Text(
                                      'Simpan Jabatan Pengurus',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: context.appColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          Row(
                            children: [
                              const Text(
                                'DAFTAR PENGURUS TERDAFTAR',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF334155),
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${provider.members.length} Pengurus',
                                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (provider.members.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Text('Belum ada pengurus terdaftar.', style: TextStyle(fontSize: 11, color: AppColors.neutral400)),
                              ),
                            )
                          else
                            ...provider.members.map((m) {
                              final rStyle = _getRoleBadgeStyle(m.role);
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
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
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
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
                                                  borderRadius: BorderRadius.circular(4),
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
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                                                  ),
                                                  child: Text(
                                                    'Divisi ${m.division}',
                                                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
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
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFEE2E2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
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
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F5F9),
                          foregroundColor: const Color(0xFF475569),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ],
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
      primaryButtonText: 'Hapus',
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
      return _RoleBadgeStyle(
        bgColor: const Color(0xFFFEF3C7),
        borderColor: const Color(0xFFFDE047),
        textColor: const Color(0xFFB45309),
      );
    }
    if (r.contains('wakil')) {
      return _RoleBadgeStyle(
        bgColor: const Color(0xFFFFEDD5),
        borderColor: const Color(0xFFFED7AA),
        textColor: const Color(0xFFC2410C),
      );
    }
    if (r.contains('pembina') || r.contains('penasihat') || r.contains('dosen')) {
      return _RoleBadgeStyle(
        bgColor: const Color(0xFFE0E7FF),
        borderColor: const Color(0xFFC7D2FE),
        textColor: const Color(0xFF4338CA),
      );
    }
    if (r.contains('sekretaris') || r.contains('bendahara') || r.contains('bph')) {
      return _RoleBadgeStyle(
        bgColor: const Color(0xFFE0F2FE),
        borderColor: const Color(0xFFBAE6FD),
        textColor: const Color(0xFF0369A1),
      );
    }
    if (r.contains('kepala') || r.contains('kadiv') || r.contains('koordinator')) {
      return _RoleBadgeStyle(
        bgColor: const Color(0xFFF3E8FF),
        borderColor: const Color(0xFFE9D5FF),
        textColor: const Color(0xFF7E22CE),
      );
    }
    return _RoleBadgeStyle(
      bgColor: const Color(0xFFD1FAE5),
      borderColor: const Color(0xFFA7F3D0),
      textColor: const Color(0xFF047857),
    );
  }
}

class _RoleBadgeStyle {
  final Color bgColor;
  final Color borderColor;
  final Color textColor;

  _RoleBadgeStyle({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
  });
}

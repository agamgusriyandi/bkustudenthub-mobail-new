import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dropdown.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';

class _RoleBadgeStyle {
  final Color bgColor;
  final Color textColor;
  final Color borderColor;

  const _RoleBadgeStyle({
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
  });
}

_RoleBadgeStyle _getRoleBadgeStyle(String role) {
  final r = role.toLowerCase().trim();
  if (r.contains('ketua umum') || (r.contains('ketua') && !r.contains('wakil') && !r.contains('divisi'))) {
    return _RoleBadgeStyle(
      bgColor: BkuTheme.amberSoft,
      textColor: BkuTheme.amber,
      borderColor: BkuTheme.amberBorder,
    );
  }
  if (r.contains('wakil')) {
    return _RoleBadgeStyle(
      bgColor: BkuTheme.amberSoft,
      textColor: BkuTheme.amber,
      borderColor: BkuTheme.amberBorder,
    );
  }
  if (r.contains('pembina') || r.contains('penanggung jawab') || r.contains('penasihat')) {
    return _RoleBadgeStyle(
      bgColor: BkuTheme.purpleSoft,
      textColor: BkuTheme.purple,
      borderColor: BkuTheme.purpleBorder,
    );
  }
  if (r.contains('sekretaris') || r.contains('bendahara') || r.contains('bph')) {
    return _RoleBadgeStyle(
      bgColor: BkuTheme.skySoft,
      textColor: BkuTheme.statusInfoText,
      borderColor: BkuTheme.skyBorder,
    );
  }
  if (r.contains('kepala') || r.contains('kadiv') || r.contains('koordinator')) {
    return _RoleBadgeStyle(
      bgColor: BkuTheme.indigoSoft,
      textColor: BkuTheme.indigo,
      borderColor: BkuTheme.indigoBorder,
    );
  }
  if (r.contains('staff') || r.contains('staf') || r == 'anggota' || r.contains('anggota')) {
    return _RoleBadgeStyle(
      bgColor: BkuTheme.slateSoft,
      textColor: BkuTheme.textBody,
      borderColor: BkuTheme.border,
    );
  }
  return _RoleBadgeStyle(
    bgColor: BkuTheme.borderSubtle,
    textColor: BkuTheme.textHeading,
    borderColor: BkuTheme.border,
  );
}

Widget _buildAvatar(String name, String? fotoUrl, {double size = 40}) {
  String initials = 'M';
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.length == 1) {
    initials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  } else if (parts.length > 1) {
    initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String? fullUrl;
  if (fotoUrl != null && fotoUrl.isNotEmpty) {
    fullUrl = ApiGate.getImageUrl(fotoUrl);
  }

  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: BkuTheme.borderSubtle,
      borderRadius: size > 44 ? BkuTheme.r20 : (size > 34 ? BkuTheme.r12 : BkuTheme.r8),
      border: Border.all(color: BkuTheme.border, width: 1.0),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: fullUrl != null
        ? Image.network(
            fullUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Center(
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: size * 0.36,
                  fontWeight: FontWeight.w900,
                  color: BkuTheme.textMuted,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          )
        : Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.36,
                fontWeight: FontWeight.w900,
                color: BkuTheme.textMuted,
                letterSpacing: -0.5,
              ),
            ),
          ),
  );
}

class OrmawaStafScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaStafScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaStafScreen> createState() => _OrmawaStafScreenState();
}

class _OrmawaStafScreenState extends State<OrmawaStafScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedRoleFilter = 'all';
  String _selectedDivisiFilter = 'all';

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
      final q = _searchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          m.name.toLowerCase().contains(q) ||
          m.nim.toLowerCase().contains(q);

      final matchesRole = _selectedRoleFilter == 'all' ||
          m.role.toLowerCase() == _selectedRoleFilter.toLowerCase();

      final matchesDivisi = _selectedDivisiFilter == 'all' ||
          (m.division.isEmpty ? 'Umum' : m.division).toLowerCase() == _selectedDivisiFilter.toLowerCase();

      return matchesSearch && matchesRole && matchesDivisi;
    }).toList();
  }

  void _showDetailModal(BuildContext context, OrmawaMember member) {
    BkuBottomSheet.show(
      context: context,
      title: 'Detail Pengurus',
      child: _OrmawaStafDetailSheet(member: member),
    );
  }

  void _showFormModal(BuildContext context, [OrmawaMember? member]) {
    BkuBottomSheet.show(
      context: context,
      title: member != null ? 'Edit Pengurus' : 'Tambah Pengurus Baru',
      child: _OrmawaStafFormSheet(initialMember: member),
    );
  }

  void _confirmDelete(BuildContext context, OrmawaMember member) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Pengurus?',
      message: 'Hapus "${member.name}" dari jajaran staf dan pengurus organisasi?',
      primaryButtonText: 'Hapus',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await context.read<OrmawaProvider>().deleteMember(member.id);
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Pengurus berhasil dihapus');
        }
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final members = provider.members;
        final filteredMembers = _getFilteredMembers(members);
        final canCreateStaff = provider.hasPermission('ormawa.staff.create, ormawa.staff.manage, ormawa.members.create, ormawa.organisasi.manage');
        final canEditStaff = provider.hasPermission('ormawa.staff.update, ormawa.staff.manage, ormawa.members.update, ormawa.organisasi.manage');
        final canDeleteStaff = provider.hasPermission('ormawa.staff.delete, ormawa.staff.manage, ormawa.members.delete, ormawa.organisasi.manage');

        return Scaffold(
          backgroundColor: BkuTheme.scaffoldBg,
          body: RefreshIndicator(
            onRefresh: () => context.read<OrmawaProvider>().refreshData(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Manajemen Staf',
                  subtitle: 'Pengurus & Personil Struktural',
                  expandedHeight: 115.0,
                  showBackButton: widget.showBackButton,
                  isExpandable: false,
                ),

                if (provider.isLoading)
                  const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
                      child: BkuShimmerList(itemCount: 5, itemHeight: 80),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroBanner(context, canCreateStaff),
                          const SizedBox(height: 14),

                          _buildStatsGrid(context, members),
                          const SizedBox(height: 14),

                          _buildToolbarAndFilter(context, provider, filteredMembers.length, members.length),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),

                if (!provider.isLoading && filteredMembers.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 20),
                      child: BkuEmptyState(
                        icon: Icons.shield_outlined,
                        title: 'Tidak ada pengurus ditemukan',
                        message: 'Coba sesuaikan kata kunci pencarian atau filter jabatan.',
                      ),
                    ),
                  )
                else if (!provider.isLoading)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 32),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final member = filteredMembers[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildMemberCard(context, member, canEditStaff, canDeleteStaff),
                          );
                        },
                        childCount: filteredMembers.length,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool showAddButton) {
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r8,
                  border: Border.all(color: BkuTheme.border),
                ),
                child: Text(
                  'Organisasi Kemahasiswaan',
                  style: BkuTheme.textBadge.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: BkuTheme.textHeading,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              if (showAddButton)
                BkuButton.primary(
                  onPressed: () => _showFormModal(context),
                  icon: Icons.person_add_rounded,
                  text: 'Tambah Pengurus',
                  height: 34,
                  fontSize: 11,
                  fullWidth: false,
                  customRadius: BkuTheme.r8,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, size: 22, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Manajemen ',
                            style: BkuTheme.textSectionTitle.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: 'Staf & Pengurus',
                            style: BkuTheme.textSectionTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Pengelolaan jajaran pimpinan, pengurus harian (BPH), kepala divisi, dan staf pelaksana organisasi.',
                      style: BkuTheme.textCaption.copyWith(
                        fontSize: 10.5,
                        color: BkuTheme.textMuted,
                        height: 1.35,
                      ),
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

  Widget _buildStatsGrid(BuildContext context, List<OrmawaMember> members) {
    final total = members.length;
    final countBPH = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('ketua') || r.contains('wakil') || r.contains('sekretaris') || r.contains('bendahara') || r.contains('pembina');
    }).length;

    final countKadiv = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('kepala') || r.contains('kadiv') || r.contains('koordinator');
    }).length;

    final countStaf = (total - countBPH - countKadiv) < 0 ? 0 : (total - countBPH - countKadiv);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 10) / 2;
        return Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: OrmawaKpiCard(
                    title: 'Total Pengurus',
                    value: '$total',
                    badgeText: 'Pengurus',
                    badgeColor: BkuTheme.emerald,
                    icon: Icons.groups_rounded,
                    subtitle: 'Seluruh personil struktural',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: cardWidth,
                  child: OrmawaKpiCard(
                    title: 'Pengurus BPH',
                    value: '$countBPH',
                    badgeText: 'BPH',
                    badgeColor: BkuTheme.sky,
                    icon: Icons.security_rounded,
                    subtitle: 'Pimpinan & Pengurus Harian',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: cardWidth,
                  child: OrmawaKpiCard(
                    title: 'Kepala Divisi',
                    value: '$countKadiv',
                    badgeText: 'Kadiv',
                    badgeColor: BkuTheme.amber,
                    icon: Icons.workspaces_rounded,
                    subtitle: 'Koordinator bidang aktif',
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: cardWidth,
                  child: OrmawaKpiCard(
                    title: 'Staf & Anggota',
                    value: '$countStaf',
                    badgeText: 'Pelaksana',
                    badgeColor: BkuTheme.primary,
                    icon: Icons.assignment_ind_rounded,
                    subtitle: 'Staf bidang operasional',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildToolbarAndFilter(
    BuildContext context,
    OrmawaProvider provider,
    int filteredCount,
    int totalCount,
  ) {
    final rbacRoles = provider.roles.map((r) => r.name.trim()).where((n) => n.isNotEmpty).toSet().toList();
    final memberRoles = provider.members.map((m) => m.role.trim()).where((r) => r.isNotEmpty).toSet().toList();
    final allRoles = {...rbacRoles, ...memberRoles}.toList();
    if (allRoles.isEmpty) {
      allRoles.addAll(['Ketua Umum', 'Wakil Ketua', 'Sekretaris', 'Bendahara', 'Kepala Divisi', 'Staff']);
    }

    final allDivisions = provider.divisions.map((d) => d.name).where((d) => d.trim().isNotEmpty).toSet().toList();
    final hasActiveFilter = _searchQuery.isNotEmpty || _selectedRoleFilter != 'all' || _selectedDivisiFilter != 'all';

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 16,
      child: Column(
        children: [
          BkuTextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            hint: 'Cari nama atau NIM pengurus...',
            prefixIcon: const Icon(Icons.search, size: 18, color: BkuTheme.textMuted),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, size: 16, color: BkuTheme.textMuted),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: BkuDropdown<String>(
                  value: _selectedRoleFilter,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('Semua Jabatan', style: TextStyle(fontSize: 11))),
                    ...allRoles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRoleFilter = val);
                  },
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: BkuDropdown<String>(
                  value: _selectedDivisiFilter,
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem(value: 'all', child: Text('Semua Divisi', style: TextStyle(fontSize: 11))),
                    ...allDivisions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 11)))),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDivisiFilter = val);
                  },
                ),
              ),
              if (hasActiveFilter) ...[
                const SizedBox(width: 8),
                BkuButton.dangerOutline(
                  text: 'Reset',
                  height: 48,
                  fullWidth: false,
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedRoleFilter = 'all';
                      _selectedDivisiFilter = 'all';
                    });
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                '$filteredCount / $totalCount pengurus',
                style: BkuTheme.textCaption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: BkuTheme.textPlaceholder,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    OrmawaMember member,
    bool canEdit,
    bool canDelete,
  ) {
    final roleStyle = _getRoleBadgeStyle(member.role);
    final phone = member.phone;
    final email = member.email;

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(member.name, member.fotoUrl, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: BkuTheme.textCardTitle.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIM: ${member.nim}${member.prodi != null && member.prodi!.isNotEmpty ? ' • ${member.prodi}' : ''}',
                      style: BkuTheme.textCaption.copyWith(
                        fontSize: 10,
                        color: BkuTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showDetailModal(context, member),
                    borderRadius: BkuTheme.r8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: BkuTheme.borderSubtle,
                        borderRadius: BkuTheme.r8,
                      ),
                      child: const Icon(Icons.visibility_rounded, size: 16, color: BkuTheme.textMuted),
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _showFormModal(context, member),
                      borderRadius: BkuTheme.r8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: BkuTheme.amberSoft,
                          borderRadius: BkuTheme.r8,
                        ),
                        child: const Icon(Icons.edit_rounded, size: 16, color: BkuTheme.amber),
                      ),
                    ),
                  ],
                  if (canDelete) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _confirmDelete(context, member),
                      borderRadius: BkuTheme.r8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: BkuTheme.roseSoft,
                          borderRadius: BkuTheme.r8,
                        ),
                        child: const Icon(Icons.delete_rounded, size: 16, color: BkuTheme.rose),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: roleStyle.bgColor,
                  borderRadius: BkuTheme.r8,
                  border: Border.all(color: roleStyle.borderColor),
                ),
                child: Text(
                  member.role.toUpperCase(),
                  style: BkuTheme.textBadge.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: roleStyle.textColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: BkuTheme.borderSubtle,
                  borderRadius: BkuTheme.r8,
                  border: Border.all(color: BkuTheme.border),
                ),
                child: Text(
                  member.division.isEmpty ? 'Umum' : member.division,
                  style: BkuTheme.textBadge.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: BkuTheme.textBody,
                  ),
                ),
              ),
            ],
          ),

          if ((phone != null && phone.isNotEmpty) || (email != null && email.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (phone != null && phone.isNotEmpty) ...[
                  InkWell(
                    onTap: () async {
                      final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
                      final uri = Uri.parse('https://wa.me/$clean');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    borderRadius: BkuTheme.r8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: BkuTheme.emeraldSoft,
                        borderRadius: BkuTheme.r8,
                        border: Border.all(color: BkuTheme.emeraldBorder),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_rounded, size: 12, color: BkuTheme.emerald),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: BkuTheme.textCaption.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: BkuTheme.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (email != null && email.isNotEmpty) ...[
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final uri = Uri.parse('mailto:$email');
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        }
                      },
                      borderRadius: BkuTheme.r8,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mail_outline_rounded, size: 12, color: BkuTheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              email,
                              style: BkuTheme.textCaption.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: BkuTheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }
}

class _OrmawaStafDetailSheet extends StatelessWidget {
  final OrmawaMember member;
  const _OrmawaStafDetailSheet({required this.member});

  @override
  Widget build(BuildContext context) {
    final roleStyle = _getRoleBadgeStyle(member.role);
    final phone = member.phone;
    final email = member.email;

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(member.name, member.fotoUrl, size: 72),
          const SizedBox(height: 12),

          Text(
            member.name,
            style: BkuTheme.textSectionTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            'NIM: ${member.nim}${member.prodi != null && member.prodi!.isNotEmpty ? ' • ${member.prodi}' : ''}',
            style: BkuTheme.textCaption.copyWith(
              fontSize: 11,
              color: BkuTheme.textMuted,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: roleStyle.bgColor,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: roleStyle.borderColor),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Jabatan Struktural',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.role,
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: roleStyle.textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  decoration: BoxDecoration(
                    color: BkuTheme.borderSubtle,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Divisi Kerja',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        member.division.isEmpty ? 'Umum' : member.division,
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: BkuTheme.textHeading,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (email != null && email.isNotEmpty) ...[
            InkWell(
              onTap: () async {
                final uri = Uri.parse('mailto:$email');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
              borderRadius: BkuTheme.r12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkuTheme.primarySoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.primaryBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.mail_rounded, size: 18, color: BkuTheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Kampus',
                            style: BkuTheme.textCaption.copyWith(
                              fontSize: 9.5,
                              color: BkuTheme.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            email,
                            style: BkuTheme.textCaption.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: BkuTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 12, color: BkuTheme.primary),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],

          if (phone != null && phone.isNotEmpty) ...[
            InkWell(
              onTap: () async {
                final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
                final uri = Uri.parse('https://wa.me/$clean');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              borderRadius: BkuTheme.r12,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BkuTheme.emeraldSoft,
                  borderRadius: BkuTheme.r12,
                  border: Border.all(color: BkuTheme.emeraldBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.chat_rounded, size: 18, color: BkuTheme.emerald),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WhatsApp',
                            style: BkuTheme.textCaption.copyWith(
                              fontSize: 9.5,
                              color: BkuTheme.textMuted,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            phone,
                            style: BkuTheme.textCaption.copyWith(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: BkuTheme.emerald,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: BkuTheme.emerald),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),

          BkuButton.outline(
            onPressed: () => Navigator.pop(context),
            text: 'Tutup Profil',
            height: 44,
          ),
        ],
      ),
    );
  }
}

class _OrmawaStafFormSheet extends StatefulWidget {
  final OrmawaMember? initialMember;
  const _OrmawaStafFormSheet({this.initialMember});

  @override
  State<_OrmawaStafFormSheet> createState() => _OrmawaStafFormSheetState();
}

class _OrmawaStafFormSheetState extends State<_OrmawaStafFormSheet> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  OrmawaMember? _selectedStudent;
  String _selectedRole = '';
  String _selectedDivision = '';
  bool _isSearching = false;
  String _searchKeyword = '';
  List<Map<String, dynamic>> _loadedStudents = [];
  bool _isLoadingStudents = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMember;
    if (m != null) {
      _selectedStudent = m;
      _selectedRole = m.role;
      _selectedDivision = m.division;
      _emailController.text = m.email ?? '';
      _phoneController.text = m.phone ?? '';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<OrmawaProvider>();
    final isEdit = widget.initialMember != null;

    final rbacRoles = provider.roles.map((r) => r.name.trim()).where((n) => n.isNotEmpty).toSet().toList();
    final memberRoles = provider.members.map((m) => m.role.trim()).where((r) => r.isNotEmpty).toSet().toList();
    final dynamicRoles = {
      ...rbacRoles,
      ...memberRoles,
      if (widget.initialMember != null && widget.initialMember!.role.trim().isNotEmpty) widget.initialMember!.role.trim(),
    }.toList();

    if (dynamicRoles.isEmpty) {
      dynamicRoles.addAll(['Ketua Umum', 'Wakil Ketua', 'Sekretaris', 'Bendahara', 'Kepala Divisi', 'Staff', 'Anggota', 'Pembina']);
    }

    if (_selectedRole.isEmpty || !dynamicRoles.contains(_selectedRole)) {
      _selectedRole = dynamicRoles.first;
    }

    final allDivisions = provider.divisions.map((d) => d.name).where((d) => d.trim().isNotEmpty).toSet().toList();
    if (_selectedDivision.isNotEmpty && !allDivisions.contains(_selectedDivision)) {
      allDivisions.add(_selectedDivision);
    }

    return StatefulBuilder(
      builder: (ctx, setSheetState) {
        if (_isLoadingStudents && _loadedStudents.isEmpty) {
          provider.getStudents().then((res) {
            if (mounted) {
              setState(() {
                _loadedStudents = res;
                _isLoadingStudents = false;
              });
            }
          }).catchError((_) {
            if (mounted) {
              setState(() => _isLoadingStudents = false);
            }
          });
        }

        final filteredStudents = _searchKeyword.isEmpty
            ? _loadedStudents
            : _loadedStudents.where((s) {
                final name = (s['Nama'] ?? s['nama'] ?? s['nama_mahasiswa'] ?? '').toString().toLowerCase();
                final nim = (s['NIM'] ?? s['nim'] ?? '').toString().toLowerCase();
                final q = _searchKeyword.toLowerCase();
                return name.contains(q) || nim.contains(q);
              }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Mahasiswa',
                style: BkuTheme.textCardTitle.copyWith(fontSize: 12),
              ),
              const SizedBox(height: 6),

              if (_selectedStudent != null && !_isSearching) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: BkuTheme.cardSurface,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.border),
                  ),
                  child: Row(
                    children: [
                      _buildAvatar(_selectedStudent!.name, _selectedStudent!.fotoUrl, size: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedStudent!.name,
                              style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'NIM: ${_selectedStudent!.nim}${_selectedStudent!.prodi != null && _selectedStudent!.prodi!.isNotEmpty ? ' • ${_selectedStudent!.prodi}' : ''}',
                              style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      BkuButton.outline(
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                            _searchKeyword = '';
                          });
                        },
                        text: 'Ganti',
                        height: 32,
                        fontSize: 11,
                        fullWidth: false,
                        customRadius: BkuTheme.r8,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                BkuTextField(
                  autofocus: _isSearching,
                  onChanged: (val) => setState(() {
                    _isSearching = true;
                    _searchKeyword = val;
                  }),
                  hint: 'Ketik Nama atau NIM mahasiswa...',
                  prefixIcon: const Icon(Icons.search, size: 18, color: BkuTheme.textMuted),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 140,
                  decoration: BoxDecoration(
                    border: Border.all(color: BkuTheme.border),
                    borderRadius: BkuTheme.r12,
                    color: BkuTheme.cardSurface,
                  ),
                  child: _isLoadingStudents
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : filteredStudents.isEmpty
                          ? Center(
                              child: Text(
                                'Mahasiswa tidak ditemukan',
                                style: BkuTheme.textCaption.copyWith(color: BkuTheme.textPlaceholder),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredStudents.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: BkuTheme.borderSubtle),
                              itemBuilder: (c, idx) {
                                final st = filteredStudents[idx];
                                final mId = (st['id'] ?? st['ID'] ?? st['mahasiswa_id'] ?? st['MahasiswaID'])?.toString() ?? '';
                                final stName = (st['Nama'] ?? st['nama'] ?? st['nama_mahasiswa'] ?? '').toString();
                                final stNim = (st['NIM'] ?? st['nim'] ?? '').toString();
                                final stProdi = (st['ProgramStudi'] is Map ? (st['ProgramStudi']['Nama'] ?? st['ProgramStudi']['nama']) : (st['prodi'] ?? st['Prodi']))?.toString() ?? '';
                                final stFoto = (st['foto_url'] ?? st['avatar_url'] ?? st['foto'] ?? st['Foto'])?.toString();
                                final stEmail = (st['EmailKampus'] ?? st['email'] ?? '').toString();
                                final stPhone = (st['NoHP'] ?? st['no_hp'] ?? '').toString();

                                return ListTile(
                                  dense: true,
                                  leading: _buildAvatar(stName, stFoto, size: 30),
                                  title: Text(
                                    stName,
                                    style: BkuTheme.textCardTitle.copyWith(fontSize: 11.5),
                                  ),
                                  subtitle: Text(
                                    'NIM: $stNim${stProdi.isNotEmpty ? ' • $stProdi' : ''}',
                                    style: BkuTheme.textCaption.copyWith(fontSize: 9.5, color: BkuTheme.textMuted),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedStudent = OrmawaMember(
                                        id: '',
                                        mahasiswaId: mId,
                                        name: stName,
                                        nim: stNim,
                                        role: _selectedRole,
                                        division: _selectedDivision,
                                        status: 'aktif',
                                        prodi: stProdi,
                                        fotoUrl: stFoto,
                                        email: stEmail,
                                        phone: stPhone,
                                      );
                                      if (stEmail.isNotEmpty && _emailController.text.isEmpty) {
                                        _emailController.text = stEmail;
                                      }
                                      if (stPhone.isNotEmpty && _phoneController.text.isEmpty) {
                                        _phoneController.text = stPhone;
                                      }
                                      _isSearching = false;
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
                        Text(
                          'Jabatan Struktural',
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        BkuDropdown<String>(
                          value: _selectedRole,
                          isExpanded: true,
                          items: dynamicRoles.map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedRole = val);
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
                        Text(
                          'Divisi Kerja',
                          style: BkuTheme.textCardTitle.copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        BkuDropdown<String>(
                          value: _selectedDivision,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem(value: '', child: Text('Umum (Tanpa Divisi)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            ...allDivisions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)))),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDivision = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              BkuTextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                label: 'Email Kampus (Opsional)',
                hint: 'contoh@bku.ac.id',
                prefixIcon: const Icon(Icons.mail_outline_rounded, size: 18, color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 12),

              BkuTextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                label: 'Nomor WhatsApp (Opsional)',
                hint: '081234567890',
                prefixIcon: const Icon(Icons.phone_outlined, size: 18, color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 20),

              BkuButton.primary(
                isLoading: _isSubmitting,
                icon: Icons.save_rounded,
                text: _isSubmitting ? 'Menyimpan...' : (isEdit ? 'Simpan Perubahan' : 'Daftarkan Pengurus'),
                height: 46,
                onPressed: _isSubmitting ? null : () async {
                  if (_selectedStudent == null) {
                    AppSnackbar.showError(context, 'Wajib mencari dan memilih mahasiswa terlebih dahulu!');
                    return;
                  }

                  setState(() => _isSubmitting = true);
                  try {
                    final existing = provider.members.where((m) => m.mahasiswaId == _selectedStudent!.mahasiswaId).firstOrNull;

                    if (isEdit && widget.initialMember != null) {
                      await provider.updateMember(widget.initialMember!.id, {
                        'Role': _selectedRole,
                        'Divisi': _selectedDivision,
                        'EmailKampus': _emailController.text.trim(),
                        'NoHP': _phoneController.text.trim(),
                      });
                    } else if (existing != null) {
                      await provider.updateMember(existing.id, {
                        'Role': _selectedRole,
                        'Divisi': _selectedDivision,
                        'EmailKampus': _emailController.text.trim(),
                        'NoHP': _phoneController.text.trim(),
                      });
                    } else {
                      await provider.addMember({
                        'MahasiswaID': int.tryParse(_selectedStudent!.mahasiswaId) ?? _selectedStudent!.mahasiswaId,
                        'Role': _selectedRole,
                        'Divisi': _selectedDivision,
                        'EmailKampus': _emailController.text.trim(),
                        'NoHP': _phoneController.text.trim(),
                      });
                    }

                    if (context.mounted) {
                      AppSnackbar.showSuccess(context, isEdit ? 'Data pengurus diperbarui' : 'Pengurus berhasil ditambahkan');
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      AppSnackbar.showError(context, 'Gagal menyimpan data: $e');
                    }
                  } finally {
                    if (mounted) setState(() => _isSubmitting = false);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
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
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFFEF3C7),
      textColor: Color(0xFF92400E),
      borderColor: Color(0xFFFDE68A),
    );
  }
  if (r.contains('wakil')) {
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFFFEDD5),
      textColor: Color(0xFF9A3412),
      borderColor: Color(0xFFFED7AA),
    );
  }
  if (r.contains('pembina') || r.contains('penanggung jawab') || r.contains('penasihat')) {
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFF1F5F9),
      textColor: Color(0xFF1E293B),
      borderColor: Color(0xFFCBD5E1),
    );
  }
  if (r.contains('sekretaris') || r.contains('bendahara') || r.contains('bph')) {
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFE0F2FE),
      textColor: Color(0xFF075985),
      borderColor: Color(0xFFBAE6FD),
    );
  }
  if (r.contains('kepala') || r.contains('kadiv') || r.contains('koordinator')) {
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFF1F5F9),
      textColor: Color(0xFF1E293B),
      borderColor: Color(0xFFCBD5E1),
    );
  }
  if (r.contains('staff') || r.contains('staf') || r == 'anggota' || r.contains('anggota')) {
    return const _RoleBadgeStyle(
      bgColor: Color(0xFFF8FAFC),
      textColor: Color(0xFF334155),
      borderColor: Color(0xFFE2E8F0),
    );
  }
  return const _RoleBadgeStyle(
    bgColor: Color(0xFFF1F5F9),
    textColor: Color(0xFF1E293B),
    borderColor: Color(0xFFCBD5E1),
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
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(size > 44 ? 20 : (size > 34 ? 12 : 8)),
      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
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
                  color: const Color(0xFF475569),
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
                color: const Color(0xFF475569),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrmawaStafDetailSheet(member: member),
    );
  }

  void _showFormModal(BuildContext context, [OrmawaMember? member]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrmawaStafFormSheet(initialMember: member),
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
          backgroundColor: OrmawaTheme.scaffoldBg,
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
                  SliverToBoxAdapter(child: _buildEmptyState())
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'ORGANISASI KEMAHASISWAAN',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              if (showAddButton)
                ElevatedButton.icon(
                  onPressed: () => _showFormModal(context),
                  icon: const Icon(Icons.person_add_rounded, size: 14),
                  label: const Text('Tambah Pengurus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrmawaTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
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
                  color: OrmawaTheme.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(Icons.admin_panel_settings_rounded, size: 22, color: OrmawaTheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Manajemen ',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          TextSpan(
                            text: 'Staf & Pengurus',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: OrmawaTheme.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Pengelolaan jajaran pimpinan, pengurus harian (BPH), kepala divisi, dan staf pelaksana organisasi.',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
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
                    badgeColor: const Color(0xFF059669),
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
                    badgeColor: const Color(0xFF0284C7),
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
                    badgeColor: const Color(0xFFD97706),
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
                    badgeColor: const Color(0xFF2563EB),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Cari nama atau NIM pengurus...',
              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF64748B)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 14, color: Color(0xFF64748B)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: OrmawaTheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedRoleFilter,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('Semua Jabatan', style: TextStyle(fontSize: 11))),
                        ...allRoles.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 11)))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedRoleFilter = val);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedDivisiFilter,
                      isExpanded: true,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('Semua Divisi', style: TextStyle(fontSize: 11))),
                        ...allDivisions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 11)))),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDivisiFilter = val);
                      },
                    ),
                  ),
                ),
              ),
              if (hasActiveFilter) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedRoleFilter = 'all';
                      _selectedDivisiFilter = 'all';
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFE4E6)),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Text(
                '$filteredCount / $totalCount pengurus',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(12),
      borderRadius: AppRadius.md,
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
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIM: ${member.nim}${member.prodi != null && member.prodi!.isNotEmpty ? ' • ${member.prodi}' : ''}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
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
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.visibility_rounded, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _showFormModal(context, member),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFFD97706)),
                      ),
                    ),
                  ],
                  if (canDelete) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => _confirmDelete(context, member),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.delete_rounded, size: 16, color: Color(0xFFE11D48)),
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
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: roleStyle.borderColor),
                ),
                child: Text(
                  member.role.toUpperCase(),
                  style: TextStyle(
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  member.division.isEmpty ? 'Umum' : member.division,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
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
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_rounded, size: 12, color: Color(0xFF047857)),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF047857),
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
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.mail_outline_rounded, size: 12, color: Color(0xFF2563EB)),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              email,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
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

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 40, color: Color(0xFF94A3B8)),
          SizedBox(height: 8),
          Text(
            'Tidak ada pengurus ditemukan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          SizedBox(height: 2),
          Text(
            'Coba sesuaikan kata kunci pencarian atau filter jabatan.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
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

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            _buildAvatar(member.name, member.fotoUrl, size: 72),
            const SizedBox(height: 12),

            Text(
              member.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              'NIM: ${member.nim}${member.prodi != null && member.prodi!.isNotEmpty ? ' • ${member.prodi}' : ''}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: roleStyle.borderColor),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'JABATAN STRUKTURAL',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.role,
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: roleStyle.textColor),
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
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'DIVISI KERJA',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          member.division.isEmpty ? 'Umum' : member.division,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
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
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mail_rounded, size: 18, color: Color(0xFF2563EB)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Email Kampus', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                            Text(email, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF60A5FA)),
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
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_rounded, size: 18, color: Color(0xFF059669)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('WhatsApp', style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                            Text(phone, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46))),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Color(0xFF34D399)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Text('Tutup Profil', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              ),
            ),
          ],
        ),
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
  final TextEditingController _searchController = TextEditingController();
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
    _searchController.dispose();
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

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: StatefulBuilder(
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

            return Column(
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
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: OrmawaTheme.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                          size: 20,
                          color: OrmawaTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Edit Pengurus' : 'Tambah Pengurus Baru',
                              style: const TextStyle(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Kelola jajaran personil kepengurusan struktural.',
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
                        onTap: () => Navigator.pop(context),
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
                const SizedBox(height: 8),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Mahasiswa',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 5),

                        if (_selectedStudent != null && !_isSearching) ...[
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
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
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'NIM: ${_selectedStudent!.nim}${_selectedStudent!.prodi != null && _selectedStudent!.prodi!.isNotEmpty ? ' • ${_selectedStudent!.prodi}' : ''}',
                                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isSearching = true;
                                      _searchKeyword = '';
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
                            autofocus: _isSearching,
                            onChanged: (val) => setState(() {
                              _isSearching = true;
                              _searchKeyword = val;
                            }),
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
                                borderSide: BorderSide(color: OrmawaTheme.primary, width: 1.5),
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
                            child: _isLoadingStudents
                                ? const Center(
                                    child: SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                : filteredStudents.isEmpty
                                    ? const Center(
                                        child: Text(
                                          'Mahasiswa tidak ditemukan',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
                                          final stEmail = (st['EmailKampus'] ?? st['email'] ?? '').toString();
                                          final stPhone = (st['NoHP'] ?? st['no_hp'] ?? '').toString();

                                          return ListTile(
                                            dense: true,
                                            leading: _buildAvatar(stName, stFoto, size: 30),
                                            title: Text(
                                              stName,
                                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                            ),
                                            subtitle: Text(
                                              'NIM: $stNim${stProdi.isNotEmpty ? ' • $stProdi' : ''}',
                                              style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
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
                                  const Text(
                                    'Jabatan Struktural',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedRole,
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
                                    items: dynamicRoles.map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
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
                                  const Text(
                                    'Divisi Kerja',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    initialValue: _selectedDivision,
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
                                      const DropdownMenuItem(value: '', child: Text('Umum (Tanpa Divisi)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)))),
                                      ...allDivisions.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))))),
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

                        const Text('Email Kampus (Opsional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'contoh@bku.ac.id',
                            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.mail_outline_rounded, size: 16, color: Color(0xFF64748B)),
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
                        ),
                        const SizedBox(height: 12),

                        const Text('Nomor WhatsApp (Opsional)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: '081234567890',
                            hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF64748B)),
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
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
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
                            icon: _isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save_rounded, size: 16),
                            label: Text(
                              _isSubmitting ? 'Menyimpan...' : (isEdit ? 'Simpan Perubahan' : 'Daftarkan Pengurus'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: OrmawaTheme.primary,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

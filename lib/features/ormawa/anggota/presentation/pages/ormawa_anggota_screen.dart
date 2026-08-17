import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
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

class OrmawaAnggotaScreen extends StatefulWidget {
  const OrmawaAnggotaScreen({super.key});

  @override
  State<OrmawaAnggotaScreen> createState() => _OrmawaAnggotaScreenState();
}

class _OrmawaAnggotaScreenState extends State<OrmawaAnggotaScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterRole = 'all';
  String _selectedFilterDivisi = 'all';
  String _selectedFilterStatus = 'all';

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

      final matchesRole = _selectedFilterRole == 'all' ||
          m.role.toLowerCase() == _selectedFilterRole.toLowerCase();

      final matchesDivisi = _selectedFilterDivisi == 'all' ||
          (m.division.isEmpty ? 'Umum' : m.division).toLowerCase() == _selectedFilterDivisi.toLowerCase();

      final statusStr = m.status.toLowerCase().trim();
      final isAktif = statusStr == 'aktif' || statusStr.isEmpty;
      final matchesStatus = _selectedFilterStatus == 'all' ||
          (_selectedFilterStatus == 'aktif' && isAktif) ||
          (_selectedFilterStatus == 'nonaktif' && !isAktif);

      return matchesSearch && matchesRole && matchesDivisi && matchesStatus;
    }).toList();
  }

  void _confirmRegenerate() {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.warning,
      title: 'Regenerasi Kepengurusan?',
      message: 'Apakah Anda yakin ingin memulai periode baru? Semua anggota aktif saat ini akan menjadi demisioner/alumni.',
      primaryButtonText: 'Regenerasi Sekarang',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().regenerateMembers();
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Regenerasi kepengurusan berhasil!');
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, 'Gagal regenerasi: $e');
          }
        }
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  void _confirmDelete(BuildContext context, OrmawaMember member) {
    BkuDialog.show(
      context: context,
      type: BkuDialogType.error,
      title: 'Hapus Anggota?',
      message: 'Hapus "${member.name}" dari basis data keanggotaan ormawa?',
      primaryButtonText: 'Hapus',
      secondaryButtonText: 'Batal',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await context.read<OrmawaProvider>().deleteMember(member.id);
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Anggota berhasil dihapus');
        }
      },
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  void _showDetailModal(BuildContext context, OrmawaMember member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrmawaAnggotaDetailSheet(member: member),
    );
  }

  void _showFormModal(BuildContext context, [OrmawaMember? member]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _OrmawaAnggotaFormSheet(initialMember: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final filteredMembers = _getFilteredMembers(provider.members);
        final canCreate = provider.hasPermission('create_members') || provider.hasPermission('ormawa.members.create, ormawa.organisasi.manage');
        final canEdit = provider.hasPermission('edit_members') || provider.hasPermission('ormawa.members.update, ormawa.organisasi.manage');
        final isAktifPeriod = provider.selectedPeriod == 'aktif';

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: RefreshIndicator(
            onRefresh: () => context.read<OrmawaProvider>().refreshData(),
            child: CustomScrollView(
              slivers: [
                BkuAppBar(
                  variant: AppBarVariant.ormawa,
                  title: 'Manajemen Anggota',
                  subtitle: 'Database Keanggotaan Ormawa',
                  expandedHeight: 115.0,
                  showBackButton: true,
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
                          _buildHeroBanner(context, canCreate && isAktifPeriod),
                          const SizedBox(height: 14),

                          _buildStatsGrid(context, provider),
                          const SizedBox(height: 14),

                          _buildPeriodCard(context, provider, canEdit && isAktifPeriod),
                          const SizedBox(height: 16),

                          _buildToolbarAndFilter(context, provider, filteredMembers.length),
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
                            child: _buildMemberCard(context, member, provider),
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
                  label: const Text('Tambah Anggota', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.appColors.primary,
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.groups_rounded, size: 22, color: Color(0xFF475569)),
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
                            text: 'Anggota Ormawa',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: context.appColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Database keanggotaan menyeluruh, pembagian divisi kerja, dan pemantauan status keaktifan mahasiswa.',
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

  Widget _buildStatsGrid(BuildContext context, OrmawaProvider provider) {
    final total = provider.members.length;
    final aktif = provider.members.where((m) => m.status.toLowerCase() == 'aktif').length;
    final totalDivisi = provider.divisions.length;
    final selectedPeriodText = provider.selectedPeriod == 'aktif' ? 'Aktif' : 'Thn ${provider.selectedPeriod}';
    final periodBadge = provider.selectedPeriod == 'aktif' ? '2025/2026' : provider.selectedPeriod;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Anggota',
                value: '$total',
                icon: Icons.groups_rounded,
                iconColor: const Color(0xFF475569),
                iconBg: const Color(0xFFF1F5F9),
                subtitle: 'Database anggota',
                badge: '${provider.availablePeriods.length + 1} Periode',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: 'Anggota Aktif',
                value: '$aktif',
                icon: Icons.how_to_reg_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFECFDF5),
                subtitle: 'Status kepengurusan',
                badge: 'Aktif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Divisi',
                value: '$totalDivisi',
                icon: Icons.domain_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFF0F9FF),
                subtitle: 'Struktur departemen',
                badge: '$totalDivisi Unit',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                title: 'Periode Terpilih',
                value: selectedPeriodText,
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFFD97706),
                iconBg: const Color(0xFFFEF3C7),
                subtitle: 'Masa bakti',
                badge: periodBadge,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String subtitle,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            title,
            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(BuildContext context, OrmawaProvider provider, bool canRegenerate) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_rounded, size: 18, color: Color(0xFF475569)),
              SizedBox(width: 8),
              Text(
                'PERIODE KEPENGURUSAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Tampilkan daftar anggota & pengurus berdasarkan tahun periode masa bakti aktif.',
            style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 10),
          Builder(
            builder: (context) {
              final uniquePeriods = provider.availablePeriods.where((p) => p.isNotEmpty && p.toLowerCase() != 'aktif').toSet().toList();
              final allPeriodItems = ['aktif', ...uniquePeriods];
              final currentSelectedPeriod = allPeriodItems.contains(provider.selectedPeriod) ? provider.selectedPeriod : 'aktif';

              return Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: currentSelectedPeriod,
                          isExpanded: true,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                          items: [
                            const DropdownMenuItem(
                              value: 'aktif',
                              child: Text('Aktif Sekarang (Terbaru)'),
                            ),
                            ...uniquePeriods.map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text('Periode $p (Demisioner/Alumni)'),
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
                  if (canRegenerate) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _confirmRegenerate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        height: 38,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.history_rounded, size: 16, color: Color(0xFFE11D48)),
                            SizedBox(width: 6),
                            Text(
                              'Regenerasi',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFFE11D48)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarAndFilter(BuildContext context, OrmawaProvider provider, int filteredCount) {
    final rbacRoles = provider.roles.map((r) => r.name.trim()).where((n) => n.isNotEmpty);
    final memberRoles = provider.members.map((m) => m.role.trim()).where((r) => r.isNotEmpty);
    final defaults = ['Ketua', 'Wakil Ketua', 'Sekretaris', 'Bendahara', 'Kepala Divisi', 'Staff', 'Anggota', 'Pembina'];
    final allRoles = {'all', ...defaults, ...rbacRoles, ...memberRoles}.toList();

    final allDivisions = {'all', 'Umum', ...provider.divisions.map((d) => d.name).where((d) => d.trim().isNotEmpty)}.toList();

    final hasActiveFilter = _searchQuery.isNotEmpty ||
        _selectedFilterRole != 'all' ||
        _selectedFilterDivisi != 'all' ||
        _selectedFilterStatus != 'all';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Cari nama atau NIM anggota...',
              hintStyle: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 16, color: Color(0xFF94A3B8)),
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
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.appColors.primary, width: 1.2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: allRoles.contains(_selectedFilterRole) ? _selectedFilterRole : 'all',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      icon: const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF64748B)),
                      items: allRoles.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r == 'all' ? 'Semua Jabatan' : r),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFilterRole = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: allDivisions.contains(_selectedFilterDivisi) ? _selectedFilterDivisi : 'all',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      icon: const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF64748B)),
                      items: allDivisions.map((d) => DropdownMenuItem(
                        value: d,
                        child: Text(d == 'all' ? 'Semua Divisi' : d),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFilterDivisi = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 6),

                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ['all', 'aktif', 'nonaktif'].contains(_selectedFilterStatus) ? _selectedFilterStatus : 'all',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      icon: const Icon(Icons.arrow_drop_down, size: 16, color: Color(0xFF64748B)),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('Semua Status')),
                        DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                        DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedFilterStatus = val);
                      },
                    ),
                  ),
                ),

                if (hasActiveFilter) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _selectedFilterRole = 'all';
                        _selectedFilterDivisi = 'all';
                        _selectedFilterStatus = 'all';
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: const Center(
                        child: Text(
                          'Reset',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Menampilkan $filteredCount dari ${provider.members.length} anggota',
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, OrmawaMember member, OrmawaProvider provider) {
    final roleStyle = _getRoleBadgeStyle(member.role);
    final canEdit = provider.hasPermission('edit_members') || provider.hasPermission('ormawa.members.update, ormawa.organisasi.manage');
    final canDelete = provider.hasPermission('delete_members') || provider.hasPermission('ormawa.members.delete, ormawa.organisasi.manage');
    final isAktifPeriod = provider.selectedPeriod == 'aktif';

    final subText = [
      if (member.nim.isNotEmpty && member.nim != '-') member.nim,
      if (member.prodi != null && member.prodi!.isNotEmpty) member.prodi!,
    ].join(' • ');

    final isAktif = member.status.toLowerCase().trim() == 'aktif' || member.status.isEmpty;

    return BkuCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(12),
      borderRadius: AppRadius.md,
      child: InkWell(
        onTap: () => _showDetailModal(context, member),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(member.name, member.fotoUrl, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined, size: 16, color: Color(0xFF64748B)),
                            padding: const EdgeInsets.all(3),
                            constraints: const BoxConstraints(),
                            onPressed: () => _showDetailModal(context, member),
                            tooltip: 'Lihat Detail',
                          ),
                          if (canEdit && isAktifPeriod) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFD97706)),
                              padding: const EdgeInsets.all(3),
                              constraints: const BoxConstraints(),
                              onPressed: () => _showFormModal(context, member),
                              tooltip: 'Edit Anggota',
                            ),
                          ],
                          if (canDelete && isAktifPeriod) ...[
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                              padding: const EdgeInsets.all(3),
                              constraints: const BoxConstraints(),
                              onPressed: () => _confirmDelete(context, member),
                              tooltip: 'Hapus Anggota',
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (subText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subText,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
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
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: roleStyle.textColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: Text(
                          member.division.isEmpty ? 'Umum' : member.division,
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAktif ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isAktif ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          isAktif ? 'Aktif' : 'Nonaktif',
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: isAktif ? const Color(0xFF047857) : const Color(0xFF64748B),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Anggota tidak ditemukan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Coba gunakan kata kunci pencarian atau filter yang berbeda.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    );
  }
}

class OrmawaAnggotaDetailScreen extends StatelessWidget {
  final OrmawaMember member;

  const OrmawaAnggotaDetailScreen({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          const BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: 'Detail Anggota',
            subtitle: 'Profil Anggota Ormawa',
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: _OrmawaAnggotaDetailSheet(member: member),
          ),
        ],
      ),
    );
  }
}

class OrmawaFormAnggotaScreen extends StatelessWidget {
  final OrmawaMember? initialMember;

  const OrmawaFormAnggotaScreen({super.key, this.initialMember});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            variant: AppBarVariant.ormawa,
            title: initialMember != null ? 'Edit Anggota' : 'Tambah Anggota',
            subtitle: 'Manajemen Keanggotaan',
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: _OrmawaAnggotaFormSheet(initialMember: initialMember),
          ),
        ],
      ),
    );
  }
}

class _OrmawaAnggotaDetailSheet extends StatelessWidget {
  final OrmawaMember member;

  const _OrmawaAnggotaDetailSheet({required this.member});

  @override
  Widget build(BuildContext context) {
    final roleStyle = _getRoleBadgeStyle(member.role);
    final isAktif = member.status.toLowerCase().trim() == 'aktif' || member.status.isEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_rounded, size: 18, color: Color(0xFF475569)),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Anggota',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        Text(
                          'Informasi keanggotaan aktif organisasi mahasiswa.',
                          style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    _buildAvatar(member.name, member.fotoUrl, size: 84),
                    const SizedBox(height: 12),

                    Text(
                      member.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),

                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('NIM', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF475569))),
                        ),
                        Text(
                          member.nim.isNotEmpty ? member.nim : '—',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                        ),
                        if (member.prodi != null && member.prodi!.isNotEmpty) ...[
                          const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                          Text(
                            member.prodi!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.badge_outlined, size: 20, color: Color(0xFF64748B)),
                                const SizedBox(height: 4),
                                const Text(
                                  'JABATAN STRUKTURAL',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.3),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: roleStyle.bgColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: roleStyle.borderColor, width: 0.8),
                                  ),
                                  child: Text(
                                    member.role,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: roleStyle.textColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.workspaces_outlined, size: 20, color: Color(0xFF3B82F6)),
                                const SizedBox(height: 4),
                                const Text(
                                  'DIVISI KERJA',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF94A3B8), letterSpacing: 0.3),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.8),
                                  ),
                                  child: Text(
                                    member.division.isEmpty ? 'Umum' : member.division,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF1E40AF)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EMAIL KAMPUS',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (member.email != null && member.email!.isNotEmpty) ? member.email! : '—',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'NO. WHATSAPP',
                                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (member.phone != null && member.phone!.isNotEmpty) ? member.phone! : '—',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Keanggotaan',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAktif ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: isAktif ? const Color(0xFFA7F3D0) : const Color(0xFFCBD5E1)),
                            ),
                            child: Text(
                              isAktif ? 'Aktif' : 'Nonaktif',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: isAktif ? const Color(0xFF047857) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 4, AppSpacing.lg, 8),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: const Color(0xFF475569),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Tutup Profil', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrmawaAnggotaFormSheet extends StatefulWidget {
  final OrmawaMember? initialMember;

  const _OrmawaAnggotaFormSheet({this.initialMember});

  @override
  State<_OrmawaAnggotaFormSheet> createState() => _OrmawaAnggotaFormSheetState();
}

class _OrmawaAnggotaFormSheetState extends State<_OrmawaAnggotaFormSheet> {
  Map<String, dynamic>? _selectedStudent;
  String _selectedRole = 'Anggota';
  String _selectedDivision = '';
  String _selectedStatus = 'Aktif';
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _studentList = [];
  bool _isLoadingStudents = false;
  String _studentSearchQuery = '';
  bool _isSearchingStudent = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMember != null) {
      final m = widget.initialMember!;
      _selectedRole = m.role.isNotEmpty ? m.role : 'Anggota';
      _selectedDivision = (m.division.toLowerCase() == 'umum' || m.division == '-') ? '' : m.division;
      final s = m.status.trim().toLowerCase();
      _selectedStatus = (s == 'nonaktif' || s == 'alumni') ? s : 'aktif';
      _emailController.text = m.email ?? '';
      _phoneController.text = m.phone ?? '';
      _selectedStudent = {
        'id': m.mahasiswaId,
        'Nama': m.name,
        'NIM': m.nim,
        'prodi': m.prodi,
        'foto_url': m.fotoUrl,
      };
    } else {
      _loadStudents();
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoadingStudents = true);
    try {
      final list = await context.read<OrmawaProvider>().getStudents();
      if (mounted) {
        setState(() {
          _studentList = list;
          _isLoadingStudents = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingStudents = false);
    }
  }

  Future<void> _handleSave() async {
    if (_selectedStudent == null) {
      AppSnackbar.showWarning(context, 'Wajib memilih mahasiswa terlebih dahulu!');
      return;
    }

    final rawId = _selectedStudent!['id'] ?? _selectedStudent!['MahasiswaID'] ?? _selectedStudent!['ID'];
    final mahasiswaId = int.tryParse(rawId.toString());

    setState(() => _isSubmitting = true);

    final data = {
      'MahasiswaID': mahasiswaId,
      'Role': _selectedRole,
      'Divisi': _selectedDivision,
      'Status': _selectedStatus,
      'EmailKampus': _emailController.text,
      'NoHP': _phoneController.text,
    };

    try {
      final provider = context.read<OrmawaProvider>();
      if (widget.initialMember != null) {
        await provider.updateMember(widget.initialMember!.id, data);
        if (mounted) {
          Navigator.pop(context);
          AppSnackbar.showSuccess(context, 'Data anggota berhasil diperbarui');
        }
      } else {
        await provider.addMember(data);
        if (mounted) {
          Navigator.pop(context);
          AppSnackbar.showSuccess(context, 'Anggota baru berhasil ditambahkan');
        }
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final isEditMode = widget.initialMember != null;

    final defaults = ['Ketua', 'Wakil Ketua', 'Sekretaris', 'Bendahara', 'Kepala Divisi', 'Staff', 'Anggota', 'Pembina'];
    final rbacRoles = provider.roles.map((r) => r.name.trim()).where((n) => n.isNotEmpty);
    final memberRoles = provider.members.map((m) => m.role.trim()).where((r) => r.isNotEmpty);
    final rawRoles = <String>{...defaults, ...rbacRoles, ...memberRoles}.toList();

    String currentRole = _selectedRole.trim();
    if (currentRole.isEmpty) currentRole = 'Anggota';
    if (!rawRoles.contains(currentRole)) {
      rawRoles.add(currentRole);
    }

    final rawDivisions = provider.divisions
        .map((d) => d.name.trim())
        .where((d) => d.isNotEmpty && d.toLowerCase() != 'umum' && d != '-')
        .toSet()
        .toList();
    final divisionOptions = <String>['', ...rawDivisions];

    String currentDivision = _selectedDivision.trim();
    if (currentDivision.toLowerCase() == 'umum' || currentDivision == '-') {
      currentDivision = '';
    }
    if (!divisionOptions.contains(currentDivision)) {
      divisionOptions.add(currentDivision);
    }

    final currentStatus = (_selectedStatus == 'nonaktif' || _selectedStatus == 'alumni') ? _selectedStatus : 'aktif';

    final filteredStudents = _studentSearchQuery.isEmpty
        ? _studentList
        : _studentList.where((s) {
            final name = (s['Nama'] ?? s['nama'] ?? s['nama_mahasiswa'] ?? '').toString().toLowerCase();
            final nim = (s['NIM'] ?? s['nim'] ?? '').toString().toLowerCase();
            final q = _studentSearchQuery.toLowerCase();
            return name.contains(q) || nim.contains(q);
          }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
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
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: context.appColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEditMode ? Icons.edit_rounded : Icons.person_add_rounded,
                      size: 20,
                      color: context.appColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode ? 'Edit Anggota' : 'Tambah Anggota Baru',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                        ),
                        const Text(
                          'MANAJEMEN KEANGGOTAAN ORMAWA',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.3),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Mahasiswa', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                    const SizedBox(height: 5),

                    if (_selectedStudent != null && !_isSearchingStudent) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: Row(
                          children: [
                            _buildAvatar(
                              _selectedStudent!['Nama'] ?? _selectedStudent!['nama'] ?? 'M',
                              _selectedStudent!['foto_url'] ?? _selectedStudent!['FotoURL'],
                              size: 36,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedStudent!['Nama'] ?? _selectedStudent!['nama'] ?? '—',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'NIM: ${_selectedStudent!['NIM'] ?? _selectedStudent!['nim'] ?? '—'}',
                                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            if (!isEditMode)
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _isSearchingStudent = true;
                                    _studentSearchQuery = '';
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
                        autofocus: _isSearchingStudent,
                        onChanged: (val) => setState(() {
                          _isSearchingStudent = true;
                          _studentSearchQuery = val;
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
                            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                            : filteredStudents.isEmpty
                                ? const Center(
                                    child: Text('Mahasiswa tidak ditemukan', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                                  )
                                : ListView.separated(
                                    itemCount: filteredStudents.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    itemBuilder: (c, idx) {
                                      final st = filteredStudents[idx];
                                      final name = st['Nama'] ?? st['nama'] ?? '—';
                                      final nim = st['NIM'] ?? st['nim'] ?? '—';
                                      final prodi = st['ProgramStudi']?['Nama'] ?? st['prodi'] ?? '';
                                      return ListTile(
                                        dense: true,
                                        leading: _buildAvatar(name, st['foto_url'] ?? st['FotoURL'], size: 30),
                                        title: Text(
                                          name,
                                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                        ),
                                        subtitle: Text(
                                          'NIM: $nim${prodi.isNotEmpty ? ' • $prodi' : ''}',
                                          style: const TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _selectedStudent = st;
                                            _emailController.text = st['EmailKampus'] ?? st['email_kampus'] ?? '';
                                            _phoneController.text = st['NoHP'] ?? st['no_hp'] ?? '';
                                            _isSearchingStudent = false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Jabatan (Role)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: currentRole,
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
                                items: rawRoles.map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r, style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A))),
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
                              const Text('Divisi (Departemen)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: currentDivision,
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
                                items: divisionOptions.map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(
                                    d.isEmpty ? 'Umum (Tanpa Divisi)' : d,
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A)),
                                  ),
                                )).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedDivision = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status Keaktifan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: currentStatus,
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
                          items: const [
                            DropdownMenuItem(value: 'aktif', child: Text('Aktif')),
                            DropdownMenuItem(value: 'nonaktif', child: Text('Nonaktif')),
                            DropdownMenuItem(value: 'alumni', child: Text('Alumni')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email Kampus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _emailController,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: 'mhs@bku.ac.id',
                                  hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('No. WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  hintText: '081234567890',
                                  hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleSave,
                        icon: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Icon(isEditMode ? Icons.save_rounded : Icons.person_add_rounded, size: 16),
                        label: Text(
                          isEditMode ? 'Simpan Perubahan' : 'Daftarkan Anggota',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
            ),
          ],
        ),
      ),
    );
  }
}

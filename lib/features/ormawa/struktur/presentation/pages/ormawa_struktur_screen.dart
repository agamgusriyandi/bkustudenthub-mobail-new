import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';

class OrmawaStrukturScreen extends StatefulWidget {
  const OrmawaStrukturScreen({super.key});

  @override
  State<OrmawaStrukturScreen> createState() => _OrmawaStrukturScreenState();
}

class _OrmawaStrukturScreenState extends State<OrmawaStrukturScreen> {
  String _viewMode = 'tree';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final members = ormawaProvider.members;
    final divisions = ormawaProvider.divisions;

    final pembina = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('pembina') ||
          r.contains('penanggung jawab') ||
          r.contains('penasihat') ||
          r.contains('dosen');
    }).toList();
    final pembinaIds = pembina.map((m) => m.id).toSet();

    final ketua = members.where((m) {
      final r = m.role.toLowerCase();
      return (r.contains('ketua umum') ||
              (r.contains('ketua') && !r.contains('wakil') && !r.contains('divisi') && !r.contains('departemen') && !r.contains('bidang'))) &&
          !pembinaIds.contains(m.id);
    }).firstOrNull;

    final ketuaId = ketua?.id;

    final wakil = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('wakil') && !pembinaIds.contains(m.id) && m.id != ketuaId;
    }).firstOrNull;

    final wakilId = wakil?.id;

    final sekretaris = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('sekretaris') && !pembinaIds.contains(m.id) && m.id != ketuaId && m.id != wakilId;
    }).toList();
    final sekretarisIds = sekretaris.map((m) => m.id).toSet();

    final bendahara = members.where((m) {
      final r = m.role.toLowerCase();
      return r.contains('bendahara') && !pembinaIds.contains(m.id) && m.id != ketuaId && m.id != wakilId;
    }).toList();
    final bendaharaIds = bendahara.map((m) => m.id).toSet();

    final bphInti = members.where((m) {
      final r = m.role.toLowerCase();
      final d = m.division.toUpperCase();
      return m.id != ketuaId &&
          m.id != wakilId &&
          !pembinaIds.contains(m.id) &&
          !sekretarisIds.contains(m.id) &&
          !bendaharaIds.contains(m.id) &&
          (d == 'BPH' || d == 'INTI' || d.isEmpty || r.contains('bph') || r.contains('pengurus harian'));
    }).toList();
    final bphIntiIds = bphInti.map((m) => m.id).toSet();

    final registeredDivNames = divisions.map((d) => d.name).where((n) => n.isNotEmpty).toList();
    final memberDivNames = members
        .map((m) => m.division)
        .where((d) => d.isNotEmpty && d.toUpperCase() != 'BPH' && d.toUpperCase() != 'INTI' && d != '-')
        .toList();
    final allDivNames = {...registeredDivNames, ...memberDivNames}.toList();

    final accountedIds = {
      ...pembinaIds,
      if (ketuaId != null) ketuaId,
      if (wakilId != null) wakilId,
      ...sekretarisIds,
      ...bendaharaIds,
      ...bphIntiIds,
    };

    final totalBph = (ketua != null ? 1 : 0) +
        (wakil != null ? 1 : 0) +
        sekretaris.length +
        bendahara.length +
        bphInti.length;

    final canManage = ormawaProvider.hasPermission('manage_structure') ||
        ormawaProvider.hasPermission('ormawa.structure.manage, ormawa.structure.update, ormawa.organisasi.manage, ormawa.members.update');

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
            BkuAppBar(
              variant: AppBarVariant.ormawa,
              title: 'Struktur Organisasi',
              subtitle: ormawaProvider.orgName.isNotEmpty
                  ? ormawaProvider.orgName
                  : 'Struktur Kepengurusan',
              showBackButton: true,
              isExpandable: false,
              actions: [
                if (canManage)
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Kelola Struktur',
                    onPressed: () {
                      context.push(AppRoutes.ormawaStrukturManage);
                    },
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(
                      context,
                      totalMembers: members.length,
                      totalBph: totalBph,
                      totalDivisions: allDivNames.length,
                      totalPembina: pembina.length,
                    ),
                    const SizedBox(height: 14),

                    _buildViewSwitcher(),
                    const SizedBox(height: 14),

                    if (_viewMode == 'tree') ...[
                      if (pembina.isNotEmpty) ...[
                        _buildSectionTitle('Pembina & Penasihat', Icons.school_rounded, BkuTheme.indigo),
                        const SizedBox(height: AppSpacing.sm),
                        ...pembina.map((m) => _buildMemberCard(context, m, customRoleBadge: 'Pembina')),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      if (ketua != null || wakil != null) ...[
                        _buildSectionTitle('Pimpinan Utama', Icons.military_tech_rounded, BkuTheme.amber),
                        const SizedBox(height: AppSpacing.sm),
                        if (ketua != null)
                          _buildHeroLeaderCard(context, ketua, isPrimary: true),
                        if (wakil != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          _buildHeroLeaderCard(context, wakil, isPrimary: false),
                        ],
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      if (sekretaris.isNotEmpty || bendahara.isNotEmpty || bphInti.isNotEmpty) ...[
                        _buildSectionTitle('Badan Pengurus Harian (BPH)', Icons.shield_rounded, BkuTheme.sky),
                        const SizedBox(height: AppSpacing.sm),
                        ...sekretaris.map((m) => _buildMemberCard(context, m)),
                        ...bendahara.map((m) => _buildMemberCard(context, m)),
                        ...bphInti.map((m) => _buildMemberCard(context, m)),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      if (allDivNames.isNotEmpty) ...[
                        _buildSectionTitle('Divisi & Departemen', Icons.category_rounded, BkuTheme.purple),
                        const SizedBox(height: AppSpacing.sm),
                        ...allDivNames.map((divName) {
                          final divMembers = members.where((m) => m.division == divName && !pembinaIds.contains(m.id)).toList();
                          accountedIds.addAll(divMembers.map((m) => m.id));

                          final kadivList = divMembers.where((m) {
                            final r = m.role.toLowerCase();
                            return r.contains('kepala') ||
                                r.contains('kadiv') ||
                                r.contains('koordinator') ||
                                r.contains('ketua divisi');
                          }).toList();
                          final kadivIds = kadivList.map((m) => m.id).toSet();
                          final stafList = divMembers.where((m) => !kadivIds.contains(m.id)).toList();

                          return _buildDivisionContainer(
                            context,
                            divisionName: divName,
                            kadivList: kadivList,
                            stafList: stafList,
                          );
                        }),
                        const SizedBox(height: AppSpacing.lg),
                      ],

                      ...[
                        Builder(builder: (context) {
                          final generalMembers = members.where((m) => !accountedIds.contains(m.id)).toList();
                          if (generalMembers.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Anggota Organisasi', Icons.groups_rounded, BkuTheme.emerald),
                              const SizedBox(height: AppSpacing.sm),
                              ...generalMembers.map((m) => _buildMemberCard(context, m)),
                            ],
                          );
                        }),
                      ],
                    ] else ...[
                      _buildGridMode(
                        context,
                        ketua: ketua,
                        wakil: wakil,
                        sekretaris: sekretaris,
                        bendahara: bendahara,
                        bphInti: bphInti,
                        pembina: pembina,
                        divisions: allDivNames,
                        members: members,
                        accountedIds: accountedIds,
                        pembinaIds: pembinaIds,
                        totalBph: totalBph,
                      ),
                    ],

                    if (members.isEmpty && !ormawaProvider.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: BkuEmptyState(
                          title: 'Belum Ada Data Pengurus',
                          message: 'Data pengurus atau anggota organisasi belum ditambahkan.',
                          icon: Icons.account_tree_outlined,
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

  Widget _buildViewSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r12,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _viewMode = 'tree'),
              borderRadius: BkuTheme.r8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _viewMode == 'tree' ? BkuTheme.primary : Colors.transparent,
                  borderRadius: BkuTheme.r8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_tree_rounded,
                      size: 16,
                      color: _viewMode == 'tree' ? Colors.white : BkuTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Bagan Pohon',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _viewMode == 'tree' ? Colors.white : BkuTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _viewMode = 'grid'),
              borderRadius: BkuTheme.r8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _viewMode == 'grid' ? BkuTheme.primary : Colors.transparent,
                  borderRadius: BkuTheme.r8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: _viewMode == 'grid' ? Colors.white : BkuTheme.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Grid Departemen',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _viewMode == 'grid' ? Colors.white : BkuTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridMode(
    BuildContext context, {
    required OrmawaMember? ketua,
    required OrmawaMember? wakil,
    required List<OrmawaMember> sekretaris,
    required List<OrmawaMember> bendahara,
    required List<OrmawaMember> bphInti,
    required List<OrmawaMember> pembina,
    required List<String> divisions,
    required List<OrmawaMember> members,
    required Set<String> accountedIds,
    required Set<String> pembinaIds,
    required int totalBph,
  }) {
    final allBph = [
      if (ketua != null) ketua,
      if (wakil != null) wakil,
      ...sekretaris,
      ...bendahara,
      ...bphInti,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pimpinan & BPH ($totalBph)', Icons.shield_rounded, BkuTheme.sky),
        const SizedBox(height: AppSpacing.sm),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allBph.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, i) {
            final m = allBph[i];
            return _buildGridMemberCard(context, m);
          },
        ),
        const SizedBox(height: AppSpacing.lg),

        if (pembina.isNotEmpty) ...[
          _buildSectionTitle('Pembina (${pembina.length})', Icons.school_rounded, BkuTheme.indigo),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pembina.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, i) {
              final m = pembina[i];
              return _buildGridMemberCard(context, m, customBadge: 'Pembina');
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        if (divisions.isNotEmpty) ...[
          _buildSectionTitle('Departemen & Divisi (${divisions.length})', Icons.category_rounded, BkuTheme.purple),
          const SizedBox(height: AppSpacing.sm),
          ...divisions.map((divName) {
            final divMembers = members.where((m) => m.division == divName && !pembinaIds.contains(m.id)).toList();
            return BkuCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: BkuTheme.purpleSoft,
                              borderRadius: BkuTheme.r8,
                            ),
                            child: const Icon(Icons.folder_shared_rounded, size: 15, color: BkuTheme.purple),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            divName,
                            style: BkuTheme.textCardTitle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: BkuTheme.borderSubtle,
                          borderRadius: BkuTheme.r8,
                        ),
                        child: Text(
                          '${divMembers.length} Anggota',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: BkuTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                  if (divMembers.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: divMembers.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 2.3,
                      ),
                      itemBuilder: (context, i) {
                        return _buildGridMemberCard(context, divMembers[i]);
                      },
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildGridMemberCard(BuildContext context, OrmawaMember member, {String? customBadge}) {
    final role = customBadge ?? member.role;
    final roleStyle = _getRoleBadgeStyle(role);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: BkuTheme.borderSubtle,
        borderRadius: BkuTheme.r10,
        border: Border.all(color: BkuTheme.border),
      ),
      child: Row(
        children: [
          _buildAvatar(member.name, member.fotoUrl, size: 30),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  member.name,
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 10.5, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: roleStyle.textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalMembers,
    required int totalBph,
    required int totalDivisions,
    required int totalPembina,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OrmawaKpiCard(
                title: 'Total Anggota',
                value: '$totalMembers',
                badgeText: 'Anggota',
                icon: Icons.groups_rounded,
                badgeColor: BkuTheme.indigo,
                subtitle: 'Pengurus & anggota aktif',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrmawaKpiCard(
                title: 'Pengurus BPH',
                value: '$totalBph',
                badgeText: 'BPH',
                icon: Icons.shield_rounded,
                badgeColor: BkuTheme.sky,
                subtitle: 'Pimpinan & harian',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OrmawaKpiCard(
                title: 'Divisi & Dept',
                value: '$totalDivisions',
                badgeText: 'Divisi',
                icon: Icons.category_rounded,
                badgeColor: BkuTheme.amber,
                subtitle: 'Bidang operasional',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrmawaKpiCard(
                title: 'Pembina',
                value: '$totalPembina',
                badgeText: 'Dosen',
                icon: Icons.school_rounded,
                badgeColor: BkuTheme.emerald,
                subtitle: 'Dosen penasihat',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: BkuTheme.textSectionTitle,
        ),
      ],
    );
  }

  Widget _buildHeroLeaderCard(
    BuildContext context,
    OrmawaMember member, {
    required bool isPrimary,
  }) {
    final badgeColor = isPrimary ? BkuTheme.amber : BkuTheme.rose;
    final roleText = isPrimary ? 'Ketua Umum' : 'Wakil Ketua';

    final subText = [
      if (member.nim.isNotEmpty && member.nim != '-') member.nim,
      if (member.prodi != null && member.prodi!.isNotEmpty) member.prodi!,
    ].join(' • ');

    return BkuCard(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: 14,
      child: Row(
        children: [
          _buildAvatar(member.name, member.fotoUrl, size: 42),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BkuTheme.r8,
                      ),
                      child: Text(
                        roleText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    if (member.division.isNotEmpty &&
                        member.division != 'BPH' &&
                        member.division != 'INTI' &&
                        member.division != '-') ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: BkuTheme.borderSubtle,
                          borderRadius: BkuTheme.r8,
                          border: Border.all(color: BkuTheme.border, width: 0.8),
                        ),
                        child: Text(
                          member.division,
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: BkuTheme.textMuted),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  member.name,
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subText.isNotEmpty)
                  Text(
                    subText,
                    style: BkuTheme.textCaption.copyWith(
                      fontSize: 9.5,
                      color: BkuTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    OrmawaMember member, {
    String? customRoleBadge,
  }) {
    final role = customRoleBadge ?? member.role;
    final roleStyle = _getRoleBadgeStyle(role);

    final subText = [
      if (member.nim.isNotEmpty && member.nim != '-') member.nim,
      if (member.prodi != null && member.prodi!.isNotEmpty) member.prodi!,
    ].join(' • ');

    return BkuCard(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      borderRadius: 12,
      child: Row(
        children: [
          _buildAvatar(member.name, member.fotoUrl, size: 34),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subText.isNotEmpty)
                  Text(
                    subText,
                    style: BkuTheme.textCaption.copyWith(
                      fontSize: 9,
                      color: BkuTheme.textMuted,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: roleStyle.bgColor,
                  borderRadius: BkuTheme.r8,
                  border: Border.all(
                    color: roleStyle.borderColor,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  role,
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
                    border: Border.all(
                      color: BkuTheme.border,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    member.division,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: BkuTheme.textMuted,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionContainer(
    BuildContext context, {
    required String divisionName,
    required List<OrmawaMember> kadivList,
    required List<OrmawaMember> stafList,
  }) {
    final totalMembers = kadivList.length + stafList.length;

    return BkuCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.zero,
      borderRadius: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: BkuTheme.purpleSoft,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(
                  color: BkuTheme.purple.withAlpha(30),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.folder_shared_rounded,
                      size: 15,
                      color: BkuTheme.purple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      divisionName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: BkuTheme.purple,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BkuTheme.r8,
                    border: Border.all(
                      color: BkuTheme.purple.withAlpha(40),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$totalMembers Anggota',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: BkuTheme.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ...kadivList.map((m) => _buildMemberCard(context, m, customRoleBadge: 'Kadiv')),
                ...stafList.map((m) => _buildMemberCard(context, m, customRoleBadge: 'Staf')),
                if (kadivList.isEmpty && stafList.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        'Belum ada anggota terdaftar di divisi ini',
                        style: TextStyle(fontSize: 10, color: BkuTheme.textPlaceholder),
                      ),
                    ),
                  ),
              ],
            ),
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
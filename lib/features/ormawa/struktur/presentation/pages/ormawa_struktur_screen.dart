import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';

class OrmawaStrukturScreen extends StatefulWidget {
  const OrmawaStrukturScreen({super.key});

  @override
  State<OrmawaStrukturScreen> createState() => _OrmawaStrukturScreenState();
}

class _OrmawaStrukturScreenState extends State<OrmawaStrukturScreen> {
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
        ormawaProvider.hasPermission('view_structure');

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
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.s100,
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
                    const SizedBox(height: AppSpacing.xl),

                    if (pembina.isNotEmpty) ...[
                      _buildSectionTitle('PEMBINA & PENASIHAT', Icons.school_rounded, AppColors.serviceIndigo),
                      const SizedBox(height: AppSpacing.sm),
                      ...pembina.map((m) => _buildMemberCard(context, m, customRoleBadge: 'Pembina')),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (ketua != null || wakil != null) ...[
                      _buildSectionTitle('PIMPINAN UTAMA', Icons.military_tech_rounded, AppColors.serviceAmber),
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
                      _buildSectionTitle('BADAN PENGURUS HARIAN (BPH)', Icons.shield_rounded, AppColors.serviceSky),
                      const SizedBox(height: AppSpacing.sm),
                      ...sekretaris.map((m) => _buildMemberCard(context, m)),
                      ...bendahara.map((m) => _buildMemberCard(context, m)),
                      ...bphInti.map((m) => _buildMemberCard(context, m)),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    if (allDivNames.isNotEmpty) ...[
                      _buildSectionTitle('DIVISI & DEPARTEMEN', Icons.category_rounded, AppColors.servicePurple),
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
                            _buildSectionTitle('ANGGOTA ORGANISASI', Icons.groups_rounded, AppColors.serviceEmerald),
                            const SizedBox(height: AppSpacing.sm),
                            ...generalMembers.map((m) => _buildMemberCard(context, m)),
                          ],
                        );
                      }),
                    ],

                    if (members.isEmpty && !ormawaProvider.isLoading)
                      _buildEmptyState('Belum ada data pengurus atau anggota'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: canManage ? _buildFab(context) : null,
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalMembers,
    required int totalBph,
    required int totalDivisions,
    required int totalPembina,
  }) {
    return GridView.count(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.75,
      children: [
        _buildStatCard(
          context,
          title: 'Total Anggota',
          value: '$totalMembers Anggota',
          subtitle: 'Pengurus & anggota aktif',
          icon: Icons.groups_rounded,
          color: AppColors.serviceIndigo,
        ),
        _buildStatCard(
          context,
          title: 'Pengurus BPH',
          value: '$totalBph Orang',
          subtitle: 'Pimpinan & harian',
          icon: Icons.shield_rounded,
          color: AppColors.serviceSky,
        ),
        _buildStatCard(
          context,
          title: 'Divisi & Dept',
          value: '$totalDivisions Divisi',
          subtitle: 'Bidang operasional',
          icon: Icons.category_rounded,
          color: AppColors.serviceAmber,
        ),
        _buildStatCard(
          context,
          title: 'Pembina',
          value: '$totalPembina Dosen',
          subtitle: 'Dosen penasihat',
          icon: Icons.school_rounded,
          color: AppColors.serviceEmerald,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return BkuCard(
      borderRadius: AppRadius.md,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: AppRadius.br2,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: color),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: context.appColors.onSurfaceVariant,
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

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
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

  Widget _buildHeroLeaderCard(
    BuildContext context,
    OrmawaMember member, {
    required bool isPrimary,
  }) {
    final bgGradient = isPrimary
        ? const [Color(0xFFFFFBEB), Colors.white]
        : const [Color(0xFFFFF7ED), Colors.white];
    final borderColor = isPrimary ? const Color(0xFFFDE047) : const Color(0xFFFED7AA);
    final badgeColor = isPrimary ? const Color(0xFFD97706) : const Color(0xFFEA580C);
    final roleText = isPrimary ? 'KETUA UMUM' : 'WAKIL KETUA';

    final subText = [
      if (member.nim.isNotEmpty && member.nim != '-') member.nim,
      if (member.prodi != null && member.prodi!.isNotEmpty) member.prodi!,
    ].join(' • ');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withAlpha(12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                        borderRadius: BorderRadius.circular(4),
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
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                        ),
                        child: Text(
                          member.division,
                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: context.appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subText.isNotEmpty)
                  Text(
                    subText,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: context.appColors.onSurfaceVariant,
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
      borderRadius: AppRadius.md,
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.appColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subText.isNotEmpty)
                  Text(
                    subText,
                    style: TextStyle(
                      fontSize: 9,
                      color: context.appColors.onSurfaceVariant,
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
                  borderRadius: BorderRadius.circular(4),
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
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    member.division,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral200, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.servicePurple.withAlpha(12),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.servicePurple.withAlpha(30),
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
                      color: AppColors.servicePurple,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      divisionName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.servicePurple,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.servicePurple.withAlpha(40),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '$totalMembers Anggota',
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: AppColors.servicePurple,
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
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: Text(
                        'Belum ada anggota terdaftar di divisi ini',
                        style: TextStyle(fontSize: 10, color: AppColors.neutral500),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Icon(
              Icons.account_tree_outlined,
              color: AppColors.neutral400,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.neutral500,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        context.push(AppRoutes.ormawaStrukturManage);
      },
      backgroundColor: context.appColors.primary,
      elevation: 4,
      icon: const Icon(Icons.settings_suggest_rounded, color: Colors.white, size: 18),
      label: const Text(
        'Kelola Struktur',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
          letterSpacing: 0.3,
        ),
      ),
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

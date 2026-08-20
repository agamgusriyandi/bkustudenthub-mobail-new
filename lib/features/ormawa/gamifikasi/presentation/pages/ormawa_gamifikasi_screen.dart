import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_empty_state.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaGamifikasiScreen extends StatefulWidget {
  const OrmawaGamifikasiScreen({super.key});

  @override
  State<OrmawaGamifikasiScreen> createState() => _OrmawaGamifikasiScreenState();
}

class _OrmawaGamifikasiScreenState extends State<OrmawaGamifikasiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showRuleDetailModal(BuildContext context, Map<String, dynamic> rule) {
    final title = rule['label']?.toString() ?? rule['aksi']?.toString() ?? 'Aturan Gamifikasi';
    final desc = rule['deskripsi']?.toString() ?? rule['key']?.toString() ?? 'Trigger poin otomatis.';
    final key = rule['key']?.toString() ?? '';
    final poin = int.tryParse(rule['poin']?.toString() ?? '0') ?? 0;
    final isMinus = poin < 0;
    final color = isMinus ? BkuTheme.rose : BkuTheme.emerald;
    final softColor = isMinus ? BkuTheme.roseSoft : BkuTheme.emeraldSoft;
    final borderColor = isMinus ? BkuTheme.roseBorder : BkuTheme.emeraldBorder;

    IconData icon;
    if (key.contains('proposal')) {
      icon = Icons.assignment_turned_in_rounded;
    } else if (key.contains('kegiatan') || key.contains('event')) {
      icon = Icons.event_available_rounded;
    } else if (key.contains('aspirasi')) {
      icon = Icons.campaign_rounded;
    } else if (key.contains('prestasi')) {
      icon = Icons.military_tech_rounded;
    } else if (key.contains('lpj')) {
      icon = Icons.description_rounded;
    } else {
      icon = Icons.stars_rounded;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: BkuTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BkuTheme.r12,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BkuTheme.textCardTitle.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Trigger Otomatis: $key',
                        style: BkuTheme.textBadge.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: BkuTheme.textMuted,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BkuTheme.r8,
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    '${isMinus ? '' : '+'}$poin XP',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Deskripsi Aturan',
              style: BkuTheme.textBadge.copyWith(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: BkuTheme.textHeading,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BkuTheme.borderSubtle,
                borderRadius: BkuTheme.r12,
                border: Border.all(color: BkuTheme.border),
              ),
              child: Text(
                desc,
                style: BkuTheme.textBodyRegular.copyWith(
                  fontSize: 11.5,
                  color: BkuTheme.textHeading,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: BkuButton.primary(
                onPressed: () => Navigator.pop(ctx),
                text: 'Tutup',
                height: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final leaderboard = provider.gamifikasiLeaderboard;
    final rules = provider.gamifikasiRules;
    final history = provider.gamifikasiHistory;

    final totalPoints = leaderboard.fold<int>(
      0,
      (sum, item) => sum + (int.tryParse(item['total_poin']?.toString() ?? item['poin']?.toString() ?? '0') ?? 0),
    );
    final avgPoints =
        leaderboard.isNotEmpty ? (totalPoints / leaderboard.length).round() : 0;
    final topOrmawaName =
        leaderboard.isNotEmpty
            ? (leaderboard[0]['singkatan']?.toString().isNotEmpty == true
                ? leaderboard[0]['singkatan']
                : leaderboard[0]['nama'] ?? '—')
            : '—';

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        color: BkuTheme.primary,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BkuAppBar(
                title: 'Gamifikasi & Klasemen',
                subtitle: 'Sistem Prestasi Ormawa',
                info: 'Peringkat #${provider.gamifikasiPeringkat} • ${provider.gamifikasiPoin} XP',
                variant: AppBarVariant.ormawa,
                expandedHeight: 140.0,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsGrid(
                        context,
                        totalPoints: totalPoints,
                        avgPoints: avgPoints,
                        topOrmawaName: topOrmawaName.toString(),
                        rulesCount: rules.length,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildCustomTabBar(context),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboardTab(context, provider, leaderboard),
              _buildHistoryTab(context, provider, history),
              _buildRulesTab(context, provider, rules),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context, {
    required int totalPoints,
    required int avgPoints,
    required String topOrmawaName,
    required int rulesCount,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OrmawaKpiCard(
                title: 'Total Poin Beredar',
                value: NumberFormat.decimalPattern('id').format(totalPoints),
                badgeText: 'Total XP',
                icon: Icons.workspace_premium_rounded,
                badgeColor: BkuTheme.amber,
                subtitle: 'Akumulasi seluruh ormawa',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrmawaKpiCard(
                title: 'Rata-rata Skor',
                value: '$avgPoints XP',
                badgeText: 'Rata-rata',
                icon: Icons.trending_up_rounded,
                badgeColor: BkuTheme.sky,
                subtitle: 'Per organisasi aktif',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OrmawaKpiCard(
                title: 'Juara Klasemen',
                value: topOrmawaName,
                badgeText: 'Peringkat #1',
                icon: Icons.military_tech_rounded,
                badgeColor: BkuTheme.primary,
                subtitle: 'Peringkat #1 Univ',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OrmawaKpiCard(
                title: 'Aturan Gamifikasi',
                value: '$rulesCount Aturan',
                badgeText: 'Rules',
                icon: Icons.tune_rounded,
                badgeColor: BkuTheme.emerald,
                subtitle: 'Trigger poin aktif',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomTabBar(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BkuTheme.r12,
        border: Border.all(color: BkuTheme.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: BkuTheme.primary,
          borderRadius: BkuTheme.r8,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: BkuTheme.textMuted,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        tabs: const [
          Tab(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_rounded, size: 14),
                SizedBox(width: 5),
                Text('Klasemen'),
              ],
            ),
          ),
          Tab(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 14),
                SizedBox(width: 5),
                Text('Riwayat'),
              ],
            ),
          ),
          Tab(
            height: 32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune_rounded, size: 14),
                SizedBox(width: 5),
                Text('Aturan'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(
    BuildContext context,
    OrmawaProvider provider,
    List<Map<String, dynamic>> leaderboard,
  ) {
    if (provider.isLoading && leaderboard.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: BkuShimmerList(itemCount: 4, itemHeight: 70),
      );
    }

    if (leaderboard.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: BkuEmptyState(
          title: 'Belum Ada Data Klasemen',
          message: 'Data perolehan poin dan klasemen organisasi belum tersedia.',
          icon: Icons.emoji_events_outlined,
        ),
      );
    }

    final top3 = leaderboard.take(3).toList();

    final filteredLeaderboard = leaderboard.where((item) {
      if (_searchQuery.isEmpty) return true;
      final nama = (item['nama'] ?? '').toString().toLowerCase();
      final singkatan = (item['singkatan'] ?? '').toString().toLowerCase();
      return nama.contains(_searchQuery) || singkatan.contains(_searchQuery);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.s100,
      ),
      children: [
        if (top3.isNotEmpty && _searchQuery.isEmpty) ...[
          _buildPodiumTop3(context, top3),
          const SizedBox(height: AppSpacing.lg),
        ],
        OrmawaSearchBar(
          controller: _searchController,
          hintText: 'Cari organisasi mahasiswa...',
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Klasemen Lengkap',
              style: BkuTheme.textCardTitle.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: BkuTheme.primarySoft,
                borderRadius: BkuTheme.r8,
                border: Border.all(
                  color: BkuTheme.primaryBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                '${filteredLeaderboard.length} Organisasi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: BkuTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (filteredLeaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: BkuEmptyState(
              title: 'Organisasi Tidak Ditemukan',
              message: 'Tidak ada organisasi yang sesuai dengan kata kunci pencarian.',
              icon: Icons.search_off_rounded,
            ),
          )
        else
          ...List.generate(filteredLeaderboard.length, (index) {
            final item = filteredLeaderboard[index];
            final originalRank = leaderboard.indexOf(item) + 1;
            return _buildLeaderboardRow(context, provider, item, originalRank > 0 ? originalRank : index + 1);
          }),
      ],
    );
  }

  Widget _buildPodiumTop3(
    BuildContext context,
    List<Map<String, dynamic>> top3,
  ) {
    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    if (first == null) return const SizedBox.shrink();

    final firstName = first['nama']?.toString() ?? 'Ormawa';
    final firstShort = first['singkatan']?.toString() ?? '';
    final firstPoin = int.tryParse(first['total_poin']?.toString() ?? first['poin']?.toString() ?? '0') ?? 0;

    return Column(
      children: [
        BkuCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: 16,
          borderColor: BkuTheme.amberBorder,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BkuTheme.amberSoft,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: BkuTheme.amberBorder,
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: BkuTheme.amber,
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: BkuTheme.amber,
                        borderRadius: BkuTheme.r8,
                      ),
                      child: const Text(
                        '#1 JUARA KLASEMEN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      firstName,
                      style: BkuTheme.textCardTitle.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (firstShort.isNotEmpty)
                      Text(
                        firstShort,
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
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: BkuTheme.amber,
                  borderRadius: BkuTheme.r8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '$firstPoin XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (second != null || third != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: second != null
                    ? _buildRunnerUpCard(
                        context,
                        rank: 2,
                        item: second,
                        borderColor: BkuTheme.slateBorder,
                        badgeColor: BkuTheme.slate,
                        trophyColor: BkuTheme.slate,
                        trophyBgColor: BkuTheme.slateSoft,
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: third != null
                    ? _buildRunnerUpCard(
                        context,
                        rank: 3,
                        item: third,
                        borderColor: BkuTheme.roseBorder,
                        badgeColor: BkuTheme.rose,
                        trophyColor: BkuTheme.rose,
                        trophyBgColor: BkuTheme.roseSoft,
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildRunnerUpCard(
    BuildContext context, {
    required int rank,
    required Map<String, dynamic> item,
    required Color borderColor,
    required Color badgeColor,
    required Color trophyColor,
    required Color trophyBgColor,
  }) {
    final nama = item['nama']?.toString() ?? 'Ormawa';
    final singkatan = item['singkatan']?.toString() ?? '';
    final displayName = singkatan.isNotEmpty ? singkatan : nama;
    final poin = int.tryParse(item['total_poin']?.toString() ?? item['poin']?.toString() ?? '0') ?? 0;

    return BkuCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: 14,
      borderColor: borderColor,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: trophyBgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: trophyColor.withAlpha(50),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events_rounded,
                color: trophyColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BkuTheme.r8,
                      ),
                      child: Text(
                        '#$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$poin XP',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: trophyColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  style: BkuTheme.textCardTitle.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
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

  Widget _buildLeaderboardRow(
    BuildContext context,
    OrmawaProvider provider,
    Map<String, dynamic> item,
    int rank,
  ) {
    final nama = item['nama']?.toString() ?? 'Ormawa';
    final singkatan = item['singkatan']?.toString() ?? '';
    final poin = int.tryParse(item['total_poin']?.toString() ?? item['poin']?.toString() ?? '0') ?? 0;
    final id = item['id']?.toString() ?? item['ID']?.toString();
    final isMyOrmawa = id != null && id == provider.ormawaId?.toString();

    Color rankBg;
    Color rankColor;
    if (rank == 1) {
      rankBg = BkuTheme.amberSoft;
      rankColor = BkuTheme.amber;
    } else if (rank == 2) {
      rankBg = BkuTheme.slateSoft;
      rankColor = BkuTheme.slate;
    } else if (rank == 3) {
      rankBg = BkuTheme.roseSoft;
      rankColor = BkuTheme.rose;
    } else {
      rankBg = BkuTheme.borderSubtle;
      rankColor = BkuTheme.textMuted;
    }

    final initial = singkatan.isNotEmpty
        ? (singkatan.length > 4 ? singkatan.substring(0, 4) : singkatan)
        : (nama.length > 2 ? nama.substring(0, 2).toUpperCase() : 'OR');

    return BkuCard(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      borderRadius: 14,
      borderColor: isMyOrmawa ? BkuTheme.primary : BkuTheme.border,
      backgroundColor: isMyOrmawa ? BkuTheme.primarySoft : Colors.white,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankBg,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BkuTheme.primarySoft,
              borderRadius: BkuTheme.r8,
              border: Border.all(
                color: BkuTheme.primaryBorder,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: BkuTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nama,
                        style: BkuTheme.textCardTitle.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMyOrmawa) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: BkuTheme.primary,
                          borderRadius: BkuTheme.r8,
                        ),
                        child: const Text(
                          'Ormawa Anda',
                          style: TextStyle(
                            fontSize: 7.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  singkatan.isNotEmpty ? singkatan : 'Unit Kegiatan Mahasiswa',
                  style: BkuTheme.textCaption.copyWith(
                    fontSize: 9.5,
                    color: BkuTheme.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: BkuTheme.amberSoft,
              borderRadius: BkuTheme.r8,
              border: Border.all(
                color: BkuTheme.amberBorder,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 12,
                  color: BkuTheme.amber,
                ),
                const SizedBox(width: 2),
                Text(
                  '$poin XP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: BkuTheme.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(
    BuildContext context,
    OrmawaProvider provider,
    List<Map<String, dynamic>> history,
  ) {
    if (provider.isLoading && history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: BkuShimmerList(itemCount: 4, itemHeight: 60),
      );
    }

    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: BkuEmptyState(
          title: 'Belum Ada Riwayat Poin',
          message: 'Riwayat perolehan atau pengurangan poin ormawa belum tercatat.',
          icon: Icons.history_rounded,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.s100,
      ),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final item = history[index];
        final poin = int.tryParse(item['poin']?.toString() ?? '0') ?? 0;
        final isMinus = poin < 0;
        final color = isMinus ? BkuTheme.rose : BkuTheme.emerald;
        final softColor = isMinus ? BkuTheme.roseSoft : BkuTheme.emeraldSoft;
        final borderColor = isMinus ? BkuTheme.roseBorder : BkuTheme.emeraldBorder;
        final deskripsi = item['deskripsi']?.toString() ?? item['aksi']?.toString() ?? 'Aktivitas Ormawa';
        final rawDate = item['created_at']?.toString() ?? item['Tanggal']?.toString() ?? '';

        String formattedDate = '';
        if (rawDate.isNotEmpty) {
          try {
            final dt = DateTime.parse(rawDate);
            formattedDate = DateFormat('dd MMM yyyy, HH:mm', 'id').format(dt);
          } catch (_) {
            formattedDate = rawDate.split('T').first;
          }
        }

        return BkuCard(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          borderRadius: 14,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: softColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isMinus
                      ? Icons.remove_circle_outline_rounded
                      : Icons.add_circle_outline_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deskripsi,
                      style: BkuTheme.textCardTitle.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: BkuTheme.textCaption.copyWith(
                          fontSize: 9.5,
                          color: BkuTheme.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: softColor,
                  borderRadius: BkuTheme.r8,
                  border: Border.all(
                    color: borderColor,
                    width: 0.8,
                  ),
                ),
                child: Text(
                  '${isMinus ? '' : '+'}$poin XP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRulesTab(
    BuildContext context,
    OrmawaProvider provider,
    List<Map<String, dynamic>> rules,
  ) {
    if (provider.isLoading && rules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: BkuShimmerList(itemCount: 4, itemHeight: 60),
      );
    }

    if (rules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: BkuEmptyState(
          title: 'Belum Ada Aturan Poin',
          message: 'Aturan gamifikasi aktif belum dikonfigurasi.',
          icon: Icons.tune_rounded,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xs,
        AppSpacing.xl,
        AppSpacing.s100,
      ),
      itemCount: rules.length,
      itemBuilder: (context, index) {
        final rule = rules[index];
        final poin = int.tryParse(rule['poin']?.toString() ?? '0') ?? 0;
        final isMinus = poin < 0;
        final color = isMinus ? BkuTheme.rose : BkuTheme.emerald;
        final softColor = isMinus ? BkuTheme.roseSoft : BkuTheme.emeraldSoft;
        final borderColor = isMinus ? BkuTheme.roseBorder : BkuTheme.emeraldBorder;
        final title = rule['label']?.toString() ?? rule['aksi']?.toString() ?? 'Aturan';
        final desc = rule['deskripsi']?.toString() ?? rule['key']?.toString() ?? 'Trigger Poin Otomatis';
        final key = rule['key']?.toString() ?? '';

        IconData icon;
        if (key.contains('proposal')) {
          icon = Icons.assignment_turned_in_rounded;
        } else if (key.contains('kegiatan') || key.contains('event')) {
          icon = Icons.event_available_rounded;
        } else if (key.contains('aspirasi')) {
          icon = Icons.campaign_rounded;
        } else if (key.contains('prestasi')) {
          icon = Icons.military_tech_rounded;
        } else if (key.contains('lpj')) {
          icon = Icons.description_rounded;
        } else {
          icon = Icons.stars_rounded;
        }

        return InkWell(
          onTap: () => _showRuleDetailModal(context, rule),
          borderRadius: BorderRadius.circular(14),
          child: BkuCard(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            borderRadius: 14,
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BkuTheme.r8,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BkuTheme.textCardTitle.copyWith(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        desc,
                        style: BkuTheme.textCaption.copyWith(
                          fontSize: 9.5,
                          color: BkuTheme.textMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: softColor,
                    borderRadius: BkuTheme.r8,
                    border: Border.all(
                      color: borderColor,
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    '${isMinus ? '' : '+'}$poin Poin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: color,
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
}
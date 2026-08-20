import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
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
    final color = isMinus ? AppColors.error : AppColors.serviceEmerald;

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
                  color: const Color(0xFFCBD5E1),
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
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
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
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'TRIGGER OTOMATIS: ${key.toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withAlpha(60)),
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
            const Text(
              'DESKRIPSI ATURAN',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Color(0xFF64748B),
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                desc,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF0F172A),
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: OrmawaTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
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
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        color: OrmawaTheme.primary,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              BkuAppBar(
                title: 'Gamifikasi & Klasemen',
                subtitle: 'SISTEM PRESTASI ORMAWA',
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
                badgeColor: const Color(0xFFD97706),
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
                badgeColor: const Color(0xFF0284C7),
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
                badgeColor: OrmawaTheme.primary,
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
                badgeColor: const Color(0xFF059669),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: OrmawaTheme.primary,
          borderRadius: BorderRadius.circular(9),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
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
      return _buildEmptyState('Belum ada data klasemen');
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
        TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val.toLowerCase().trim()),
          style: const TextStyle(fontSize: 12, color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'Cari organisasi mahasiswa...',
            hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: OrmawaTheme.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Klasemen Lengkap',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: OrmawaTheme.primarySoft,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: OrmawaTheme.primaryBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                '${filteredLeaderboard.length} Organisasi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: OrmawaTheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (filteredLeaderboard.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Center(
              child: Text(
                'Organisasi tidak ditemukan.',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
              ),
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
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE047), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD97706).withAlpha(18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withAlpha(80),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Color(0xFFD97706),
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
                        color: const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(4),
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
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (firstShort.isNotEmpty)
                      Text(
                        firstShort,
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
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(8),
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
                        borderColor: const Color(0xFFCBD5E1),
                        badgeColor: const Color(0xFF64748B),
                        trophyColor: const Color(0xFF475569),
                        trophyBgColor: const Color(0xFFF1F5F9),
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
                        borderColor: const Color(0xFFFED7AA),
                        badgeColor: const Color(0xFFEA580C),
                        trophyColor: const Color(0xFFC2410C),
                        trophyBgColor: const Color(0xFFFFEDD5),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: trophyColor.withAlpha(10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                        borderRadius: BorderRadius.circular(4),
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
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
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
      rankBg = const Color(0xFFFEF3C7);
      rankColor = const Color(0xFFD97706);
    } else if (rank == 2) {
      rankBg = const Color(0xFFF1F5F9);
      rankColor = const Color(0xFF64748B);
    } else if (rank == 3) {
      rankBg = const Color(0xFFFFEDD5);
      rankColor = const Color(0xFFEA580C);
    } else {
      rankBg = const Color(0xFFF1F5F9);
      rankColor = const Color(0xFF475569);
    }

    final initial = singkatan.isNotEmpty
        ? (singkatan.length > 4 ? singkatan.substring(0, 4) : singkatan)
        : (nama.length > 2 ? nama.substring(0, 2).toUpperCase() : 'OR');

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMyOrmawa ? OrmawaTheme.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMyOrmawa ? OrmawaTheme.primary : const Color(0xFFE2E8F0),
          width: isMyOrmawa ? 1.5 : 1,
        ),
      ),
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
              color: OrmawaTheme.primarySoft,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: OrmawaTheme.primaryBorder,
                width: 0.8,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: OrmawaTheme.primary,
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
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
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
                          color: OrmawaTheme.primary,
                          borderRadius: BorderRadius.circular(4),
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
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF64748B),
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
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFFFDE047),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  size: 12,
                  color: Color(0xFFD97706),
                ),
                const SizedBox(width: 2),
                Text(
                  '$poin XP',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFB45309),
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
      return _buildEmptyState('Belum ada riwayat perolehan poin');
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
        final color = isMinus ? AppColors.error : AppColors.success;
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

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(18),
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
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: color.withAlpha(40),
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
      return _buildEmptyState('Belum ada aturan poin aktif');
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
        final color = isMinus ? AppColors.error : AppColors.serviceEmerald;
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
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withAlpha(18),
                    borderRadius: BorderRadius.circular(8),
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
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: Color(0xFF64748B),
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
                    color: color.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: color.withAlpha(40),
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

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            color: Color(0xFF94A3B8),
            size: 48,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
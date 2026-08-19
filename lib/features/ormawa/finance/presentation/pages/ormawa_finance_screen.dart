import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_search_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/finance/presentation/pages/create_transaction_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/pagu/presentation/pages/ormawa_pagu_screen.dart';

class OrmawaFinanceScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaFinanceScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaFinanceScreen> createState() => _OrmawaFinanceScreenState();
}

class _OrmawaFinanceScreenState extends State<OrmawaFinanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double val) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final allTransactions = ormawaProvider.financeList;

    double totalMasuk = 0;
    double totalKeluar = 0;
    double campusMasuk = 0;
    double campusKeluar = 0;

    for (var t in allTransactions) {
      final isIncome = t.type == 'pemasukan';
      final isCampus = t.sumber == 'kampus';

      if (isIncome) {
        totalMasuk += t.nominal;
        if (isCampus) campusMasuk += t.nominal;
      } else {
        totalKeluar += t.nominal;
        if (isCampus) campusKeluar += t.nominal;
      }
    }

    final balance = totalMasuk - totalKeluar;
    final campusBalance = campusMasuk - campusKeluar;

    final masukCount = allTransactions.where((t) => t.type == 'pemasukan').length;
    final keluarCount = allTransactions.where((t) => t.type == 'pengeluaran').length;
    final kampusCount = allTransactions.where((t) => t.sumber == 'kampus').length;

    final filteredTransactions = allTransactions.where((t) {
      bool matchTab = true;
      if (_activeTab == 'pemasukan') matchTab = (t.type == 'pemasukan');
      if (_activeTab == 'pengeluaran') matchTab = (t.type == 'pengeluaran');
      if (_activeTab == 'kampus') matchTab = (t.sumber == 'kampus');

      final matchQuery = _searchQuery.isEmpty ||
          t.description.toLowerCase().contains(_searchQuery) ||
          t.category.toLowerCase().contains(_searchQuery);

      return matchTab && matchQuery;
    }).toList();

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      floatingActionButton: ormawaProvider.hasPermission('create_finance')
          ? Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s100),
              child: FloatingActionButton.extended(
                onPressed: () async {
                  final provider = context.read<OrmawaProvider>();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTransactionScreen(),
                    ),
                  );
                  provider.refreshData();
                },
                backgroundColor: OrmawaTheme.primary,
                elevation: 4,
                highlightElevation: 2,
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: const Text(
                  'Catat Transaksi',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Buku Kas',
              subtitle: 'Keuangan & Mutasi Saldo',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.savings_rounded, color: Colors.white),
                  tooltip: 'Pagu Anggaran',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrmawaPaguScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Saldo Kas Total',
                            value: _formatCurrency(balance),
                            badgeText: 'Kas Gabungan',
                            icon: Icons.account_balance_rounded,
                            badgeColor: OrmawaTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Sisa Pagu Kampus',
                            value: _formatCurrency(campusBalance),
                            badgeText: 'Pagu Anggaran',
                            icon: Icons.assured_workload_rounded,
                            badgeColor: const Color(0xFF0284C7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Total Pemasukan',
                            value: _formatCurrency(totalMasuk),
                            badgeText: 'Pemasukan',
                            icon: Icons.arrow_downward_rounded,
                            badgeColor: const Color(0xFF059669),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OrmawaKpiCard(
                            title: 'Total Pengeluaran',
                            value: _formatCurrency(totalKeluar),
                            badgeText: 'Pengeluaran',
                            icon: Icons.arrow_upward_rounded,
                            badgeColor: const Color(0xFFE11D48),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    OrmawaFilterTabs(
                      tabs: [
                        OrmawaTabItem(key: 'all', label: 'Semua', count: allTransactions.length),
                        OrmawaTabItem(key: 'pemasukan', label: 'Pemasukan', count: masukCount),
                        OrmawaTabItem(key: 'pengeluaran', label: 'Pengeluaran', count: keluarCount),
                        OrmawaTabItem(key: 'kampus', label: 'Pagu Kampus', count: kampusCount),
                      ],
                      activeKey: _activeTab,
                      onTabChanged: (val) => setState(() => _activeTab = val),
                    ),
                    const SizedBox(height: 12),
                    OrmawaSearchBar(
                      controller: _searchController,
                      hintText: 'Cari catatan transaksi atau kategori...',
                      onChanged: (val) =>
                          setState(() => _searchQuery = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 14),
                    if (filteredTransactions.isEmpty)
                      const OrmawaEmptyCard(
                        title: 'Belum ada transaksi',
                        description: 'Tidak ada riwayat transaksi yang sesuai dengan filter.',
                        icon: Icons.receipt_long_rounded,
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredTransactions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final t = filteredTransactions[index];
                          final isIncome = t.type == 'pemasukan';
                          final isCampus = t.sumber == 'kampus';

                          return OrmawaCard(
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: (isIncome
                                            ? OrmawaTheme.statusSuccessBg
                                            : OrmawaTheme.statusDangerBg),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isIncome
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    color: isIncome
                                        ? OrmawaTheme.statusSuccessText
                                        : OrmawaTheme.statusDangerText,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: OrmawaTheme.textHeading,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 1.5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isCampus
                                                  ? OrmawaTheme.statusInfoBg
                                                  : const Color(0xFFF1F5F9),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isCampus ? 'Pagu Kampus' : 'Kas Mandiri',
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.bold,
                                                color: isCampus
                                                    ? OrmawaTheme.statusInfoText
                                                    : OrmawaTheme.textMuted,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Text(
                                            DateFormat('dd MMM yyyy', 'id')
                                                .format(t.date),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: OrmawaTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  '${isIncome ? '+' : '-'}${_formatCurrency(t.nominal)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: isIncome
                                        ? OrmawaTheme.statusSuccessText
                                        : OrmawaTheme.statusDangerText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: AppSpacing.s140),
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

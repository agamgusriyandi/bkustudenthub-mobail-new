import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_filter_tabs.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaMutasiScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaMutasiScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaMutasiScreen> createState() => _OrmawaMutasiScreenState();
}

class _OrmawaMutasiScreenState extends State<OrmawaMutasiScreen> {
  String _activeTab = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
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
              title: 'Riwayat Mutasi',
              subtitle: 'Log Transaksi Keuangan',
              variant: AppBarVariant.ormawa,
              expandedHeight: 125.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            Consumer<OrmawaProvider>(
              builder: (context, provider, _) {
                final allTransactions = provider.financeList;
                final incomeCount = allTransactions.where((t) => t.type == 'pemasukan').length;
                final expenseCount = allTransactions.where((t) => t.type == 'pengeluaran').length;

                final filtered = allTransactions.where((t) {
                  if (_activeTab == 'all') return true;
                  if (_activeTab == 'pemasukan') return t.type == 'pemasukan';
                  if (_activeTab == 'pengeluaran') return t.type == 'pengeluaran';
                  return true;
                }).toList();

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrmawaFilterTabs(
                          tabs: [
                            OrmawaTabItem(key: 'all', label: 'Semua', count: allTransactions.length),
                            OrmawaTabItem(key: 'pemasukan', label: 'Pemasukan', count: incomeCount),
                            OrmawaTabItem(key: 'pengeluaran', label: 'Pengeluaran', count: expenseCount),
                          ],
                          activeKey: _activeTab,
                          onTabChanged: (val) => setState(() => _activeTab = val),
                        ),
                        const SizedBox(height: 14),
                        if (filtered.isEmpty)
                          const OrmawaEmptyCard(
                            title: 'Belum Ada Mutasi',
                            description: 'Tidak ada riwayat mutasi transaksi keuangan pada kategori ini.',
                            icon: Icons.receipt_long_rounded,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final t = filtered[index];
                              final isIncome = t.type == 'pemasukan';
                              return OrmawaCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isIncome
                                            ? OrmawaTheme.statusSuccessBg
                                            : OrmawaTheme.statusDangerBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        isIncome
                                            ? Icons.arrow_downward_rounded
                                            : Icons.arrow_upward_rounded,
                                        color: isIncome
                                            ? OrmawaTheme.statusSuccessText
                                            : OrmawaTheme.statusDangerText,
                                        size: 18,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            t.description,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: OrmawaTheme.textHeading,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            '${t.category} • ${DateFormat('dd MMM yyyy', 'id').format(t.date)}',
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              color: OrmawaTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(t.nominal)}',
                                      style: TextStyle(
                                        color: isIncome
                                            ? OrmawaTheme.statusSuccessText
                                            : OrmawaTheme.statusDangerText,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 13,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
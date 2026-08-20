import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaIuranScreen extends StatefulWidget {
  const OrmawaIuranScreen({super.key});

  @override
  State<OrmawaIuranScreen> createState() => _OrmawaIuranScreenState();
}

class _OrmawaIuranScreenState extends State<OrmawaIuranScreen> {
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
        color: OrmawaTheme.primary,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            const BkuAppBar(
              title: 'Iuran Anggota',
              subtitle: 'Rekap Pembayaran Kas',
              variant: AppBarVariant.ormawa,
              expandedHeight: 125.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
                child: Consumer<OrmawaProvider>(
                  builder: (context, provider, _) {
                    final members = provider.members;
                    final iuranTransactions = provider.financeList
                        .where((t) =>
                            t.category.toLowerCase() == 'iuran anggota' &&
                            t.type == 'pemasukan')
                        .toList();

                    final totalIuran = iuranTransactions
                        .fold<double>(0, (sum, t) => sum + t.nominal);
                    final activeMembers = members
                        .where((m) => m.status.toLowerCase() == 'aktif')
                        .length;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Anggota Aktif',
                                value: '$activeMembers',
                                badgeText: 'Member',
                                icon: Icons.groups_rounded,
                                badgeColor: OrmawaTheme.statusInfoText,
                                subtitle: 'Wajib iuran',
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: OrmawaKpiCard(
                                title: 'Transaksi',
                                value: '${iuranTransactions.length}',
                                badgeText: 'Log',
                                icon: Icons.receipt_rounded,
                                badgeColor: OrmawaTheme.statusSuccessText,
                                subtitle: 'Pembayaran kas',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        OrmawaKpiCard(
                          title: 'Total Iuran Terkumpul',
                          value: NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(totalIuran),
                          badgeText: 'Kas Masuk',
                          icon: Icons.payments_rounded,
                          badgeColor: OrmawaTheme.statusSuccessText,
                          subtitle: 'Saldo iuran terakumulasi',
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              width: 3.5,
                              height: 13,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: OrmawaTheme.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Text(
                              'Riwayat Pembayaran Iuran',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: OrmawaTheme.textHeading,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (iuranTransactions.isEmpty)
                          const OrmawaEmptyCard(
                            title: 'Belum Ada Iuran Tercatat',
                            description: 'Riwayat pembayaran iuran anggota akan muncul di sini.',
                            icon: Icons.payments_outlined,
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: iuranTransactions.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final t = iuranTransactions[index];
                              return OrmawaCard(
                                child: Row(
                                  children: [
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: OrmawaTheme.statusSuccessBg,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.check_circle_rounded,
                                        color: OrmawaTheme.statusSuccessText,
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
                                      '+ ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(t.nominal)}',
                                      style: TextStyle(
                                        color: OrmawaTheme.statusSuccessText,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: AppSpacing.s100),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
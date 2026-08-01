import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/bku_app_bar.dart';
import '../../../../../core/widgets/fade_in_animation.dart';
import '../../../../../core/widgets/ormawa_list_header.dart';
import 'create_transaction_screen.dart';

class OrmawaFinanceScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaFinanceScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaFinanceScreen> createState() => _OrmawaFinanceScreenState();
}

class _OrmawaFinanceScreenState extends State<OrmawaFinanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _obscureNominal = false;
  String _selectedTypeFilter = 'Semua';
  String _selectedSumberFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<OrmawaProvider>().refreshData();
      }
    });
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = context.watch<OrmawaProvider>();
    final canCreateFinance = ormawaProvider.hasPermission('create_finance');

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      floatingActionButton:
          canCreateFinance
              ? Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.s70),
                child: FadeInAnimation(
                  delay: 1.0,
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      final provider = context.read<OrmawaProvider>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateTransactionScreen(),
                        ),
                      ).then((_) => provider.refreshData());
                    },
                    backgroundColor: context.appColors.primary,
                    elevation: 8,
                    icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
                    label: Text(
                      'Catat Transaksi',
                      style: AppTextStyles.labelMd.copyWith(
                        color: context.appColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'BUKU KAS',
              subtitle: 'FINANCIAL MANAGEMENT',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),

            SliverToBoxAdapter(child: _buildSummaryHeader()),
            SliverToBoxAdapter(child: _buildFinanceChart()),

            _buildTransactionList(),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final transactions = provider.financeList;
        double totalMasuk = 0;
        double totalKeluar = 0;
        double campusMasuk = 0;
        double campusKeluar = 0;
        double orgMasuk = 0;
        double orgKeluar = 0;

        for (var t in transactions) {
          final isIncome = t.type == 'pemasukan';
          final isCampus = t.sumber == 'kampus';

          if (isIncome) {
            totalMasuk += t.nominal;
            if (isCampus) {
              campusMasuk += t.nominal;
            } else {
              orgMasuk += t.nominal;
            }
          } else {
            totalKeluar += t.nominal;
            if (isCampus) {
              campusKeluar += t.nominal;
            } else {
              orgKeluar += t.nominal;
            }
          }
        }

        final balance = totalMasuk - totalKeluar;
        final campusBalance = campusMasuk - campusKeluar;
        final orgBalance = orgMasuk - orgKeluar;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.s20),
            SizedBox(
              height: 140,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    _buildBalanceCard(
                      title: 'SALDO KAS GABUNGAN',
                      balance: balance,
                      subtitle:
                          _obscureNominal
                              ? 'Masuk: Rp â€¢â€¢â€¢ | Keluar: Rp â€¢â€¢â€¢'
                              : 'Masuk: Rp ${_formatNominal(totalMasuk)} | Keluar: Rp ${_formatNominal(totalKeluar)}',
                      accentColor: context.appColors.primary,
                      icon: Icons.account_balance_rounded,
                      showVisibilityToggle: true,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _buildBalanceCard(
                      title: 'SISA PAGU KAMPUS',
                      balance: campusBalance,
                      subtitle:
                          _obscureNominal
                              ? 'Hibah: Rp â€¢â€¢â€¢ | LPJ: Rp â€¢â€¢â€¢'
                              : 'Hibah: Rp ${_formatNominal(campusMasuk)} | LPJ: Rp ${_formatNominal(campusKeluar)}',
                      accentColor: context.appColors.info,
                      icon: Icons.assured_workload_rounded,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    _buildBalanceCard(
                      title: 'KAS MANDIRI ORGANISASI',
                      balance: orgBalance,
                      subtitle:
                          _obscureNominal
                              ? 'Iuran: Rp â€¢â€¢â€¢ | Mandiri: Rp â€¢â€¢â€¢'
                              : 'Iuran: Rp ${_formatNominal(orgMasuk)} | Mandiri: Rp ${_formatNominal(orgKeluar)}',
                      accentColor: context.appColors.success,
                      icon: Icons.payments_rounded,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s20,
                AppSpacing.xl,
                AppSpacing.s20,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OrmawaListHeader(
                    title: 'RIWAYAT MUTASI',
                    searchHint: 'Cari transaksi...',
                    searchController: _searchController,
                    onRefresh: () => provider.refreshData(),
                    onFilterTap: _showFilterBottomSheet,
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatNominal(double val) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: '',
      decimalDigits: 0,
    ).format(val).trim();
  }

  Widget _buildBalanceCard({
    required String title,
    required double balance,
    required String subtitle,
    required Color accentColor,
    required IconData icon,
    bool showVisibilityToggle = false,
  }) {
    return Container(
      width: 290,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
              Icon(icon, color: accentColor, size: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                _obscureNominal
                    ? 'Rp â€¢â€¢â€¢â€¢â€¢â€¢'
                    : NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(balance),
                style: AppTextStyles.titleLg.copyWith(
                  color: AppColors.neutral900,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (showVisibilityToggle) ...[
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureNominal = !_obscureNominal;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.neutral100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neutral300,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      _obscureNominal
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.neutral600,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtitle,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final allTransactions = provider.financeList;

        // Apply search and status filters
        final transactions =
            allTransactions.where((t) {
              final matchesSearch =
                  _searchQuery.isEmpty ||
                  t.description.toLowerCase().contains(_searchQuery) ||
                  t.category.toLowerCase().contains(_searchQuery);
              final matchesType =
                  _selectedTypeFilter == 'Semua' ||
                  t.type == _selectedTypeFilter;
              final matchesSumber =
                  _selectedSumberFilter == 'Semua' ||
                  t.sumber == _selectedSumberFilter;
              return matchesSearch && matchesType && matchesSumber;
            }).toList();

        if (transactions.isEmpty) {
          final hasActiveFilters =
              _selectedTypeFilter != 'Semua' ||
              _selectedSumberFilter != 'Semua';
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.s100),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: AppColors.neutral500.withAlpha(50),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      (_searchQuery.isEmpty && !hasActiveFilters)
                          ? 'Belum ada riwayat transaksi'
                          : 'Transaksi tidak ditemukan',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final t = transactions[index];
              final isIncome = t.type == 'pemasukan';
              final isCampus = t.sumber == 'kampus';

              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: AppRadius.radiusLg,
                  border: Border.all(color: AppColors.neutral200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: (isIncome ? AppColors.success : AppColors.error)
                            .withAlpha(10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isIncome
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: isIncome ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.description,
                            style: AppTextStyles.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${t.category} â€¢ ${DateFormat('dd MMM yyyy', 'id').format(t.date)}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.s6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (isCampus ? AppColors.info : AppColors.neutral500)
                                  .withAlpha(15),
                              borderRadius: AppRadius.radiusXs,
                              border: Border.all(
                                color: (isCampus ? AppColors.info : AppColors.neutral500)
                                    .withAlpha(40),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  isCampus
                                      ? Icons.assured_workload_rounded
                                      : Icons.payments_rounded,
                                  size: 10,
                                  color:
                                      isCampus
                                        ? context.appColors.info
                                        : AppColors.neutral600,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isCampus ? 'PAGU KAMPUS' : 'KAS MANDIRI',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        isCampus
                                            ? context.appColors.info
                                            : AppColors.neutral600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      _obscureNominal
                          ? '${isIncome ? '+' : '-'} â€¢â€¢â€¢â€¢â€¢â€¢'
                          : '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(t.nominal)}',
                      style: AppTextStyles.labelMd.copyWith(
                        color: isIncome ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              );
            }, childCount: transactions.length),
          ),
        );
      },
    );
  }

  Widget _buildFinanceChart() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, child) {
        final transactions = provider.financeList;
        double campusMasuk = 0, campusKeluar = 0, orgMasuk = 0, orgKeluar = 0;
        for (var t in transactions) {
          final isIncome = t.type == 'pemasukan';
          final isCampus = t.sumber == 'kampus';
          if (isIncome) {
            if (isCampus) {
              campusMasuk += t.nominal;
            } else {
              orgMasuk += t.nominal;
            }
          } else {
            if (isCampus) {
              campusKeluar += t.nominal;
            } else {
              orgKeluar += t.nominal;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINGKASAN KEUANGAN',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  height: 160,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: [
                        campusMasuk,
                        campusKeluar,
                        orgMasuk,
                        orgKeluar,
                      ].reduce((a, b) => a > b ? a : b) *
                          1.2,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = _chartLabels[groupIndex];
                            final value = rod.toY;
                            return BarTooltipItem(
                              '$label\n${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(value)}',
                              AppTextStyles.caption.copyWith(
                                color: context.appColors.onPrimary,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < _chartLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _chartLabels[idx],
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 8,
                                      color: AppColors.neutral600,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: campusMasuk,
                              color: AppColors.info,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: campusKeluar,
                              color: AppColors.infoContainer,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: orgMasuk,
                              color: AppColors.success,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(
                              toY: orgKeluar,
                              color: AppColors.successContainer,
                              width: 18,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLegendDot(AppColors.info, 'Pagu Masuk'),
                    const SizedBox(width: AppSpacing.lg),
                    _buildLegendDot(AppColors.infoContainer, 'Pagu Keluar'),
                    const SizedBox(width: AppSpacing.lg),
                    _buildLegendDot(AppColors.success, 'Mandiri Masuk'),
                    const SizedBox(width: AppSpacing.lg),
                    _buildLegendDot(AppColors.successContainer, 'Mandiri Keluar'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static const _chartLabels = ['Pagu\nMasuk', 'Pagu\nKeluar', 'Mandiri\nMasuk', 'Mandiri\nKeluar'];

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.neutral600,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: context.appColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
              ),
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Filter Transaksi',
                        style: AppTextStyles.titleMd.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedTypeFilter = 'Semua';
                            _selectedSumberFilter = 'Semua';
                          });
                          setState(() {});
                        },
                        child: Text(
                          'Reset',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Filter Tipe Transaksi
                  Text(
                    'TIPE TRANSAKSI',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        isSelected: _selectedTypeFilter == 'Semua',
                        onTap: () {
                          setModalState(() => _selectedTypeFilter = 'Semua');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        label: 'Pemasukan',
                        isSelected: _selectedTypeFilter == 'pemasukan',
                        onTap: () {
                          setModalState(
                            () => _selectedTypeFilter = 'pemasukan',
                          );
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        label: 'Pengeluaran',
                        isSelected: _selectedTypeFilter == 'pengeluaran',
                        onTap: () {
                          setModalState(
                            () => _selectedTypeFilter = 'pengeluaran',
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s20),

                  // Filter Sumber Dana
                  Text(
                    'SUMBER DANA',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      _buildFilterChip(
                        label: 'Semua',
                        isSelected: _selectedSumberFilter == 'Semua',
                        onTap: () {
                          setModalState(() => _selectedSumberFilter = 'Semua');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        label: 'Pagu Kampus',
                        isSelected: _selectedSumberFilter == 'kampus',
                        onTap: () {
                          setModalState(() => _selectedSumberFilter = 'kampus');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _buildFilterChip(
                        label: 'Kas Mandiri',
                        isSelected: _selectedSumberFilter == 'organisasi',
                        onTap: () {
                          setModalState(
                            () => _selectedSumberFilter = 'organisasi',
                          );
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),

                      child: Text(
                        'Terapkan Filter',
                        style: AppTextStyles.labelMd.copyWith(
                          color: context.appColors.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? context.appColors.primary
                  : AppColors.neutral200,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color:
                isSelected
                    ? context.appColors.primary
                    : AppColors.neutral300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? context.appColors.onPrimary : AppColors.neutral700,
          ),
        ),
      ),
    );
  }
}

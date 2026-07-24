import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
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
                padding: const EdgeInsets.only(bottom: 70),
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
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 8,
                    icon: const Icon(Icons.add_rounded, color: Colors.white),
                    label: Text(
                      'Catat Transaksi',
                      style: AppTextStyles.labelMd.copyWith(
                        color: Colors.white,
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

            _buildTransactionList(),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
            const SizedBox(height: 20),
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
                              ? 'Masuk: Rp ••• | Keluar: Rp •••'
                              : 'Masuk: Rp ${_formatNominal(totalMasuk)} | Keluar: Rp ${_formatNominal(totalKeluar)}',
                      accentColor: Theme.of(context).colorScheme.primary,
                      icon: Icons.account_balance_rounded,
                      showVisibilityToggle: true,
                    ),
                    const SizedBox(width: 16),
                    _buildBalanceCard(
                      title: 'SISA PAGU KAMPUS',
                      balance: campusBalance,
                      subtitle:
                          _obscureNominal
                              ? 'Hibah: Rp ••• | LPJ: Rp •••'
                              : 'Hibah: Rp ${_formatNominal(campusMasuk)} | LPJ: Rp ${_formatNominal(campusKeluar)}',
                      accentColor: const Color(0xFF0284C7),
                      icon: Icons.assured_workload_rounded,
                    ),
                    const SizedBox(width: 16),
                    _buildBalanceCard(
                      title: 'KAS MANDIRI ORGANISASI',
                      balance: orgBalance,
                      subtitle:
                          _obscureNominal
                              ? 'Iuran: Rp ••• | Mandiri: Rp •••'
                              : 'Iuran: Rp ${_formatNominal(orgMasuk)} | Mandiri: Rp ${_formatNominal(orgKeluar)}',
                      accentColor: const Color(0xFF059669),
                      icon: Icons.payments_rounded,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
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
                  const SizedBox(height: 16),
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
        color: Colors.white,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
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
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _obscureNominal
                    ? 'Rp ••••••'
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
                const SizedBox(width: 8),
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
          const SizedBox(height: 8),
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
              padding: const EdgeInsets.only(top: 100),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: Colors.grey.withAlpha(50),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      (_searchQuery.isEmpty && !hasActiveFilters)
                          ? 'Belum ada riwayat transaksi'
                          : 'Transaksi tidak ditemukan',
                      style: AppTextStyles.labelMd.copyWith(color: Colors.grey),
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
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                    const SizedBox(width: 16),
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
                            '${t.category} • ${DateFormat('dd MMM yyyy', 'id').format(t.date)}',
                            style: AppTextStyles.labelSm.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (isCampus ? AppColors.info : Colors.grey)
                                  .withAlpha(15),
                              borderRadius: AppRadius.radiusXs,
                              border: Border.all(
                                color: (isCampus ? AppColors.info : Colors.grey)
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
                                          ? const Color(0xFF1D4ED8)
                                          : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isCampus ? 'PAGU KAMPUS' : 'KAS MANDIRI',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color:
                                        isCampus
                                            ? const Color(0xFF1D4ED8)
                                            : Colors.grey.shade600,
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
                          ? '${isIncome ? '+' : '-'} ••••••'
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                  const SizedBox(height: 16),

                  // Filter Tipe Transaksi
                  Text(
                    'TIPE TRANSAKSI',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      const SizedBox(width: 8),
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
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 20),

                  // Filter Sumber Dana
                  Text(
                    'SUMBER DANA',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'Pagu Kampus',
                        isSelected: _selectedSumberFilter == 'kampus',
                        onTap: () {
                          setModalState(() => _selectedSumberFilter = 'kampus');
                          setState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),

                      child: Text(
                        'Terapkan Filter',
                        style: AppTextStyles.labelMd.copyWith(
                          color: Colors.white,
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
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.neutral200,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.neutral300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.neutral700,
          ),
        ),
      ),
    );
  }
}

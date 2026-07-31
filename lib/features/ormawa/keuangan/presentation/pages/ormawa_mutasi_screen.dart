import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrmawaMutasiScreen extends StatefulWidget {
  const OrmawaMutasiScreen({super.key});

  @override
  State<OrmawaMutasiScreen> createState() => _OrmawaMutasiScreenState();
}

class _OrmawaMutasiScreenState extends State<OrmawaMutasiScreen> {
  String _selectedFilter = 'Semua';

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
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'RIWAYAT MUTASI',
              subtitle: 'LOG TRANSAKSI KEUANGAN',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterChips(),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            _buildMutasiList(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.s100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: ['Semua', 'Pemasukan', 'Pengeluaran'].map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : AppColors.neutral200,
                  borderRadius: AppRadius.radiusXl,
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? context.appColors.onPrimary
                        : AppColors.neutral700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMutasiList() {
    return Consumer<OrmawaProvider>(
      builder: (context, provider, _) {
        final transactions = provider.financeList.where((t) {
          if (_selectedFilter == 'Semua') return true;
          if (_selectedFilter == 'Pemasukan') return t.type == 'pemasukan';
          if (_selectedFilter == 'Pengeluaran') return t.type == 'pengeluaran';
          return true;
        }).toList();

        if (transactions.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 48, color: AppColors.neutral500.withAlpha(50)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Belum ada mutasi',
                      style: AppTextStyles.labelMd.copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final t = transactions[index];
                final isIncome = t.type == 'pemasukan';
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
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.description,
                                style: AppTextStyles.bodyMd
                                    .copyWith(fontWeight: FontWeight.bold, fontSize: 13)),
                            Text(
                              '${t.category} - ${DateFormat('dd MMM yyyy', 'id').format(t.date)}',
                              style: AppTextStyles.labelSm
                                  .copyWith(color: AppColors.neutral500, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'} ${NumberFormat.currency(locale: 'id', symbol: '', decimalDigits: 0).format(t.nominal)}',
                        style: AppTextStyles.bodyMd.copyWith(
                          color: isIncome ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: transactions.length,
            ),
          ),
        );
      },
    );
  }
}

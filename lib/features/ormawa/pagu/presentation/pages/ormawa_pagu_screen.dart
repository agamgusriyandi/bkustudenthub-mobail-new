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

class OrmawaPaguScreen extends StatefulWidget {
  const OrmawaPaguScreen({super.key});

  @override
  State<OrmawaPaguScreen> createState() => _OrmawaPaguScreenState();
}

class _OrmawaPaguScreenState extends State<OrmawaPaguScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0)
        .format(value);
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
              title: 'PAGU ANGGARAN',
              subtitle: 'ALOKASI DANA KAMPUS',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Consumer<OrmawaProvider>(
                  builder: (context, provider, _) {
                    final transactions = provider.financeList;
                    double campusMasuk = 0;
                    double campusKeluar = 0;

                    for (var t in transactions) {
                      if (t.sumber == 'kampus') {
                        if (t.type == 'pemasukan') {
                          campusMasuk += t.nominal;
                        } else {
                          campusKeluar += t.nominal;
                        }
                      }
                    }

                    final sisaPagu = campusMasuk - campusKeluar;
                    final persentaseTerpakai =
                        campusMasuk > 0 ? (campusKeluar / campusMasuk * 100).toDouble() : 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPaguOverview(
                            campusMasuk, campusKeluar, sisaPagu, persentaseTerpakai),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'RINCIAN PAGU KAMPUS',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _buildDetailRow(
                          'Total Hibah Diterima',
                          _formatCurrency(campusMasuk),
                          AppColors.success,
                          Icons.account_balance_rounded,
                        ),
                        _buildDetailRow(
                          'Total LPJ Disetujui',
                          _formatCurrency(campusKeluar),
                          AppColors.error,
                          Icons.receipt_long_rounded,
                        ),
                        _buildDetailRow(
                          'Sisa Pagu',
                          _formatCurrency(sisaPagu),
                          context.appColors.primary,
                          Icons.savings_rounded,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _buildTransactionsBySource(transactions),
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

  Widget _buildPaguOverview(
      double masuk, double keluar, double sisa, double persentase) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
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
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_rounded,
                  color: context.appColors.primary, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'RINGKASAN PAGU',
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            _formatCurrency(sisa),
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: context.appColors.primary,
            ),
          ),
          Text(
            'Sisa Pagu Tersedia',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral500,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ClipRRect(
            borderRadius: AppRadius.radiusSm,
            child: LinearProgressIndicator(
              value: persentase / 100,
              minHeight: 8,
              backgroundColor: AppColors.neutral200,
              valueColor: AlwaysStoppedAnimation<Color>(
                persentase > 80
                    ? AppColors.error
                    : persentase > 50
                        ? AppColors.warning
                        : context.appColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${persentase.toStringAsFixed(1)}% terpakai',
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, IconData icon) {
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
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMd
                    .copyWith(color: AppColors.neutral700, fontSize: 13)),
          ),
          Text(value,
              style: AppTextStyles.bodyMd
                  .copyWith(fontWeight: FontWeight.w900, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTransactionsBySource(List<dynamic> transactions) {
    final campusTransactions =
        transactions.where((t) => t.sumber == 'kampus').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RIWAYAT PAGU KAMPUS (${campusTransactions.length})',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (campusTransactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              child: Column(
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 48,
                      color: AppColors.neutral500.withAlpha(50)),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Belum ada transaksi pagu',
                      style: AppTextStyles.labelMd
                          .copyWith(color: AppColors.neutral500)),
                ],
              ),
            ),
          )
        else
          ...campusTransactions.take(10).map((t) {
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
                    padding: const EdgeInsets.all(AppSpacing.sm),
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
                      size: 16,
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
                        Text(t.category,
                            style: AppTextStyles.labelSm
                                .copyWith(color: AppColors.neutral500, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'} ${_formatCurrency(t.nominal)}',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: isIncome ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

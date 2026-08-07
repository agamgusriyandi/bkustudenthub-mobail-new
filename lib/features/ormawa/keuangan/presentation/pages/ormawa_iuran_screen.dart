import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () => context.read<OrmawaProvider>().refreshData(),
        child: CustomScrollView(
          slivers: [
            BkuAppBar(
              title: 'Iuran Anggota',
              subtitle: 'Rekap Pembayaran Iuran',
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
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: context.appColors.surface,
                            borderRadius: AppRadius.radiusXl,
                            border: Border.all(color: AppColors.neutral200),
                            boxShadow: [
                              BoxShadow(
                                color: context.appColors.onSurface.withAlpha(12),
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
                                  Icon(Icons.payments_rounded,
                                      color:
                                          context.appColors.primary,
                                      size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    'RINGKASAN IURAN',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.neutral600,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSummaryItem(
                                      activeMembers.toString(), 'Anggota Aktif'),
                                  _buildSummaryItem(
                                      iuranTransactions.length.toString(),
                                      'Transaksi Iuran'),
                                  _buildSummaryItem(
                                      'Rp ${(totalIuran / 1000).toStringAsFixed(0)}K',
                                      'Total Terkumpul'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'RIWAYAT IURAN',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (iuranTransactions.isEmpty)
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.all(AppSpacing.xxxl),
                              child: Column(
                                children: [
                                  Icon(Icons.payments_outlined,
                                      size: 48,
                                      color:
                                          AppColors.neutral500.withAlpha(50)),
                                  const SizedBox(height: AppSpacing.lg),
                                  Text('Belum ada iuran tercatat',
                                      style: AppTextStyles.labelMd.copyWith(
                                          color: AppColors.neutral500)),
                                ],
                              ),
                            ),
                          )
                        else
                          ...iuranTransactions.map(
                            (t) => Container(
                              margin:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
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
                                      color: AppColors.success.withAlpha(10),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.check_circle_rounded,
                                        color: AppColors.success,
                                        size: 18),
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(t.description,
                                            style: AppTextStyles.bodyMd.copyWith(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13)),
                                        Text(
                                          t.category,
                                          style: AppTextStyles.labelSm.copyWith(
                                              color: AppColors.neutral500,
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '+ Rp ${t.nominal.toStringAsFixed(0)}',
                                    style: AppTextStyles.bodyMd.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget _buildSummaryItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: AppColors.neutral800,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: AppSpacing.xs),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 10,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

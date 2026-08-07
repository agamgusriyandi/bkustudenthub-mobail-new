import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrmawaStafScreen extends StatefulWidget {
  const OrmawaStafScreen({super.key});

  @override
  State<OrmawaStafScreen> createState() => _OrmawaStafScreenState();
}

class _OrmawaStafScreenState extends State<OrmawaStafScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<OrmawaProvider>().refreshData();
    });
  }

  Color _getRoleColor(String name) {
    final n = name.toLowerCase();
    if (n.contains('ketua')) return context.appColors.primary;
    if (n.contains('wakil')) return AppColors.info;
    if (n.contains('sekretaris') || n.contains('bendahara')) {
      return context.appColors.info;
    }
    if (n.contains('kepala') || n.contains('kadiv')) return AppColors.warning;
    return AppColors.success;
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
              title: 'Staf & Jabatan',
              subtitle: 'Manajemen Peran',
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
                    final roles = provider.roles;

                    if (roles.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xxxl),
                          child: Column(
                            children: [
                              Icon(Icons.group_rounded,
                                  size: 48,
                                  color: AppColors.neutral500.withAlpha(50)),
                              const SizedBox(height: AppSpacing.lg),
                              Text('Belum ada staf',
                                  style: AppTextStyles.labelMd
                                      .copyWith(color: AppColors.neutral500)),
                            ],
                          ),
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAFTAR JABATAN (${roles.length})',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.neutral500,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ...roles.map((role) {
                          final color = _getRoleColor(role.name);
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            padding: const EdgeInsets.all(AppSpacing.lg),
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
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: color.withAlpha(15),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Icon(Icons.shield_rounded,
                                      color: color, size: 22),
                                ),
                                const SizedBox(width: AppSpacing.lg),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        role.name,
                                        style: AppTextStyles.bodyMd.copyWith(
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                      if (role.description.isNotEmpty)
                                        Text(
                                          role.description,
                                          style: AppTextStyles.labelSm
                                              .copyWith(
                                                  color: AppColors.neutral500),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs),
                                  decoration: BoxDecoration(
                                    color: AppColors.neutral100,
                                    borderRadius: AppRadius.radiusSm,
                                  ),
                                  child: Text(
                                    '${role.permissions.length} izin',
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.neutral600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
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

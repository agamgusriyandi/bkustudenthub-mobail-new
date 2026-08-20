import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_hero_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaRbacScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaRbacScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaRbacScreen> createState() => _OrmawaRbacScreenState();
}

class _OrmawaRbacScreenState extends State<OrmawaRbacScreen> {
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
              title: 'Hak Akses & Role (RBAC)',
              subtitle: 'Manajemen Otoritas Pengguna',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            Consumer<OrmawaProvider>(
              builder: (context, provider, _) {
                final roles = provider.roles;

                if (provider.isLoading && roles.isEmpty) {
                  return const SliverFillRemaining(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: BkuShimmerList(itemCount: 4, itemHeight: 90),
                    ),
                  );
                }

                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OrmawaHeroCard(
                          icon: Icons.admin_panel_settings_rounded,
                          title: '${roles.length} Role Terdaftar',
                          description: 'Kelola dan pantau izin akses sistem untuk setiap peran struktural organisasi.',
                        ),
                        SizedBox(height: 14),
                        if (roles.isEmpty)
                          const OrmawaEmptyCard(
                            title: 'Belum Ada Role',
                            description: 'Konfigurasi role dan hak akses belum tersedia.',
                            icon: Icons.admin_panel_settings_outlined,
                          )
                        else
                          ...roles.map((role) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: OrmawaCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: OrmawaTheme.primarySoft,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.shield_rounded,
                                            color: OrmawaTheme.primary,
                                            size: 20,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                role.name,
                                                style: TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: OrmawaTheme.textHeading,
                                                ),
                                              ),
                                              if (role.description.isNotEmpty) ...[
                                                SizedBox(height: 2),
                                                Text(
                                                  role.description,
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    color: OrmawaTheme.textMuted,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            '${role.permissions.length} Izin',
                                            style: TextStyle(
                                              color: OrmawaTheme.textMuted,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 9.5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (role.permissions.isNotEmpty) ...[
                                      SizedBox(height: 10),
                                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                      const SizedBox(height: 10),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: role.permissions.map((perm) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: OrmawaTheme.statusSuccessBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  color: OrmawaTheme.statusSuccessText,
                                                  size: 12,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  perm,
                                                  style: TextStyle(
                                                    color: OrmawaTheme.statusSuccessText,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
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
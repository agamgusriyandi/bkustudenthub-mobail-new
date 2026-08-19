import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaStafScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaStafScreen({super.key, this.showBackButton = true});

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
    if (n.contains('ketua')) return OrmawaTheme.primary;
    if (n.contains('wakil')) return const Color(0xFF0284C7);
    if (n.contains('sekretaris') || n.contains('bendahara')) {
      return const Color(0xFF0284C7);
    }
    if (n.contains('kepala') || n.contains('kadiv')) return const Color(0xFFD97706);
    return const Color(0xFF059669);
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
              title: 'Staf & Jabatan',
              subtitle: 'Manajemen Peran Organisasi',
              variant: AppBarVariant.ormawa,
              expandedHeight: 130.0,
              showBackButton: widget.showBackButton,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: 12,
                ),
                child: Consumer<OrmawaProvider>(
                  builder: (context, provider, _) {
                    final roles = provider.roles;

                    if (roles.isEmpty) {
                      return const OrmawaEmptyCard(
                        title: 'Belum ada jabatan',
                        description: 'Tidak ada peran atau jabatan yang terdaftar.',
                        icon: Icons.shield_outlined,
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DAFTAR JABATAN (${roles.length})',
                          style: TextStyle(
                            color: OrmawaTheme.textPlaceholder,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...roles.map((role) {
                          final color = _getRoleColor(role.name);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: OrmawaCard(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.shield_rounded,
                                      color: color,
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
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${role.permissions.length} izin',
                                      style: TextStyle(
                                        color: OrmawaTheme.textMuted,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 9.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: AppSpacing.s140),
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

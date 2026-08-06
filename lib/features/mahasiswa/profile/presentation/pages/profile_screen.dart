import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';

import '../widgets/profile_widgets.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import '../dialogs/profile_dialogs.dart';

import '../widgets/data_diri_tab.dart';
import '../widgets/akademik_tab.dart';
import '../widgets/notifikasi_tab.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<Color> _tabColors = [
    AppColors.info,
    AppColors.success,
    AppColors.info,
    AppColors.warning,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const BkuAppBar(
              title: 'Profile',
              variant: AppBarVariant.student,
              showBackButton: true,
              showNotification: true,
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    FadeInAnimation(
                      delay: 0.1,
                      child: buildRoleCard(context, profile),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabBarDelegate(
                AnimatedBuilder(
                  animation: _tabController.animation ?? _tabController,
                  builder: (context, _) {
                    final int activeIndex = _tabController.index.clamp(0, 3);
                    final Color activeColor = _tabColors[activeIndex];

                    return TabBar(
                      controller: _tabController,
                      isScrollable: false,
                      labelPadding: EdgeInsets.zero,
                      labelColor: context.appColors.onPrimary,
                      unselectedLabelColor: AppColors.neutral600,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: activeColor,
                        borderRadius: AppRadius.radiusMd,
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.withAlpha(70),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      tabs: const [
                        Tab(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_outline_rounded, size: 14),
                                SizedBox(width: AppSpacing.s3),
                                Text('Data Diri'),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.school_outlined, size: 14),
                                SizedBox(width: AppSpacing.s3),
                                Text('Akademik'),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.security_outlined, size: 14),
                                SizedBox(width: AppSpacing.s3),
                                Text('Keamanan'),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.notifications_none_rounded, size: 14),
                                SizedBox(width: AppSpacing.s3),
                                Text('Notif'),
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
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            DataDiriTabWidget(),
            AkademikTabWidget(),
            _buildKeamananTab(context, profile),
            NotifikasiTabWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeamananTab(BuildContext context, ProfileProvider profile) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        FadeInAnimation(
          delay: 0.1,
          child: buildMenuSection(
            context,
            'Keamanan Akun',
            [
              buildMenuItem(
                context,
                'Ubah Kata Sandi',
                'Perbarui password Anda secara berkala untuk perlindungan akun',
                Icons.lock_outline_rounded,
                context.appColors.info,
                () => showChangePasswordDialog(context),
              ),
            ],
            headerIcon: Icons.security_rounded,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        FadeInAnimation(
          delay: 0.2,
          child: buildLogoutButton(context),
        ),
        const SizedBox(height: AppSpacing.s120),
      ],
    );
  }
}

class _ProfileTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _ProfileTabBarDelegate(this.child);

  @override
  double get minExtent => 52.0;
  @override
  double get maxExtent => 52.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.neutral100,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppRadius.radiusLg,
          boxShadow: [
            BoxShadow(
              color: context.appColors.onSurface.withAlpha(10),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: AppSpacing.padding3,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) {
    return true;
  }
}

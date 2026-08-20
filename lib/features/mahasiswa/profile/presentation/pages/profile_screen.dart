import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import '../widgets/data_diri_tab.dart';
import '../widgets/akademik_tab.dart';
import '../widgets/keamanan_tab.dart';
import '../widgets/notifikasi_tab.dart';
import '../dialogs/avatar_upload_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadProfileData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'aktif') return const Color(0xFF059669);
    if (s == 'cuti') return const Color(0xFFD97706);
    return const Color(0xFF64748B);
  }

  Color _getStatusBg(String status) {
    final s = status.toLowerCase();
    if (s == 'aktif') return const Color(0xFFECFDF5);
    if (s == 'cuti') return const Color(0xFFFEF3C7);
    return const Color(0xFFF1F5F9);
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const BkuAppBar(
              title: 'Pengaturan Profil Akun',
              subtitle: 'Kelola informasi identitas, akademik & keamanan',
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
                      child: _buildHeroCard(context, profile),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _ProfileTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelPadding: EdgeInsets.zero,
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: BkuTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x20F97316),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  tabs: const [
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_outline_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Data Diri'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 14),
                          SizedBox(width: 4),
                          Text('Akademik'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security_outlined, size: 14),
                          SizedBox(width: 4),
                          Text('Keamanan'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 38,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_none_rounded, size: 14),
                          SizedBox(width: 4),
                          Text('Notifikasi'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: const [
            DataDiriTabWidget(),
            AkademikTabWidget(),
            KeamananTabWidget(),
            NotifikasiTabWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, ProfileProvider profile) {
    final statusColor = _getStatusColor(profile.statusAkademik);
    final statusBg = _getStatusBg(profile.statusAkademik);
    final photo = profile.fotoUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => AvatarUploadSheet.show(context),
                child: Stack(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                      ),
                      child: ClipOval(
                        child: photo != null && photo.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ApiGate.getImageUrl(photo),
                                fit: BoxFit.cover,
                                placeholder: (_, __) => const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.account_circle,
                                  size: 48,
                                  color: Color(0xFFCBD5E1),
                                ),
                              )
                            : const Icon(
                                Icons.account_circle,
                                size: 48,
                                color: Color(0xFFCBD5E1),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: BkuTheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name : 'Mahasiswa BKU',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withAlpha(60)),
                          ),
                          child: Text(
                            profile.statusAkademik,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.badge_rounded, size: 14, color: Color(0xFF2563EB)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'NIM: ${profile.nim.isNotEmpty ? profile.nim : '-'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeroStatItem(
                    icon: Icons.school_rounded,
                    label: 'Program Studi',
                    value: profile.prodi.isNotEmpty ? profile.prodi : '-',
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: _buildHeroStatItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Angkatan',
                    value: profile.intakeYear.isNotEmpty ? profile.intakeYear : '-',
                  ),
                ),
                Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                Expanded(
                  child: _buildHeroStatItem(
                    icon: Icons.timeline_rounded,
                    label: 'Semester',
                    value: profile.semester > 0 ? '${profile.semester} • Aktif' : '-',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFFD97706)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Data akademik terintegrasi otomatis dari sistem BKU dan bersifat read-only.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 11, color: const Color(0xFF94A3B8)),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: BkuTheme.scaffoldBg,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(_ProfileTabBarDelegate oldDelegate) => true;
}
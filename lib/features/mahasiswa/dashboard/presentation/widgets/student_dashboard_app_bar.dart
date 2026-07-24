import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';

class StudentDashboardAppBar extends StatelessWidget {
  final String name;

  const StudentDashboardAppBar({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final topPadding = MediaQuery.of(context).padding.top;
    const expandedHeight = 240.0; // Increased for more premium space

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      elevation: 0,
      stretch: false,
      backgroundColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double percentage =
              (constraints.biggest.height - (kToolbarHeight + topPadding)) /
              (expandedHeight - (kToolbarHeight + topPadding));

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  themeProvider.colors.gradientStart,
                  themeProvider.colors.gradientMiddle,
                  themeProvider.colors.gradientEnd,
                ],
              ),
            ),
            child: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                children: [
                  // Collapsed Header (Visible when scrolled)
                  Positioned(
                    top: topPadding,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: percentage < 0.2 ? 1.0 : 0.0,
                      child: Container(
                        height: kToolbarHeight,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(30),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  name,
                                  style: AppTextStyles.labelMd.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Decorative elements for premium look
                  Positioned(
                    top: -30,
                    right: -30,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: topPadding + 15,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: percentage < 0.3 ? 0.0 : 1.0,
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: AppRadius.radiusLg,
                              border: Border.all(
                                color: Colors.white.withAlpha(20),
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Selamat Datang Kembali,',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  name,
                                  style: AppTextStyles.titleLg.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: AppRadius.radiusLg,
                            ),
                            child: const Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 45, // Adjusted for new height
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      opacity: percentage < 0.3 ? 0.0 : 1.0,
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: AppRadius.radiusLg,
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: Colors.white60,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Cari info akademik atau layanan...',
                              style: AppTextStyles.labelSm.copyWith(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

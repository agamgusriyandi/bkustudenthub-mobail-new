import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';

class StudentAppBar extends StatelessWidget {
  final String title;
  final String? label;
  final double expandedHeight;
  final List<Widget>? actions;
  final Widget? leading;
  final bool pinned;

  const StudentAppBar({
    super.key,
    required this.title,
    this.label,
    this.expandedHeight = 200.0,
    this.actions,
    this.leading,
    this.pinned = true,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = context.watch<ThemeProvider>();
    final gradientColors = themeProvider.primaryGradient;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: IconThemeData(color: context.appColors.onPrimary),
      leading: leading,
      centerTitle: true,
      actions: [if (actions != null) ...actions!, const SizedBox(width: AppSpacing.sm)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(
          height: 20,
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xxl),
              topRight: Radius.circular(AppRadius.xxl),
            ),
          ),
        ),
      ),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double percentage =
              (constraints.biggest.height - (kToolbarHeight + topPadding)) /
              (expandedHeight - (kToolbarHeight + topPadding));
          final bool isCollapsed = percentage <= 0.1;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
            ),
            child: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              centerTitle: true,
              titlePadding: EdgeInsets.zero,
              title: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isCollapsed ? 1.0 : 0.0,
                child: Container(
                  height: kToolbarHeight,
                  alignment: Alignment.center,
                  child: Text(
                    title,
                    style: AppTextStyles.titleLg.copyWith(
                      color: context.appColors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              background: Stack(
                children: [
                  // Decorative elements for premium look
                  Positioned(
                    top: -20,
                    right: -20,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: context.appColors.surface.withAlpha(10),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: -10,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: context.appColors.surface.withAlpha(5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Content
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(top: topPadding, bottom: AppSpacing.s20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (label != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: context.appColors.surface.withAlpha(30),
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(
                                  color: context.appColors.surface.withAlpha(20),
                                ),
                              ),
                              child: Text(
                                label!.toUpperCase(),
                                style: AppTextStyles.labelSm.copyWith(
                                  color: context.appColors.onPrimary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.s10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xxxl,
                            ),
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleLg.copyWith(
                                color: context.appColors.onPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
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

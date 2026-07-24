import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';

/// AppBarVariant - Defines the visual variant for the app bar
enum AppBarVariant {
  primary, // Default blue gradient (Student, Ormawa)
  secondary, // Gold/amber gradient (Alternative variant)
  tertiary, // Teal/green gradient (Success variant)
  custom, // Custom gradient provided via parameters
}

/// NavItem - Navigation item for bottom nav bar
class NavItem {
  final int index;
  final IconData icon;
  final String label;

  const NavItem({required this.index, required this.icon, required this.label});
}

/// UnifiedAppBar - Single AppBar component for all roles
///
/// Uses ThemeProvider to get dynamic colors from backend API.
/// Replaces multiple app bar variants (StudentAppBar, OrmawaAppBar, etc.)
class UnifiedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? info;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? profileImage;
  final double expandedHeight;
  final bool pinned;
  final bool showBackButton;
  final bool showNotification;
  final bool showProfileOnCollapse;
  final bool isExpandable;
  final int notificationCount;
  final AppBarVariant variant;
  final List<Color>? customGradientColors;
  final VoidCallback? onBack;
  final VoidCallback? onProfileTap;
  final void Function(BuildContext, AppBarVariant)? onNotificationTap;

  const UnifiedAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.info,
    this.actions,
    this.leading,
    this.profileImage,
    this.expandedHeight = 200.0,
    this.pinned = true,
    this.showBackButton = false,
    this.showNotification = true,
    this.showProfileOnCollapse = false,
    this.isExpandable = true,
    this.notificationCount = 0,
    this.variant = AppBarVariant.primary,
    this.customGradientColors,
    this.onBack,
    this.onProfileTap,
    this.onNotificationTap,
  });

  static void Function(BuildContext, AppBarVariant)? defaultOnNotificationTap;

  @override
  Size get preferredSize =>
      Size.fromHeight(isExpandable ? expandedHeight + 20 : 100);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = context.watch<ThemeProvider>();

    // Get gradient colors from theme provider
    List<Color> gradientColors = _getGradientColors(themeProvider);

    // Fixed AppBar (non-expandable)
    if (!isExpandable) {
      return SliverAppBar(
        pinned: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading:
            leading ??
            (showBackButton
                ? IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                )
                : null),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(left: showBackButton ? 0 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              if (info != null)
                Text(
                  info!,
                  style: TextStyle(
                    color: Colors.white.withAlpha(160),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
            ],
          ),
        ),
        actions: [
          if (actions != null) ...actions!,
          if (showNotification)
            IconButton(
              onPressed: () {
                if (onNotificationTap != null) {
                  onNotificationTap!(context, variant);
                } else if (defaultOnNotificationTap != null) {
                  defaultOnNotificationTap!(context, variant);
                }
              },
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          const SizedBox(width: 8),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.1,
                    child: Image.asset(
                      'assets/images/batik_pattern.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Expandable AppBar (for dashboard)
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      stretch: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading:
          leading ??
          (showBackButton
              ? IconButton(
                onPressed: onBack ?? () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              )
              : null),
      actions: [
        if (actions != null) ...actions!,
        if (showNotification)
          Padding(
            padding: EdgeInsets.only(bottom: showProfileOnCollapse ? 8 : 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    if (onNotificationTap != null) {
                      onNotificationTap!(context, variant);
                    } else if (defaultOnNotificationTap != null) {
                      defaultOnNotificationTap!(context, variant);
                    }
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  tooltip: 'Notifikasi',
                ),
                if (notificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        notificationCount > 9 ? '9+' : '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(32),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/batik_pattern.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              LayoutBuilder(
          builder: (context, constraints) {
            final double currentHeight = constraints.biggest.height;
            final double toolbarBaseHeight = kToolbarHeight + topPadding;
            final double percentage =
                (currentHeight - toolbarBaseHeight) /
                (expandedHeight - toolbarBaseHeight);
            final bool isCollapsed = percentage <= 0.4;

            return FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.zero,
              title: IgnorePointer(
                ignoring: !isCollapsed,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isCollapsed ? 1.0 : 0.0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: showBackButton ? 72 : 20,
                      bottom: 20,
                    ),
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showProfileOnCollapse && profileImage != null) ...[
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withAlpha(80),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(30),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: AppRadius.radiusLg,
                              child: profileImage!,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              if (info != null && showProfileOnCollapse)
                                Text(
                                  info!,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(160),
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              background: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(10),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(8),
                      ),
                    ),
                  ),
                  // Expanded content
                  Opacity(
                    opacity: (percentage * 2.5).clamp(0.0, 1.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding + 20,
                            bottom: 20,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: onProfileTap,
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    if (profileImage != null) ...[
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withAlpha(100),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(40),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                          child: profileImage!,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          if (info != null) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              info!,
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(
                                                  180,
                                                ),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    ),
  ),
),
    );
  }

  List<Color> _getGradientColors(ThemeProvider themeProvider) {
    // Custom gradient takes priority
    if (customGradientColors != null && customGradientColors!.isNotEmpty) {
      return customGradientColors!;
    }

    // Get from theme provider based on variant
    switch (variant) {
      case AppBarVariant.primary:
        return themeProvider.primaryGradient;
      case AppBarVariant.secondary:
        return themeProvider.secondaryGradient;
      case AppBarVariant.tertiary:
        return [
          themeProvider.tertiary,
          themeProvider.tertiaryContainer,
          const Color(0xFF3DBE6E), // onTertiaryContainer
        ];
      case AppBarVariant.custom:
        return themeProvider.primaryGradient;
    }
  }
}

/// UnifiedStaticAppBar - Non-expandable app bar version
class UnifiedStaticAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showNotification;
  final AppBarVariant variant;
  final VoidCallback? onBack;
  final void Function(BuildContext, AppBarVariant)? onNotificationTap;

  const UnifiedStaticAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.showNotification = true,
    this.variant = AppBarVariant.primary,
    this.onBack,
    this.onNotificationTap,
  });

  static void Function(BuildContext, AppBarVariant)? defaultOnNotificationTap;

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final gradientColors = _getGradientColors(themeProvider);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24, top: 8),
          child: Row(
            children: [
              if (showBackButton)
                IconButton(
                  onPressed: onBack ?? () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              else
                const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              if (actions != null) ...actions!,
              if (showNotification)
                IconButton(
                  onPressed: () {
                    if (onNotificationTap != null) {
                      onNotificationTap!(context, variant);
                    } else if (defaultOnNotificationTap != null) {
                      defaultOnNotificationTap!(context, variant);
                    }
                  },
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors(ThemeProvider themeProvider) {
    switch (variant) {
      case AppBarVariant.primary:
        return themeProvider.primaryGradient;
      case AppBarVariant.secondary:
        return themeProvider.secondaryGradient;
      case AppBarVariant.tertiary:
        return [
          themeProvider.tertiary,
          themeProvider.tertiaryContainer,
          const Color(0xFF3DBE6E),
        ];
      case AppBarVariant.custom:
        return themeProvider.primaryGradient;
    }
  }
}

import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/providers/navigation_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/services/notification_service.dart';
import 'package:go_router/go_router.dart';

void performSafeBack(BuildContext context, VoidCallback? onBack) {
  if (onBack != null) {
    try {
      onBack();
      return;
    } catch (_) {}
  }
  if (context.canPop()) {
    context.pop();
  } else if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    try {
      context.read<NavigationProvider>().setIndex(0);
    } catch (_) {
      context.go('/');
    }
  }
}

enum AppBarVariant { student, ormawa, secondary, psychologist, nakes }

class BkuAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final double expandedHeight;
  final bool pinned;
  final AppBarVariant variant;
  final bool? showBackButton;
  final VoidCallback? onBack;
  final Widget? child;
  final Widget? bottomChild;
  final bool showNotification;
  final Widget? profileImage;
  final bool showProfileOnCollapse;
  final bool isExpandable;
  final String? info;
  final int notificationCount;

  final void Function(BuildContext, AppBarVariant)? onNotificationTap;
  final VoidCallback? onProfileTap;
  static void Function(BuildContext, AppBarVariant)? defaultOnNotificationTap;

  const BkuAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.info,
    this.actions,
    this.leading,
    this.expandedHeight = 200.0,
    this.pinned = true,
    this.variant = AppBarVariant.student,
    this.showBackButton,
    this.onBack,
    this.child,
    this.bottomChild,
    this.showNotification = true,
    this.profileImage,
    this.showProfileOnCollapse = false,
    this.isExpandable = true,
    this.onNotificationTap,
    this.onProfileTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final themeProvider = context.watch<ThemeProvider>();
    final List<Color> gradientColors = _getGradientColors(context);
    final Color onColor =
        variant == AppBarVariant.secondary
            ? themeProvider.onSecondary
            : themeProvider.onPrimary;
    // SETAN DUMMY UNTUK TESTING VISUAL (Ganti ke 0 jika ingin menggunakan data asli dari database/server)
    final int mockCountForTesting = 0;
    final int dynamicNotificationCount =
        mockCountForTesting > 0
            ? mockCountForTesting
            : (variant == AppBarVariant.student ||
                    variant == AppBarVariant.secondary
                ? (showNotification
                    ? context.watch<NotificationService>().unreadCount
                    : 0)
                : notificationCount);

    // Jalur 1: FIXED APP BAR (Untuk Halaman Selain Dashboard)
    if (!isExpandable) {
      return SliverAppBar(
        pinned: true,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading:
            leading ??
            ((showBackButton ?? (onBack != null || context.canPop() || Navigator.canPop(context)))
                ? IconButton(
                  onPressed: () => performSafeBack(context, onBack),
                  icon: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: onColor,
                  ),
                )
                : null),
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(
            left: (showBackButton ?? context.canPop()) ? 0 : AppSpacing.s20,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: AppTextStyles.titleLg.copyWith(
                          color: onColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    if (info != null || subtitle != null)
                      Text(
                        info ?? subtitle!,
                        style: AppTextStyles.labelSm.copyWith(
                          color: onColor.withAlpha(160),
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
        actions: [
          if (actions != null) ...actions!,
          if (showNotification)
            Stack(
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
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: onColor,
                    size: 24,
                  ),
                ),
                if (dynamicNotificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.error,
                        borderRadius: AppRadius.br10, // Pill shape agar muat 2-3 digit
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        dynamicNotificationCount > 99
                            ? '99+'
                            : '$dynamicNotificationCount',
                        style: TextStyle(
                          color: context.appColors.onPrimary,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
        flexibleSpace: IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: kToolbarHeight + topPadding,
            decoration: BoxDecoration(
              color: gradientColors[1],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xxl),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/batik_pattern.png'),
                            repeat: ImageRepeat.repeat,
                            scale: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    }

    // Jalur 2: EXPANDABLE APP BAR (Untuk Dashboard)
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      stretch: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading:
          leading ??
          ((showBackButton ?? (onBack != null || context.canPop() || Navigator.canPop(context)))
              ? IconButton(
                onPressed: () => performSafeBack(context, onBack),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: onColor,
                ),
              )
              : null),
      actions: [
        if (actions != null)
          ...actions!.map(
            (action) => Padding(
              padding: EdgeInsets.only(bottom: showProfileOnCollapse ? AppSpacing.sm : AppSpacing.xs),
              child: action,
            ),
          ),
        if (showNotification)
          Padding(
            padding: EdgeInsets.only(bottom: showProfileOnCollapse ? AppSpacing.sm : AppSpacing.xs),
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
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 24,
                    color: onColor,
                  ),
                  tooltip: 'Notifikasi',
                ),
                if (dynamicNotificationCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.error,
                        borderRadius: AppRadius.br10, // Pill shape agar muat 2-3 digit
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        dynamicNotificationCount > 99
                            ? '99+'
                            : '$dynamicNotificationCount',
                        style: TextStyle(
                          color: context.appColors.onPrimary,
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
        const SizedBox(width: AppSpacing.md),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double currentHeight = constraints.biggest.height;
          final double toolbarBaseHeight = kToolbarHeight + topPadding;
          final double percentage =
              (currentHeight - toolbarBaseHeight) /
              (expandedHeight - toolbarBaseHeight);
          final bool isCollapsed = percentage <= 0.4;

          return Container(
            decoration: BoxDecoration(
              color: gradientColors[1],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xxl),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xxl),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/batik_pattern.png'),
                            repeat: ImageRepeat.repeat,
                            scale: 4.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FlexibleSpaceBar(
                    expandedTitleScale: 1.0,
                    centerTitle: false,
                    titlePadding: EdgeInsets.zero,
                    title: IgnorePointer(
                      ignoring: !isCollapsed,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isCollapsed ? 1.0 : 0.0,
                        child: Container(
                          padding: EdgeInsets.only(
                            left: (showBackButton ?? true) ? 72 : AppSpacing.s20,
                            bottom: AppSpacing.s20,
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
                                      color: onColor.withAlpha(80),
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
                                  child: ClipOval(
                                    child: SizedBox.expand(child: profileImage!),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        title,
                                        style: AppTextStyles.titleLg.copyWith(
                                          color: onColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                    ),
                                    if (info != null && showProfileOnCollapse)
                                      Text(
                                        info!,
                                        style: AppTextStyles.labelSm.copyWith(
                                          color: onColor.withAlpha(160),
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
                  // Dekorasi Lingkaran
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: onColor.withAlpha(10),
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
                        color: onColor.withAlpha(8),
                      ),
                    ),
                  ),
                  // Konten Expanded
                  Opacity(
                    opacity: (percentage * 2.5).clamp(0.0, 1.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: topPadding + AppSpacing.s10,
                            bottom: AppSpacing.md,
                            left: AppSpacing.s18,
                            right: AppSpacing.s18,
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
                                            color: onColor.withAlpha(100),
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
                                      const SizedBox(width: AppSpacing.lg),
                                    ],
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (subtitle != null) ...[
                                            Text(
                                              subtitle!,
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: onColor.withAlpha(
                                                      190,
                                                    ),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w800,
                                                    letterSpacing: 0.8,
                                                  ),
                                            ),
                                            const SizedBox(height: AppSpacing.s2),
                                          ],
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              title,
                                              style: AppTextStyles.titleLg
                                                  .copyWith(
                                                    color: onColor,
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.w900,
                                                    letterSpacing: -0.5,
                                                  ),
                                            ),
                                          ),
                                          if (info != null) ...[
                                            const SizedBox(height: AppSpacing.s2),
                                            Text(
                                              info!,
                                              style: AppTextStyles.labelSm
                                                  .copyWith(
                                                    color: onColor.withAlpha(
                                                      180,
                                                    ),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    letterSpacing: 0.3,
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    // ── child widget (e.g. AvailabilityToggle) moved to right ──
                                    if (child != null) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      child!,
                                    ],
                                  ],
                                ),
                              ),
                              if (bottomChild != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                bottomChild!,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

  List<Color> _getGradientColors(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    switch (variant) {
      case AppBarVariant.student:
        return themeProvider.primaryGradient;
      case AppBarVariant.ormawa:
        return themeProvider.primaryGradient;
      case AppBarVariant.secondary:
        return themeProvider.secondaryGradient;
      case AppBarVariant.psychologist:
        return themeProvider.primaryGradient;
      case AppBarVariant.nakes:
        return themeProvider.primaryGradient;
    }
  }
}

class BkuStaticAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final String? info;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;
  final AppBarVariant variant;
  final bool showNotification;

  const BkuStaticAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.info,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.variant = AppBarVariant.student,
    this.showNotification = true,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final List<Color> gradientColors = _getGradientColors(context);
    final Color onColor =
        variant == AppBarVariant.secondary
            ? themeProvider.onSecondary
            : themeProvider.onPrimary;
    final resolvedSubtitle = subtitle ?? info;

    return Container(
      decoration: BoxDecoration(
        color: gradientColors[1],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl)),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.xxl)),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/batik_pattern.png'),
                      repeat: ImageRepeat.repeat,
                      scale: 4.0,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md, top: AppSpacing.xs),
                child: Row(
                  children: [
                    if (showBackButton)
                      IconButton(
                        onPressed: () => performSafeBack(context, onBack),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: onColor,
                          size: 20,
                        ),
                      )
                    else
                      const SizedBox(width: AppSpacing.s48),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.titleLg.copyWith(
                              color: onColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: -0.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (resolvedSubtitle != null)
                            Text(
                              resolvedSubtitle,
                              style: AppTextStyles.labelSm.copyWith(
                                color: onColor.withAlpha(160),
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ),
                    if (actions != null) ...actions!,
                    if (variant == AppBarVariant.nakes && showNotification) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Consumer<NotificationService>(
                        builder: (context, notifService, _) {
                          final count = notifService.unreadCount;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed:
                                    () => context.push('/notifications/tk'),
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  size: 24,
                                  color: onColor,
                                ),
                                tooltip: 'Notifikasi',
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.appColors.error,
                                      borderRadius: AppRadius.radiusMd,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      count > 99 ? '99+' : '$count',
                        style: TextStyle(
                           color: context.appColors.onPrimary,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                    const SizedBox(width: AppSpacing.md),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    switch (variant) {
      case AppBarVariant.student:
        return themeProvider.primaryGradient;
      case AppBarVariant.ormawa:
        return themeProvider.primaryGradient;
      case AppBarVariant.secondary:
        return themeProvider.secondaryGradient;
      case AppBarVariant.psychologist:
        return themeProvider.primaryGradient;
      case AppBarVariant.nakes:
        return themeProvider.primaryGradient;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}

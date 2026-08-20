import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    _checkSessionAndNavigate();
  }

  Future<void> _checkSessionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final upgrader = Upgrader(
        durationUntilAlertAgain: const Duration(seconds: 0),
      );
      await upgrader.initialize();

      if (upgrader.isUpdateAvailable()) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => PopScope(
            canPop: false,
            child: BkuDialog(
              title: 'Update Diperlukan',
              message:
                  'Versi terbaru BKU Student HUB telah tersedia. Silakan lakukan pembaruan aplikasi untuk menikmati fitur terbaru dan pengalaman yang lebih stabil.',
              type: BkuDialogType.warning,
              customImageAsset: 'assets/images/update.png',
              primaryButtonText: 'Update Sekarang',
              onPrimaryPressed: () async {
                final url = Uri.parse('https://play.google.com/store/apps/details?id=com.bkustudenthub.app');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {
                  upgrader.sendUserToAppStore();
                }
              },
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }

    final authService = AuthService();
    await authService.loadSession();

    if (!mounted) return;

    if (authService.token != null &&
        authService.currentRole != UserRole.guest) {
      if (authService.currentRole == UserRole.ormawa) {
        context.go(AppRoutes.ormawaMain);
      } else if (authService.currentRole == UserRole.psychologist) {
        context.go(AppRoutes.psychologistMain);
      } else if (authService.currentRole == UserRole.tenagaKesehatan) {
        context.go(AppRoutes.tkMain);
      } else if (authService.currentRole == UserRole.mentorKencana) {
        context.go(AppRoutes.mentorKencanaMain);
      } else {
        context.go(AppRoutes.studentMain);
      }
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final themeColors = themeProvider.colors;
    final splashLogo = themeColors.splashLogoUrl ?? themeColors.logoUrl;
    final primaryColor = themeProvider.primary;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Semantics(
              excludeSemantics: true,
              child: Image.asset(
                'assets/images/gedung.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
                cacheWidth: 800,
              ),
            ),
          ),
          Positioned.fill(
            child: ColoredBox(
              color: primaryColor.withValues(alpha: 0.85),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 36,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Semantics(
                      excludeSemantics: true,
                      child: splashLogo != null && splashLogo.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: ApiGate.getImageUrl(splashLogo),
                              width: 130,
                              height: 130,
                              fit: BoxFit.contain,
                              errorWidget: (_, __, ___) => Image.asset(
                                'assets/images/icons.png',
                                width: 130,
                                height: 130,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Image.asset(
                              'assets/images/icons.png',
                              width: 130,
                              height: 130,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _opacityAnimation.value,
                      child: child,
                    );
                  },
                  child: Column(
                    children: [
                      Text(
                        'BKU Student HUB',
                        style: BkuTheme.textPageTitle.copyWith(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Smart Campus Ecosystem',
                        style: BkuTheme.textCardSubtitle.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          letterSpacing: 0.8,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Version 1.0.5',
                    style: BkuTheme.textCaption.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
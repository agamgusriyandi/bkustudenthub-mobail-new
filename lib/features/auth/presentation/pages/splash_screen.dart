import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';
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
      begin: 0.8,
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
                } catch (e) {
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
      // Session exists, go to correct main screen
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
      // No session, go to login
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
    final Color activeColor = themeProvider.colors.primary;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Background Image
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
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    activeColor.withAlpha(140),
                    activeColor.withAlpha(217),
                  ],
                ),
              ),
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
                    padding: AppSpacing.paddingXl,
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xxl + 8),
                      boxShadow: [
                        BoxShadow(
                          color: context.appColors.onSurface.withValues(alpha: 0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: Semantics(
                      excludeSemantics: true,
                      child: Image.asset(
                        'assets/images/icons.png',
                        width: 160,
                        height: 160,
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
                        style: AppTextStyles.displayMedium.copyWith(
                          color: context.appColors.onPrimary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              color: context.appColors.onSurface.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Smart Campus Ecosystem',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: context.appColors.onPrimary.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          shadows: [
                            Shadow(
                              color: context.appColors.onSurface.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Version or Info
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(context.appColors.onPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Version 1.0.5',
                    style: AppTextStyles.labelSm.copyWith(
                          color: context.appColors.onPrimary.withValues(alpha: 0.8),
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

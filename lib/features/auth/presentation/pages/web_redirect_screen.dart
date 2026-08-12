import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';

class WebRedirectScreen extends StatelessWidget {
  const WebRedirectScreen({super.key});

  Future<void> _launchWebsite(BuildContext context) async {
    final Uri url = Uri.parse('https://bkustudenthub.com/login');
    try {
      if (!await launchUrl(url, mode: LaunchMode.inAppBrowserView)) {
        if (context.mounted) {
          AppSnackbar.showError(context, 'Tidak dapat membuka tautan website.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          'Terjadi kesalahan saat membuka browser.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.neutral900,
          ),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
              const Spacer(flex: 2),
              FadeInAnimation(
                delay: 0.2,
                child: Center(
                  child: Image.asset(
                    'assets/images/web_redirect_illustration.png',
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              FadeInAnimation(
                delay: 0.4,
                child: Text(
                  'Akses Aplikasi Terbatas',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeInAnimation(
                delay: 0.6,
                child: Text(
                  'Aplikasi mobile BKU Student HUB saat ini dikhususkan untuk Mahasiswa, Psikolog, dan Tenaga Medis.\n\nBagi peran lain (seperti Admin, Ormawa, Dosen, dll), mohon untuk mengakses dashboard dan layanan melalui portal website resmi kami.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral500,
                    height: 1.5,
                  ),
                ),
              ),
              const Spacer(flex: 3),
              FadeInAnimation(
                delay: 0.8,
                child: BkuButton.primary(
                  text: 'Buka Website Sekarang',
                  icon: Icons.language_rounded,
                  onPressed: () => _launchWebsite(context),
                  fullWidth: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeInAnimation(
                delay: 0.9,
                child: BkuButton.text(
                  text: 'Kembali ke Halaman Login',
                  onPressed: () => context.go(AppRoutes.login),
                  fullWidth: true,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}

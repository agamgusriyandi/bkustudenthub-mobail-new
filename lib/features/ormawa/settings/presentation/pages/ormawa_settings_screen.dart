import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/coming_soon_screen.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';

class OrmawaSettingsScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaSettingsScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaSettingsScreen> createState() => _OrmawaSettingsScreenState();
}

class _OrmawaSettingsScreenState extends State<OrmawaSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrmawaProvider>().getOrmawaSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                variant: AppBarVariant.ormawa,
                title: 'Pengaturan Portal',
                subtitle: 'Konfigurasi Sistem',
                expandedHeight: 130.0,
                showBackButton: widget.showBackButton,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildSectionHeader('AKUN SAYA'),
                    _buildSettingTile(
                      Icons.person_rounded,
                      'Profil Pribadi',
                      'Info & kontak saya',
                      context.appColors.info,
                      () => context.push(AppRoutes.ormawaProfile),
                    ),

                    if (provider.hasPermission('ADMIN_PANEL') ||
                        provider.hasPermission('MANAGE_ORG')) ...[
                      const SizedBox(height: AppSpacing.md),
                      _buildSectionHeader('MANAJEMEN ORGANISASI'),
                      _buildSettingTile(
                        Icons.storefront_rounded,
                        'Profil Organisasi',
                        'Nama, Logo, Visi & Misi',
                        AppColors.info,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const ComingSoonScreen(
                                  featureName: 'Profil Organisasi',
                                ),
                          ),
                        ),
                      ),
                      _buildSettingTile(
                        Icons.account_tree_rounded,
                        'Struktur Organisasi',
                        'Bagan & hierarki divisi',
                        context.appColors.info,
                        () => context.push(AppRoutes.ormawaStruktur),
                      ),
                    ],

                    () {
                      final canViewRecruitment =
                          provider.hasPermission('view_recruitment') ||
                          provider.hasPermission('manage_recruitment') ||
                          provider.hasPermission('manage_staff');
                      final canViewAspirations =
                          provider.hasPermission('view_aspirations') ||
                          provider.hasPermission('respond_aspirations');

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (canViewRecruitment || canViewAspirations) ...[
                            const SizedBox(height: AppSpacing.md),
                            _buildSectionHeader('LAYANAN & MODUL'),
                            if (canViewRecruitment)
                              _buildSettingTile(
                                Icons.person_add_rounded,
                                'Open Recruitment',
                                'Kelola pendaftaran anggota',
                                context.appColors.info,
                                () => context.push(AppRoutes.ormawaRecruitment),
                              ),
                            if (canViewAspirations)
                              _buildSettingTile(
                                Icons.chat_bubble_outline_rounded,
                                'Daftar Aspirasi',
                                'Kelola keluhan & saran',
                                context.appColors.error,
                                () => context.push(AppRoutes.ormawaAspirasi),
                              ),
                          ],
                        ],
                      );
                    }(),

                    const SizedBox(height: AppSpacing.md),
                    _buildSectionHeader('KEAMANAN & AKSES'),
                    _buildSettingTile(
                      Icons.security_rounded,
                      'Keamanan Akun',
                      'Password & Autentikasi',
                      AppColors.success,
                      () => context.push(AppRoutes.ormawaSecurity),
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                    _buildLogoutButton(),
                    const SizedBox(height: AppSpacing.s140),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.sm,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Text(
        title,
        style: AppTextStyles.overline.copyWith(color: AppColors.neutral500),
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: AppRadius.radiusLg,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title, style: AppTextStyles.titleMd),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.neutral400,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.appColors.error.withAlpha(10),
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: context.appColors.error.withAlpha(50),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            leading: Container(
              padding: AppSpacing.padding9,
              decoration: BoxDecoration(
                color: context.appColors.error.withAlpha(20),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: context.appColors.error,
                size: 20,
              ),
            ),
            title: Text(
              'Keluar Portal',
              style: TextStyle(
                color: context.appColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Anda akan keluar dari sesi administrasi',
              style: AppTextStyles.labelSm.copyWith(
                color: context.appColors.error.withAlpha(150),
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: context.appColors.error,
            ),
            onTap: () => _showLogoutDialog(),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            contentPadding: AppSpacing.padding28,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.appColors.errorContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: context.appColors.error,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AppSpacing.s20),
                Text(
                  'Keluar Portal?',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),
                Text(
                  'Sesi administrasi Anda akan diakhiri. Pastikan semua data laporan sudah tersimpan.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: context.appColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),

                        child: Text(
                          'Batal',
                          style: AppTextStyles.labelLg.copyWith(
                            color: context.appColors.onSurface,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await AuthService().logout();
                          if (mounted) {
                            context.go(AppRoutes.login);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.appColors.error,
                          foregroundColor: context.appColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMd,
                          ),
                        ),
                        child: Text(
                          'Keluar',
                          style: AppTextStyles.labelLg.copyWith(
                            fontWeight: FontWeight.w600,
                            color: context.appColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

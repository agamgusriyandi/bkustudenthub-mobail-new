import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_settings_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/settings/presentation/pages/ormawa_security_screen.dart';

class OrmawaProfileScreen extends StatefulWidget {
  final bool showBackButton;
  const OrmawaProfileScreen({super.key, this.showBackButton = true});

  @override
  State<OrmawaProfileScreen> createState() => _OrmawaProfileScreenState();
}

class _OrmawaProfileScreenState extends State<OrmawaProfileScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    final ormawaProvider = context.read<OrmawaProvider>();

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Potong Foto Profil',
              toolbarColor: OrmawaTheme.primaryDark,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Potong Foto Profil',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
            ),
          ],
        );

        if (croppedFile != null) {
          if (!mounted) return;
          setState(() => _isUploadingAvatar = true);
          await AuthService().uploadAvatar(croppedFile.path);
          if (!mounted) return;
          await ormawaProvider.refreshData();
          if (!mounted) return;
          AppSnackbar.showSuccess(context, 'Foto profil berhasil diperbarui');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, 'Gagal mengunggah foto');
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingAvatar = false);
        }
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    BkuDialog.show(
      context: context,
      title: 'Keluar Portal Ormawa?',
      message: 'Sesi administrasi Anda akan diakhiri.',
      type: BkuDialogType.error,
      primaryButtonText: 'Keluar',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        await AuthService().logout();
        if (context.mounted) {
          context.go(AppRoutes.login);
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final member = provider.currentMember;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              BkuAppBar(
                variant: AppBarVariant.ormawa,
                title: 'Profil Saya',
                subtitle: 'Data Pribadi & Akun Pengurus',
                expandedHeight: 125.0,
                showBackButton: widget.showBackButton,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child: member != null
                    ? _buildProfileContent(context, member, provider)
                    : _buildEmptyState(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    OrmawaMember member,
    OrmawaProvider provider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OrmawaCard(
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: OrmawaTheme.primarySoft,
                        border: Border.all(
                          color: OrmawaTheme.primaryBorder,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ApiGate.getImageUrl(member.fotoUrl!),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Icon(
                                    Icons.person_rounded,
                                    size: 36,
                                    color: OrmawaTheme.primary,
                                  );
                                },
                                placeholder: (context, url) =>
                                    Container(color: const Color(0xFFF1F5F9)),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: OrmawaTheme.primary,
                              ),
                      ),
                    ),
                    if (!_isUploadingAvatar)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: BkuBounceButton(
                          onTap: _pickAndUploadAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: OrmawaTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                              boxShadow: OrmawaTheme.cardShadow,
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    if (_isUploadingAvatar)
                      const Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: BkuShimmerList(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: OrmawaTheme.textCardTitle.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member.role} • ${provider.orgName}',
                        style: OrmawaTheme.textCardSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          OrmawaBadge(
                            text: 'NIM: ${member.nim}',
                            variant: OrmawaBadgeVariant.neutral,
                            icon: Icons.badge_outlined,
                          ),
                          OrmawaBadge(
                            text: member.status.toUpperCase(),
                            variant: member.status.toLowerCase() == 'aktif'
                                ? OrmawaBadgeVariant.success
                                : OrmawaBadgeVariant.warning,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            'Informasi Keanggotaan',
            [
              _buildMenuItem(
                'Jabatan / Peran',
                member.role,
                Icons.badge_rounded,
                OrmawaTheme.primary,
              ),
              _buildMenuItem(
                'Divisi / Departemen',
                member.division.isEmpty ? 'Umum' : member.division,
                Icons.group_work_rounded,
                const Color(0xFF0284C7),
              ),
              _buildMenuItem(
                'Organisasi',
                provider.orgName,
                Icons.account_balance_rounded,
                const Color(0xFF7C3AED),
              ),
              if (member.periode != null && member.periode!.isNotEmpty)
                _buildMenuItem(
                  'Periode Kepengurusan',
                  member.periode!,
                  Icons.date_range_rounded,
                  const Color(0xFF059669),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            'Kontak & Komunikasi',
            [
              _buildMenuItem(
                'Email Kampus',
                member.email?.isNotEmpty == true ? member.email! : 'Belum diatur',
                Icons.email_outlined,
                const Color(0xFFEA580C),
              ),
              _buildMenuItem(
                'No Handphone / WhatsApp',
                member.phone?.isNotEmpty == true ? member.phone! : 'Belum diatur',
                Icons.phone_outlined,
                const Color(0xFF16A34A),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMenuSection(
            'Pengaturan & Keamanan',
            [
              _buildActionMenuItem(
                'Pengaturan Organisasi',
                'Edit profil ormawa, visi, misi, dan rekening',
                Icons.tune_rounded,
                OrmawaTheme.primary,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrmawaSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildActionMenuItem(
                'Keamanan & Sandi',
                'Ganti kata sandi akun administrasi',
                Icons.lock_reset_rounded,
                const Color(0xFF2563EB),
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OrmawaSecurityScreen(),
                    ),
                  );
                },
              ),
              _buildActionMenuItem(
                'Keluar Akun',
                'Akhiri sesi portal Ormawa',
                Icons.logout_rounded,
                const Color(0xFFDC2626),
                () => _showLogoutDialog(context),
                isDestructive: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s100),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: OrmawaTheme.textSectionTitle,
          ),
        ),
        OrmawaCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: OrmawaTheme.textCaption.copyWith(
                    color: OrmawaTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: OrmawaTheme.textCardTitle.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionMenuItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: OrmawaTheme.textCardTitle.copyWith(
                      fontSize: 13,
                      color: isDestructive ? const Color(0xFFDC2626) : OrmawaTheme.textHeading,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: OrmawaTheme.textCaption.copyWith(
                      color: isDestructive
                          ? const Color(0xFFDC2626).withAlpha(180)
                          : OrmawaTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDestructive ? const Color(0xFFDC2626) : OrmawaTheme.textPlaceholder,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.s60),
          Icon(
            Icons.person_off_rounded,
            size: 64,
            color: OrmawaTheme.textPlaceholder,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Data Profil Tidak Ditemukan',
            style: OrmawaTheme.textCardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gagal memuat informasi pribadi Anda. Pastikan Anda sudah terdaftar sebagai pengurus aktif.',
            textAlign: TextAlign.center,
            style: OrmawaTheme.textBodyRegular.copyWith(color: OrmawaTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
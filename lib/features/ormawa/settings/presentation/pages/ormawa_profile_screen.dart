import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_status_badge.dart';
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
              toolbarColor: BkuTheme.primaryDark,
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
      backgroundColor: BkuTheme.scaffoldBg,
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
          BkuCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            borderRadius: 16,
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: BkuTheme.primarySoft,
                        border: Border.all(
                          color: BkuTheme.primaryBorder,
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
                                    color: BkuTheme.primary,
                                  );
                                },
                                placeholder: (context, url) =>
                                    Container(color: BkuTheme.borderSubtle),
                              )
                            : Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: BkuTheme.primary,
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
                              color: BkuTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
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
                          child: BkuShimmerList(itemCount: 1),
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
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${member.role} • ${provider.orgName}',
                        style: BkuTheme.textCardSubtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          BkuStatusBadge(
                            status: BkuStatus.neutral,
                            customText: 'NIM: ${member.nim}',
                            showIcon: false,
                          ),
                          BkuStatusBadge(
                            status: member.status.toLowerCase() == 'aktif'
                                ? BkuStatus.success
                                : BkuStatus.warning,
                            customText: member.status.toUpperCase(),
                            showIcon: false,
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
                BkuTheme.primary,
              ),
              _buildMenuItem(
                'Divisi / Departemen',
                member.division.isEmpty ? 'Umum' : member.division,
                Icons.group_work_rounded,
                BkuTheme.sky,
              ),
              _buildMenuItem(
                'Organisasi',
                provider.orgName,
                Icons.account_balance_rounded,
                BkuTheme.purple,
              ),
              if (member.periode != null && member.periode!.isNotEmpty)
                _buildMenuItem(
                  'Periode Kepengurusan',
                  member.periode!,
                  Icons.date_range_rounded,
                  BkuTheme.emerald,
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
                BkuTheme.emerald,
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
                BkuTheme.primary,
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
                BkuTheme.primary,
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
                BkuTheme.rose,
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
            style: BkuTheme.textSectionTitle,
          ),
        ),
        BkuCard(
          padding: const EdgeInsets.symmetric(vertical: 6),
          borderRadius: 16,
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
              color: color.withValues(alpha: 0.1),
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
                  style: BkuTheme.textCaption.copyWith(
                    color: BkuTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
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
                color: color.withValues(alpha: 0.1),
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
                    style: BkuTheme.textCardTitle.copyWith(
                      fontSize: 13,
                      color: isDestructive ? BkuTheme.rose : BkuTheme.textHeading,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: BkuTheme.textCaption.copyWith(
                      color: isDestructive
                          ? BkuTheme.rose.withValues(alpha: 0.8)
                          : BkuTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDestructive ? BkuTheme.rose : BkuTheme.textPlaceholder,
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
            color: BkuTheme.textPlaceholder,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Data Profil Tidak Ditemukan',
            style: BkuTheme.textCardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gagal memuat informasi pribadi Anda. Pastikan Anda sudah terdaftar sebagai pengurus aktif.',
            textAlign: TextAlign.center,
            style: BkuTheme.textBodyRegular.copyWith(color: BkuTheme.textMuted),
          ),
        ],
      ),
    );
  }
}
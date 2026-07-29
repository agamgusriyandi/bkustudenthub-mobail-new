import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/profile/presentation/dialogs/profile_dialogs.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MentorProfileScreen extends StatefulWidget {
  const MentorProfileScreen({super.key});

  @override
  State<MentorProfileScreen> createState() => _MentorProfileScreenState();
}

class _MentorProfileScreenState extends State<MentorProfileScreen> {
  String _getMentorAvatarUrl(Map? fullData) {
    return AuthService().studentAvatarUrl ?? '';
  }

  Future<void> _pickAvatar(BuildContext context) async {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 85,
    );
    if (result != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: result.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Potong Foto',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Potong Foto',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const Center(child: CircularProgressIndicator()),
          );
        }
        try {
          await AuthService().uploadAvatar(croppedFile.path);
          if (context.mounted) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder:
                  (ctx) => CustomDialog(
                    title: 'Berhasil',
                    content: 'Foto profil berhasil diperbarui',
                    cancelText: '',
                    confirmText: 'Tutup',
                    onCancel: () {},
                    onConfirm: () => Navigator.pop(ctx),
                  ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            Navigator.pop(context);
            showDialog(
              context: context,
              builder:
                  (ctx) => CustomDialog(
                    title: 'Gagal',
                    content: ErrorHandler.getMessage(e),
                    cancelText: '',
                    confirmText: 'Tutup',
                    isDestructive: true,
                    onCancel: () {},
                    onConfirm: () => Navigator.pop(ctx),
                  ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final userData =
        authService.userData?['user'] ?? authService.userData ?? {};
    final name = userData['name'] ?? userData['nama'] ?? 'Mentor Kencana';
    final email = userData['email'] ?? '';
    final username =
        userData['username'] ?? userData['nim'] ?? userData['NIM'] ?? '-';

    final Map? prodiMap =
        userData['ProgramStudi'] is Map
            ? userData['ProgramStudi']
            : (userData['program_studi'] is Map
                ? userData['program_studi']
                : null);
    final prodiName =
        prodiMap != null ? (prodiMap['Nama'] ?? prodiMap['name'] ?? '') : '';

    final phone =
        userData['whatsapp'] ?? userData['no_hp'] ?? userData['phone'] ?? '-';

    final rawFoto = _getMentorAvatarUrl(authService.userData);

    String fotoUrl = rawFoto;
    if (fotoUrl.isNotEmpty && !fotoUrl.startsWith('http')) {
      String base = ApiGate.baseUrl;
      if (base.endsWith('/api')) {
        base = base.substring(0, base.length - 4);
      }
      if (fotoUrl.startsWith('/')) {
        fotoUrl = '$base$fotoUrl';
      } else {
        fotoUrl = '$base/$fotoUrl';
      }
    }

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () async {
          await AuthService().fetchMe();
          if (mounted) {
            setState(() {});
          }
        },
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            BkuAppBar(
              title: 'PROFIL MENTOR',
              variant: AppBarVariant.student,
              showNotification: false,
              isExpandable: false,
              showBackButton: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    FadeInAnimation(
                      delay: 0.1,
                      child: _buildRoleCard(context, name, username, fotoUrl),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FadeInAnimation(
                      delay: 0.15,
                      child: _buildMenuSection(context, 'Data Pribadi Mentor', [
                        _buildMenuItem(
                          context,
                          'ID / Username',
                          username,
                          Icons.badge_rounded,
                          context.appColors.info,
                          null,
                        ),
                        _buildMenuItem(
                          context,
                          'Email',
                          email.isEmpty ? '-' : email,
                          Icons.alternate_email_rounded,
                          context.appColors.info,
                          null,
                        ),
                        _buildMenuItem(
                          context,
                          'Nomor WhatsApp',
                          phone,
                          Icons.phone_android_rounded,
                          context.appColors.success,
                          null,
                        ),
                        if (prodiName.isNotEmpty)
                          _buildMenuItem(
                            context,
                            'Program Studi',
                            prodiName,
                            Icons.school_rounded,
                            context.appColors.warning,
                            null,
                          ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.s28),
                    FadeInAnimation(
                      delay: 0.2,
                      child: _buildMenuSection(context, 'Keamanan', [
                        _buildMenuItem(
                          context,
                          'Ubah Password',
                          'Ganti kata sandi akun Anda',
                          Icons.lock_outline_rounded,
                          Colors.redAccent,
                          () => showChangePasswordDialog(context),
                        ),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    FadeInAnimation(
                      delay: 0.25,
                      child: _buildLogoutButton(context),
                    ),
                    const SizedBox(height: AppSpacing.s120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    String name,
    String username,
    String fotoUrl,
  ) {
    final theme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: theme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  padding: AppSpacing.padding3,
                  decoration: BoxDecoration(
                    color: AppColors.neutral600.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: AppSpacing.padding2,
                    decoration: BoxDecoration(
                      color: context.appColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          fotoUrl.isNotEmpty
                              ? CachedNetworkImage(imageUrl: 
                                ApiGate.getImageUrl(fotoUrl),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.neutral400.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      size: 36,
                                      color: AppColors.neutral600,
                                    ),
                                  );
                                },
                                placeholder: (context, url) => Container(color: AppColors.neutral200),
                              )
                              : Container(
                                width: 64,
                                height: 64,
                                color: AppColors.neutral400.withValues(
                                  alpha: 0.1,
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: AppColors.neutral600,
                                ),
                              ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _pickAvatar(context),
                    child: Container(
                      padding: AppSpacing.padding6,
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black12, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  const Text(
                    'BKU HUB MEMBER',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surfaceContainerHighest.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: theme.outline.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.badge_rounded,
                              color: Colors.black87,
                              size: 12,
                            ),
                            const SizedBox(width: AppSpacing.s6),
                            Text(
                              'ID: $username',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.appColors.success.withValues(alpha: 0.1),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: context.appColors.success.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: context.appColors.success,
                              size: 12,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'MENTOR KENCANA',
                              style: TextStyle(
                                color: context.appColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.md),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.titleSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral300.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children:
                items.asMap().entries.map((entry) {
                  final isLast = entry.key == items.length - 1;
                  return Column(
                    children: [
                      entry.value,
                      if (!isLast)
                        Divider(
                          height: 1,
                          indent: 64,
                          endIndent: 20,
                          color: AppColors.neutral300.withAlpha(30),
                        ),
                    ],
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xs,
        ),
        leading: Container(
          padding: AppSpacing.padding9,
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: AppRadius.radiusMd,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: AppTextStyles.bodyMd.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.neutral800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing:
            onTap != null
                ? Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.outline,
                )
                : null,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.appColors.error.withAlpha(10),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: context.appColors.error.withAlpha(50)),
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
            'Keluar Aplikasi',
            style: TextStyle(
              color: context.appColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Anda akan keluar dari sesi ini',
            style: AppTextStyles.labelSm.copyWith(
              color: context.appColors.error.withAlpha(150),
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: context.appColors.error,
          ),
          onTap: () => showLogoutDialog(context),
        ),
      ),
    );
  }
}

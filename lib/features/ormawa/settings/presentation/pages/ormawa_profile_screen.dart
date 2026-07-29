import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrmawaProfileScreen extends StatefulWidget {
  const OrmawaProfileScreen({super.key});

  @override
  State<OrmawaProfileScreen> createState() => _OrmawaProfileScreenState();
}

class _OrmawaProfileScreenState extends State<OrmawaProfileScreen> {
  bool _isUploadingAvatar = false;

  Future<void> _pickAndUploadAvatar() async {
    final themeProvider = context.read<ThemeProvider>();
    final primaryColor = themeProvider.primary;
    final ormawaProvider = context.read<OrmawaProvider>();
    // Extract context-dependent values BEFORE any await
    final onPrimaryColor = context.appColors.onPrimary;

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
              toolbarTitle: 'Potong Foto',
              toolbarColor: primaryColor,
              toolbarWidgetColor: onPrimaryColor,
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
          AppSnackbar.showError(context, 'Gagal mengunggah foto: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isUploadingAvatar = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: Consumer<OrmawaProvider>(
        builder: (context, provider, child) {
          final member = provider.currentMember;

          return CustomScrollView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const BkuAppBar(
                variant: AppBarVariant.ormawa,
                title: 'PROFIL PRIBADI',
                subtitle: 'INFO & KONTAK SAYA',
                expandedHeight: 130.0,
                showBackButton: true,
                isExpandable: false,
              ),
              SliverToBoxAdapter(
                child:
                    member != null
                        ? _buildProfileContent(context, member)
                        : _buildEmptyState(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, OrmawaMember member) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(member),
          const SizedBox(height: AppSpacing.xxl),
          _buildMenuSection('Informasi Ormawa', [
            _buildMenuItem(
              'Jabatan / Role',
              member.role,
              Icons.badge_rounded,
              context.appColors.info,
            ),
            _buildMenuItem(
              'Divisi / Departemen',
              member.division,
              Icons.group_work_rounded,
              AppColors.info,
            ),
            _buildMenuItem(
              'Status Keanggotaan',
              _capitalize(member.status),
              Icons.verified_user_rounded,
              member.status.toLowerCase() == 'aktif'
                  ? AppColors.success
                  : AppColors.warning,
            ),
            if (member.periode != null && member.periode!.isNotEmpty)
              _buildMenuItem(
                'Periode Kepengurusan',
                member.periode!,
                Icons.date_range_rounded,
                AppColors.neutral700,
              ),
          ]),
          const SizedBox(height: AppSpacing.s28),
          _buildMenuSection('Kontak & Data Diri', [
            _buildMenuItem(
              'Email Kampus',
              member.email ?? 'Belum diatur',
              Icons.email_rounded,
              context.appColors.error,
            ),
            _buildMenuItem(
              'No Handphone / WhatsApp',
              member.phone ?? 'Belum diatur',
              Icons.phone_rounded,
              context.appColors.info,
            ),
            if (member.joinedAt != null)
              _buildMenuItem(
                'Bergabung Sejak',
                '${member.joinedAt!.day}/${member.joinedAt!.month}/${member.joinedAt!.year}',
                Icons.access_time_rounded,
                AppColors.neutral600,
              ),
          ]),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(OrmawaMember member) {
    final theme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: theme.outline.withAlpha(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
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
                    color: AppColors.neutral600.withAlpha(26),
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
                          member.fotoUrl != null && member.fotoUrl!.isNotEmpty
                              ? CachedNetworkImage(imageUrl: 
                                ApiGate.getImageUrl(member.fotoUrl!),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.neutral400.withAlpha(26),
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
                                color: AppColors.neutral400.withAlpha(26),
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 36,
                                  color: AppColors.neutral600,
                                ),
                              ),
                    ),
                  ),
                ),
                if (!_isUploadingAvatar)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickAndUploadAvatar(),
                      child: Container(
                        padding: AppSpacing.padding6,
                        decoration: BoxDecoration(
                          color: context.appColors.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                if (_isUploadingAvatar)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalizeEachWord(member.name),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.s2),
                  Text(
                    '${member.role} • ${member.division}',
                    style: const TextStyle(
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
                          color: theme.surfaceContainerHighest.withAlpha(128),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: theme.outline.withAlpha(13),
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
                              'NIM: ${member.nim}',
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
                          color: (member.status.toLowerCase() == 'aktif'
                                  ? AppColors.success
                                  : AppColors.warning)
                              .withAlpha(26),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: (member.status.toLowerCase() == 'aktif'
                                    ? AppColors.success
                                    : AppColors.warning)
                                .withAlpha(51),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color:
                                  member.status.toLowerCase() == 'aktif'
                                      ? AppColors.success
                                      : AppColors.warning,
                              size: 12,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              member.status.toUpperCase(),
                              style: TextStyle(
                                color:
                                    member.status.toLowerCase() == 'aktif'
                                        ? AppColors.success
                                        : AppColors.warning,
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

  Widget _buildMenuSection(String title, List<Widget> items) {
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
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
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
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.neutral500,
            fontWeight: FontWeight.w500,
          ),
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
          Icon(Icons.person_off_rounded, size: 80, color: AppColors.neutral300),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Data Profil Tidak Ditemukan',
            style: AppTextStyles.titleLg.copyWith(
              color: AppColors.neutral700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Gagal memuat informasi pribadi Anda. Pastikan Anda sudah terdaftar sebagai pengurus.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';

  String _capitalizeEachWord(String s) {
    if (s.isEmpty) return '';
    return s
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
        })
        .join(' ');
  }
}

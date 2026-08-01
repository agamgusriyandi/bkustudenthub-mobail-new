import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_dashboard_provider.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/error/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/pages/tk_main_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkSettingsScreen extends StatefulWidget {
  final bool showBackButton;

  const TkSettingsScreen({super.key, this.showBackButton = true});

  @override
  State<TkSettingsScreen> createState() => _TkSettingsScreenState();
}

class _TkSettingsScreenState extends State<TkSettingsScreen> {
  bool _isUploadingAvatar = false;
  bool _notifBooking = true;
  bool _notifReminder = true;
  bool _notifAlert = true;

  Future<void> _pickAndUploadAvatar(TkDashboardProvider provider) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (!mounted) return;
      final themeProvider = context.read<ThemeProvider>();
      final primaryColor = themeProvider.primary;
      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Potong Foto',
              toolbarColor: primaryColor,
              toolbarWidgetColor: context.appColors.surface,
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
          setState(() => _isUploadingAvatar = true);
          final success = await provider.uploadProfileAvatar(croppedFile.path);
          if (mounted) {
            success
                ? AppSnackbar.showSuccess(context, 'Profil berhasil diperbarui')
                : AppSnackbar.showError(
                  context,
                  provider.error ?? 'Gagal mengunggah foto profil',
                );
          }
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, 'Gagal mengunggah foto: $e');
        }
      } finally {
        if (mounted) setState(() => _isUploadingAvatar = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkDashboardProvider>().loadActivities();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifBooking = prefs.getBool('tk_notif_booking') ?? true;
      _notifReminder = prefs.getBool('tk_notif_reminder') ?? true;
      _notifAlert = prefs.getBool('tk_notif_alert') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  void _testNotification() {
    LocalNotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.hashCode,
      title: 'Test Notifikasi Nakes',
      body: 'Ini adalah pesan uji coba sistem notifikasi Tenaga Kesehatan.',
    );
    showDialog(
      context: context,
      builder:
          (ctx) => CustomDialog(
            title: 'Test Notifikasi',
            content: 'Notifikasi uji coba berhasil dikirim ke perangkat Anda.',
            cancelText: '',
            confirmText: 'Tutup',
            isSuccess: true,
            onCancel: () {},
            onConfirm: () => Navigator.pop(ctx),
          ),
    );
  }

  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: BoxDecoration(
                  color: context.appColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral500.withAlpha(80),
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: Icon(Icons.notifications_active_rounded, color: AppColors.neutral900,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Notifikasi & Reminder',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _buildSwitchTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi Booking',
                    subtitle: 'Aktifkan notifikasi booking baru',
                    color: context.appColors.info,
                    value: _notifBooking,
                    onChanged: (v) {
                      setSheetState(() => _notifBooking = v);
                      setState(() => _notifBooking = v);
                      _savePreference('tk_notif_booking', v);
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.event_rounded,
                    title: 'Pengingat Jadwal',
                    subtitle: 'Notifikasi pengingat pemeriksaan',
                    color: context.appColors.success,
                    value: _notifReminder,
                    onChanged: (v) {
                      setSheetState(() => _notifReminder = v);
                      setState(() => _notifReminder = v);
                      _savePreference('tk_notif_reminder', v);
                    },
                  ),
                  _buildSwitchTile(
                    icon: Icons.warning_amber_rounded,
                    title: 'Notifikasi Perhatian',
                    subtitle: 'Alert mahasiswa perlu perhatian',
                    color: context.appColors.warning,
                    value: _notifAlert,
                    onChanged: (v) {
                      setSheetState(() => _notifAlert = v);
                      setState(() => _notifAlert = v);
                      _savePreference('tk_notif_alert', v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s28),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _testNotification,
                      icon: const Icon(Icons.notifications_active_rounded, size: 18),
                      label: const Text(
                        'Cek Notifikasi (Test)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.appColors.info,
                        backgroundColor: context.appColors.info.withAlpha(15),
                        side: BorderSide(color: context.appColors.info.withAlpha(30)),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.br10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.appColors.success,
                        foregroundColor: context.appColors.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.br10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(sheetContext).padding.bottom + 24,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Profile',
        variant: AppBarVariant.nakes,
        showBackButton: true,
        onBack: () {
          if (GoRouter.of(context).canPop()) {
            context.pop();
          } else {
            final mainState =
                context.findAncestorStateOfType<TkMainScreenState>();
            if (mainState != null) {
              mainState.setSelectedIndex(0);
            } else {
              context.go('/tenagakes?tab=0');
            }
          }
        },
      ),
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Consumer<TkDashboardProvider>(
              builder: (context, provider, child) {
                final profile = provider.profile;
                final authEmail =
                    AuthService().userData?['email']?.toString() ?? '-';
                final email =
                    (profile != null && profile.email.isNotEmpty == true)
                        ? profile.email
                        : authEmail;

                final authPhone =
                    AuthService().userData?['no_hp']?.toString() ?? '-';
                final phone =
                    (profile != null && profile.noHP.isNotEmpty == true)
                        ? profile.noHP
                        : authPhone;

                final authLokasi =
                    AuthService().userData?['lokasi']?.toString() ?? '-';
                final lokasi =
                    (profile != null && profile.lokasi.isNotEmpty == true)
                        ? profile.lokasi
                        : authLokasi;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xl),

                      // Role Card - Consistent with Student
                      _buildRoleCard(provider),
                      const SizedBox(height: AppSpacing.xxl),

                      // 1. Data Pribadi Tenaga Kesehatan
                      _buildSectionHeader('Data Pribadi Tenaga Kesehatan'),
                      const SizedBox(height: AppSpacing.md),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          icon: Icons.alternate_email_rounded,
                          title: 'Email Institusi',
                          subtitle: email,
                          color: context.appColors.info,
                          onTap: null,
                        ),
                        _buildSettingsTile(
                          icon: Icons.phone_android_rounded,
                          title: 'Nomor WhatsApp',
                          subtitle: phone,
                          color: context.appColors.success,
                          onTap: null,
                        ),
                        _buildSettingsTile(
                          icon: Icons.location_on_rounded,
                          title: 'Lokasi Dinas/Praktek',
                          subtitle: lokasi,
                          color: context.appColors.error,
                          onTap: null,
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.s28),

                      // 2. Pengaturan Akun
                      _buildSectionHeader('Pengaturan Akun'),
                      const SizedBox(height: AppSpacing.md),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          icon: Icons.person_rounded,
                          title: 'Edit Profil',
                          subtitle: 'Ubah informasi pribadi',
                          color: context.appColors.info,
                          onTap: () => _showEditProfileSheet(provider),
                        ),
                        _buildSettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Ubah Password',
                          subtitle: 'Update kata sandi akun',
                          color: context.appColors.warning,
                          onTap: () => _showChangePasswordSheet(provider),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.s28),

                      // 3. Preferensi Sistem
                      _buildSectionHeader('Preferensi Sistem'),
                      const SizedBox(height: AppSpacing.md),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Notifikasi & Reminder',
                          subtitle: 'Atur preferensi notifikasi sistem',
                          color: context.appColors.info,
                          onTap: _showNotificationsSheet,
                        ),
                      ]),

                      const SizedBox(height: AppSpacing.md),

                      // Logout Button
                      _buildLogoutButton(context),
                      const SizedBox(height: AppSpacing.s120),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(TkDashboardProvider provider) {
    final profile = provider.profile;

    final authName =
        AuthService().userData?['name']?.toString() ??
        AuthService().userData?['nama']?.toString() ??
        'Tenaga Kesehatan';
    final name =
        (profile != null && profile.nama.isNotEmpty == true)
            ? profile.nama
            : authName;

    final authSpesialisasi =
        AuthService().userData?['spesialisasi']?.toString() ??
        'Pemeriksaan Umum';
    final spesialisasi =
        (profile != null && profile.spesialisasi.isNotEmpty == true)
            ? profile.spesialisasi
            : authSpesialisasi;

    final authFoto =
        AuthService().userData?['foto_url']?.toString() ??
        AuthService().userData?['avatar_url']?.toString() ??
        AuthService().userData?['foto']?.toString() ??
        '';
    final fotoUrl =
        (profile != null && profile.fotoURL.isNotEmpty == true)
            ? profile.fotoURL
            : authFoto;

    final String initials;
    if (name.trim().isEmpty) {
      initials = 'TK';
    } else {
      final parts = name.trim().split(' ');
      if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
        initials = parts[0][0].toUpperCase();
      } else {
        initials = 'TK';
      }
    }

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _pickAndUploadAvatar(provider),
            child: Stack(
              children: [
                Container(
                  padding: AppSpacing.padding3,
                  decoration: BoxDecoration(
                    color: AppColors.neutral600.withAlpha(25),
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
                                () {
                                  final rawUrl = ApiGate.getImageUrl(fotoUrl);
                                  return rawUrl.contains('?')
                                      ? '$rawUrl&v=${DateTime.now().millisecondsSinceEpoch}'
                                      : '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';
                                }(),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.neutral400.withAlpha(25),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: TextStyle(fontWeight: FontWeight.w900,
                                          color: AppColors.neutral600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                placeholder: (context, url) => Container(color: AppColors.neutral200),
                              )
                              : Container(
                                width: 64,
                                height: 64,
                                color: AppColors.neutral600.withAlpha(25),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: TextStyle(fontWeight: FontWeight.w900,
                                      color: AppColors.neutral600,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                    ),
                  ),
                ),
                if (_isUploadingAvatar)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                    color: context.appColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(color: context.appColors.onPrimary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  spesialisasi,
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.neutral600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.md),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.titleSm.copyWith(
          color: AppColors.neutral600,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return BkuCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
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
            color: context.appColors.onSurfaceVariant,
          ),
        ),
        trailing:
            onTap != null
                ? Icon(
                  Icons.chevron_right_rounded,
                  color: context.appColors.onSurfaceVariant,
                )
                : null,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool value,
    required Function(bool) onChanged,
  }) {
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
          style: AppTextStyles.labelSm.copyWith(
            color: context.appColors.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: context.appColors.primary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    color: context.appColors.error.withAlpha(15),
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
                  'Keluar Aplikasi?',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),
                Text(
                  'Sesi Anda akan diakhiri. Pastikan semua catatan sudah tersimpan sebelum keluar.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    color: context.appColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.s28),
                Row(
                  children: [
                    Expanded(
                      child: BkuButton(
                        onPressed: () => Navigator.pop(ctx),
                        text: 'Batal',
                        variant: BkuButtonVariant.outline,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: BkuButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await AuthService().logout();
                          if (mounted) {
                            context.go(AppRoutes.login);
                          }
                        },
                        text: 'Keluar',
                        variant: BkuButtonVariant.danger,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Material(
      color: context.appColors.error.withAlpha(10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
        side: BorderSide(color: context.appColors.error.withAlpha(50)),
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(),
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
          style: TextStyle(color: context.appColors.error, fontWeight: FontWeight.bold),
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
      ),
    );
  }

  void _showEditProfileSheet(TkDashboardProvider provider) {
    final profile = provider.profile;
    final namaController = TextEditingController(text: profile?.nama ?? '');
    final emailController = TextEditingController(text: profile?.email ?? '');
    final noHpController = TextEditingController(text: profile?.noHP ?? '');
    final lokasiController = TextEditingController(text: profile?.lokasi ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => StatefulBuilder(
            builder: (stateContext, setSheetState) {
              final theme = Theme.of(stateContext).colorScheme;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(stateContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Edit Profil',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BkuTextField(
                            controller: namaController,
                            label: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_rounded, color: context.appColors.info,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuTextField(
                            controller: emailController,
                            label: 'Email',
                            prefixIcon: Icon(Icons.email_rounded, color: context.appColors.success,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuTextField(
                            controller: noHpController,
                            label: 'No HP',
                            prefixIcon: Icon(Icons.phone_rounded, color: context.appColors.info,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuTextField(
                            controller: lokasiController,
                            label: 'Lokasi',
                            prefixIcon: Icon(Icons.location_on_rounded, color: context.appColors.error,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            bool success = await provider.updateProfileData({
                              'nama': namaController.text,
                              'email': emailController.text,
                              'no_hp': noHpController.text,
                              'lokasi': lokasiController.text,
                            });
                            if (stateContext.mounted) {
                              Navigator.pop(sheetContext);
                              success
                                  ? AppSnackbar.showSuccess(
                                    stateContext,
                                    'Profil berhasil diperbarui',
                                  )
                                  : AppSnackbar.showError(
                                    stateContext,
                                    provider.error ??
                                        'Gagal memperbarui profil',
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColors.success,
                            foregroundColor: context.appColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.br10,
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  void _showChangePasswordSheet(TkDashboardProvider provider) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (sheetContext) => StatefulBuilder(
            builder: (stateContext, setSheetState) {
              final theme = Theme.of(stateContext).colorScheme;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.xxl),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(stateContext).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Ubah Password',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s20),
                      Text(
                        'Demi keamanan akun Anda, pastikan password baru memiliki kombinasi huruf dan angka.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BkuTextField(
                            controller: oldPasswordController,
                            obscureText: true,
                            label: 'Password Lama',
                            prefixIcon: Icon(Icons.lock_outline_rounded, color: context.appColors.warning,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuTextField(
                            controller: newPasswordController,
                            obscureText: true,
                            label: 'Password Baru',
                            prefixIcon: Icon(Icons.lock_rounded, color: context.appColors.info,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          BkuTextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            label: 'Konfirmasi Password Baru',
                            prefixIcon: Icon(Icons.lock_clock_rounded, color: context.appColors.info,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (oldPasswordController.text.isEmpty) {
                              AppSnackbar.showError(
                                context,
                                'Password lama tidak boleh kosong',
                              );
                              return;
                            }
                            if (newPasswordController.text.isEmpty) {
                              AppSnackbar.showError(
                                context,
                                'Password baru tidak boleh kosong',
                              );
                              return;
                            }
                            if (newPasswordController.text !=
                                confirmPasswordController.text) {
                              AppSnackbar.showError(
                                context,
                                'Password baru tidak cocok',
                              );
                              return;
                            }
                            try {
                              await provider.changePassword(
                                oldPasswordController.text,
                                newPasswordController.text,
                                confirmPasswordController.text,
                              );
                              if (stateContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              if (!mounted) return;
                              AppSnackbar.showSuccess(
                                context,
                                'Password berhasil diubah',
                              );
                            } catch (e) {
                              if (!mounted) return;
                              AppSnackbar.showError(
                                context,
                                ErrorHandler.getMessage(e),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.appColors.success,
                            foregroundColor: context.appColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.br10,
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Simpan Perubahan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
}

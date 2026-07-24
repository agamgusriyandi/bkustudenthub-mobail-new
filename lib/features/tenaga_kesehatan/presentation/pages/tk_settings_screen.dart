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
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                        color: Colors.grey.withAlpha(80),
                        borderRadius: AppRadius.radiusMd,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.neutral200,
                          borderRadius: AppRadius.radiusMd,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.neutral900,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Notifikasi & Reminder',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSwitchTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi Booking',
                    subtitle: 'Aktifkan notifikasi booking baru',
                    color: const Color(0xFF2563EB),
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
                    color: const Color(0xFF16A34A),
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
                    color: const Color(0xFFD97706),
                    value: _notifAlert,
                    onChanged: (v) {
                      setSheetState(() => _notifAlert = v);
                      setState(() => _notifAlert = v);
                      _savePreference('tk_notif_alert', v);
                    },
                  ),
                  const SizedBox(height: 28),
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
                        foregroundColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFEFF6FF),
                        side: const BorderSide(color: Color(0xFFBFDBFE)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
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
                      const SizedBox(height: 24),

                      // Role Card - Consistent with Student
                      _buildRoleCard(provider),
                      const SizedBox(height: 32),

                      // 1. Data Pribadi Tenaga Kesehatan
                      _buildSectionHeader('Data Pribadi Tenaga Kesehatan'),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          icon: Icons.alternate_email_rounded,
                          title: 'Email Institusi',
                          subtitle: email,
                          color: const Color(0xFF2563EB),
                          onTap: null,
                        ),
                        _buildSettingsTile(
                          icon: Icons.phone_android_rounded,
                          title: 'Nomor WhatsApp',
                          subtitle: phone,
                          color: const Color(0xFF16A34A),
                          onTap: null,
                        ),
                        _buildSettingsTile(
                          icon: Icons.location_on_rounded,
                          title: 'Lokasi Dinas/Praktek',
                          subtitle: lokasi,
                          color: const Color(0xFFE11D48),
                          onTap: null,
                        ),
                      ]),
                      const SizedBox(height: 28),

                      // 2. Pengaturan Akun
                      _buildSectionHeader('Pengaturan Akun'),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          icon: Icons.person_rounded,
                          title: 'Edit Profil',
                          subtitle: 'Ubah informasi pribadi',
                          color: const Color(0xFF2563EB),
                          onTap: () => _showEditProfileSheet(provider),
                        ),
                        _buildSettingsTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Ubah Password',
                          subtitle: 'Update kata sandi akun',
                          color: const Color(0xFFD97706),
                          onTap: () => _showChangePasswordSheet(provider),
                        ),
                      ]),
                      const SizedBox(height: 28),

                      // 3. Preferensi Sistem
                      _buildSectionHeader('Preferensi Sistem'),
                      const SizedBox(height: 12),
                      _buildSettingsCard([
                        _buildSettingsTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Notifikasi & Reminder',
                          subtitle: 'Atur preferensi notifikasi sistem',
                          color: const Color(0xFF9333EA),
                          onTap: _showNotificationsSheet,
                        ),
                      ]),

                      const SizedBox(height: 12),

                      // Logout Button
                      _buildLogoutButton(context),
                      const SizedBox(height: 120),
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
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AppColors.neutral600.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child:
                          fotoUrl.isNotEmpty
                              ? Image.network(
                                () {
                                  final rawUrl = ApiGate.getImageUrl(fotoUrl);
                                  return rawUrl.contains('?')
                                      ? '$rawUrl&v=${DateTime.now().millisecondsSinceEpoch}'
                                      : '$rawUrl?v=${DateTime.now().millisecondsSinceEpoch}';
                                }(),
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 64,
                                    height: 64,
                                    color: AppColors.neutral400.withAlpha(25),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.neutral600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                              : Container(
                                width: 64,
                                height: 64,
                                color: AppColors.neutral600.withAlpha(25),
                                child: Center(
                                  child: Text(
                                    initials,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
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
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
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
      padding: const EdgeInsets.only(left: 8, bottom: 12),
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
          padding: const EdgeInsets.all(9),
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
          padding: const EdgeInsets.all(9),
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).colorScheme.primary,
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
            contentPadding: const EdgeInsets.all(28),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Keluar Aplikasi?',
                  style: AppTextStyles.titleLg.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.neutral800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Sesi Anda akan diakhiri. Pastikan semua catatan sudah tersimpan sebelum keluar.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.labelMd.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: BkuButton(
                        onPressed: () => Navigator.pop(ctx),
                        text: 'Batal',
                        variant: BkuButtonVariant.outline,
                      ),
                    ),
                    const SizedBox(width: 12),
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
      color: AppColors.error.withAlpha(10),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
        side: BorderSide(color: AppColors.error.withAlpha(50)),
      ),
      child: ListTile(
        onTap: () => _showLogoutDialog(),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: AppColors.error.withAlpha(20),
            borderRadius: AppRadius.radiusMd,
          ),
          child: const Icon(
            Icons.logout_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
        title: const Text(
          'Keluar Aplikasi',
          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Anda akan keluar dari sesi ini',
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.error.withAlpha(150),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.error,
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
                    top: Radius.circular(32),
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
                      const SizedBox(height: 12),
                      Text(
                        'Edit Profil',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BkuTextField(
                            controller: namaController,
                            label: 'Nama Lengkap',
                            prefixIcon: const Icon(
                              Icons.person_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BkuTextField(
                            controller: emailController,
                            label: 'Email',
                            prefixIcon: const Icon(
                              Icons.email_rounded,
                              color: Color(0xFF16A34A),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BkuTextField(
                            controller: noHpController,
                            label: 'No HP',
                            prefixIcon: const Icon(
                              Icons.phone_rounded,
                              color: Color(0xFF0D9488),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BkuTextField(
                            controller: lokasiController,
                            label: 'Lokasi',
                            prefixIcon: const Icon(
                              Icons.location_on_rounded,
                              color: Color(0xFFE11D48),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
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
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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
                    top: Radius.circular(32),
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
                      const SizedBox(height: 12),
                      Text(
                        'Ubah Password',
                        style: AppTextStyles.titleLg.copyWith(
                          fontWeight: FontWeight.w900,
                          color: theme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Demi keamanan akun Anda, pastikan password baru memiliki kombinasi huruf dan angka.',
                        style: AppTextStyles.labelMd.copyWith(
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BkuTextField(
                            controller: oldPasswordController,
                            obscureText: true,
                            label: 'Password Lama',
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: Color(0xFFD97706),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BkuTextField(
                            controller: newPasswordController,
                            obscureText: true,
                            label: 'Password Baru',
                            prefixIcon: const Icon(
                              Icons.lock_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BkuTextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            label: 'Konfirmasi Password Baru',
                            prefixIcon: const Icon(
                              Icons.lock_clock_rounded,
                              color: Color(0xFF9333EA),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
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
                            backgroundColor: const Color(0xFF16A34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
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

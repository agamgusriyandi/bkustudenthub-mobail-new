import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_text_field.dart';
import 'package:bkuhub_mobile/core/widgets/custom_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bkuhub_mobile/core/routes/app_routes.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/psychologist_dashboard_provider.dart';
import 'package:bkuhub_mobile/features/counseling/presentation/providers/counseling_provider.dart';
import 'package:bkuhub_mobile/core/services/local_notification_service.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PsychologistSettingsScreen extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBack;
  const PsychologistSettingsScreen({
    super.key,
    this.showBackButton = true,
    this.onBack,
  });

  @override
  State<PsychologistSettingsScreen> createState() =>
      _PsychologistSettingsScreenState();
}

class _PsychologistSettingsScreenState
    extends State<PsychologistSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
        color: themeProvider.primary,
        backgroundColor: context.appColors.surface,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            BkuAppBar(
              title: 'Pengaturan',
              variant: AppBarVariant.psychologist,
              showBackButton: true,
              onBack:
                  widget.onBack ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      Navigator.maybePop(context);
                    }
                  },
              isExpandable: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    _buildRoleCard(),
                    const SizedBox(height: AppSpacing.xxl),

                    _buildMenuGroup('AKUN & PROFIL', [
                      _buildProfileTile(),
                      _buildChangePwTile(),
                    ]),

                    const SizedBox(height: AppSpacing.s28),

                    _buildMenuGroup('PREFERENSI SISTEM', [
                      _buildActionTile(
                        Icons.notifications_active_rounded,
                        'Notifikasi & Reminder',
                        'Atur pengingat jadwal sesi',
                        AppColors.neutral200,
                        AppColors.neutral900,
                        () => _showNotificationsReminderSheet(),
                      ),
                    ]),

                    const SizedBox(height: AppSpacing.xxxl),
                    _buildLogoutButton(),
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

  // ─── Menu Group Builder ───────────────────────────────────────────────────

  Widget _buildMenuGroup(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.md),
          child: Text(
            title,
            style: AppTextStyles.titleSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        BkuCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  // ─── Profile Tile ─────────────────────────────────────────────────────────

  Widget _buildProfileTile() {
    final themeProvider = context.watch<ThemeProvider>();
    final profile = context.watch<PsychologistDashboardProvider>().profile;
    final name = profile?.name ?? 'Psikolog';
    final displayName = name == '-' || name.trim().isEmpty ? 'Psikolog' : name;
    final initials =
        displayName.trim().isEmpty || displayName == 'Psikolog'
            ? 'P'
            : displayName
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                .join();

    final imageUrl = profile?.profileImageUrl ?? '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: themeProvider.primaryGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.radiusMd,
        ),
        clipBehavior: Clip.antiAlias,
        child:
            imageUrl.isNotEmpty
                ? CachedNetworkImage(imageUrl: 
                  (() {
                    final url = ApiGate.getImageUrl(imageUrl);
                    final version =
                        context
                            .watch<PsychologistDashboardProvider>()
                            .avatarVersion;
                    return url.contains('?')
                        ? '$url&v=$version'
                        : '$url?v=$version';
                  })(),
                  fit: BoxFit.cover,
                  errorWidget:
                      (context, url, error) => Center(
                        child: Text(
                          initials,
                          style: AppTextStyles.titleMd.copyWith(
                            color: context.appColors.onPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                  placeholder: (context, url) => Container(color: AppColors.neutral200),
                )
                : Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.titleMd.copyWith(
                      color: context.appColors.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
      ),
      title: Text(
        displayName,
        style: AppTextStyles.bodyMd.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.neutral800,
        ),
      ),
      subtitle: Text(
        'Kelengkapan data profil',
        style: AppTextStyles.labelSm.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: () => _showProfileBottomSheet(profile),
    );
  }

  void _showProfileBottomSheet(dynamic profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProfileBottomSheet(profile: profile),
    );
  }

  // ─── Role Card ────────────────────────────────────────────────────────────

  Widget _buildRoleCard() {
    final themeProvider = context.watch<ThemeProvider>();
    final profile = context.watch<PsychologistDashboardProvider>().profile;
    final name = profile?.name ?? 'Psikolog';
    final spec = profile?.specialization ?? 'Psikolog';
    final nidn = profile?.nidn ?? '-';
    final imageUrl = profile?.profileImageUrl ?? '';

    return BkuCard(
      child: ClipRRect(
        borderRadius: AppRadius.radiusXl,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: themeProvider.primary.withAlpha(5),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: themeProvider.primary.withAlpha(15),
                      borderRadius: AppRadius.radiusXl,
                      image:
                          imageUrl.isNotEmpty
                              ? DecorationImage(
                                image: NetworkImage(
                                  ApiGate.getImageUrl(imageUrl),
                                ),
                                fit: BoxFit.cover,
                              )
                              : null,
                    ),
                    child:
                        imageUrl.isNotEmpty
                            ? null
                            : const Icon(
                              Icons.psychology_alt_rounded,
                              color: AppColors.primary,
                              size: 36,
                            ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name == '-' || name.trim().isEmpty
                              ? 'Psikolog'
                              : name,
                          style: AppTextStyles.titleLg.copyWith(
                            color: AppColors.neutral900,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.s2),
                        Text(
                          '$spec • BKU Care',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.neutral500,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s10),
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
                                color: AppColors.neutral100,
                                borderRadius: AppRadius.radiusMd,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.badge_rounded,
                                    color: AppColors.neutral500,
                                    size: 12,
                                  ),
                                  const SizedBox(width: AppSpacing.s6),
                                  Text(
                                    'NIDN: $nidn',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: AppColors.neutral500,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
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
                                color: AppColors.success.withAlpha(40),
                                borderRadius: AppRadius.radiusMd,
                                border: Border.all(
                                  color: AppColors.success.withAlpha(80),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.verified_rounded,
                                    color: Color(0xFF34D399),
                                    size: 12,
                                  ),
                                  SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'Verified',
                                    style: AppTextStyles.labelMd.copyWith(
                                      color: Color(0xFF34D399),
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
          ],
        ),
      ),
    );
  }

  // ─── Change Password Tile ─────────────────────────────────────────────────

  Widget _buildChangePwTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        padding: AppSpacing.padding9,
        decoration: BoxDecoration(
          color: const Color(0xFFFCE7F3),
          borderRadius: AppRadius.radiusMd,
        ),
        child: const Icon(
          Icons.password_rounded,
          color: Color(0xFFBE185D),
          size: 20,
        ),
      ),
      title: Text(
        'Ubah Password',
        style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Ganti password akun Anda',
        style: AppTextStyles.labelSm.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: () => _showChangePwSheet(),
    );
  }

  void _showChangePwSheet() {
    final provider = context.read<PsychologistDashboardProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangePwBottomSheet(provider: provider),
    );
  }

  // ─── Tile Builders ────────────────────────────────────────────────────────

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    Color bg,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      leading: Container(
        padding: AppSpacing.padding9,
        decoration: BoxDecoration(color: bg, borderRadius: AppRadius.radiusMd),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.labelSm.copyWith(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
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
          padding: AppSpacing.padding9,
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
                    color: AppColors.error.withAlpha(15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
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
                    color: Theme.of(context).colorScheme.outline,
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
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          context.read<CounselingProvider>().clearState();
                          await AuthService().logout();
                          if (mounted) {
                            context.go(AppRoutes.login);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: context.appColors.onPrimary,
                          elevation: 0,
                        ),
                        child: Text(
                          'Keluar',
                          style: AppTextStyles.bodyMd.copyWith(
                            fontWeight: FontWeight.bold,
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

  // ignore: unused_element
  void _showSessionLogsSheet() {
    final provider = context.read<PsychologistDashboardProvider>();
    final logs = provider.recentActivities;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
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
                      color: const Color(0xFFE0E7FF),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Color(0xFF4338CA),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Log Aktivitas Sesi',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (logs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xxxl,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history_toggle_off_rounded,
                          size: 48,
                          color: AppColors.neutral300,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Belum ada log aktivitas sesi',
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.neutral500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: logs.length,
                    separatorBuilder:
                        (_, __) => Divider(
                          height: 20,
                          color: AppColors.neutral500.withAlpha(30),
                        ),
                    itemBuilder: (context, index) {
                      final log = logs[index];
                      final title = log['title'] ?? 'Aktivitas';
                      final desc = log['description'] ?? '';
                      final time = log['time'] ?? '-';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: AppSpacing.padding6,
                            decoration: const BoxDecoration(
                              color: AppColors.neutral200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.circle_notifications_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral800,
                                  ),
                                ),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.s2),
                                  Text(
                                    desc,
                                    style: AppTextStyles.labelSm.copyWith(
                                      color: AppColors.neutral600,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  time,
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: AppColors.neutral400,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.s20),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsReminderSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NotificationReminderBottomSheet(),
    );
  }
}

// ─── Change Password Bottom Sheet ────────────────────────────────────────────

class _ChangePwBottomSheet extends StatefulWidget {
  final PsychologistDashboardProvider provider;
  const _ChangePwBottomSheet({required this.provider});

  @override
  State<_ChangePwBottomSheet> createState() => _ChangePwBottomSheetState();
}

class _ChangePwBottomSheetState extends State<_ChangePwBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await widget.provider.changePassword(
        _oldCtrl.text.trim(),
        _newCtrl.text.trim(),
        _confirmCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diubah!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Parse pesan error dari DioException
      String msg = 'Gagal mengubah password';
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          msg = data['message']?.toString() ?? data['error']?.toString() ?? msg;
        } else if (data is String && data.isNotEmpty) {
          msg = data;
        }
      } else {
        final raw = e.toString();
        if (raw.contains('salah')) {
          msg = 'Password saat ini salah';
        } else if (raw.contains('minimal')) {
          msg = 'Password baru minimal 8 karakter';
        } else if (raw.contains('sama')) {
          msg = 'Konfirmasi password tidak sama';
        }
      }
      AppSnackbar.showSuccess(context, msg);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration:  BoxDecoration(
          color: context.appColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral500.withAlpha(60),
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.s20),

              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE7F3),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Color(0xFFBE185D),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ubah Password',
                        style: AppTextStyles.bodyMd.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral800,
                        ),
                      ),
                      Text(
                        'Minimal 8 karakter',
                        style: AppTextStyles.labelMd.copyWith(
                          fontSize: 12,
                          color: AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Password lama
              _buildPwField(
                controller: _oldCtrl,
                label: 'Password Saat Ini',
                show: _showOld,
                onToggle: () => setState(() => _showOld = !_showOld),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: AppSpacing.s14),

              // Password baru
              _buildPwField(
                controller: _newCtrl,
                label: 'Password Baru',
                show: _showNew,
                onToggle: () => setState(() => _showNew = !_showNew),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v.length < 8) return 'Minimal 8 karakter';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.s14),

              // Konfirmasi
              _buildPwField(
                controller: _confirmCtrl,
                label: 'Konfirmasi Password Baru',
                show: _showConfirm,
                onToggle: () => setState(() => _showConfirm = !_showConfirm),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (v != _newCtrl.text) return 'Password tidak sama';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: context.appColors.onPrimary,
                  ),
                  child:
                      _isLoading
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: context.appColors.onPrimary,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            'Simpan Password',
                            style: AppTextStyles.titleMd.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: context.appColors.onPrimary,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPwField({
    required TextEditingController controller,
    required String label,
    required bool show,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return BkuTextField(
      controller: controller,
      obscureText: !show,
      validator: validator,
      style: AppTextStyles.bodyMd.copyWith(
        fontSize: 14,
        color: AppColors.neutral800,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySm.copyWith(
          fontSize: 13,
          color: AppColors.neutral600,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: AppColors.primary,
          size: 20,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: AppColors.neutral500,
            size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: AppColors.neutral100,
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.neutral500.withAlpha(40)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusLg,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }
}

// ─── Profile Bottom Sheet ─────────────────────────────────────────────────────

class _ProfileBottomSheet extends StatefulWidget {
  final dynamic profile;
  const _ProfileBottomSheet({required this.profile});

  @override
  State<_ProfileBottomSheet> createState() => _ProfileBottomSheetState();
}

class _ProfileBottomSheetState extends State<_ProfileBottomSheet> {
  bool _isUploading = false;

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    // Cache the provider before the async gap
    final provider = context.read<PsychologistDashboardProvider>();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() => _isUploading = true);
      try {
        await provider.uploadProfileAvatar(pickedFile.path);
        if (mounted) {
          AppSnackbar.showSuccess(context, 'Foto profil berhasil diperbarui');
        }
      } catch (e) {
        if (mounted) {
          AppSnackbar.showError(context, 'Gagal mengunggah foto: $e');
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final provider = context.watch<PsychologistDashboardProvider>();
    final profile = provider.profile;

    final name = profile?.name ?? widget.profile?.name ?? '-';
    final email = profile?.email ?? widget.profile?.email ?? '-';
    final phone = profile?.phone ?? widget.profile?.phone ?? '-';
    final spec =
        profile?.specialization ?? widget.profile?.specialization ?? '-';
    final location = profile?.location ?? widget.profile?.location ?? '-';
    final languages = profile?.languages ?? widget.profile?.languages ?? '-';
    final bio = profile?.bio ?? widget.profile?.bio ?? '';
    final nidn = profile?.nidn ?? widget.profile?.nidn ?? '-';
    final imageUrl =
        profile?.profileImageUrl ?? widget.profile?.profileImageUrl ?? '';
    final initials =
        name.trim().isEmpty
            ? 'P'
            : name
                .trim()
                .split(' ')
                .take(2)
                .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
                .join();

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.s20),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.neutral500.withAlpha(60),
              borderRadius: AppRadius.radiusXs,
            ),
          ),

          // Avatar + nama
          GestureDetector(
            onTap: _isUploading ? null : _pickAndUploadAvatar,
            child: Stack(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeProvider.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: themeProvider.primary.withAlpha(60),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child:
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(imageUrl: 
                            (() {
                              final url = ApiGate.getImageUrl(imageUrl);
                              final version = provider.avatarVersion;
                              return url.contains('?')
                                  ? '$url&v=$version'
                                  : '$url?v=$version';
                            })(),
                            fit: BoxFit.cover,
                            errorWidget:
                                (context, url, error) => Center(
                                  child: Text(
                                    initials,
                                    style: AppTextStyles.titleLg.copyWith(
                          color: context.appColors.onPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(color: AppColors.neutral200),
                  )
                  : Center(
                    child: Text(
                      initials,
                      style: AppTextStyles.titleLg.copyWith(
                        color: context.appColors.onPrimary,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                    child: Container(
                      padding: AppSpacing.padding6,
                      decoration: BoxDecoration(
                        color: context.appColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      size: 16,
                      color: themeProvider.primary,
                    ),
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                      child:  Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: context.appColors.onPrimary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            spec != '-' ? spec : 'Psikolog',
            style: AppTextStyles.bodySm.copyWith(
              fontSize: 13,
              color: AppColors.neutral600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: themeProvider.primary.withAlpha(12),
              borderRadius: AppRadius.radiusSm,
            ),
            child: Text(
              'NIDN: $nidn',
              style: AppTextStyles.labelMd.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: themeProvider.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.s20),

          // Info list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              children: [
                _infoTile(
                  Icons.email_rounded,
                  'Email',
                  email,
                  const Color(0xFFD1FAE5),
                  const Color(0xFF065F46),
                ),
                _infoTile(
                  Icons.phone_rounded,
                  'No. HP',
                  phone,
                  const Color(0xFFFEF3C7),
                  const Color(0xFFB45309),
                ),
                _infoTile(
                  Icons.location_on_rounded,
                  'Lokasi',
                  location,
                  const Color(0xFFE0E7FF),
                  const Color(0xFF4338CA),
                ),
                _infoTile(
                  Icons.language_rounded,
                  'Bahasa',
                  languages,
                  const Color(0xFFFCE7F3),
                  const Color(0xFFBE185D),
                ),
                if (bio.isNotEmpty)
                  _infoTile(
                    Icons.notes_rounded,
                    'Bio',
                    bio,
                    const Color(0xFFF0FDF4),
                    const Color(0xFF16A34A),
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.s20),

          // Edit button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.psychologistEditProfile);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neutral900,
                  foregroundColor: context.appColors.onPrimary,
                ),
                icon:  Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: context.appColors.onPrimary,
                ),
                label: Text(
                  'Edit Profil',
                  style: AppTextStyles.titleMd.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: context.appColors.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
    IconData icon,
    String label,
    String value,
    Color bg,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelMd.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral500,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: AppTextStyles.bodySm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutral800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationReminderBottomSheet extends StatefulWidget {
  const _NotificationReminderBottomSheet();

  @override
  State<_NotificationReminderBottomSheet> createState() =>
      _NotificationReminderBottomSheetState();
}

class _NotificationReminderBottomSheetState
    extends State<_NotificationReminderBottomSheet> {
  bool _sessionReminder = true;
  int _sessionReminderMinutes = 15;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sessionReminder = prefs.getBool('pref_session_reminder') ?? true;
      _sessionReminderMinutes =
          prefs.getInt('pref_session_reminder_minutes') ?? 15;
      _isLoading = false;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveIntPreference(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  void _testNotification() {
    // 1. Dapatkan nama mahasiswa dari booking hari ini jika ada
    final dashboardProvider = context.read<PsychologistDashboardProvider>();
    final bookings = dashboardProvider.upcomingBookings;

    String studentName = 'Ahmad Fathoni (Simulasi)';
    if (bookings.isNotEmpty) {
      final firstBooking = bookings.first;
      studentName = firstBooking['name'] ?? 'Mahasiswa';
    }

    final message =
        'Sesi konseling dengan $studentName akan dimulai dalam $_sessionReminderMinutes menit lagi! Siapkan ruang konseling online Anda.';

    // 2. Tambah ke CounselingProvider agar muncul di list notifikasi
    final counselingProvider = context.read<CounselingProvider>();
    final notifId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    counselingProvider.addLocalNotification({
      'id': notifId,
      'title': 'Pengingat Sesi Konseling',
      'desc': message,
      'time': 'Baru Saja',
      'type': 'booking',
      'unread': true,
    });

    // 2b. Trigger OS-level system tray notification
    LocalNotificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.hashCode,
      title: 'Pengingat Sesi Konseling',
      body: message,
    );

    // 3. Tampilkan peringatan menggunakan CustomDialog agar konsisten
    showDialog(
      context: context,
      builder:
          (context) => CustomDialog(
            title: 'Pengingat Sesi Konseling',
            content: message,
            cancelText: '',
            confirmText: 'Tutup',
            onCancel: () {},
            onConfirm: () => Navigator.pop(context),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
            color: context.appColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.radius28)),
          ),
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: const BkuShimmerList(itemCount: 2, itemHeight: 80),
      );
    }

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
                color: Colors.grey.withAlpha(80),
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
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.neutral900,
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

          // Switch: Session Reminder
          _buildSwitchTile(
            title: 'Pengingat Jadwal Sesi',
            subtitle: 'Ingatkan jadwal sesi sebelum dimulai',
            value: _sessionReminder,
            onChanged: (val) {
              setState(() => _sessionReminder = val);
              _savePreference('pref_session_reminder', val);
            },
          ),

          if (_sessionReminder) ...[
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Waktu Sebelum Sesi:',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.neutral600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neutral200,
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: Colors.grey.withAlpha(40)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _sessionReminderMinutes,
                        items:
                            [5, 10, 15, 30].map((int val) {
                              return DropdownMenuItem<int>(
                                value: val,
                                child: Text(
                                  '$val Menit',
                                  style: AppTextStyles.bodyMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => _sessionReminderMinutes = val);
                            _saveIntPreference(
                              'pref_session_reminder_minutes',
                              val,
                            );
                          }
                        },
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: themeProvider.primary,
                        ),
                        dropdownColor: context.appColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          // Outlined Button: Test Notifikasi
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: _sessionReminder ? _testNotification : null,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.neutral900.withAlpha(50)),
              ),
              icon: const Icon(
                Icons.notifications_active_rounded,
                color: AppColors.neutral900,
              ),
              label: Text(
                'Cek Notifikasi (Test)',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Primary Button: Simpan
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neutral900,
                foregroundColor: context.appColors.onPrimary,
              ),
              child: Text(
                'Tutup',
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.appColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral800,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                subtitle,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeThumbColor: context.read<ThemeProvider>().primary,
        ),
      ],
    );
  }
}

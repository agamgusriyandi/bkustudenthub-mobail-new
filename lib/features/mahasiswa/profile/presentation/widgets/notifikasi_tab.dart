import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class NotifikasiTabWidget extends StatefulWidget {
  const NotifikasiTabWidget({super.key});

  @override
  State<NotifikasiTabWidget> createState() => _NotifikasiTabWidgetState();
}

class _NotifikasiTabWidgetState extends State<NotifikasiTabWidget> {
  bool _emailNotif = false;
  bool _pushNotif = false;
  bool _inAppNotif = false;
  bool _isLoading = false;

  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = context.watch<ProfileProvider>();
    if (!_hasLoadedData && profile.rawProfileData.isNotEmpty) {
      _emailNotif = profile.emailNotif;
      _pushNotif = profile.pushNotif;
      _inAppNotif = profile.inAppNotif;
      _hasLoadedData = true;
    }
  }

  Future<void> _updatePreferences() async {
    setState(() => _isLoading = true);
    try {
      final profile = context.read<ProfileProvider>();
      profile.updateNotifPreferences(
        email: _emailNotif,
        push: _pushNotif,
        inApp: _inAppNotif,
      );
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        AppSnackbar.showSuccess(context, 'Preferensi berhasil disimpan');
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, 'Gagal menyimpan: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSwitch(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.s14),
      padding: AppSpacing.paddingLg,
      borderRadius: 22,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(18),
              borderRadius: AppRadius.br13,
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: AppSpacing.s14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.s3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.neutral600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Switch(
            value: value,
            onChanged: _isLoading ? null : onChanged,
            activeThumbColor: context.appColors.onPrimary,
            activeTrackColor: context.appColors.secondary,
            inactiveThumbColor: AppColors.neutral500,
            inactiveTrackColor: AppColors.neutral200,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Container(
          padding: AppSpacing.paddingLg,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: AppRadius.br20,
          ),
          child: Row(
            children: [
              Container(
                padding: AppSpacing.padding10,
                decoration: BoxDecoration(
                  color: AppColors.neutral200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: context.appColors.secondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.s14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferensi Notifikasi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s3),
                    Text(
                      'Atur saluran pemberitahuan yang ingin Anda aktifkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neutral700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.s20),

        _buildSwitch(
          'Notifikasi Email',
          'Info tagihan, tugas, dan pesan penting ke email Anda',
          Icons.mail_outline_rounded,
          context.appColors.info,
          _emailNotif,
          (val) {
            setState(() => _emailNotif = val);
            _updatePreferences();
          },
        ),
        _buildSwitch(
          'Push Notifications',
          'Pemberitahuan instan di layar handphone Anda',
          Icons.notifications_outlined,
          context.appColors.warning,
          _pushNotif,
          (val) {
            setState(() => _pushNotif = val);
            _updatePreferences();
          },
        ),
        _buildSwitch(
          'In-App Notifikasi',
          'Peringatan saat Anda sedang membuka aplikasi',
          Icons.devices_rounded,
          context.appColors.success,
          _inAppNotif,
          (val) {
            setState(() => _inAppNotif = val);
            _updatePreferences();
          },
        ),
        const SizedBox(height: AppSpacing.s120),
      ],
    );
  }
}

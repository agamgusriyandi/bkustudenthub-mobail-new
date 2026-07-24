import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';

class NotifikasiTabWidget extends StatefulWidget {
  final StudentProvider student;

  const NotifikasiTabWidget({super.key, required this.student});

  @override
  State<NotifikasiTabWidget> createState() => _NotifikasiTabWidgetState();
}

class _NotifikasiTabWidgetState extends State<NotifikasiTabWidget> {
  late bool _emailNotif;
  late bool _pushNotif;
  late bool _inAppNotif;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailNotif = widget.student.emailNotif;
    _pushNotif = widget.student.pushNotif;
    _inAppNotif = widget.student.inAppNotif;
  }

  Future<void> _updatePreferences() async {
    setState(() => _isLoading = true);
    try {
      widget.student.updateNotifPreferences(
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(18),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: _isLoading ? null : onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFF1E293B),
            inactiveThumbColor: const Color(0xFF94A3B8),
            inactiveTrackColor: const Color(0xFFE2E8F0),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Color(0xFF334155),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preferensi Notifikasi',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Atur saluran pemberitahuan yang ingin Anda aktifkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        _buildSwitch(
          'Notifikasi Email',
          'Info tagihan, tugas, dan pesan penting ke email Anda',
          Icons.mail_outline_rounded,
          const Color(0xFF3B82F6),
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
          const Color(0xFFF59E0B),
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
          const Color(0xFF10B981),
          _inAppNotif,
          (val) {
            setState(() => _inAppNotif = val);
            _updatePreferences();
          },
        ),
        const SizedBox(height: 120),
      ],
    );
  }
}

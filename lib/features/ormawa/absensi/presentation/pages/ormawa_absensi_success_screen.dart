import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';

class OrmawaAbsensiSuccessScreen extends StatefulWidget {
  final String eventId;
  final String eventTitle;
  final String studentName;
  final String nim;
  final DateTime timestamp;

  const OrmawaAbsensiSuccessScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
    required this.studentName,
    required this.nim,
    required this.timestamp,
  });

  @override
  State<OrmawaAbsensiSuccessScreen> createState() => _OrmawaAbsensiSuccessScreenState();
}

class _OrmawaAbsensiSuccessScreenState extends State<OrmawaAbsensiSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: const BoxDecoration(
                    color: BkuTheme.emeraldSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      color: BkuTheme.emerald,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: BkuTheme.emerald.withAlpha(80),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      'Presensi Berhasil!',
                      style: BkuTheme.textPageTitle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Kehadiran telah berhasil tercatat di sistem',
                      style: BkuTheme.textCaption.copyWith(
                        fontSize: 12.5,
                        color: BkuTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    BkuCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Nama Mahasiswa', widget.studentName, Icons.person_outline_rounded),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: BkuTheme.borderSubtle, height: 1),
                          ),
                          _buildDetailRow('NIM', widget.nim, Icons.badge_outlined),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: BkuTheme.borderSubtle, height: 1),
                          ),
                          _buildDetailRow('Kegiatan', widget.eventTitle, Icons.event_note_outlined),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: BkuTheme.borderSubtle, height: 1),
                          ),
                          _buildDetailRow('Waktu Presensi', dateFormat.format(widget.timestamp), Icons.access_time_rounded),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: BkuButton.primary(
                    onPressed: () {
                      int count = 0;
                      Navigator.popUntil(context, (route) {
                        return count++ == 2;
                      });
                    },
                    icon: Icons.check_circle_outline_rounded,
                    text: 'Selesai & Kembali',
                    height: 50,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: BkuTheme.primarySoft,
            borderRadius: BkuTheme.r8,
            border: Border.all(color: BkuTheme.primaryBorder),
          ),
          child: Icon(icon, size: 16, color: BkuTheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BkuTheme.textCaption.copyWith(
                  fontSize: 10.5,
                  color: BkuTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: BkuTheme.textCardTitle.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
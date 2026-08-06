import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';

// Screens
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/health_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_screen.dart';
// // import 'package:bkuhub_mobile/features/mahasiswa/achievement/presentation/pages/achievement_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/scholarship/presentation/pages/scholarship_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/student_voice/presentation/pages/student_voice_screen.dart';

class StudentStatusGrid extends StatelessWidget {
  final bool isLoading;
  final num kencanaPercentage;
  final String kencanaStatus;
  final int beasiswaTersedia;
  final int voiceAktif;
  final int voiceMenunggu;
  final dynamic latestHealth;

  const StudentStatusGrid({
    super.key,
    required this.isLoading,
    required this.kencanaPercentage,
    required this.kencanaStatus,
    required this.beasiswaTersedia,
    required this.voiceAktif,
    required this.voiceMenunggu,
    required this.latestHealth,
  });

  @override
  Widget build(BuildContext context) {
    IconData healthIcon = Icons.favorite_rounded;
    Color healthColor = context.appColors.error;
    String healthStatus = 'Normal';
    String healthSub = 'Ketuk untuk skrining';

    if (latestHealth != null && latestHealth is HealthRecord) {
      final HealthRecord record = latestHealth;
      final bmi = record.bmi;
      final bmiStatus = record.bmiStatus;

      // Default values based on BMI
      healthStatus = bmiStatus;
      healthSub = 'Skor BMI: ${bmi.toStringAsFixed(1)}';

      if (bmiStatus == 'Underweight') {
        healthIcon = Icons.health_and_safety_rounded;
        healthColor = AppColors.info;
      } else if (bmiStatus == 'Normal') {
        healthIcon = Icons.spa_rounded;
        healthColor = AppColors.success;
      } else if (bmiStatus == 'Overweight') {
        healthIcon = Icons.directions_run_rounded;
        healthColor = AppColors.warning;
      } else {
        healthIcon = Icons.warning_amber_rounded;
        healthColor = AppColors.error;
      }

      // Check for realistic screening JSON notes
      if (record.notes.isNotEmpty) {
        try {
          if (record.notes.startsWith('{') && record.notes.endsWith('}')) {
            final data = jsonDecode(record.notes) as Map<String, dynamic>;
            if (data['is_screening_realistis'] == true) {
              final stres = data['tingkat_stres'] ?? 3;
              final mood = data['mood'] ?? 'Baik';
              final keluhan = data['daftar_keluhan'] as List?;
              final hasKeluhan = keluhan != null && keluhan.isNotEmpty;

              if (stres >= 8 || record.bmiStatus == 'Obese' || hasKeluhan) {
                healthStatus = 'Perlu Perhatian';
                healthSub =
                    hasKeluhan ? keluhan.first.toString() : 'Stres: $stres/10';
                healthIcon = Icons.warning_amber_rounded;
                healthColor = AppColors.error;
              } else if (stres >= 5 || record.bmiStatus == 'Overweight') {
                healthStatus = 'Waspada';
                healthSub = 'Stres: $stres/10 • Mood: $mood';
                healthIcon = Icons.monitor_heart_rounded;
                healthColor = AppColors.warning;
              } else {
                healthStatus = 'Sangat Fit';
                healthSub = 'Tidur Cukup • Mood: $mood';
                healthIcon = Icons.spa_rounded;
                healthColor = AppColors.info;
              }
            }
          }
        } catch (_) {
          // Not JSON, fallback to BMI defaults
        }
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final aspectRatio = isTablet ? 2.3 : 1.75;

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            if (isLoading) ...[
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(AppRadius.radius20)),
              ),
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(AppRadius.radius20)),
              ),
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(AppRadius.radius20)),
              ),
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(AppRadius.radius20)),
              ),
            ] else ...[
              _StatusItem(
                label: 'KENCANA',
                value: '${kencanaPercentage.round()}%',
                subValue: kencanaStatus == 'Selesai ✓' ? 'Selesai' : kencanaStatus,
                icon: Icons.school_rounded,
                color: kencanaStatus == 'Selesai ✓' ? AppColors.success : (kencanaPercentage > 0 ? AppColors.info : AppColors.secondary),
                target: const KencanaScreen(),
              ),
              _StatusItem(
                label: 'Aspirasi Terbuka',
                value: '$voiceAktif',
                subValue: voiceMenunggu > 0 ? '$voiceMenunggu Menunggu' : (voiceAktif > 0 ? 'Diproses' : 'Aman'),
                icon: Icons.chat_rounded,
                color: voiceMenunggu > 0 ? AppColors.warning : (voiceAktif > 0 ? AppColors.info : AppColors.success),
                target: const StudentVoiceScreen(),
              ),
              _StatusItem(
                label: 'Beasiswa Aktif',
                value: '$beasiswaTersedia',
                subValue: beasiswaTersedia > 0 ? 'Terbuka' : 'Tutup',
                icon: Icons.menu_book_rounded,
                color: beasiswaTersedia > 0 ? AppColors.success : AppColors.secondary,
                target: const ScholarshipScreen(),
              ),
              _StatusItem(
                label: 'Kesehatan',
                value: healthStatus,
                subValue: healthSub,
                icon: healthIcon,
                color: healthColor,
                target: const HealthScreen(),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;
  final IconData icon;
  final Color color;
  final Widget target;

  const _StatusItem({
    required this.label,
    required this.value,
    required this.subValue,
    required this.icon,
    required this.color,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.br20,
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => target),
              ),
          borderRadius: AppRadius.br20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.br2,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 16, color: color),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: color,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: context.appColors.onSurface,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subValue,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: context.appColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withAlpha(50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: context.appColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

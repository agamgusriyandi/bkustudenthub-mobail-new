import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
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
  final int completedMissions;
  final int totalMissions;
  final int pendingAspirations;
  final int appliedScholarships;
  final dynamic latestHealth;

  const StudentStatusGrid({
    super.key,
    required this.isLoading,
    required this.completedMissions,
    required this.totalMissions,
    required this.pendingAspirations,
    required this.appliedScholarships,
    required this.latestHealth,
  });

  @override
  Widget build(BuildContext context) {
    IconData healthIcon = Icons.favorite_rounded;
    Color healthColor = Colors.redAccent;
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
                healthColor = Colors.teal;
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
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 75,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
            ] else ...[
              _StatusItem(
                label: 'Kencana',
                value: '$completedMissions/$totalMissions Misi',
                subValue: 'Progres Kamu',
                icon: Icons.auto_awesome_rounded,
                color: AppColors.warning,
                target: const KencanaScreen(),
              ),
              _StatusItem(
                label: 'Aspirasi',
                value: '$pendingAspirations Terbuka',
                subValue: 'Menunggu',
                icon: Icons.campaign_rounded,
                color: AppColors.error,
                target: const StudentVoiceScreen(),
              ),
              _StatusItem(
                label: 'Beasiswa',
                value: '$appliedScholarships Aktif',
                subValue: 'Pendaftaran',
                icon: Icons.school_rounded,
                color: AppColors.success,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(icon, size: 13, color: color),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subValue,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline.withAlpha(120),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

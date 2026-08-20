import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_kpi_card.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/health_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/presentation/pages/kencana_screen.dart';
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
    IconData healthIcon = Icons.monitor_heart_rounded;
    Color healthColor = BkuTheme.rose;
    String healthStatus = 'Normal';
    String healthSub = 'Ketuk untuk skrining';

    if (latestHealth != null && latestHealth is HealthRecord) {
      final HealthRecord record = latestHealth;
      final bmi = record.bmi;
      final bmiStatus = record.bmiStatus;

      healthStatus = bmiStatus;
      healthSub = 'Skor BMI: ${bmi.toStringAsFixed(1)}';

      if (bmiStatus == 'Underweight') {
        healthIcon = Icons.health_and_safety_rounded;
        healthColor = BkuTheme.sky;
      } else if (bmiStatus == 'Normal') {
        healthIcon = Icons.spa_rounded;
        healthColor = BkuTheme.emerald;
      } else if (bmiStatus == 'Overweight') {
        healthIcon = Icons.directions_run_rounded;
        healthColor = BkuTheme.amber;
      } else {
        healthIcon = Icons.warning_amber_rounded;
        healthColor = BkuTheme.rose;
      }

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
                healthColor = BkuTheme.rose;
              } else if (stres >= 5 || record.bmiStatus == 'Overweight') {
                healthStatus = 'Waspada';
                healthSub = 'Stres: $stres/10 • Mood: $mood';
                healthIcon = Icons.monitor_heart_rounded;
                healthColor = BkuTheme.amber;
              } else {
                healthStatus = 'Sangat Fit';
                healthSub = 'Tidur Cukup • Mood: $mood';
                healthIcon = Icons.spa_rounded;
                healthColor = BkuTheme.emerald;
              }
            }
          }
        } catch (_) {}
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 600;
        final crossAxisCount = isTablet ? 4 : 2;
        final aspectRatio = isTablet ? 1.4 : 1.18;

        if (isLoading) {
          return GridView.count(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: aspectRatio,
            children: List.generate(
              4,
              (_) => BkuShimmer(
                width: MediaQuery.of(context).size.width,
                height: 110,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }

        final double kencanaProgress = (kencanaPercentage / 100).clamp(0.0, 1.0).toDouble();

        return GridView.count(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: aspectRatio,
          children: [
            OrmawaKpiCard(
              title: 'Kencana PKKMB',
              value: '${kencanaPercentage.round()}%',
              icon: Icons.school_rounded,
              badgeText: kencanaStatus == 'Selesai ✓' ? 'Selesai' : '${kencanaPercentage.round()}%',
              badgeColor: kencanaStatus == 'Selesai ✓' ? BkuTheme.emerald : BkuTheme.indigo,
              subtitle: 'Orientasi Mahasiswa',
              progress: kencanaProgress,
              progressColor: kencanaStatus == 'Selesai ✓' ? BkuTheme.emerald : BkuTheme.indigo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KencanaScreen()),
              ),
            ),
            OrmawaKpiCard(
              title: 'Aspirasi Mahasiswa',
              value: '$voiceAktif',
              icon: Icons.chat_bubble_outline_rounded,
              badgeText: voiceMenunggu > 0 ? '$voiceMenunggu Pending' : (voiceAktif > 0 ? 'Diproses' : 'Aman'),
              badgeColor: voiceMenunggu > 0 ? BkuTheme.amber : (voiceAktif > 0 ? BkuTheme.sky : BkuTheme.emerald),
              subtitle: 'Laporan & masukan',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StudentVoiceScreen()),
              ),
            ),
            OrmawaKpiCard(
              title: 'Beasiswa Kampus',
              value: '$beasiswaTersedia',
              icon: Icons.workspace_premium_rounded,
              badgeText: beasiswaTersedia > 0 ? 'Terbuka' : 'Tutup',
              badgeColor: beasiswaTersedia > 0 ? BkuTheme.emerald : const Color(0xFF64748B),
              subtitle: 'Program bantuan aktif',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScholarshipScreen()),
              ),
            ),
            OrmawaKpiCard(
              title: 'Skrining Sehat',
              value: healthStatus,
              icon: healthIcon,
              badgeText: healthStatus == 'Normal' || healthStatus == 'Sangat Fit' ? 'Fit' : 'Skrining',
              badgeColor: healthColor,
              subtitle: healthSub,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HealthScreen()),
              ),
            ),
          ],
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_empty_card.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/domain/entities/recruitment_applicant.dart';
import 'package:bkuhub_mobile/features/ormawa/recruitment/presentation/widgets/recruitment_history_card.dart';

class RecruitmentHistoryScreen extends StatelessWidget {
  const RecruitmentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<RecruitmentApplicant> history = [];

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      appBar: const BkuStaticAppBar(
        title: 'Riwayat Keputusan',
        subtitle: 'Hasil Seleksi & Keputusan Rekrutmen',
        variant: AppBarVariant.ormawa,
      ),
      body: history.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: OrmawaEmptyCard(
                  title: 'Belum Ada Riwayat',
                  description: 'Riwayat keputusan seleksi dan kelulusan pendaftar akan tampil di sini.',
                  icon: Icons.history_rounded,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final applicant = history[index];
                return RecruitmentHistoryCard(applicant: applicant);
              },
            ),
    );
  }
}
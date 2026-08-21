import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_kpi_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/profile_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/health_view_model.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/report_health_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/klinik_booking_screen.dart';
import 'package:bkuhub_mobile/features/mahasiswa/health/presentation/pages/medical_referral_screen.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  int _currentScreeningPage = 1;
  static const int _screeningPerPage = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KlinikBookingScreen(),
            ),
          );
        },
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BkuTheme.rPill,
        ),
        backgroundColor: BkuTheme.emerald,
        icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
        label: Text(
          'Booking Klinik',
          style: BkuTheme.textBadge.copyWith(
            color: Colors.white,
            fontSize: 12.5,
          ),
        ),
      ),
      body: Consumer2<ProfileProvider, HealthViewModel>(
        builder: (context, student, health, child) {
          final latest = health.latestHealthRecord;
          return RefreshIndicator(
            onRefresh: () async {
              await health.refreshHealthData();
            },
            color: BkuTheme.primary,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              slivers: [
                const BkuAppBar(
                  title: 'Layanan Medis',
                  subtitle: 'Pusat Layanan Kesehatan Mahasiswa',
                  variant: AppBarVariant.student,
                  expandedHeight: 130,
                  showBackButton: true,
                  isExpandable: false,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.xl),
                        if (student.isLoading) ...[
                          const BkuShimmer(
                            width: double.infinity,
                            height: 140,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const BkuShimmer(
                            width: double.infinity,
                            height: 160,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const BkuShimmerList(itemCount: 2, itemHeight: 100),
                        ] else ...[
                          FadeInAnimation(
                            delay: 0.1,
                            child: latest == null
                                ? _buildEmptyWelcomeBanner(student)
                                : _buildDynamicWelcomeCard(student, latest),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FadeInAnimation(
                            delay: 0.15,
                            child: _buildReferralNavCard(context),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          if (latest != null) ...[
                            FadeInAnimation(
                              delay: 0.2,
                              child: _buildBMIIndicator(latest),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            FadeInAnimation(
                              delay: 0.25,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kondisi Tubuh Saat Ini',
                                    style: BkuTheme.textSectionTitle.copyWith(
                                      fontSize: 14,
                                      color: BkuTheme.textHeading,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ReportHealthScreen(),
                                        ),
                                      );
                                    },
                                    borderRadius: BkuTheme.rPill,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      child: Text(
                                        'Update Data',
                                        style: BkuTheme.textBadge.copyWith(
                                          color: BkuTheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FadeInAnimation(
                              delay: 0.3,
                              child: _buildStatsGrid(latest),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            FadeInAnimation(
                              delay: 0.35,
                              child: _buildHealthInsights(latest),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            if (health.healthRecords.isEmpty) ...[
                              Text(
                                'Riwayat Skrining Mandiri',
                                style: BkuTheme.textSectionTitle.copyWith(
                                  fontSize: 14,
                                  color: BkuTheme.textHeading,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 32),
                                  child: Text(
                                    'Belum ada riwayat skrining',
                                    style: BkuTheme.textCaption,
                                  ),
                                ),
                              ),
                            ] else ...[
                              () {
                                final totalRecords = health.healthRecords.length;
                                final totalPages = (totalRecords / _screeningPerPage).ceil();
                                final validPage = _currentScreeningPage.clamp(1, totalPages > 0 ? totalPages : 1);
                                final startIndex = (validPage - 1) * _screeningPerPage;
                                final endIndex = (startIndex + _screeningPerPage < totalRecords)
                                    ? startIndex + _screeningPerPage
                                    : totalRecords;
                                final paginatedRecords = health.healthRecords.sublist(startIndex, endIndex);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Riwayat Skrining Mandiri',
                                          style: BkuTheme.textSectionTitle.copyWith(
                                            fontSize: 14,
                                            color: BkuTheme.textHeading,
                                          ),
                                        ),
                                        if (totalPages > 1)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: BkuTheme.cardSurface,
                                              borderRadius: BkuTheme.rPill,
                                              border: Border.all(color: BkuTheme.border),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: validPage > 1
                                                      ? () => setState(() => _currentScreeningPage = validPage - 1)
                                                      : null,
                                                  borderRadius: BkuTheme.rPill,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Icon(
                                                      Icons.chevron_left_rounded,
                                                      size: 16,
                                                      color: validPage > 1 ? BkuTheme.primary : BkuTheme.textPlaceholder,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                                  child: Text(
                                                    '$validPage / $totalPages',
                                                    style: BkuTheme.textBadge.copyWith(
                                                      fontSize: 10,
                                                      color: BkuTheme.textMuted,
                                                    ),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: validPage < totalPages
                                                      ? () => setState(() => _currentScreeningPage = validPage + 1)
                                                      : null,
                                                  borderRadius: BkuTheme.rPill,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(2),
                                                    child: Icon(
                                                      Icons.chevron_right_rounded,
                                                      size: 16,
                                                      color: validPage < totalPages ? BkuTheme.primary : BkuTheme.textPlaceholder,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    ...List.generate(
                                      paginatedRecords.length,
                                      (index) => FadeInAnimation(
                                        delay: 0.05 + (index * 0.04),
                                        child: _buildHistoryCard(context, paginatedRecords[index]),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.s80),
                                  ],
                                );
                              }(),
                            ],
                          ] else ...[
                            FadeInAnimation(
                              delay: 0.2,
                              child: Text(
                                'Indikator yang Dipantau',
                                style: BkuTheme.textSectionTitle.copyWith(
                                  fontSize: 14,
                                  color: BkuTheme.textHeading,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FadeInAnimation(
                              delay: 0.25,
                              child: GridView.count(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.4,
                                children: [
                                  _buildEmptyStatTile('Tinggi Badan', 'cm', Icons.height_rounded, BkuTheme.indigo, BkuTheme.indigoSoft),
                                  _buildEmptyStatTile('Berat Badan', 'kg', Icons.monitor_weight_rounded, BkuTheme.emerald, BkuTheme.emeraldSoft),
                                  _buildEmptyStatTile('Tekanan Darah', 'mmHg', Icons.favorite_rounded, BkuTheme.rose, BkuTheme.roseSoft),
                                  _buildEmptyStatTile('Golongan Darah', 'Tipe', Icons.bloodtype_rounded, BkuTheme.amber, BkuTheme.amberSoft),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            FadeInAnimation(
                              delay: 0.3,
                              child: Text(
                                'Langkah Menjaga Kesehatan',
                                style: BkuTheme.textSectionTitle.copyWith(
                                  fontSize: 14,
                                  color: BkuTheme.textHeading,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            FadeInAnimation(
                              delay: 0.35,
                              child: Column(
                                children: [
                                  _buildGuideStep(
                                    1,
                                    'Update Parameter Vital',
                                    'Ukur tekanan darah, detak jantung, suhu, serta berat badanmu.',
                                    Icons.edit_note_rounded,
                                    BkuTheme.indigo,
                                    BkuTheme.indigoSoft,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const ReportHealthScreen()),
                                    ),
                                  ),
                                  _buildGuideStep(
                                    2,
                                    'Analisis BMI & Kesehatan',
                                    'Sistem langsung menghitung Indeks Massa Tubuh (BMI) idealmu.',
                                    Icons.calculate_rounded,
                                    BkuTheme.emerald,
                                    BkuTheme.emeraldSoft,
                                    onTap: () {
                                      AppSnackbar.showSuccess(
                                        context,
                                        'Analisis BMI dapat dilihat setelah Anda mengisi skrining awal.',
                                      );
                                    },
                                  ),
                                  _buildGuideStep(
                                    3,
                                    'Rekomendasi Medis Kampus',
                                    'Dapatkan saran dan langkah selanjutnya sesuai kondisimu.',
                                    Icons.medical_services_rounded,
                                    BkuTheme.teal,
                                    BkuTheme.tealSoft,
                                    onTap: () {
                                      AppSnackbar.showSuccess(
                                        context,
                                        'Rekomendasi medis akan muncul setelah kamu memperbarui data kesehatan.',
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: AppSpacing.s80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyWelcomeBanner(ProfileProvider student) {
    final firstName = student.name.split(' ').first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $firstName! 👋',
                  style: BkuTheme.textPageTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jaga kebugaran fisikmu untuk performa belajar optimal. Mulai isi skrining kesehatan pertamamu!',
                  style: BkuTheme.textCardSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: BkuTheme.emeraldSoft,
              borderRadius: BkuTheme.r16,
              border: Border.all(color: BkuTheme.emeraldBorder),
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: BkuTheme.emerald,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicWelcomeCard(
    ProfileProvider student,
    HealthRecord latest,
  ) {
    final firstName = student.name.split(' ').first;
    String statusText;
    String message;
    Color statusColor;
    Color statusBg;

    switch (latest.bmiStatus) {
      case 'Normal':
        statusText = 'Optimal & Ideal';
        message = 'Kondisi fisikmu berada di batas optimal. Pertahankan pola hidup sehatmu!';
        statusColor = BkuTheme.emerald;
        statusBg = BkuTheme.emeraldSoft;
        break;
      case 'Underweight':
        statusText = 'Berat Kurang';
        message = 'Status gizimu underweight. Tingkatkan asupan kalori dan nutrisi harian!';
        statusColor = BkuTheme.indigo;
        statusBg = BkuTheme.indigoSoft;
        break;
      case 'Overweight':
        statusText = 'Kelebihan Berat';
        message = 'Kondisi tubuhmu overweight. Batasi konsumsi gula dan rutin olahraga ringan!';
        statusColor = BkuTheme.amber;
        statusBg = BkuTheme.amberSoft;
        break;
      case 'Obese':
        statusText = 'Perhatian Medis';
        message = 'Kategori obesitas terdeteksi. Disarankan konsultasi dengan klinik kampus.';
        statusColor = BkuTheme.rose;
        statusBg = BkuTheme.roseSoft;
        break;
      default:
        statusText = 'Kondisi Terpantau';
        message = 'Terus pantau kesehatan fisikmu secara berkala di BKUHub.';
        statusColor = BkuTheme.teal;
        statusBg = BkuTheme.tealSoft;
    }

    final score = _calculateHealthScore(latest);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $firstName! 👋',
                  style: BkuTheme.textPageTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    'Kondisi: $statusText',
                    style: BkuTheme.textBadge.copyWith(
                      color: statusColor,
                      fontSize: 9.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: BkuTheme.textCaption.copyWith(
                    color: BkuTheme.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: (score / 100.0).clamp(0.0, 1.0),
                  strokeWidth: 4.5,
                  backgroundColor: BkuTheme.primarySoft,
                  valueColor: AlwaysStoppedAnimation<Color>(BkuTheme.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: BkuTheme.textKpiValue.copyWith(fontSize: 16),
                  ),
                  Text(
                    'SKOR',
                    style: BkuTheme.textCaption.copyWith(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w700,
                      color: BkuTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMIIndicator(HealthRecord latest) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r20,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Indeks Massa Tubuh (BMI)', style: BkuTheme.textCardSubtitle),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        latest.bmi.toStringAsFixed(1),
                        style: BkuTheme.textKpiValue.copyWith(
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: latest.bmiColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: latest.bmiColor.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          latest.bmiStatus.capitalizeFirstLetter(),
                          style: BkuTheme.textBadge.copyWith(
                            color: latest.bmiColor,
                            fontSize: 9.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              _buildHealthBadge(latest.bmiStatus, latest.bmiColor),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildBMISlider(latest.bmi),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: latest.bmiColor.withValues(alpha: 0.08),
              borderRadius: BkuTheme.r12,
              border: Border.all(color: latest.bmiColor.withValues(alpha: 0.16)),
            ),
            child: Text(
              _getBMIMessage(latest.bmiStatus),
              textAlign: TextAlign.center,
              style: BkuTheme.textCaption.copyWith(
                color: latest.bmiColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMISlider(double bmi) {
    double progress = (bmi - 15) / (35 - 15);
    progress = progress.clamp(0.0, 1.0);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) => Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [
                      BkuTheme.indigo,
                      BkuTheme.emerald,
                      BkuTheme.amber,
                      BkuTheme.rose,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: (constraints.maxWidth * progress - 4).clamp(
                  0.0,
                  constraints.maxWidth - 8,
                ),
                top: 0,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['15', '20', '25', '30', '35']
              .map(
                (v) => Text(
                  v,
                  style: BkuTheme.textCaption.copyWith(
                    fontSize: 9.5,
                    color: BkuTheme.textPlaceholder,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildHealthBadge(String status, Color color) {
    String emoji;
    switch (status) {
      case 'Underweight':
        emoji = '🥗';
        break;
      case 'Normal':
        emoji = '😊';
        break;
      case 'Overweight':
        emoji = '🏃‍♂️';
        break;
      case 'Obese':
        emoji = '⚠️';
        break;
      default:
        emoji = '✨';
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BkuTheme.r16,
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }

  String _getBMIMessage(String status) {
    switch (status) {
      case 'Underweight':
        return 'Berat badanmu kurang. Yuk, mulai perbaiki nutrisi harianmu!';
      case 'Normal':
        return 'Keren! Kondisi tubuhmu ideal. Pertahankan pola hidup sehatmu!';
      case 'Overweight':
        return 'Sedikit kelebihan berat badan. Coba kurangi konsumsi gula dan rutin olahraga ya.';
      case 'Obese':
        return 'Kondisi obesitas perlu perhatian khusus. Konsultasikan dengan tim medis kampus yuk.';
      default:
        return 'Tetap pantau kesehatanmu setiap hari.';
    }
  }

  Widget _buildStatsGrid(HealthRecord latest) {
    Map<String, dynamic>? data;
    try {
      if (latest.notes.startsWith('{') && latest.notes.endsWith('}')) {
        data = jsonDecode(latest.notes) as Map<String, dynamic>;
      }
    } catch (_) {}

    final jamTidur = data?['jam_tidur'] ?? 8;
    final olahraga = data?['olahraga'] ?? 2;
    final air = data?['konsumsi_air'] ?? 2.0;
    final stres = data?['tingkat_stres'] ?? 5;

    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.18,
      children: [
        BkuKpiCard(
          title: 'Tinggi Badan',
          value: latest.height.toStringAsFixed(0),
          subtitle: 'cm (Sentimeter)',
          icon: Icons.straighten_rounded,
          badgeColor: BkuTheme.indigo,
          badgeText: 'cm',
        ),
        BkuKpiCard(
          title: 'Berat Badan',
          value: latest.weight.toStringAsFixed(0),
          subtitle: 'kg (Kilogram)',
          icon: Icons.monitor_weight_rounded,
          badgeColor: BkuTheme.emerald,
          badgeText: 'kg',
        ),
        BkuKpiCard(
          title: 'Tidur Harian',
          value: '$jamTidur',
          subtitle: 'Jam per hari',
          icon: Icons.bedtime_rounded,
          badgeColor: BkuTheme.teal,
          badgeText: 'Jam',
        ),
        BkuKpiCard(
          title: 'Olahraga',
          value: '$olahraga',
          subtitle: 'Sesi per minggu',
          icon: Icons.fitness_center_rounded,
          badgeColor: BkuTheme.amber,
          badgeText: 'x/Mgg',
        ),
        BkuKpiCard(
          title: 'Konsumsi Air',
          value: air.toStringAsFixed(1),
          subtitle: 'Liter per hari',
          icon: Icons.water_drop_rounded,
          badgeColor: BkuTheme.indigo,
          badgeText: 'L/Hari',
        ),
        BkuKpiCard(
          title: 'Tingkat Stres',
          value: '$stres',
          subtitle: 'Skala evaluasi',
          icon: Icons.psychology_rounded,
          badgeColor: BkuTheme.rose,
          badgeText: '/10',
        ),
      ],
    );
  }

  Widget _buildHealthInsights(HealthRecord latest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saran & Rekomendasi Medis', style: BkuTheme.textSectionTitle),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: [
              _buildInsightCard(
                'Nutrisi Harian',
                latest.bmiStatus == 'Normal'
                    ? 'Pertahankan asupan serat dan protein harianmu.'
                    : 'Sesuaikan kalori dengan aktivitas harianmu.',
                Icons.restaurant_rounded,
                BkuTheme.amber,
                BkuTheme.amberSoft,
              ),
              _buildInsightCard(
                'Aktivitas Fisik',
                'Jalan santai atau peregangan 30 menit setiap pagi.',
                Icons.directions_run_rounded,
                BkuTheme.emerald,
                BkuTheme.emeraldSoft,
              ),
              _buildInsightCard(
                'Kualitas Tidur',
                'Pastikan tidur 7-8 jam per hari untuk metabolisme.',
                Icons.bedtime_rounded,
                BkuTheme.indigo,
                BkuTheme.indigoSoft,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    String title,
    String desc,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      width: 210,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: BkuTheme.textCaption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HealthRecord record) {
    Color statusBg = BkuTheme.statusSuccessBg;
    Color statusText = BkuTheme.statusSuccessText;
    Color statusBorder = BkuTheme.statusSuccessBorder;
    IconData cardIcon = Icons.health_and_safety_rounded;

    final statusLower = record.bmiStatus.toLowerCase();
    if (statusLower.contains('underweight') || statusLower.contains('kurang')) {
      statusBg = BkuTheme.indigoSoft;
      statusText = BkuTheme.indigo;
      statusBorder = BkuTheme.indigoBorder;
      cardIcon = Icons.monitor_weight_rounded;
    } else if (statusLower.contains('overweight') || statusLower.contains('kelebihan')) {
      statusBg = BkuTheme.statusWarningBg;
      statusText = BkuTheme.statusWarningText;
      statusBorder = BkuTheme.statusWarningBorder;
      cardIcon = Icons.warning_amber_rounded;
    } else if (statusLower.contains('obese') || statusLower.contains('obesitas')) {
      statusBg = BkuTheme.statusDangerBg;
      statusText = BkuTheme.statusDangerText;
      statusBorder = BkuTheme.statusDangerBorder;
      cardIcon = Icons.error_outline_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHistoryDetail(context, record),
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: statusBorder),
                  ),
                  child: Icon(cardIcon, size: 22, color: statusText),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.date.day}/${record.date.month}/${record.date.year}',
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'BMI: ${record.bmi.toStringAsFixed(1)} • ${record.weight.toStringAsFixed(0)} kg • ${record.height.toStringAsFixed(0)} cm',
                        style: BkuTheme.textCaption,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BkuTheme.rPill,
                    border: Border.all(color: statusBorder),
                  ),
                  child: Text(
                    record.bmiStatus,
                    style: BkuTheme.textBadge.copyWith(
                      color: statusText,
                      fontSize: 9.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showHistoryDetail(BuildContext context, HealthRecord record) {
    BkuBottomSheet.show(
      context: context,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Detail Skrining Mandiri', style: BkuTheme.textPageTitle.copyWith(fontSize: 16)),
            Text('${record.date.day}/${record.date.month}/${record.date.year}', style: BkuTheme.textCardSubtitle),
            const SizedBox(height: AppSpacing.xl),
            _buildDetailRow('Tinggi Badan', '${record.height.toStringAsFixed(0)} cm', Icons.height_rounded, BkuTheme.indigo, BkuTheme.indigoSoft),
            _buildDetailRow('Berat Badan', '${record.weight.toStringAsFixed(0)} kg', Icons.monitor_weight_rounded, BkuTheme.emerald, BkuTheme.emeraldSoft),
            _buildDetailRow('Tekanan Darah', record.bloodPressure, Icons.favorite_rounded, BkuTheme.rose, BkuTheme.roseSoft),
            _buildDetailRow('Golongan Darah', record.bloodType, Icons.bloodtype_rounded, BkuTheme.amber, BkuTheme.amberSoft),
            if (record.gulaDarah != null)
              _buildDetailRow('Gula Darah', '${record.gulaDarah} mg/dL', Icons.water_drop_rounded, BkuTheme.rose, BkuTheme.roseSoft),
            _buildNotesSection(record),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: BkuButton(
                text: 'Tutup',
                variant: BkuButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection(HealthRecord record) {
    if (record.notes.isEmpty) return const SizedBox.shrink();

    Map<String, dynamic>? data;
    try {
      if (record.notes.startsWith('{') && record.notes.endsWith('}')) {
        data = jsonDecode(record.notes) as Map<String, dynamic>;
      }
    } catch (_) {}

    if (data == null || data['is_screening_realistis'] != true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text('Catatan / Keluhan:', style: BkuTheme.textSectionTitle),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: BkuTheme.cardSurface,
              borderRadius: BkuTheme.r12,
              border: Border.all(color: BkuTheme.border),
            ),
            child: Text(record.notes, style: BkuTheme.textBodyRegular),
          ),
        ],
      );
    }

    final jamTidur = data['jam_tidur'] ?? 8;
    final olahraga = data['olahraga'] ?? 0;
    final air = data['konsumsi_air'] ?? 2.0;
    final stres = data['tingkat_stres'] ?? 5;
    final mood = data['mood'] ?? 'Biasa Saja';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.lg),
        Text('Gaya Hidup & Pola Istirahat', style: BkuTheme.textSectionTitle),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: BkuTheme.cardSurface,
            borderRadius: BkuTheme.r16,
            border: Border.all(color: BkuTheme.border),
          ),
          child: Column(
            children: [
              _buildDetailInfoRow('Tidur Harian', '$jamTidur Jam', Icons.bedtime_rounded, BkuTheme.indigo),
              _buildDetailInfoRow('Olahraga', '$olahraga Kali/Minggu', Icons.fitness_center_rounded, BkuTheme.emerald),
              _buildDetailInfoRow('Konsumsi Air', '$air Liter/Hari', Icons.water_drop_rounded, BkuTheme.teal),
              const Divider(height: 16, color: BkuTheme.borderSubtle),
              _buildDetailInfoRow('Tingkat Stres', '$stres / 10', Icons.psychology_rounded, BkuTheme.amber),
              _buildDetailInfoRow('Suasana Hati (Mood)', mood, Icons.mood_rounded, BkuTheme.indigo),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Text(label, style: BkuTheme.textCaption),
          const Spacer(),
          Text(
            value,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: BkuTheme.textCardSubtitle),
          const Spacer(),
          Text(
            value,
            style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStatTile(
    String label,
    String unit,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const Icon(Icons.lock_outline_rounded, size: 13, color: BkuTheme.textPlaceholder),
            ],
          ),
          const Spacer(),
          Text(
            label,
            style: BkuTheme.textCaption.copyWith(color: BkuTheme.textMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 1),
          Text(
            '-- $unit',
            style: BkuTheme.textKpiValue.copyWith(
              fontSize: 18,
              color: BkuTheme.textPlaceholder,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideStep(
    int number,
    String title,
    String desc,
    IconData icon,
    Color color,
    Color bg, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r16,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BkuTheme.r16,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BkuTheme.r12,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        desc,
                        style: BkuTheme.textCaption,
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(top: 10, left: 4),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: BkuTheme.textPlaceholder,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _calculateHealthScore(HealthRecord r) {
    double score = 100;
    double bmi = r.bmi;
    if (bmi >= 30) {
      score -= 25;
    } else if (bmi >= 25 || bmi < 18.5) {
      score -= 12;
    }

    final parts = r.bloodPressure.split('/');
    if (parts.length == 2) {
      int sys = int.tryParse(parts[0]) ?? 120;
      int dia = int.tryParse(parts[1]) ?? 80;
      if (sys >= 140 || dia >= 90) {
        score -= 18;
      } else if (sys >= 130 || dia >= 80) {
        score -= 10;
      }
    }

    if (r.notes.startsWith('{')) {
      try {
        final data = jsonDecode(r.notes);
        int sleep = data['jam_tidur'] ?? 8;
        if (sleep < 7) {
          score -= (7 - sleep) * 4;
        } else if (sleep > 9) {
          score -= (sleep - 9) * 4;
        }
        double water = double.tryParse(data['konsumsi_air'].toString()) ?? 2.0;
        if (water < 2.0) {
          score -= ((2.0 - water) / 0.5) * 5;
        }
        int sports = data['olahraga'] ?? 0;
        if (sports < 2) {
          score -= (2 - sports) * 6;
        }
        int stress = data['tingkat_stres'] ?? 5;
        if (stress > 4) {
          score -= (stress - 4) * 4;
        }
        String smoking = data['merokok'] ?? 'Tidak';
        if (smoking.toLowerCase() == 'ya') {
          score -= 15;
        }
        final symptoms = data['daftar_keluhan'] as List?;
        if (symptoms != null) {
          score -= symptoms.length * 6;
        }
      } catch (_) {}
    }

    if (score < 10) score = 10;
    if (score > 100) score = 100;
    return score.toInt();
  }

  Widget _buildReferralNavCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BkuTheme.cardSurface,
        borderRadius: BkuTheme.r18,
        border: Border.all(color: BkuTheme.border),
        boxShadow: BkuTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MedicalReferralScreen(),
              ),
            );
          },
          borderRadius: BkuTheme.r18,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BkuTheme.indigoSoft,
                    borderRadius: BkuTheme.r12,
                    border: Border.all(color: BkuTheme.indigoBorder),
                  ),
                  child: const Icon(
                    Icons.medical_information_rounded,
                    color: BkuTheme.indigo,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Surat Rujukan Medis',
                        style: BkuTheme.textCardTitle.copyWith(fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Akses & download surat rujukan klinik yang telah disetujui.',
                        style: BkuTheme.textCaption,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: BkuTheme.textPlaceholder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

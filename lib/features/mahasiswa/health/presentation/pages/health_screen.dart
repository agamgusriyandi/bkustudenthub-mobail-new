import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/health_record.dart';
import 'package:bkuhub_mobile/core/extensions/string_extensions.dart';
import 'package:bkuhub_mobile/core/widgets/fade_in_animation.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'report_health_screen.dart';
import 'klinik_booking_screen.dart';
import 'medical_referral_screen.dart';

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
    final student = context.watch<StudentProvider>();
    final latest = student.latestHealthRecord;

    return Scaffold(
      backgroundColor: context.appColors.surface,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KlinikBookingScreen(),
            ),
          );
        },
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
        ),
        backgroundColor: context.appColors.success,
        icon: Icon(Icons.calendar_month_rounded, color: context.appColors.onPrimary),
        label: Text(
          'Booking Klinik',
          style: TextStyle(
            color: context.appColors.onPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await student.refreshHealthData();
        },
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
          ),
          slivers: [
            BkuAppBar(
              title: 'Layanan Medis',
              subtitle: 'PUSAT LAYANAN KESEHATAN MAHASISWA',
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
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const BkuShimmer(
                        width: double.infinity,
                        height: 180,
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.radius20)),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const BkuShimmerList(itemCount: 2, itemHeight: 120),
                    ] else ...[
                      // Welcome Banner
                      FadeInAnimation(
                        delay: 0.1,
                        child:
                            latest == null
                                ? _buildEmptyWelcomeBanner(student)
                                : _buildDynamicWelcomeCard(student, latest),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Medical Referral Nav Card
                      FadeInAnimation(
                        delay: 0.15,
                        child: _buildReferralNavCard(context),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Self Screening Dashboard
                      if (latest != null) ...[
                        // Populated Screening Dashboard State
                        FadeInAnimation(
                          delay: 0.2,
                          child: _buildBMIIndicator(latest),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        FadeInAnimation(
                          delay: 0.3,
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral900,
                                  borderRadius: AppRadius.radiusXs,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.s10),
                              Text(
                                'Kondisi Tubuh Saat Ini',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.neutral900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FadeInAnimation(
                          delay: 0.4,
                          child: _buildStatsGrid(latest),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        FadeInAnimation(
                          delay: 0.5,
                          child: _buildHealthInsights(latest),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        if (student.healthRecords.isEmpty) ...[
                          Text(
                            'Riwayat Skrining Mandiri',
                            style: AppTextStyles.titleLg.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xxxl,
                              ),
                              child: Text(
                                'Belum ada riwayat skrining',
                                style: AppTextStyles.labelMd.copyWith(
                                  color: AppColors.neutral500,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          () {
                            final totalRecords = student.healthRecords.length;
                            final totalPages = (totalRecords / _screeningPerPage).ceil();
                            final validPage = _currentScreeningPage.clamp(1, totalPages > 0 ? totalPages : 1);
                            final startIndex = (validPage - 1) * _screeningPerPage;
                            final endIndex = (startIndex + _screeningPerPage < totalRecords)
                                ? startIndex + _screeningPerPage
                                : totalRecords;
                            final paginatedRecords = student.healthRecords.sublist(startIndex, endIndex);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Riwayat Skrining Mandiri',
                                      style: AppTextStyles.titleLg.copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.neutral900,
                                      ),
                                    ),
                                    if (totalPages > 1)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.neutral100,
                                          borderRadius: AppRadius.br10,
                                          border: Border.all(
                                            color: AppColors.neutral400,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            InkWell(
                                              onTap: validPage > 1
                                                  ? () => setState(() => _currentScreeningPage = validPage - 1)
                                                  : null,
                                              borderRadius: AppRadius.br6,
                                              child: Padding(
                                                padding: AppSpacing.paddingXs,
                                                child: Icon(
                                                  Icons.chevron_left_rounded,
                                                  size: 18,
                                                  color: validPage > 1
                                                      ? context.appColors.secondary
                                                      : AppColors.neutral500,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 6),
                                              child: Text(
                                                '$validPage / $totalPages',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: context.appColors.secondaryContainer,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: validPage < totalPages
                                                  ? () => setState(() => _currentScreeningPage = validPage + 1)
                                                  : null,
                                              borderRadius: AppRadius.br6,
                                              child: Padding(
                                                padding: AppSpacing.paddingXs,
                                                child: Icon(
                                                  Icons.chevron_right_rounded,
                                                  size: 18,
                                                  color: validPage < totalPages
                                                      ? context.appColors.secondary
                                                      : AppColors.neutral500,
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
                                    delay: 0.05 + (index * 0.03),
                                    child: _buildHistoryCard(
                                      context,
                                      paginatedRecords[index],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.s80),
                              ],
                            );
                          }(),
                        ],
                      ] else ...[
                        // Empty Screening Dashboard State
                        FadeInAnimation(
                          delay: 0.2,
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.neutral900,
                                  borderRadius: AppRadius.radiusXs,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Indikator yang Akan Dipantau',
                                style: AppTextStyles.titleLg.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.neutral900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        FadeInAnimation(
                          delay: 0.3,
                          child: GridView.count(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.15,
                            children: [
                              _buildEmptyStatTile(
                                'Tinggi Badan',
                                'cm',
                                Icons.height_rounded,
                                AppColors.info,
                              ),
                              _buildEmptyStatTile(
                                'Berat Badan',
                                'kg',
                                Icons.monitor_weight_rounded,
                                AppColors.success,
                              ),
                              _buildEmptyStatTile(
                                'Tekanan Darah',
                                'mmHg',
                                Icons.favorite_rounded,
                                AppColors.error,
                              ),
                              _buildEmptyStatTile(
                                'Golongan Darah',
                                'Tipe',
                                Icons.bloodtype_rounded,
                                AppColors.warning,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.s28),
                        FadeInAnimation(
                          delay: 0.4,
                          child: Text(
                            '3 Langkah Mudah Memulai',
                            style: AppTextStyles.titleLg.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neutral900,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FadeInAnimation(
                          delay: 0.5,
                          child: Column(
                            children: [
                              _buildGuideStep(
                                1,
                                'Update Parameter Vital',
                                'Ukur tekanan darah, detak jantung, suhu, serta berat badanmu.',
                                Icons.edit_note_rounded,
                                AppColors.info,
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                const ReportHealthScreen(),
                                      ),
                                    ),
                              ),
                              _buildGuideStep(
                                2,
                                'Analisis BMI & Kesehatan',
                                'Sistem langsung menghitung Indeks Massa Tubuh (BMI) idealmu.',
                                Icons.calculate_rounded,
                                AppColors.info,
                                onTap: () {
                                  AppSnackbar.showSuccess(
                                    context,
                                    'Analisis BMI kamu dapat dilihat di bagian atas halaman ini.',
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _buildGuideStep(
                                3,
                                'Dapatkan Rekomendasi Medis',
                                'Sistem akan memberikan saran dan langkah selanjutnya sesuai kondisimu.',
                                Icons.medical_services_rounded,
                                AppColors.primary,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWelcomeBanner(StudentProvider student) {
    final firstName = student.name.split(' ').first;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $firstName! 👋',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.neutral900,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  'Jaga kebugaran tubuhmu untuk performa belajar yang optimal. Mulai isi skrining kesehatan pertamamu!',
                  style: AppTextStyles.labelSm.copyWith(
                    color: themeProvider.outline,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: themeProvider.primary.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.spa_rounded,
              color: themeProvider.primary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicWelcomeCard(
    StudentProvider student,
    HealthRecord latest,
  ) {
    final firstName = student.name.split(' ').first;
    final themeProvider = context.watch<ThemeProvider>();
    String statusText;
    String message;

    switch (latest.bmiStatus) {
      case 'Normal':
        statusText = 'Sangat Baik & Ideal';
        message =
            'Keren! Kondisi fisikmu berada di batas optimal. Pertahankan pola hidup sehatmu!';
        break;
      case 'Underweight':
        statusText = 'Berat Badan Kurang';
        message =
            'Status gizimu underweight. Yuk, perbaiki nutrisi harian dan asupan kalori proteinmu!';
        break;
      case 'Overweight':
        statusText = 'Kelebihan Berat Badan';
        message =
            'Kondisi tubuhmu overweight. Coba batasi makanan manis dan rutin olahraga ringan ya!';
        break;
      case 'Obese':
        statusText = 'Perhatian Khusus (Obesitas)';
        message =
            'Kategori obesitas terdeteksi. Sebaiknya jadwalkan konsultasi dengan klinik kampus.';
        break;
      default:
        statusText = 'Kondisi Terpantau';
        message = 'Terus pantau kesehatan fisikmu secara berkala di BKUHub.';
    }

    final score = _calculateHealthScore(latest);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $firstName! 👋',
                  style: AppTextStyles.titleLg.copyWith(
                    color: AppColors.neutral900,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.s6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: themeProvider.primary.withAlpha(15),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Text(
                    'Kondisimu: $statusText',
                    style: AppTextStyles.labelSm.copyWith(
                      color: themeProvider.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.s10),
                Text(
                  message,
                  style: AppTextStyles.labelSm.copyWith(
                    color: themeProvider.outline,
                    fontSize: 11,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: score / 100.0,
                  strokeWidth: 5,
                  backgroundColor: themeProvider.primary.withAlpha(20),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    themeProvider.primary,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score',
                    style: const TextStyle(
                      color: AppColors.neutral900,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'SKOR',
                    style: TextStyle(
                      color: themeProvider.outline,
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
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
    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Indeks Massa Tubuh (BMI)',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        latest.bmi.toStringAsFixed(1),
                        style: AppTextStyles.headlineMd.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral900,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: latest.bmiColor.withAlpha(20),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: latest.bmiColor.withAlpha(50),
                          ),
                        ),
                        child: Text(
                          latest.bmiStatus.capitalizeFirstLetter(),
                          style: AppTextStyles.labelSm.copyWith(
                            color: latest.bmiColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
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
          const SizedBox(height: AppSpacing.xl),
          _buildBMISlider(latest.bmi),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: latest.bmiColor.withAlpha(10),
              borderRadius: AppRadius.radiusLg,
            ),
            child: Text(
              _getBMIMessage(latest.bmiStatus),
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSm.copyWith(
                color: latest.bmiColor,
                height: 1.4,
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
          builder:
              (context, constraints) => Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 10,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: AppRadius.radiusXs,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.info,
                          AppColors.success,
                          AppColors.warning,
                          AppColors.error,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: (constraints.maxWidth * progress - 4).clamp(
                      0.0,
                      constraints.maxWidth - 8,
                    ),
                    top: 1,
                    child: Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ),
        const SizedBox(height: AppSpacing.s10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              ['15', '20', '25', '30', '35']
                  .map(
                    (v) => Text(
                      v,
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.outline,
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: color.withAlpha(15),
            borderRadius: AppRadius.radiusLg,
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 32)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          status == 'Normal' ? 'Baik' : status.capitalizeFirstLetter(),
          style: AppTextStyles.labelSm.copyWith(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
    } catch (_) { /* Silenced: non-critical parse fallback */ }

    final jamTidur = data?['jam_tidur'] ?? 8;
    final olahraga = data?['olahraga'] ?? 2;
    final air = data?['konsumsi_air'] ?? 2.0;
    final stres = data?['tingkat_stres'] ?? 5;

    return GridView.count(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        _buildStatTile(
          'Tinggi Badan',
          latest.height.toStringAsFixed(0),
          'cm',
          Icons.straighten_rounded,
          AppColors.info,
        ),
        _buildStatTile(
          'Berat Badan',
          latest.weight.toStringAsFixed(0),
          'kg',
          Icons.monitor_weight_rounded,
          AppColors.success,
        ),
        _buildStatTile(
          'Tidur Harian',
          '$jamTidur',
          'Jam',
          Icons.bedtime_rounded,
          AppColors.info,
        ),
        _buildStatTile(
          'Olahraga',
          '$olahraga',
          'x/Mgg',
          Icons.fitness_center_rounded,
          AppColors.warning,
        ),
        _buildStatTile(
          'Konsumsi Air',
          air.toStringAsFixed(1),
          'L/Hari',
          Icons.water_drop_rounded,
          AppColors.info,
        ),
        _buildStatTile(
          'Tingkat Stres',
          '$stres',
          '/10',
          Icons.psychology_rounded,
          AppColors.secondary,
        ),
      ],
    );
  }

  Widget _buildStatTile(
    String label,
    String value,
    String unit,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: color.withAlpha(20), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.success.withAlpha(100),
                  size: 14,
                ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: value,
                      style: AppTextStyles.labelMd.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: AppColors.neutral900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInsights(HealthRecord latest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Saran Kesehatan',
          style: AppTextStyles.titleLg.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.neutral900,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Row(
            children: [
              _buildInsightCard(
                'Nutrisi Harian',
                latest.bmiStatus == 'Normal'
                    ? 'Pertahankan asupan serat & proteinmu.'
                    : 'Atur kalori sesuai kebutuhan tubuhmu.',
                Icons.restaurant_rounded,
                AppColors.warning,
              ),
              _buildInsightCard(
                'Aktivitas Fisik',
                'Jalan santai 30 menit setiap pagi sangat baik.',
                Icons.directions_run_rounded,
                AppColors.info,
              ),
              _buildInsightCard(
                'Kualitas Tidur',
                'Pastikan tidur 7-8 jam untuk regenerasi sel.',
                Icons.bedtime_rounded,
                AppColors.info,
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
  ) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withAlpha(20), color.withAlpha(5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: color.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            desc,
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
              height: 1.3,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, HealthRecord record) {
    Color cardBg;
    Color borderColor;
    Color iconBgColor;
    Color iconColor;
    IconData cardIcon;
    Color statusTextColor;
    Color statusBadgeBg;

    final statusLower = record.bmiStatus.toLowerCase();
    if (statusLower.contains('normal') || statusLower.contains('sehat') || statusLower.contains('ideal')) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFF86EFAC);
      iconBgColor = const Color(0xFFDCFCE7);
      iconColor = const Color(0xFF16A34A);
      cardIcon = Icons.health_and_safety_rounded;
      statusTextColor = const Color(0xFF15803D);
      statusBadgeBg = const Color(0xFFDCFCE7);
    } else if (statusLower.contains('underweight') || statusLower.contains('kurang')) {
      cardBg = const Color(0xFFEFF6FF);
      borderColor = const Color(0xFF93C5FD);
      iconBgColor = const Color(0xFFDBEAFE);
      iconColor = const Color(0xFF2563EB);
      cardIcon = Icons.monitor_weight_rounded;
      statusTextColor = const Color(0xFF1D4ED8);
      statusBadgeBg = const Color(0xFFDBEAFE);
    } else if (statusLower.contains('overweight') || statusLower.contains('kelebihan')) {
      cardBg = const Color(0xFFFEF3C7);
      borderColor = const Color(0xFFFCD34D);
      iconBgColor = const Color(0xFFFEF3C7);
      iconColor = const Color(0xFFD97706);
      cardIcon = Icons.warning_amber_rounded;
      statusTextColor = const Color(0xFFB45309);
      statusBadgeBg = const Color(0xFFFEF3C7);
    } else {
      cardBg = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFCA5A5);
      iconBgColor = const Color(0xFFFEE2E2);
      iconColor = const Color(0xFFDC2626);
      cardIcon = Icons.error_outline_rounded;
      statusTextColor = const Color(0xFFB91C1C);
      statusBadgeBg = const Color(0xFFFEE2E2);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showHistoryDetail(context, record),
          borderRadius: AppRadius.radiusLg,
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              children: [
                Container(
                  padding: AppSpacing.paddingMd,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    cardIcon,
                    size: 24,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${record.date.day}/${record.date.month}/${record.date.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: context.appColors.secondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.s3),
                      Text(
                        'BMI: ${record.bmi.toStringAsFixed(1)} • ${record.weight} kg • ${record.height} cm',
                        style: const TextStyle(
                          color: AppColors.neutral600,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusBadgeBg,
                    borderRadius: AppRadius.radiusSm,
                    border: Border.all(color: borderColor),
                  ),
                  child: Text(
                    record.bmiStatus,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: context.appColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                        borderRadius: AppRadius.radiusXs,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Detail Skrining',
                    style: AppTextStyles.titleLg.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.neutral900,
                    ),
                  ),
                  Text(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildDetailRow(
                    'Tinggi Badan',
                    '${record.height.toStringAsFixed(0)} cm',
                    Icons.height_rounded,
                    AppColors.info,
                  ),
                  _buildDetailRow(
                    'Berat Badan',
                    '${record.weight.toStringAsFixed(0)} kg',
                    Icons.monitor_weight_rounded,
                    AppColors.success,
                  ),
                  _buildDetailRow(
                    'Tekanan Darah',
                    record.bloodPressure,
                    Icons.favorite_rounded,
                    AppColors.error,
                  ),
                  _buildDetailRow(
                    'Golongan Darah',
                    record.bloodType,
                    Icons.bloodtype_rounded,
                    AppColors.warning,
                  ),
                  if (record.gulaDarah != null)
                    _buildDetailRow(
                      'Gula Darah',
                      '${record.gulaDarah} mg/dL',
                      Icons.water_drop_rounded,
                      context.appColors.error,
                    ),
                  _buildNotesSection(record),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
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
    } catch (_) { /* Silenced: non-critical parse fallback */ }

    if (data == null || data['is_screening_realistis'] != true) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Keluhan / Catatan:',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            child: Text(
              record.notes,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.neutral800,
              ),
            ),
          ),
        ],
      );
    }

    final jamTidur = data['jam_tidur'] ?? 8;
    final olahraga = data['olahraga'] ?? 0;
    final air = data['konsumsi_air'] ?? 2.0;
    final merokok = data['merokok'] ?? 'Tidak';
    final stres = data['tingkat_stres'] ?? 5;
    final mood = data['mood'] ?? 'Biasa Saja';
    final motivasi = data['motivasi_belajar'] ?? 'Biasa Saja';
    final List keluhanList = data['daftar_keluhan'] ?? [];
    final catatanTambahan = data['catatan_tambahan'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.s20),
        Text(
          'Gaya Hidup & Mental:',
          style: AppTextStyles.labelSm.copyWith(
            color: Theme.of(context).colorScheme.outline,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: Column(
            children: [
              _buildDetailInfoRow(
                'Tidur / Hari',
                '$jamTidur Jam',
                Icons.bedtime_rounded,
                AppColors.info,
              ),
              _buildDetailInfoRow(
                'Olahraga / Minggu',
                '$olahraga Kali',
                Icons.fitness_center_rounded,
                AppColors.info,
              ),
              _buildDetailInfoRow(
                'Konsumsi Air',
                '$air Liter',
                Icons.water_drop_rounded,
                AppColors.info,
              ),
              _buildDetailInfoRow(
                'Merokok',
                merokok,
                Icons.smoke_free_rounded,
                AppColors.info,
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              _buildDetailInfoRow(
                'Tingkat Stres',
                '$stres / 10',
                Icons.psychology_rounded,
                AppColors.secondary,
              ),
              _buildDetailInfoRow(
                'Mood',
                mood,
                Icons.mood_rounded,
                AppColors.secondary,
              ),
              _buildDetailInfoRow(
                'Motivasi Belajar',
                motivasi,
                Icons.auto_stories_rounded,
                AppColors.secondary,
              ),
            ],
          ),
        ),
        if (keluhanList.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Keluhan yang Dirasakan:',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                keluhanList.map((k) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(20),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(color: AppColors.error.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.s6),
                        Text(
                          k.toString(),
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
        if (catatanTambahan.toString().isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s20),
          Text(
            'Catatan Tambahan:',
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: AppRadius.radiusLg,
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            child: Text(
              catatanTambahan,
              style: AppTextStyles.labelMd.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelSm.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
              fontSize: 12,
            ),
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
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: color.withAlpha(10),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            label,
            style: AppTextStyles.labelMd.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMd.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
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
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: color.withAlpha(20),
          width: 1.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withAlpha(10),
                    borderRadius: AppRadius.radiusMd,
                  ),
                  child: Icon(icon, color: color.withAlpha(120), size: 18),
                ),
                Icon(
                  Icons.lock_outline_rounded,
                  color: Theme.of(context).colorScheme.outline.withAlpha(60),
                  size: 14,
                ),
              ],
            ),
            const Spacer(),
            Text(
              label,
              style: AppTextStyles.labelSm.copyWith(
                color: Theme.of(context).colorScheme.outline.withAlpha(150),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.s2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '--',
                  style: AppTextStyles.labelMd.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                    color: Theme.of(context).colorScheme.primary.withAlpha(60),
                  ),
                ),
                Text(
                  ' $unit',
                  style: AppTextStyles.labelSm.copyWith(
                    color: Theme.of(context).colorScheme.outline.withAlpha(80),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideStep(
    int number,
    String title,
    String desc,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppSpacing.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral900,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: AppTextStyles.labelSm.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm, left: AppSpacing.sm),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withAlpha(100),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMenuCardLong({
    required Widget destination,
    required Color color,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(50),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destination),
              ),
          borderRadius: AppRadius.radiusXl,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: AppRadius.radiusLg,
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelMd.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.neutral900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        desc,
                        style: AppTextStyles.labelSm.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          height: 1.3,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.outline.withAlpha(100),
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
      } catch (_) { /* Silenced: non-critical parse fallback */ }
    }

    if (score < 10) score = 10;
    if (score > 100) score = 100;
    return score.toInt();
  }
  Widget _buildReferralNavCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MedicalReferralScreen(),
          ),
        );
      },
      borderRadius: AppRadius.radiusXl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.info.withAlpha(20),
          borderRadius: AppRadius.radiusXl,
          border: Border.all(color: AppColors.info.withAlpha(50), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColors.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.info.withAlpha(30),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_information_rounded,
                color: AppColors.info,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Surat Rujukan Medis',
                    style: AppTextStyles.titleSm.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Lihat & download surat rujukan klinik UBK yang telah disetujui.',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.info,
            ),
          ],
        ),
      ),
    );
  }
}

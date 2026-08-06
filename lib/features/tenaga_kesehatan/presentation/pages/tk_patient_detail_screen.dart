import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_patient_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/domain/entities/medical_record.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:bkuhub_mobile/core/services/auth_service.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TkPatientDetailScreen extends StatefulWidget {
  final int patientId;

  const TkPatientDetailScreen({super.key, required this.patientId});

  @override
  State<TkPatientDetailScreen> createState() => _TkPatientDetailScreenState();
}

class _TkPatientDetailScreenState extends State<TkPatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TkPatientProvider>().loadPatientMedicalRecord(
        widget.patientId,
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    return Consumer<TkPatientProvider>(
      builder: (context, provider, child) {
        final patient = provider.selectedPatient;
        final records = provider.medicalRecords;
        final referrals = provider.referrals;

        return Scaffold(
          backgroundColor: AppColors.neutral100,
          appBar: BkuStaticAppBar(
            title: 'Detail Pasien',
            variant: AppBarVariant.nakes,
            showBackButton: true,
            onBack: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/tk');
              }
            },
          ),
          body:
              provider.isLoadingRecord
                  ? const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                  )
                  : Column(
                    children: [
                      // Patient Header
                      if (patient != null) _buildPatientHeader(patient),

                      // Tabs
                      Container(
                        color: context.appColors.surface,
                        child: TabBar(
                          controller: _tabController,
                          labelColor: primaryColor,
                          unselectedLabelColor: AppColors.neutral500,
                          indicatorColor: primaryColor,
                          dividerColor: Colors.transparent,
                          tabs: const [
                            Tab(text: 'Info'),
                            Tab(text: 'Riwayat'),
                            Tab(text: 'Rujukan'),
                          ],
                        ),
                      ),

                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildInfoTab(patient),
                            _buildHistoryTab(records),
                            _buildReferralsTab(referrals),
                          ],
                        ),
                      ),
                    ],
                  ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed:
                () => context.push(
                  '/tk/screening?patient_id=${widget.patientId}',
                ),
            backgroundColor: context.watch<ThemeProvider>().colors.success,
            icon: Icon(Icons.add_rounded, color: context.appColors.onPrimary),
            label: Text(
              'Input Screening',
              style: TextStyle(color: context.appColors.onPrimary),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPatientHeader(patient) {
    final theme = Theme.of(context).colorScheme;
    final initials = patient.initials;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.s20,
        AppSpacing.sm,
      ),
      child: BkuCard(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Row(
          children: [
            // Avatar
            Container(
              padding: AppSpacing.padding3,
              decoration: BoxDecoration(
                color: AppColors.neutral600.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: AppSpacing.padding2,
                decoration: BoxDecoration(
                  color: context.appColors.surface,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child:
                      patient.fotoURL != null && patient.fotoURL!.isNotEmpty
                          ? CachedNetworkImage(imageUrl: 
                            ApiGate.getImageUrl(patient.fotoURL),
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorWidget: (context, url, error) {
                              return _buildInitialsAvatar(initials);
                            },
                            placeholder: (context, url) => Container(color: AppColors.neutral200),
                          )
                          : _buildInitialsAvatar(initials),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.nama,
                    style: TextStyle(
                      color: context.appColors.onSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    patient.prodi.toUpperCase(),
                    style: TextStyle(
                      color: context.appColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildBadge(
                        icon: Icons.badge_rounded,
                        label: 'NIM: ${patient.nim}',
                        color: theme.surfaceContainerHighest.withAlpha(120),
                        borderColor: theme.outline.withAlpha(15),
                        textColor: context.appColors.onSurface,
                      ),
                      _buildBadge(
                        icon: Icons.calendar_month_rounded,
                        label: 'SMT ${patient.semester}',
                        color: AppColors.info.withAlpha(25),
                        borderColor: AppColors.info.withAlpha(50),
                        textColor: context.appColors.info,
                      ),
                      if (patient.golonganDarah != null)
                        _buildBadge(
                          icon: Icons.water_drop_rounded,
                          label: 'GOL. DARAH: ${patient.golonganDarah}',
                          color: theme.error.withAlpha(25),
                          borderColor: theme.error.withAlpha(50),
                          textColor: theme.error,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.radiusMd,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: AppSpacing.s6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String initials) {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.neutral600.withAlpha(25),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.neutral600,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTab(patient) {
    if (patient == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildGridSection('Informasi Pribadi', [
          _buildGridItem(
            'Nama Lengkap',
            patient.nama,
            Icons.person_rounded,
            AppColors.info,
          ),
          _buildGridItem(
            'NIM',
            patient.nim,
            Icons.badge_rounded,
            AppColors.warning,
          ),
          _buildGridItem(
            'Jenis Kelamin',
            patient.jenisKelamin,
            Icons.wc_rounded,
            context.appColors.error,
          ),
          _buildGridItem(
            'Fakultas',
            patient.fakultas,
            Icons.account_balance_rounded,
            context.appColors.primary,
          ),
          _buildGridItem(
            'Program Studi',
            patient.prodi,
            Icons.school_rounded,
            context.appColors.info,
          ),
          _buildGridItem(
            'Semester',
            '${patient.semester}',
            Icons.calendar_month_rounded,
            AppColors.success,
          ),
        ]),
        const SizedBox(height: AppSpacing.s28),
        _buildGridSection('Informasi Kontak', [
          _buildGridItem(
            'No. HP',
            patient.noHP != null && patient.noHP!.trim().isNotEmpty
                ? patient.noHP!
                : 'Belum ada data',
            Icons.phone_android_rounded,
            AppColors.success,
          ),
          _buildGridItem(
            'Email Personal',
            patient.email != null && patient.email!.trim().isNotEmpty
                ? patient.email!
                : 'Belum ada data',
            Icons.email_rounded,
            AppColors.info,
          ),
          _buildGridItem(
            'Email Kampus',
            patient.emailKampus != null &&
                    patient.emailKampus!.trim().isNotEmpty
                ? patient.emailKampus!
                : 'Belum ada data',
            Icons.alternate_email_rounded,
            AppColors.info,
          ),
        ]),
        if (patient.alergiObat != null && patient.alergiObat!.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.s28),
          _buildGridSection('Riwayat Alergi', [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.appColors.error.withAlpha(15),
                borderRadius: AppRadius.radiusXl,
                border: Border.all(
                  color: context.appColors.error.withAlpha(30),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: context.appColors.error,
                    size: 22,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      patient.alergiObat!,
                      style: TextStyle(
                        color: context.appColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ],
    );
  }

  Widget _buildGridSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.md),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.titleSm.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 12) / 2;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  items.map((item) {
                    return SizedBox(width: width, child: item);
                  }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: AppSpacing.padding10,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.radiusMd,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySm.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral800,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(List<MedicalRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 64, color: AppColors.neutral300),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Belum ada riwayat pemeriksaan',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: records.length,
      itemBuilder: (context, index) => _buildRecordCard(records[index]),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: context.appColors.onSurface.withAlpha(4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, record.statusKesehatan).withAlpha(20),
                  borderRadius: AppRadius.radiusSm,
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  color: _getStatusColor(context, record.statusKesehatan),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDate(record.tanggal),
                      style: AppTextStyles.bodyMd.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (record.namaPemeriksa != null)
                      Text(
                        'Pemeriksa: ${record.namaPemeriksa}',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.neutral500,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, record.statusKesehatan).withAlpha(20),
                  borderRadius: AppRadius.radiusXl,
                ),
                child: Text(
                  record.statusCategory,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(context, record.statusKesehatan),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // Vital Signs Grid
          Row(
            children: [
              Expanded(
                child: _buildVitalItem('TB', '${record.tinggiBadan} cm'),
              ),
              Expanded(child: _buildVitalItem('BB', '${record.beratBadan} kg')),
              Expanded(
                child: _buildVitalItem('BMI', record.bmi.toStringAsFixed(1)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildVitalItem('Tensi', record.tekananDarah)),
              Expanded(
                child: _buildVitalItem('Nadi', '${record.denyutNadi} bpm'),
              ),
              Expanded(child: _buildVitalItem('Suhu', '${record.suhuTubuh}°C')),
            ],
          ),
          if (record.catatan != null && record.catatan!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: AppRadius.radiusSm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_rounded,
                    size: 14,
                    color: AppColors.neutral500,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      record.catatan!,
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => _showRecordDetails(context, record),
              icon: Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: primaryColor,
              ),
              label: Text(
                'Lihat Detail Selengkapnya',
                style: AppTextStyles.labelSm.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(BuildContext context, MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
      return Container(
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xxl),
          topRight: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pull Bar
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.neutral300,
                borderRadius: AppRadius.radiusXs,
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Rekam Medis',
                        style: AppTextStyles.titleLg.copyWith(
                          color: context.appColors.secondary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${_formatDate(record.tanggal)} • Oleh ${record.namaPemeriksa ?? "-"}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  children: [
                    // Status Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            context,
                            record.statusKesehatan,
                          ).withAlpha(20),
                          borderRadius: AppRadius.radiusXl,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.medical_services_rounded,
                              color: _getStatusColor(context, record.statusKesehatan),
                              size: 16,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              record.statusCategory,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(context, record.statusKesehatan),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s20),

                    // Section 1: Tanda Vital & Fisik
                    _buildModalSectionTitle('Tanda Vital & Fisik'),
                    const SizedBox(height: AppSpacing.md),
                    _buildModalGrid([
                      _buildModalGridItem(
                        'Tinggi Badan',
                        '${record.tinggiBadan.toStringAsFixed(1)} cm',
                      ),
                      _buildModalGridItem(
                        'Berat Badan',
                        '${record.beratBadan.toStringAsFixed(1)} kg',
                      ),
                      _buildModalGridItem(
                        'BMI',
                        '${record.bmi.toStringAsFixed(1)} (${record.bmiCategory})',
                      ),
                      _buildModalGridItem('Tekanan Darah', record.tekananDarah),
                      _buildModalGridItem(
                        'Denyut Nadi',
                        '${record.denyutNadi} bpm',
                      ),
                      _buildModalGridItem(
                        'Suhu Tubuh',
                        '${record.suhuTubuh.toStringAsFixed(1)}°C',
                      ),
                      _buildModalGridItem('SpO2', '${record.spO2}%'),
                      _buildModalGridItem(
                        'Gula Darah',
                        record.gulaDarah != null
                            ? '${record.gulaDarah} mg/dL'
                            : '-',
                      ),
                      _buildModalGridItem(
                        'Golongan Darah',
                        record.golonganDarah ?? '-',
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.xl),

                    // Section 2: Keluhan & Kondisi
                    _buildModalSectionTitle('Keluhan & Kondisi'),
                    const SizedBox(height: AppSpacing.md),
                    _buildDetailItem(
                      'Riwayat Penyakit',
                      record.riwayatPenyakit,
                    ),
                    _buildWarningDetailItem(context, 'Alergi Obat', record.alergiObat),
                    _buildDetailItem(
                      'Kondisi Psikologis',
                      record.kondisiPsikologis,
                    ),
                    _buildDetailItem('Konsumsi Obat', record.konsumsiObat),
                    _buildDetailItem(
                      'Skala Nyeri',
                      record.skalaNyeri != null
                          ? '${record.skalaNyeri} / 10'
                          : null,
                    ),
                    _buildDetailItem('Buta Warna', record.butaWarna),
                    const SizedBox(height: AppSpacing.xl),

                    // Section 3: Tindakan & Penanganan
                    _buildModalSectionTitle('Tindakan & Rekomendasi'),
                    const SizedBox(height: AppSpacing.md),
                    _buildDetailItem(
                      'Tindakan Diberikan',
                      record.tindakanDiberikan,
                    ),
                    _buildDetailItem('Obat Diberikan', record.obatDiberikan),
                    _buildDetailItem('Rekomendasi', record.rekomendasi),
                    _buildDetailItem('Catatan Tambahan', record.catatan),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: context.appColors.success,
            borderRadius: AppRadius.br2,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.titleSm.copyWith(
            color: AppColors.neutral800,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildModalGrid(List<Widget> children) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.4,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: children,
    );
  }

  Widget _buildModalGridItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    final displayValue = (value == null || value.trim().isEmpty) ? '-' : value;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: AppRadius.radiusLg,
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            displayValue,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningDetailItem(BuildContext context, String label, String? value) {
    final hasWarning =
        value != null &&
        value.trim().isNotEmpty &&
        value.trim().toLowerCase() != 'tidak ada' &&
        value.trim() != '-';
    if (!hasWarning) {
      return _buildDetailItem(label, value);
    }
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColors.error.withAlpha(15),
        borderRadius: AppRadius.radiusSm,
        border: Border.all(
          color: context.appColors.error.withAlpha(50),
        ),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: context.appColors.error,
                size: 14,
              ),
              const SizedBox(width: AppSpacing.s6),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: context.appColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.bodyMd.copyWith(
              color: context.appColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(color: AppColors.neutral500),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context, String status) {
    switch (status) {
      case 'Layak Kegiatan':
      case 'prima':
      case 'sehat':
        return context.watch<ThemeProvider>().colors.success;
      case 'Perlu Perhatian':
      case 'pantauan':
        return context.watch<ThemeProvider>().colors.warning;
      case 'Tidak Layak':
      case 'kritis':
        return context.appColors.error;
      default:
        return context.watch<ThemeProvider>().colors.info;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildReferralsTab(List<Map<String, dynamic>> referrals) {
    if (referrals.isEmpty) {
      return const Center(child: Text('Tidak ada riwayat rujukan medis.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: referrals.length,
      itemBuilder: (context, index) {
        final ref = referrals[index];
        final faskes = ref['faskes_tujuan'] ?? '-';
        final diagnosis = ref['diagnosis'] ?? '-';
        final status = ref['approval_status'] ?? ref['status'] ?? 'Menunggu';
        final createdAtStr = ref['created_at'] ?? '';
        final date = DateTime.tryParse(createdAtStr);

        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.lg),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(color: AppColors.neutral500.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: context.appColors.onSurface.withAlpha(4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date != null ? _formatDate(date) : '-',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.neutral500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color:
                          status.toString().toLowerCase() == 'disetujui' ||
                                  status.toString().toLowerCase() == 'selesai'
                              ? context
                                  .watch<ThemeProvider>()
                                  .colors
                                  .success
                                  .withAlpha(20)
                              : status.toString().toLowerCase() == 'ditolak'
                              ? Theme.of(
                                context,
                              ).colorScheme.error.withAlpha(20)
                              : context
                                  .watch<ThemeProvider>()
                                  .colors
                                  .warning
                                  .withAlpha(20),
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            status.toString().toLowerCase() == 'disetujui' ||
                                    status.toString().toLowerCase() == 'selesai'
                                ? context.watch<ThemeProvider>().colors.success
                                : status.toString().toLowerCase() == 'ditolak'
                                ? context.appColors.error
                                : context.watch<ThemeProvider>().colors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Faskes Tujuan: $faskes',
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text('Diagnosis: $diagnosis', style: AppTextStyles.bodyMd),
              if (status.toString().toLowerCase() == 'disetujui' ||
                  status.toString().toLowerCase() == 'selesai') ...[
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final rujukanId = ref['id'] ?? ref['ID'];
                      final token = AuthService().token;
                      final urlStr =
                          '${ApiGate.baseUrl}/tenagakes/rujukan/$rujukanId/export-pdf?token=$token';
                      final uri = Uri.parse(urlStr);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
                      } else {
                        if (context.mounted) {
                          AppSnackbar.showError(
                            context,
                            'Tidak dapat membuka PDF',
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.appColors.error.withAlpha(15),
                      foregroundColor: context.appColors.error,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.br10,
                        side: BorderSide(color: context.appColors.error.withAlpha(50)),
                      ),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text(
                      'Download Surat Rujukan PDF',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

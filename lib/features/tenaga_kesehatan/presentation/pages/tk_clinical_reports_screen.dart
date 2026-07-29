import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/presentation/providers/tk_health_provider.dart';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/models/tk_clinical_report_model.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_shimmer.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:url_launcher/url_launcher.dart';

class TkClinicalReportsScreen extends StatefulWidget {
  const TkClinicalReportsScreen({super.key});

  @override
  State<TkClinicalReportsScreen> createState() =>
      _TkClinicalReportsScreenState();
}

class _TkClinicalReportsScreenState extends State<TkClinicalReportsScreen> {
  String _selectedFilter = '30 Hari';
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter();
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    String? startDate;
    String? endDate = DateFormat('yyyy-MM-dd').format(now);

    if (_selectedFilter == 'Hari Ini') {
      startDate = DateFormat('yyyy-MM-dd').format(now);
    } else if (_selectedFilter == '7 Hari') {
      startDate = DateFormat(
        'yyyy-MM-dd',
      ).format(now.subtract(const Duration(days: 7)));
    } else if (_selectedFilter == '30 Hari') {
      startDate = DateFormat(
        'yyyy-MM-dd',
      ).format(now.subtract(const Duration(days: 30)));
    } else if (_selectedFilter == 'Custom' && _customDateRange != null) {
      startDate = DateFormat('yyyy-MM-dd').format(_customDateRange!.start);
      endDate = DateFormat('yyyy-MM-dd').format(_customDateRange!.end);
    } else if (_selectedFilter == 'Custom') {
      return; // Wait for user to select dates
    }

    context.read<TkHealthProvider>().fetchClinicalReports(
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDateRange: _customDateRange,
    );
    if (picked != null) {
      setState(() {
        _selectedFilter = 'Custom';
        _customDateRange = picked;
      });
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral100,
      appBar: BkuStaticAppBar(
        title: 'Laporan Klinis',
        variant: AppBarVariant.nakes,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            tooltip: 'Ekspor Excel',
            onPressed: _handleExportExcel,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
            tooltip: 'Unduh Laporan Klinis PDF',
            onPressed: _handleExportPdf,
          ),
        ],
      ),
      body: Consumer<TkHealthProvider>(
        builder: (context, provider, child) {
          final isListEmpty = provider.clinicalReports?.records.isEmpty ?? true;

          return RefreshIndicator(
            onRefresh: () async {
              _applyFilter();
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildFilterSection(),
                      if (provider.clinicalReports != null)
                        _buildSummaryCards(provider.clinicalReports!.summary),
                      if (provider.clinicalReports != null)
                        _buildChartCards(provider.clinicalReports!.summary),
                    ],
                  ),
                ),
                if (provider.isLoading && isListEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: BkuShimmerList(itemCount: 4, itemHeight: 120),
                    ),
                  )
                else if (isListEmpty)
                  SliverFillRemaining(child: _buildEmptyState())
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final report = provider.clinicalReports!.records[index];
                        return _buildReportCard(context, report);
                      }, childCount: provider.clinicalReports!.records.length),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: context.appColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.filter_list_rounded,
                size: 18,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Filter Periode',
                style: AppTextStyles.titleSm.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Hari Ini'),
                _buildFilterChip('7 Hari'),
                _buildFilterChip('30 Hari'),
                _buildFilterChip('Custom', isCustom: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isCustom = false}) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    final isSelected = _selectedFilter == label;
    String displayLabel = label;

    if (isCustom && _customDateRange != null && isSelected) {
      final start = DateFormat('dd MMM').format(_customDateRange!.start);
      final end = DateFormat('dd MMM').format(_customDateRange!.end);
      displayLabel = '$start - $end';
    }

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: () {
          if (isCustom) {
            _selectCustomDateRange();
          } else {
            setState(() {
              _selectedFilter = label;
            });
            _applyFilter();
          }
        },
        borderRadius: AppRadius.radiusXl,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : AppColors.neutral100,
            borderRadius: AppRadius.radiusXl,
          ),
          child: Text(
            displayLabel,
            style: AppTextStyles.bodySm.copyWith(
              color: isSelected ? context.appColors.onPrimary : AppColors.neutral700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards(TkClinicalReportStats stats) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Diperiksa',
              value: stats.totalDiperiksa.toString(),
              icon: Icons.people_alt_rounded,
              color: primaryColor,
              bgColor: primaryColor.withAlpha(25),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              title: 'Layak',
              value: stats.layak.toString(),
              icon: Icons.check_circle_rounded,
              color: context.watch<ThemeProvider>().colors.success,
              bgColor: context.watch<ThemeProvider>().colors.successContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              title: 'Perlu Perhatian',
              value: stats.perluPerhatian.toString(),
              icon: Icons.warning_rounded,
              color: context.watch<ThemeProvider>().colors.warning,
              bgColor: context.watch<ThemeProvider>().colors.warningContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _buildStatCard(
              title: 'Tidak Layak',
              value: stats.tidakLayak.toString(),
              icon: Icons.cancel_rounded,
              color: context.watch<ThemeProvider>().colors.error,
              bgColor: context.watch<ThemeProvider>().colors.errorContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return BkuCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
      child: Column(
        children: [
          Container(
            padding: AppSpacing.paddingSm,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.radiusSm,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTextStyles.titleLg.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.neutral900,
            ),
          ),
          const SizedBox(height: AppSpacing.s2),
          Text(
            title,
            style: AppTextStyles.labelSm.copyWith(
              color: AppColors.neutral600,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCards(TkClinicalReportStats stats) {
    final total =
        stats.totalDiperiksa > 0
            ? stats.totalDiperiksa
            : 1; // prevent division by zero
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _buildCircularChart(
              title: 'Layak',
              percent: stats.layak / total,
              color: context.watch<ThemeProvider>().colors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildCircularChart(
              title: 'Pantauan',
              percent: stats.perluPerhatian / total,
              color: context.watch<ThemeProvider>().colors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _buildCircularChart(
              title: 'Tidak Layak',
              percent: stats.tidakLayak / total,
              color: context.watch<ThemeProvider>().colors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularChart({
    required String title,
    required double percent,
    required Color color,
  }) {
    return BkuCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: AppColors.neutral200,
                  color: color,
                ),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: AppTextStyles.titleSm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTextStyles.bodySm.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_rounded,
            size: 64,
            color: AppColors.neutral300,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Belum ada Laporan Klinis',
            style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, TkClinicalReportRecord report) {
    return BkuCard(
      onTap: () => _showReportDetail(context, report),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  report.namaMahasiswa,
                  style: AppTextStyles.titleSm.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildStatusBadge(report.hasil),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${report.nim} • ${report.prodi} • ${report.fakultas}',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: AppSpacing.s6),
              Text(
                DateFormat('dd MMM yyyy').format(report.tanggal),
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(
                Icons.medical_services_rounded,
                size: 14,
                color: AppColors.neutral400,
              ),
              const SizedBox(width: AppSpacing.s6),
              Expanded(
                child: Text(
                  report.namaPemeriksa,
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.neutral600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    if (status.toUpperCase() == 'LAYAK' || status.toUpperCase() == 'SEHAT') {
      bgColor = context.watch<ThemeProvider>().colors.successContainer;
      textColor = AppColors.onSuccessContainer;
    } else if (status.toUpperCase() == 'TIDAK LAYAK' ||
        status.toUpperCase() == 'SAKIT') {
      bgColor = context.watch<ThemeProvider>().colors.errorContainer;
      textColor = AppColors.onErrorContainer;
    } else {
      bgColor = context.watch<ThemeProvider>().colors.warningContainer;
      textColor = AppColors.onWarningContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusMd,
      ),
      child: Text(
        status,
        style: AppTextStyles.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showReportDetail(BuildContext context, TkClinicalReportRecord report) {
    final primaryColor = context.read<ThemeProvider>().primary;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: AppRadius.radiusXs,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Detail Laporan Klinis',
                style: AppTextStyles.titleLg.copyWith(
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                DateFormat('dd MMMM yyyy - HH:mm').format(report.tanggal),
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Pasien
                      _buildGridSection(
                        title: 'Identitas Pasien',
                        icon: Icons.person_rounded,
                        children: [
                          _buildDetailItem(
                            'Nama Mahasiswa',
                            report.namaMahasiswa,
                          ),
                          _buildDetailItem('NIM', report.nim),
                          _buildDetailItem('Program Studi', report.prodi),
                          _buildDetailItem('Fakultas', report.fakultas),
                        ],
                      ),

                      // Section: Hasil
                      _buildGridSection(
                        title: 'Hasil Pemeriksaan',
                        icon: Icons.assignment_rounded,
                        children: [
                          _buildDetailItem(
                            'Status Kelayakan',
                            report.hasil,
                            isStatus: true,
                          ),
                          _buildDetailItem('Catatan Pemeriksa', report.catatan),
                          _buildDetailItem('Rekomendasi', report.rekomendasi),
                          _buildDetailItem('Pemeriksa', report.namaPemeriksa),
                        ],
                      ),

                      // Section: Vitals
                      _buildGridSection(
                        title: 'Tanda Vital & Fisik',
                        icon: Icons.monitor_heart_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  'Tekanan Darah',
                                  '${report.sistole}/${report.diastole} mmHg',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  'Suhu Tubuh',
                                  '${report.suhuTubuh} °C',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  'SpO2',
                                  '${report.spo2} %',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  'Denyut Nadi',
                                  '${report.denyutNadi} bpm',
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  'Tinggi / Berat',
                                  '${report.tinggiBadan} cm / ${report.beratBadan} kg',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  'Golongan Darah',
                                  report.golonganDarah,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDetailItem(
                                  'Gula Darah',
                                  '${report.gulaDarah} mg/dL',
                                ),
                              ),
                              Expanded(
                                child: _buildDetailItem(
                                  'Buta Warna',
                                  report.butaWarna,
                                ),
                              ),
                            ],
                          ),
                          _buildDetailItem(
                            'Skala Nyeri',
                            '${report.skalaNyeri}/10',
                          ),
                        ],
                      ),

                      // Section: Tambahan
                      _buildGridSection(
                        title: 'Catatan Tambahan',
                        icon: Icons.note_add_rounded,
                        children: [
                          _buildDetailItem('Alergi Obat', report.alergiObat),
                          _buildDetailItem(
                            'Kondisi Psikologis',
                            report.kondisiPsikologis,
                          ),
                          _buildDetailItem(
                            'Konsumsi Obat Rutin',
                            report.konsumsiObat,
                          ),
                        ],
                      ),

                      // Section: Penanganan
                      _buildGridSection(
                        title: 'Tindakan & Terapi',
                        icon: Icons.healing_rounded,
                        children: [
                          _buildDetailItem(
                            'Tindakan Diberikan',
                            report.tindakanDiberikan,
                          ),
                          _buildDetailItem(
                            'Obat Diberikan',
                            report.obatDiberikan,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: SizedBox(
                  width: double.infinity,
                  child: BkuButton(
                    onPressed: () => context.pop(),
                    text: 'Tutup',
                    variant: BkuButtonVariant.outline,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSectionHeader(title, icon), ...children],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    final primaryColor = context.watch<ThemeProvider>().primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 18, color: primaryColor),
          const SizedBox(width: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, {bool isStatus = false}) {
    Widget valueWidget;
    if (isStatus) {
      valueWidget = _buildStatusBadge(value);
    } else {
      valueWidget = Text(
        value.isEmpty || value == '-' || value == '—' ? '—' : value,
        style: AppTextStyles.bodyMd.copyWith(color: AppColors.neutral800),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.neutral500),
          ),
          const SizedBox(height: AppSpacing.xs),
          valueWidget,
        ],
      ),
    );
  }

  Future<void> _handleExportExcel() async {
    final provider = context.read<TkHealthProvider>();
    final url = await provider.getReportExcelUrl();
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          AppSnackbar.showError(context, 'Tidak dapat mengunduh file Excel');
        }
      }
    }
  }

  Future<void> _handleExportPdf() async {
    final provider = context.read<TkHealthProvider>();
    final url = await provider.getReportPdfUrl();
    if (url != null) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } else {
        if (mounted) {
          AppSnackbar.showError(
            context,
            'Tidak dapat memuat PDF Laporan Klinis',
          );
        }
      }
    }
  }
}

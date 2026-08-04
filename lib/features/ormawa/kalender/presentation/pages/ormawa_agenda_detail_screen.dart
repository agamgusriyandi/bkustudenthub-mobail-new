import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_app_bar.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/ormawa/absensi/presentation/pages/ormawa_absensi_screen.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

String formatRp(double? val) {
  if (val == null || val == 0.0) return 'Rp 0';
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(val);
}

class OrmawaAgendaDetailScreen extends StatelessWidget {
  final OrmawaAgenda agenda;

  const OrmawaAgendaDetailScreen({super.key, required this.agenda});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'terlaksana':
      case 'selesai':
        return AppColors.success;
      case 'berlangsung':
        return AppColors.warning;
      case 'batal':
      case 'dibatalkan':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(agenda.status);

    return Scaffold(
      backgroundColor: AppColors.neutral100,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'DETAIL AGENDA',
            subtitle: agenda.title.toUpperCase(),
            variant: AppBarVariant.ormawa,
            expandedHeight: 115.0,
            showBackButton: true,
            isExpandable: false,
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                top: AppSpacing.sm,
                left: AppSpacing.s20,
                right: AppSpacing.s20,
                bottom: AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(statusColor),
                  const SizedBox(height: AppSpacing.xl),

                  _buildSectionTitle('Informasi Utama'),
                  const SizedBox(height: AppSpacing.md),
                  _buildMainInfoGrid(statusColor),

                  const SizedBox(height: AppSpacing.xl),
                  _buildSectionTitle('Detail Kegiatan'),
                  const SizedBox(height: AppSpacing.md),
                  _buildTechnicalDetailsCard(),

                  const SizedBox(height: AppSpacing.xl),
                  if (agenda.latarBelakang?.isNotEmpty == true) ...[
                    _buildSectionTitle('Latar Belakang'),
                    const SizedBox(height: AppSpacing.md),
                    _buildNarrativeCard(agenda.latarBelakang!),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (agenda.tujuanKegiatan?.isNotEmpty == true) ...[
                    _buildSectionTitle('Tujuan Kegiatan'),
                    const SizedBox(height: AppSpacing.md),
                    _buildNarrativeCard(agenda.tujuanKegiatan!),
                    const SizedBox(height: AppSpacing.xl),
                  ],

                  if (agenda.description.isNotEmpty) ...[
                    _buildSectionTitle('Deskripsi & Mekanisme'),
                    const SizedBox(height: AppSpacing.md),
                    _buildNarrativeCard(agenda.description),
                    const SizedBox(height: AppSpacing.xxl),
                  ],

                  _buildBottomActions(context),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_month_rounded,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STATUS AGENDA',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(15),
                        borderRadius: AppRadius.radiusSm,
                        border: Border.all(color: statusColor.withAlpha(30)),
                      ),
                      child: Text(
                        agenda.status.toUpperCase(),
                        style: AppTextStyles.labelSm.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s6),
                Text(
                  agenda.title,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.neutral800,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.labelSm.copyWith(
        color: AppColors.neutral600,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildMainInfoGrid(Color statusColor) {
    final startTimeStr = DateFormat('HH:mm').format(agenda.date);
    final endTimeStr = DateFormat('HH:mm').format(agenda.endDate);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id').format(agenda.date);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGridItem(
            Icons.calendar_today_rounded,
            'Hari & Tanggal',
            dateStr,
            isBold: true,
          ),
          const Divider(height: 24, color: AppColors.neutral200),
          _buildGridItem(
            Icons.access_time_rounded,
            'Waktu Pelaksanaan',
            '$startTimeStr - $endTimeStr WIB',
          ),
          const Divider(height: 24, color: AppColors.neutral200),
          _buildGridItem(
            Icons.location_on_rounded,
            'Lokasi / Ruangan',
            agenda.location.isNotEmpty ? agenda.location : 'Belum ditentukan',
          ),
          if (agenda.pjKegiatan?.isNotEmpty == true) ...[
            const Divider(height: 24, color: AppColors.neutral200),
            _buildGridItem(
              Icons.person_rounded,
              'Penanggung Jawab',
              agenda.pjKegiatan!,
            ),
          ],
          if (agenda.estimasiDana != null && agenda.estimasiDana! > 0) ...[
            const Divider(height: 24, color: AppColors.neutral200),
            _buildGridItem(
              Icons.payments_rounded,
              'Estimasi Anggaran',
              formatRp(agenda.estimasiDana),
              valueColor: AppColors.success,
              isBold: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridItem(
    IconData icon,
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s2),
              Text(
                value,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
                  color: valueColor ?? AppColors.neutral800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withAlpha(3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTechnicalItem(
            'Landasan Kegiatan',
            agenda.landasanKegiatan?.isNotEmpty == true
                ? agenda.landasanKegiatan!
                : '—',
          ),
          const Divider(height: 20, color: AppColors.neutral100),
          _buildTechnicalItem(
            'Bentuk Kegiatan',
            agenda.bentukKegiatan?.isNotEmpty == true
                ? agenda.bentukKegiatan!
                : '—',
          ),
          const Divider(height: 20, color: AppColors.neutral100),
          _buildTechnicalItem(
            'Sasaran Kegiatan',
            agenda.sasaranKegiatan?.isNotEmpty == true
                ? agenda.sasaranKegiatan!
                : '—',
          ),
          const Divider(height: 20, color: AppColors.neutral100),
          _buildTechnicalItem(
            'Mitra Kerja',
            agenda.mitra?.isNotEmpty == true ? agenda.mitra! : '—',
          ),
          const Divider(height: 20, color: AppColors.neutral100),
          _buildTechnicalItem(
            'Sumber Dana',
            agenda.sumberDana?.isNotEmpty == true ? agenda.sumberDana! : '—',
          ),
          const Divider(height: 20, color: AppColors.neutral100),
          _buildTechnicalItem(
            'Indikator Keberhasilan',
            agenda.indikatorKeberhasilan?.isNotEmpty == true
                ? agenda.indikatorKeberhasilan!
                : '—',
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.neutral600,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.neutral800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrativeCard(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Text(
        content,
        style: const TextStyle(
          color: AppColors.neutral800,
          height: 1.6,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final provider = Provider.of<OrmawaProvider>(context, listen: false);
    if (!provider.hasPermission('view_attendance')) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OrmawaAbsensiScreen(),
            ),
          );
        },
        icon: Icon(Icons.qr_code_scanner_rounded, color: context.appColors.onPrimary),
        label: Text(
          'BUKA ABSENSI KEGIATAN',
          style: TextStyle(
            color: context.appColors.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

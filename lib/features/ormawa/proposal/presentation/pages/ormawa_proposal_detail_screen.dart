import 'package:bkuhub_mobile/core/theme/app_radius.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/app_colors.dart';
import 'package:bkuhub_mobile/core/theme/app_theme.dart';
import 'package:bkuhub_mobile/core/theme/app_text_styles.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/services/proposal_pdf_service.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/create_proposal_screen.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';
import 'package:intl/intl.dart';

class OrmawaProposalDetailScreen extends StatelessWidget {
  final OrmawaProposal proposal;

  const OrmawaProposalDetailScreen({super.key, required this.proposal});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
        return AppColors.success;
      case 'ditolak':
        return AppColors.error;
      case 'revisi':
        return AppColors.warning;
      case 'diajukan':
      default:
        return AppColors.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui_fakultas':
        return 'Disetujui Fakultas';
      case 'disetujui_univ':
        return 'Disetujui Universitas';
      case 'revisi':
        return 'Perlu Revisi';
      case 'diajukan':
        return 'Menunggu Review';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ormawaProvider = Provider.of<OrmawaProvider>(context, listen: false);
    final orgNameLower = ormawaProvider.orgName.toLowerCase();
    final isUnivLevel =
        orgNameLower.contains('universitas') ||
        orgNameLower.contains('ukm') ||
        orgNameLower.contains('mpm');

    final statusColor = _getStatusColor(proposal.status);
    final statusText = _getStatusText(proposal.status);
    final isRevisi = proposal.status.toLowerCase() == 'revisi';
    final isDitolak = proposal.status.toLowerCase() == 'ditolak';

    return Scaffold(
      backgroundColor: context.appColors.surface,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'DETAIL PROPOSAL',
            subtitle: proposal.code,
            variant: AppBarVariant.ormawa,
            expandedHeight: 130.0,
            showBackButton: true,
            isExpandable: false,
            actions: [
              IconButton(
                onPressed: () async {
                  AppSnackbar.showSuccess(context, 'Menyiapkan dokumen PDF...');
                  await ProposalPdfService.generateAndPrintPdf(proposal);
                },
                icon: Icon(Icons.print_rounded, color: context.appColors.onPrimary),
                tooltip: 'Cetak Proposal',
              ),
              IconButton(
                onPressed: () {
                  AppSnackbar.showSuccess(context, 'Membuka menu bagikan...');
                },
                icon: Icon(Icons.share_rounded, color: context.appColors.onPrimary),
                tooltip: 'Bagikan',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(statusColor, statusText),

                  if ((isRevisi || isDitolak) &&
                      proposal.catatan != null &&
                      proposal.catatan!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    _buildReviewerNote(proposal.catatan!),
                  ],

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle('Informasi Dasar'),
                  const SizedBox(height: AppSpacing.lg),
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _buildInfoItem(
                          Icons.title_rounded,
                          'Judul Proposal',
                          proposal.title,
                          color: AppColors.info,
                        ),
                        _buildInfoItem(
                          Icons.foundation_rounded,
                          'Landasan Kegiatan',
                          proposal.landasanKegiatan ?? '-',
                          color: context.appColors.info,
                        ),
                        _buildInfoItem(
                          Icons.category_rounded,
                          'Bentuk Kegiatan',
                          proposal.bentukKegiatan ?? '-',
                          color: AppColors.neutral700,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle('Pelaksanaan & Target'),
                  const SizedBox(height: AppSpacing.lg),
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _buildInfoItem(
                          Icons.calendar_today_rounded,
                          'Tanggal Kegiatan',
                          DateFormat(
                            'dd MMMM yyyy',
                            'id',
                          ).format(proposal.date),
                          color: AppColors.warning,
                        ),
                        _buildInfoItem(
                          Icons.schedule_rounded,
                          'Jadwal Pelaksanaan',
                          proposal.jadwalPelaksanaan ?? '-',
                          color: context.appColors.primary,
                        ),
                        _buildInfoItem(
                          Icons.handshake_rounded,
                          'Mitra Kerja',
                          proposal.mitra ?? '-',
                          color: context.appColors.warning,
                        ),
                        _buildInfoItem(
                          Icons.person_rounded,
                          'PJ Kegiatan',
                          proposal.pjKegiatan ?? '-',
                          color: context.appColors.info,
                        ),
                        _buildInfoItem(
                          Icons.group_rounded,
                          'Sasaran Kegiatan',
                          proposal.sasaranKegiatan ?? '-',
                          color: context.appColors.error,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle('Keuangan'),
                  const SizedBox(height: AppSpacing.lg),
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        _buildInfoItem(
                          Icons.payments_rounded,
                          'Total Anggaran',
                          'Rp ${NumberFormat('#,###', 'id_ID').format(proposal.budget)}',
                          color: AppColors.success,
                        ),
                        _buildInfoItem(
                          Icons.account_balance_wallet_rounded,
                          'Sumber Dana',
                          proposal.sumberDana ?? '-',
                          color: context.appColors.success,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle('Deskripsi & Analisis'),
                  const SizedBox(height: AppSpacing.lg),
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextContent(
                          'Latar Belakang',
                          proposal.latarBelakang,
                        ),
                        _buildTextContent(
                          'Tujuan Kegiatan',
                          proposal.tujuanKegiatan,
                        ),
                        _buildTextContent(
                          'Deskripsi Detail Kegiatan',
                          proposal.description,
                        ),
                        _buildTextContent(
                          'Indikator Keberhasilan',
                          proposal.indikatorKeberhasilan,
                          isLast: true,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle('Status Verifikasi'),
                  const SizedBox(height: AppSpacing.lg),
                  _buildStatusTimeline(context, proposal.status, isUnivLevel),

                  const SizedBox(height: AppSpacing.xxl),
                  _buildSectionTitle('Lampiran & Dokumen'),
                  const SizedBox(height: AppSpacing.lg),
                  if (proposal.fileUrl != null && proposal.fileUrl!.isNotEmpty)
                    _buildFileCard(
                      context,
                      'Dokumen_Proposal.pdf',
                      'Klik untuk mengunduh',
                    )
                  else
                    Text(
                      'Tidak ada dokumen terlampir',
                      style: AppTextStyles.labelSm.copyWith(
                        color: AppColors.neutral500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.xxxl),
                  if (isRevisi && ormawaProvider.hasPermission('edit_proposal'))
                    _buildReSubmitButton(context),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewerNote(String catatan) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: AppRadius.radiusLg,
        border: Border.all(color: AppColors.warning.withAlpha(50)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded, color: AppColors.warning, size: 24),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Reviewer',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.onWarningContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  catatan,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onWarningContainer.withAlpha(220),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(
    String title,
    String? content, {
    bool isLast = false,
  }) {
    if (content == null || content.isEmpty) return const SizedBox();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral600,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.neutral100,
              borderRadius: AppRadius.radiusMd,
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Text(
              content,
              style: AppTextStyles.bodyMd.copyWith(
                color: AppColors.neutral800,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(BuildContext context, String currentStatus, bool isUnivLevel) {
    final status = currentStatus.toLowerCase();

    bool isSubmitted = true;
    bool isFakultas =
        status == 'disetujui_fakultas' ||
        status == 'disetujui_univ' ||
        status == 'selesai';
    bool isUniv = status == 'disetujui_univ' || status == 'selesai';
    bool isRevisi = status == 'revisi';
    bool isDitolak = status == 'ditolak';

    return BkuCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          _buildTimelineStep(
            context,
            'Proposal Diajukan',
            isUnivLevel
                ? 'Menunggu respon Universitas'
                : 'Menunggu respon Fakultas',
            isSubmitted,
            true,
          ),
          if (!isUnivLevel)
            _buildTimelineStep(
              context,
              isRevisi
                  ? 'Revisi Fakultas'
                  : (isDitolak && !isFakultas
                      ? 'Ditolak Fakultas'
                      : 'Persetujuan Fakultas'),
              isRevisi
                  ? 'Perlu perbaikan proposal'
                  : (isDitolak && !isFakultas
                      ? 'Proposal tidak disetujui'
                      : 'Sedang dalam pengecekan'),
              isFakultas || isRevisi || isDitolak,
              true,
              isError: isDitolak && !isFakultas,
              isWarning: isRevisi,
            ),
          _buildTimelineStep(
            context,
            (isDitolak && isFakultas)
                ? 'Ditolak Universitas'
                : 'Persetujuan Universitas',
            (isDitolak && isFakultas)
                ? 'Proposal tidak disetujui'
                : (isUniv
                    ? 'Proposal telah disahkan'
                    : 'Tahap finalisasi di tingkat Univ'),
            isUniv || (isDitolak && (isFakultas || isUnivLevel)),
            false,
            isError: (isDitolak && (isFakultas || isUnivLevel)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context,
    String title,
    String subtitle,
    bool isDone,
    bool showLine, {
    bool isError = false,
    bool isWarning = false,
  }) {
    Color indicatorColor = AppColors.success;
    if (isError) indicatorColor = AppColors.error;
    if (isWarning) indicatorColor = AppColors.warning;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? indicatorColor : context.appColors.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Colors.transparent : AppColors.neutral400,
                  width: 2,
                ),
              ),
              child:
                  isDone
                      ? Icon(
                        isError
                            ? Icons.close
                            : (isWarning ? Icons.edit : Icons.check),
                        size: 14,
                        color: context.appColors.onPrimary,
                      )
                      : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 40,
                color:
                    isDone
                        ? indicatorColor.withAlpha(50)
                        : AppColors.neutral400,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMd.copyWith(
                  fontWeight: FontWeight.bold,
                  color:
                      isDone
                          ? (isError
                              ? AppColors.error
                              : (isWarning ? AppColors.warning : context.appColors.onSurface))
                          : AppColors.neutral500,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.neutral500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => CreateProposalScreen(initialProposal: proposal),
            ),
          );
        },
        icon: Icon(Icons.edit_document, color: context.appColors.onPrimary),
        label: Text(
          'PERBAIKI PROPOSAL',
          style: TextStyle(color: context.appColors.onPrimary, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildHeader(Color statusColor, String statusText) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(10),
        borderRadius: AppRadius.radiusXl,
        border: Border.all(color: statusColor.withAlpha(20)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.description_rounded,
              color: statusColor,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.s20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText.toUpperCase(),
                  style: AppTextStyles.labelSm.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Status Pengajuan Saat Ini',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.onSurface.withValues(alpha: 0.54)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelMd.copyWith(
            fontWeight: FontWeight.w900,
            color: AppColors.neutral800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: AppColors.neutral800,
            borderRadius: AppRadius.radiusXs,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    Color? color,
    bool isLast = false,
  }) {
    final effectiveColor = color ?? AppColors.primary;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.s20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: effectiveColor.withAlpha(15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: effectiveColor),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, String fileName, String size) {
    return BkuCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.bodyMd.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  size,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => AppSnackbar.showSuccess(context, 'Mengunduh berkas proposal $fileName...'),
            icon: Icon(Icons.download_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

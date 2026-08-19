import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/proposal_pdf_service.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/create_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaProposalDetailScreen extends StatelessWidget {
  final OrmawaProposal proposal;

  const OrmawaProposalDetailScreen({super.key, required this.proposal});

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
        return OrmawaBadgeVariant.success;
      case 'ditolak':
        return OrmawaBadgeVariant.danger;
      case 'revisi':
        return OrmawaBadgeVariant.warning;
      default:
        return OrmawaBadgeVariant.info;
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
        return status;
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

    final statusText = _getStatusText(proposal.status);
    final isRevisi = proposal.status.toLowerCase() == 'revisi';
    final isDitolak = proposal.status.toLowerCase() == 'ditolak';

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: 'Detail Proposal',
            subtitle: proposal.code,
            variant: AppBarVariant.ormawa,
            expandedHeight: 125.0,
            showBackButton: true,
            isExpandable: false,
            actions: [
              IconButton(
                onPressed: () async {
                  AppSnackbar.showSuccess(context, 'Menyiapkan dokumen PDF...');
                  await ProposalPdfService.generateAndPrintPdf(proposal);
                },
                icon: const Icon(Icons.print_rounded, color: Colors.white),
                tooltip: 'Cetak Proposal',
              ),
              IconButton(
                onPressed: () {
                  AppSnackbar.showSuccess(context, 'Membuka menu bagikan...');
                },
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                tooltip: 'Bagikan',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(statusText, proposal.status),
                  if ((isRevisi || isDitolak) &&
                      proposal.catatan != null &&
                      proposal.catatan!.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildReviewerNote(proposal.catatan!),
                  ],
                  const SizedBox(height: 16),
                  _buildSectionTitle('Informasi Dasar'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      children: [
                        _buildInfoItem(
                          Icons.title_rounded,
                          'Judul Proposal',
                          proposal.title,
                        ),
                        _buildInfoItem(
                          Icons.foundation_rounded,
                          'Landasan Kegiatan',
                          proposal.landasanKegiatan ?? '-',
                        ),
                        _buildInfoItem(
                          Icons.category_rounded,
                          'Bentuk Kegiatan',
                          proposal.bentukKegiatan ?? '-',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Pelaksanaan & Target'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      children: [
                        _buildInfoItem(
                          Icons.calendar_today_rounded,
                          'Tanggal Kegiatan',
                          DateFormat('dd MMMM yyyy', 'id').format(proposal.date),
                        ),
                        _buildInfoItem(
                          Icons.schedule_rounded,
                          'Jadwal Pelaksanaan',
                          proposal.jadwalPelaksanaan ?? '-',
                        ),
                        _buildInfoItem(
                          Icons.handshake_rounded,
                          'Mitra Kerja',
                          proposal.mitra ?? '-',
                        ),
                        _buildInfoItem(
                          Icons.person_rounded,
                          'PJ Kegiatan',
                          proposal.pjKegiatan ?? '-',
                        ),
                        _buildInfoItem(
                          Icons.group_rounded,
                          'Sasaran Kegiatan',
                          proposal.sasaranKegiatan ?? '-',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Keuangan'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      children: [
                        _buildInfoItem(
                          Icons.payments_rounded,
                          'Total Anggaran',
                          NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(proposal.budget),
                        ),
                        _buildInfoItem(
                          Icons.account_balance_wallet_rounded,
                          'Sumber Dana',
                          proposal.sumberDana ?? '-',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Deskripsi & Analisis'),
                  const SizedBox(height: 8),
                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextContent('Latar Belakang', proposal.latarBelakang),
                        _buildTextContent('Tujuan Kegiatan', proposal.tujuanKegiatan),
                        _buildTextContent('Deskripsi Detail Kegiatan', proposal.description),
                        _buildTextContent('Indikator Keberhasilan', proposal.indikatorKeberhasilan, isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Status Verifikasi'),
                  const SizedBox(height: 8),
                  _buildStatusTimeline(context, proposal.status, isUnivLevel),
                  const SizedBox(height: 16),
                  _buildSectionTitle('Lampiran & Dokumen'),
                  const SizedBox(height: 8),
                  if (proposal.fileUrl != null && proposal.fileUrl!.isNotEmpty)
                    _buildFileCard(
                      context,
                      'Dokumen_Proposal.pdf',
                      'Klik untuk mengunduh',
                    )
                  else
                    Text(
                      'Tidak ada dokumen terlampir',
                      style: TextStyle(
                        fontSize: 11,
                        color: OrmawaTheme.textMuted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrmawaTheme.statusWarningBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrmawaTheme.statusWarningBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: OrmawaTheme.statusWarningText, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Reviewer',
                  style: TextStyle(
                    fontSize: 11,
                    color: OrmawaTheme.statusWarningText,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  catatan,
                  style: TextStyle(
                    fontSize: 12,
                    color: OrmawaTheme.textHeading,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(String title, String? content, {bool isLast = false}) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: OrmawaTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: OrmawaTheme.textMuted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 12,
                color: OrmawaTheme.textHeading,
                height: 1.5,
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
    bool isFakultas = status == 'disetujui_fakultas' || status == 'disetujui_univ' || status == 'selesai';
    bool isUniv = status == 'disetujui_univ' || status == 'selesai';
    bool isRevisi = status == 'revisi';
    bool isDitolak = status == 'ditolak';

    return OrmawaCard(
      child: Column(
        children: [
          _buildTimelineStep(
            'Proposal Diajukan',
            isUnivLevel ? 'Menunggu respon Universitas' : 'Menunggu respon Fakultas',
            isSubmitted,
            true,
          ),
          if (!isUnivLevel)
            _buildTimelineStep(
              isRevisi
                  ? 'Revisi Fakultas'
                  : (isDitolak && !isFakultas ? 'Ditolak Fakultas' : 'Persetujuan Fakultas'),
              isRevisi
                  ? 'Perlu perbaikan proposal'
                  : (isDitolak && !isFakultas ? 'Proposal tidak disetujui' : 'Sedang dalam pengecekan'),
              isFakultas || isRevisi || isDitolak,
              true,
              isError: isDitolak && !isFakultas,
              isWarning: isRevisi,
            ),
          _buildTimelineStep(
            (isDitolak && isFakultas) ? 'Ditolak Universitas' : 'Persetujuan Universitas',
            (isDitolak && isFakultas)
                ? 'Proposal tidak disetujui'
                : (isUniv ? 'Proposal telah disahkan' : 'Tahap finalisasi di tingkat Univ'),
            isUniv || (isDitolak && (isFakultas || isUnivLevel)),
            false,
            isError: (isDitolak && (isFakultas || isUnivLevel)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    String title,
    String subtitle,
    bool isDone,
    bool showLine, {
    bool isError = false,
    bool isWarning = false,
  }) {
    Color indicatorColor = OrmawaTheme.statusSuccessText;
    if (isError) indicatorColor = OrmawaTheme.statusDangerText;
    if (isWarning) indicatorColor = OrmawaTheme.statusWarningText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isDone ? indicatorColor : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? Colors.transparent : const Color(0xFFCBD5E1),
                  width: 2,
                ),
              ),
              child: isDone
                  ? Icon(
                      isError ? Icons.close : (isWarning ? Icons.edit : Icons.check),
                      size: 13,
                      color: Colors.white,
                    )
                  : null,
            ),
            if (showLine)
              Container(
                width: 2,
                height: 36,
                color: isDone ? indicatorColor.withAlpha(50) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: isDone
                      ? (isError
                          ? OrmawaTheme.statusDangerText
                          : (isWarning ? OrmawaTheme.statusWarningText : OrmawaTheme.textHeading))
                      : OrmawaTheme.textMuted,
                ),
              ),
              SizedBox(height: 1),
              Text(
                subtitle,
                style: TextStyle(
                  color: OrmawaTheme.textMuted,
                  fontSize: 10.5,
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
      height: 48,
      child: OrmawaButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProposalScreen(initialProposal: proposal),
            ),
          );
        },
        icon: Icons.edit_document,
        text: 'PERBAIKI PROPOSAL',
      ),
    );
  }

  Widget _buildHeader(String statusText, String rawStatus) {
    return OrmawaCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: OrmawaTheme.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.description_rounded,
              color: OrmawaTheme.primary,
              size: 24,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Pengajuan',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: OrmawaTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: OrmawaTheme.textHeading,
                  ),
                ),
              ],
            ),
          ),
          OrmawaBadge(
            text: rawStatus.toUpperCase(),
            variant: _getBadgeVariant(rawStatus),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3.5,
          height: 13,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: OrmawaTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: OrmawaTheme.textHeading,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: OrmawaTheme.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: OrmawaTheme.primary),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: OrmawaTheme.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: OrmawaTheme.textHeading,
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
    return OrmawaCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: OrmawaTheme.statusDangerBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: OrmawaTheme.statusDangerText,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                    color: OrmawaTheme.textHeading,
                  ),
                ),
                Text(
                  size,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: OrmawaTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => AppSnackbar.showSuccess(context, 'Mengunduh berkas proposal $fileName...'),
            icon: Icon(Icons.download_rounded, color: OrmawaTheme.primary),
          ),
        ],
      ),
    );
  }
}

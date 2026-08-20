import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/bku_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_loading_dialog.dart';
import 'package:bkuhub_mobile/core/utils/snackbar_helper.dart';
import 'package:bkuhub_mobile/core/services/proposal_pdf_service.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/proposal/presentation/pages/edit_proposal_screen.dart';
import 'package:bkuhub_mobile/features/ormawa/presentation/providers/ormawa_provider.dart';

class OrmawaProposalDetailScreen extends StatefulWidget {
  final OrmawaProposal proposal;

  const OrmawaProposalDetailScreen({super.key, required this.proposal});

  @override
  State<OrmawaProposalDetailScreen> createState() => _OrmawaProposalDetailScreenState();
}

class _OrmawaProposalDetailScreenState extends State<OrmawaProposalDetailScreen> {
  String _formatRp(double val) {
    if (val == 0.0) return '—';
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(val);
  }

  String _formatDateRange(OrmawaProposal p) {
    final startStr = DateFormat('EEEE, d MMMM yyyy', 'id').format(p.date);
    if (p.tanggalSelesai != null) {
      final isSame = p.date.year == p.tanggalSelesai!.year &&
          p.date.month == p.tanggalSelesai!.month &&
          p.date.day == p.tanggalSelesai!.day;
      if (!isSame) {
        final endStr = DateFormat('EEEE, d MMMM yyyy', 'id').format(p.tanggalSelesai!);
        return '$startStr s/d $endStr';
      }
    }
    if (p.jadwalPelaksanaan != null && p.jadwalPelaksanaan!.contains(' s/d ')) {
      final m = RegExp(r'^(.*?)\s*\(').firstMatch(p.jadwalPelaksanaan!);
      if (m != null && m.group(1) != null) {
        return m.group(1)!.trim();
      }
    }
    return startStr;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
        return BkuTheme.emerald;
      case 'ditolak':
        return BkuTheme.rose;
      case 'revisi':
        return BkuTheme.amber;
      default:
        return BkuTheme.sky;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
        return BkuTheme.emeraldSoft;
      case 'ditolak':
        return BkuTheme.roseSoft;
      case 'revisi':
        return BkuTheme.amberSoft;
      default:
        return BkuTheme.skySoft;
    }
  }

  Color _getStatusBorder(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
        return BkuTheme.emeraldBorder;
      case 'ditolak':
        return BkuTheme.roseBorder;
      case 'revisi':
        return BkuTheme.amberBorder;
      default:
        return BkuTheme.skyBorder;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui_prodi':
        return 'ACC Prodi';
      case 'disetujui_fakultas':
        return 'ACC Fakultas';
      case 'disetujui_univ':
        return 'Disetujui Univ';
      case 'revisi':
        return 'Butuh Revisi';
      case 'diajukan':
        return 'Diajukan';
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return status.toUpperCase();
    }
  }

  void _confirmDelete() {
    BkuDialog.show(
      context: context,
      title: 'Hapus Pengajuan Proposal?',
      message: 'Apakah Anda yakin ingin membatalkan/menghapus usulan "${widget.proposal.title}"? Tindakan ini tidak dapat dibatalkan.',
      type: BkuDialogType.error,
      primaryButtonText: 'Hapus',
      onPrimaryPressed: () async {
        Navigator.pop(context);
        try {
          await context.read<OrmawaProvider>().deleteProposal(widget.proposal.id);
          if (mounted) {
            AppSnackbar.showSuccess(context, 'Proposal berhasil dihapus');
            context.pop();
          }
        } catch (e) {
          if (mounted) {
            AppSnackbar.showError(context, 'Gagal menghapus proposal: $e');
          }
        }
      },
      secondaryButtonText: 'Batal',
      onSecondaryPressed: () => Navigator.pop(context),
    );
  }

  Future<void> _handleResubmit() async {
    BkuLoadingDialog.show(context);
    try {
      await context.read<OrmawaProvider>().resubmitProposal(widget.proposal.id);
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showSuccess(context, 'Proposal berhasil diajukan ulang ke verifikator');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        BkuLoadingDialog.hide(context);
        AppSnackbar.showError(context, 'Gagal mengajukan ulang: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrmawaProvider>();
    final p = provider.proposals.cast<OrmawaProposal>().firstWhere(
      (item) => item.id == widget.proposal.id,
      orElse: () => widget.proposal,
    );
    final statusLower = p.status.toLowerCase();
    final isRevisi = statusLower == 'revisi';
    final isDitolak = statusLower == 'ditolak';

    final statusText = _getStatusText(p.status);
    final statusColor = _getStatusColor(p.status);
    final statusBg = _getStatusBg(p.status);
    final statusBorder = _getStatusBorder(p.status);

    return Scaffold(
      backgroundColor: BkuTheme.scaffoldBg,
      body: CustomScrollView(
        slivers: [
          BkuAppBar(
            title: p.title,
            subtitle: 'Rincian Usulan & Status Verifikasi',
            variant: AppBarVariant.ormawa,
            expandedHeight: 140.0,
            showBackButton: true,
            isExpandable: false,
            actions: [
              IconButton(
                onPressed: () async {
                  AppSnackbar.showSuccess(context, 'Menyiapkan dokumen PDF proposal...');
                  await ProposalPdfService.generateAndPrintPdf(p);
                },
                icon: const Icon(Icons.print_rounded, color: Colors.white),
                tooltip: 'Cetak Dokumen Proposal',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: BkuTheme.primarySoft,
                                borderRadius: BkuTheme.r12,
                              ),
                              child: Icon(Icons.description_rounded, color: BkuTheme.primary, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: BkuTheme.textCardTitle.copyWith(fontSize: 15, fontWeight: FontWeight.w900),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: BkuTheme.borderSubtle,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: BkuTheme.border),
                                        ),
                                        child: Text(
                                          '#PROP-${p.id}',
                                          style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BkuTheme.r8,
                                          border: Border.all(color: statusBorder),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (isRevisi || isDitolak) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDitolak ? BkuTheme.roseSoft : BkuTheme.amberSoft,
                        borderRadius: BkuTheme.r16,
                        border: Border.all(color: isDitolak ? BkuTheme.roseBorder : BkuTheme.amberBorder),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isDitolak ? Icons.cancel_outlined : Icons.error_outline_rounded,
                            color: isDitolak ? BkuTheme.rose : BkuTheme.amber,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDitolak ? 'Proposal Ditolak Verifikator' : 'Catatan Revisi dari Reviewer',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: isDitolak ? BkuTheme.rose : BkuTheme.amber,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  p.catatan != null && p.catatan!.isNotEmpty
                                      ? p.catatan!
                                      : (isDitolak
                                          ? 'Pengajuan tidak disetujui untuk dilaksanakan pada periode ini.'
                                          : 'Silakan perbaiki data proposal sesuai arahan, lalu ajukan kembali.'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDitolak ? BkuTheme.rose : BkuTheme.amber,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.emeraldSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.access_time_rounded, color: BkuTheme.emerald, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Waktu & Pelaksanaan', style: BkuTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.calendar_month_rounded,
                          iconColor: BkuTheme.emerald,
                          label: 'Tanggal Pelaksanaan',
                          value: _formatDateRange(p),
                        ),
                        if (p.jadwalPelaksanaan != null && p.jadwalPelaksanaan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.schedule_rounded,
                            iconColor: BkuTheme.emerald,
                            label: 'Rincian Jadwal',
                            value: p.jadwalPelaksanaan!,
                          ),
                        ],
                        if (p.bentukKegiatan != null && p.bentukKegiatan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.category_rounded,
                            iconColor: BkuTheme.purple,
                            label: 'Bentuk / Kategori Kegiatan',
                            value: p.bentukKegiatan!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.purpleSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.people_alt_rounded, color: BkuTheme.purple, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Penanggung Jawab & Struktur', style: BkuTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.person_rounded,
                          iconColor: BkuTheme.purple,
                          label: 'Penanggung Jawab (PJ)',
                          value: p.pjKegiatan != null && p.pjKegiatan!.isNotEmpty ? p.pjKegiatan! : '—',
                        ),
                        if (p.mitra != null && p.mitra!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.handshake_rounded,
                            iconColor: BkuTheme.primary,
                            label: 'Mitra Kolaborasi',
                            value: p.mitra!,
                          ),
                        ],
                        if (p.sasaranKegiatan != null && p.sasaranKegiatan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.groups_rounded,
                            iconColor: BkuTheme.sky,
                            label: 'Sasaran Peserta',
                            value: p.sasaranKegiatan!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  BkuCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    borderRadius: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: BkuTheme.amberSoft,
                                borderRadius: BkuTheme.r8,
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: BkuTheme.amber, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Anggaran & Sumber Dana', style: BkuTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.payments_rounded,
                          iconColor: BkuTheme.emerald,
                          label: 'Estimasi Total Anggaran',
                          value: _formatRp(p.budget),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.savings_rounded,
                          iconColor: BkuTheme.amber,
                          label: 'Sumber Alokasi Dana',
                          value: p.sumberDana != null && p.sumberDana!.isNotEmpty ? p.sumberDana! : 'Pagu Ormawa',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  if ((p.description != null && p.description!.isNotEmpty) ||
                      (p.latarBelakang != null && p.latarBelakang!.isNotEmpty) ||
                      (p.tujuanKegiatan != null && p.tujuanKegiatan!.isNotEmpty) ||
                      (p.landasanKegiatan != null && p.landasanKegiatan!.isNotEmpty) ||
                      (p.indikatorKeberhasilan != null && p.indikatorKeberhasilan!.isNotEmpty)) ...[
                    BkuCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: BkuTheme.primarySoft,
                                  borderRadius: BkuTheme.r8,
                                ),
                                child: Icon(Icons.article_rounded, color: BkuTheme.primary, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Naskah Kerangka Acuan Kerja (KAK)', style: BkuTheme.textSectionTitle),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (p.description != null && p.description!.isNotEmpty) ...[
                            _buildSectionBlock('Deskripsi Usulan', p.description!),
                            const SizedBox(height: 12),
                          ],
                          if (p.latarBelakang != null && p.latarBelakang!.isNotEmpty) ...[
                            _buildSectionBlock('Latar Belakang', p.latarBelakang!),
                            const SizedBox(height: 12),
                          ],
                          if (p.tujuanKegiatan != null && p.tujuanKegiatan!.isNotEmpty) ...[
                            _buildSectionBlock('Tujuan & Manfaat', p.tujuanKegiatan!),
                            const SizedBox(height: 12),
                          ],
                          if (p.landasanKegiatan != null && p.landasanKegiatan!.isNotEmpty) ...[
                            _buildSectionBlock('Landasan Hukum & Kebijakan', p.landasanKegiatan!),
                            const SizedBox(height: 12),
                          ],
                          if (p.indikatorKeberhasilan != null && p.indikatorKeberhasilan!.isNotEmpty)
                            _buildSectionBlock('Indikator Keberhasilan', p.indikatorKeberhasilan!),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (isRevisi) ...[
                    SizedBox(
                      width: double.infinity,
                      child: BkuButton.primary(
                        text: 'Ajukan Ulang Proposal (Resubmit)',
                        onPressed: _handleResubmit,
                        icon: Icons.send_rounded,
                        height: 48,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: BkuButton.primary(
                          text: 'Edit Proposal',
                          icon: Icons.edit_rounded,
                          height: 46,
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProposalScreen(proposal: p),
                              ),
                            );
                            if (context.mounted) {
                              context.read<OrmawaProvider>().refreshData();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BkuButton.outline(
                          text: 'Batalkan Usulan',
                          icon: Icons.delete_outline_rounded,
                          height: 46,
                          onPressed: _confirmDelete,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: BkuButton.outline(
                      text: 'Cetak Dokumen Resmi (PDF)',
                      icon: Icons.print_rounded,
                      height: 46,
                      onPressed: () async {
                        AppSnackbar.showSuccess(context, 'Menyiapkan dokumen PDF...');
                        await ProposalPdfService.generateAndPrintPdf(p);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BkuTheme.r8,
          ),
          child: Icon(icon, size: 15, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: BkuTheme.textCaption.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: BkuTheme.textMuted),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: BkuTheme.textBodyRegular.copyWith(fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBlock(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: BkuTheme.textBadge.copyWith(fontSize: 11, fontWeight: FontWeight.w800, color: BkuTheme.textMuted),
        ),
        const SizedBox(height: 3),
        Text(
          content,
          style: BkuTheme.textBodyRegular.copyWith(fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}
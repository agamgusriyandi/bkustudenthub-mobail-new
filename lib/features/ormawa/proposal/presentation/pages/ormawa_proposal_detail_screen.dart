import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_app_bar.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_card.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_badge.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_dialog.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/ormawa_button.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bounce_button.dart';
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

  OrmawaBadgeVariant _getBadgeVariant(String status) {
    switch (status.toLowerCase()) {
      case 'disetujui':
      case 'selesai':
      case 'disetujui_univ':
      case 'disetujui_fakultas':
      case 'disetujui_prodi':
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

    return Scaffold(
      backgroundColor: OrmawaTheme.scaffoldBg,
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
                  OrmawaCard(
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
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.description_rounded, color: Color(0xFF2563EB), size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: OrmawaTheme.textCardTitle.copyWith(fontSize: 15),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          '#PROP-${p.id}',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF334155), fontFamily: 'monospace'),
                                        ),
                                      ),
                                      OrmawaBadge(
                                        text: _getStatusText(p.status),
                                        variant: _getBadgeVariant(p.status),
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
                        color: isDitolak ? const Color(0xFFFFF1F2) : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDitolak ? const Color(0xFFFECDD3) : const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isDitolak ? Icons.cancel_outlined : Icons.error_outline_rounded,
                            color: isDitolak ? const Color(0xFFE11D48) : const Color(0xFFD97706),
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
                                    color: isDitolak ? const Color(0xFF9F1239) : const Color(0xFF92400E),
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
                                    color: isDitolak ? const Color(0xFF881337) : const Color(0xFF78350F),
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

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.access_time_rounded, color: Color(0xFF059669), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Waktu & Pelaksanaan', style: OrmawaTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF059669),
                          label: 'Tanggal Pelaksanaan',
                          value: _formatDateRange(p),
                        ),
                        if (p.jadwalPelaksanaan != null && p.jadwalPelaksanaan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.schedule_rounded,
                            iconColor: const Color(0xFF059669),
                            label: 'Rincian Jadwal',
                            value: p.jadwalPelaksanaan!,
                          ),
                        ],
                        if (p.bentukKegiatan != null && p.bentukKegiatan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.category_rounded,
                            iconColor: const Color(0xFF7C3AED),
                            label: 'Bentuk / Kategori Kegiatan',
                            value: p.bentukKegiatan!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.people_alt_rounded, color: Color(0xFF7C3AED), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Penanggung Jawab & Struktur', style: OrmawaTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          label: 'Penanggung Jawab (PJ)',
                          value: p.pjKegiatan != null && p.pjKegiatan!.isNotEmpty ? p.pjKegiatan! : '—',
                        ),
                        if (p.mitra != null && p.mitra!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.handshake_rounded,
                            iconColor: const Color(0xFF0D9488),
                            label: 'Mitra Kolaborasi',
                            value: p.mitra!,
                          ),
                        ],
                        if (p.sasaranKegiatan != null && p.sasaranKegiatan!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildDetailRow(
                            icon: Icons.groups_rounded,
                            iconColor: const Color(0xFF0284C7),
                            label: 'Sasaran Peserta',
                            value: p.sasaranKegiatan!,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  OrmawaCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFD97706), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text('Anggaran & Sumber Dana', style: OrmawaTheme.textSectionTitle),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow(
                          icon: Icons.payments_rounded,
                          iconColor: const Color(0xFF059669),
                          label: 'Estimasi Total Anggaran',
                          value: _formatRp(p.budget),
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: Icons.savings_rounded,
                          iconColor: const Color(0xFFD97706),
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
                    OrmawaCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.article_rounded, color: Color(0xFF2563EB), size: 18),
                              ),
                              const SizedBox(width: 10),
                              Text('Naskah Kerangka Acuan Kerja (KAK)', style: OrmawaTheme.textSectionTitle),
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
                      height: 48,
                      child: OrmawaButton(
                        text: 'AJUKAN ULANG PROPOSAL (RESUBMIT)',
                        onPressed: _handleResubmit,
                        icon: Icons.send_rounded,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: BkuBounceButton(
                          onTap: () async {
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
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: OrmawaTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Edit Proposal',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: BkuBounceButton(
                          onTap: _confirmDelete,
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECDD3)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFE11D48)),
                                SizedBox(width: 6),
                                Text(
                                  'Batalkan Usulan',
                                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFFE11D48)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: BkuBounceButton(
                      onTap: () async {
                        AppSnackbar.showSuccess(context, 'Menyiapkan dokumen PDF...');
                        await ProposalPdfService.generateAndPrintPdf(p);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFCBD5E1)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.print_rounded, size: 16, color: Color(0xFF334155)),
                            SizedBox(width: 6),
                            Text(
                              'Cetak Dokumen Resmi (PDF)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                            ),
                          ],
                        ),
                      ),
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
            borderRadius: BorderRadius.circular(8),
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
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
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
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 3),
        Text(
          content,
          style: const TextStyle(fontSize: 12, color: Color(0xFF334155), height: 1.4),
        ),
      ],
    );
  }
}
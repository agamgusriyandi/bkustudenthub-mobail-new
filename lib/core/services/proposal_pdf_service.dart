import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';

import 'package:flutter/material.dart';
import 'package:bkuhub_mobile/core/theme/ormawa_theme.dart';
import 'package:bkuhub_mobile/core/widgets/bku_design/bku_bottom_sheet.dart';

class ProposalPdfService {
  static Future<pw.Document> generatePdfDocument(
    OrmawaProposal proposal, {
    String ormawaName = 'Organisasi Kemahasiswaan',
  }) async {
    final pdf = pw.Document();

    final customTheme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
    );

    pdf.addPage(
      pw.MultiPage(
        theme: customTheme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(AppSpacing.xxl),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: AppSpacing.s20),
            _buildInfoRow('Organisasi', ormawaName),
            _buildInfoRow('Judul Kegiatan', proposal.title),
            _buildInfoRow(
              'Landasan Kegiatan',
              proposal.landasanKegiatan ?? '-',
            ),
            _buildInfoRow('Bentuk Kegiatan', proposal.bentukKegiatan ?? '-'),
            _buildInfoRow('Target Sasaran', proposal.sasaranKegiatan ?? '-'),
            _buildInfoRow('Penanggung Jawab', proposal.pjKegiatan ?? '-'),
            _buildInfoRow(
              'Jadwal Pelaksanaan',
              proposal.jadwalPelaksanaan ?? '-',
            ),
            _buildInfoRow(
              'Total Anggaran',
              'Rp ${NumberFormat('#,###', 'id_ID').format(proposal.budget)}',
            ),
            _buildInfoRow('Sumber Dana', proposal.sumberDana ?? '-'),
            pw.SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Deskripsi Kegiatan'),
            pw.Text(
              proposal.description ?? '-',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Latar Belakang'),
            pw.Text(
              proposal.latarBelakang ?? '-',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Tujuan'),
            pw.Text(
              proposal.tujuanKegiatan ?? '-',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Indikator Keberhasilan'),
            pw.Text(
              proposal.indikatorKeberhasilan ?? '-',
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.SizedBox(height: AppSpacing.xxxl),
            _buildSignatureBlocks(proposal.pjKegiatan ?? 'Ketua Pelaksana'),
          ];
        },
      ),
    );

    return pdf;
  }

  static Future<void> generateAndPrintPdf(
    OrmawaProposal proposal, {
    String ormawaName = 'Organisasi Kemahasiswaan',
  }) async {
    final pdf = await generatePdfDocument(proposal, ormawaName: ormawaName);
    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Proposal_${proposal.code}.pdf',
    );
  }

  static void showPdfActionSheet(
    BuildContext context,
    OrmawaProposal proposal, {
    String ormawaName = 'Organisasi Kemahasiswaan',
  }) {
    BkuBottomSheet.show(
      context: context,
      title: 'Dokumen Proposal: ${proposal.code}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF4F46E5), size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proposal.title,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Total Anggaran: Rp ${NumberFormat('#,###', 'id_ID').format(proposal.budget)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final pdf = await generatePdfDocument(proposal, ormawaName: ormawaName);
                    await Printing.layoutPdf(
                      onLayout: (PdfPageFormat format) async => pdf.save(),
                      name: 'Proposal_${proposal.code}',
                    );
                  },
                  icon: const Icon(Icons.print_rounded, size: 16, color: Color(0xFF0F172A)),
                  label: const Text(
                    'Cetak / Preview',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await generateAndPrintPdf(proposal, ormawaName: ormawaName);
                  },
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: const Text(
                    'Bagikan PDF',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrmawaTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  static pw.Widget _buildHeader() {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            'FORM PENGAJUAN PROPOSAL KEGIATAN',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: AppSpacing.xs),
          pw.Text(
            'KEMAHASISWAAN UNIVERSITAS BINA KARYA',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.SizedBox(height: AppSpacing.s10),
          pw.Divider(),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(
            ': ',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          decoration: pw.TextDecoration.underline,
        ),
      ),
    );
  }

  static pw.Widget _buildSignatureBlocks(String pjName) {
    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSigBox('Ketua Pelaksana', pjName),
            _buildSigBox('Ketua Organisasi', '____________________'),
            _buildSigBox('BEM Universitas', '____________________'),
          ],
        ),
        pw.SizedBox(height: 30),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
          children: [
            _buildSigBox(
              'Menyetujui:\nPembina Organisasi',
              '____________________',
            ),
            _buildSigBox(
              'Menyetujui:\nKepala Divisi Kemahasiswaan',
              '____________________',
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSigBox(String role, String name) {
    return pw.Column(
      mainAxisSize: pw.MainAxisSize.min,
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          role,
          textAlign: pw.TextAlign.center,
          style: const pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(height: AppSpacing.xxxl),
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }
}

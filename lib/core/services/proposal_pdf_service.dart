import 'package:bkuhub_mobile/core/theme/app_spacing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';

class ProposalPdfService {
  static Future<void> generateAndPrintPdf(
    OrmawaProposal proposal, {
    String ormawaName = 'Organisasi Kemahasiswaan',
  }) async {
    final pdf = pw.Document();

    // Standard built-in font
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

    final bytes = await pdf.save();
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'Proposal_${proposal.code}.pdf',
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
        title.toUpperCase(),
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

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:bkuhub_mobile/features/mahasiswa/presentation/providers/student_provider.dart';
import 'package:bkuhub_mobile/features/mahasiswa/domain/entities/organization_history.dart';

class PortfolioPdfGenerator {
  static Future<void> generateAndPrintPortfolio(StudentProvider student) async {
    final doc = pw.Document();

    final primaryColor = PdfColor.fromHex('#1E293B');
    final secondaryColor = PdfColor.fromHex('#475569');
    final lightBg = PdfColor.fromHex('#F8FAFC');
    final borderColor = PdfColor.fromHex('#CBD5E1');
    final textDark = PdfColor.fromHex('#0F172A');
    final textMuted = PdfColor.fromHex('#64748B');

    final now = DateTime.now();
    final dateStr = '${now.day} ${_getNamaBulan(now.month)} ${now.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        header: (pw.Context context) {
          if (context.pageNumber == 1) return pw.SizedBox();
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'UNIVERSITAS BAKTI KENCANA - PORTOFOLIO MAHASISWA',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: textMuted,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'NIM: ${student.nim}',
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 16),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: borderColor, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Dokumen Portofolio Resmi - Sistem Informasi Akademik Universitas Bakti Kencana',
                  style: pw.TextStyle(fontSize: 8, color: textMuted),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                  style: pw.TextStyle(
                    fontSize: 8,
                    color: textMuted,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          final orgList = student.organizationHistory;
          final verifiedCount =
              orgList
                  .where(
                    (o) => o.statusVerifikasi.toLowerCase() == 'terverifikasi',
                  )
                  .length;

          return [
            // Formal Kop Dokumen
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'UNIVERSITAS BAKTI KENCANA',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'PORTOFOLIO KEGIATAN & REKAM JEJAK MAHASISWA',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: secondaryColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Tanggal Dicetak:',
                      style: pw.TextStyle(fontSize: 8, color: textMuted),
                    ),
                    pw.Text(
                      dateStr,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(color: primaryColor, thickness: 1.5),
            pw.SizedBox(height: 16),

            // Profile & Summary Table
            pw.Container(
              padding: const pw.EdgeInsets.all(14),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderColor, width: 0.8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BIODATA MAHASISWA',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Nama Lengkap',
                              student.name,
                              textDark,
                              textMuted,
                            ),
                            pw.SizedBox(height: 6),
                            _buildInfoRow(
                              'NIM',
                              student.nim,
                              textDark,
                              textMuted,
                            ),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              'Program Studi',
                              student.prodi,
                              textDark,
                              textMuted,
                            ),
                            pw.SizedBox(height: 6),
                            _buildInfoRow(
                              'Semester',
                              'Semester ${student.semester}',
                              textDark,
                              textMuted,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: borderColor, thickness: 0.5),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Ringkasan Portofolio: ${orgList.length} Organisasi ($verifiedCount Terverifikasi)',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 24),

            // Section Header: Riwayat Organisasi
            pw.Text(
              'RIWAYAT KEPENGURUSAN & ORGANISASI',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: primaryColor,
                letterSpacing: 0.5,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Divider(color: borderColor, thickness: 0.8),
            pw.SizedBox(height: 12),

            // List Organisasi
            if (orgList.isEmpty)
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: borderColor, width: 0.5),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Belum ada riwayat organisasi yang terdaftar.',
                    style: pw.TextStyle(fontSize: 10, color: textMuted),
                  ),
                ),
              )
            else
              ...orgList.map(
                (org) => _buildFormalOrgItem(
                  org,
                  textDark,
                  textMuted,
                  borderColor,
                  primaryColor,
                ),
              ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
      name: 'Portofolio_${student.nim}.pdf',
    );
  }

  static String _getNamaBulan(int month) {
    const bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    if (month >= 1 && month <= 12) return bulan[month - 1];
    return '';
  }

  static pw.Widget _buildInfoRow(
    String label,
    String value,
    PdfColor textDark,
    PdfColor textMuted,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 90,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontSize: 9, color: textMuted),
          ),
        ),
        pw.Text(': ', style: pw.TextStyle(fontSize: 9, color: textMuted)),
        pw.Expanded(
          child: pw.Text(
            value.isEmpty ? '-' : value,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: textDark,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFormalOrgItem(
    OrganizationHistory org,
    PdfColor textDark,
    PdfColor textMuted,
    PdfColor borderColor,
    PdfColor primaryColor,
  ) {
    final period =
        org.periodeSelesai != null
            ? '${org.periodeMulai} - ${org.periodeSelesai}'
            : '${org.periodeMulai} - Sekarang';
    final isVerified = org.statusVerifikasi.toLowerCase() == 'terverifikasi';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      org.namaOrganisasi,
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      '${org.jabatan} | ${org.tipe.isNotEmpty ? "${org.tipe} | " : ""}$period',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color:
                      isVerified
                          ? PdfColor.fromHex('#F0FDF4')
                          : PdfColor.fromHex('#FEF3C7'),
                  border: pw.Border.all(
                    color:
                        isVerified
                            ? PdfColor.fromHex('#BBF7D0')
                            : PdfColor.fromHex('#FDE68A'),
                    width: 0.5,
                  ),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Text(
                  isVerified ? 'TERVERIFIKASI' : 'BELUM VERIFIKASI',
                  style: pw.TextStyle(
                    fontSize: 7,
                    fontWeight: pw.FontWeight.bold,
                    color:
                        isVerified
                            ? PdfColor.fromHex('#166534')
                            : PdfColor.fromHex('#92400E'),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          if (org.deskripsiKegiatan.isNotEmpty) ...[
            pw.Text(
              'Deskripsi Kontribusi:',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: textMuted,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              org.deskripsiKegiatan,
              style: pw.TextStyle(fontSize: 9, color: textDark),
            ),
            pw.SizedBox(height: 6),
          ],
          if (org.achievements.isNotEmpty) ...[
            pw.Text(
              'Pencapaian & Impact:',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: textMuted,
              ),
            ),
            pw.SizedBox(height: 2),
            ...org.achievements.map(
              (ach) => pw.Padding(
                padding: const pw.EdgeInsets.only(left: 4, bottom: 2),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      '- ',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        ach,
                        style: pw.TextStyle(fontSize: 9, color: textDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (org.dokumentasi != null && org.dokumentasi!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              '[Dokumentasi Terlampir pada Sistem]',
              style: pw.TextStyle(
                fontSize: 7,
                fontStyle: pw.FontStyle.italic,
                color: textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

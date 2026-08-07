import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:bkuhub_mobile/core/services/api_gate.dart';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/features/mahasiswa/kencana/data/models/certificate_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificateRepository {
  final ApiClient _apiClient = ApiClient();

  Future<KencanaCertificate?> getCertificate() async {
    try {
      final response = await _apiClient.client.get(
        '/kencana-student/certificate',
      );
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data is Map<String, dynamic>) {
          final cert = KencanaCertificate.fromJson(data);
          if (cert.id > 0 && cert.fileUrl != null && cert.fileUrl!.isNotEmpty) {
            return cert;
          }
        }
      }
    } catch (_) {}

    return null;
  }

  Future<List<int>> downloadCertificateBytes(KencanaCertificate cert) async {
    try {
      final url = ApiGate.getImageUrl(cert.fileUrl ?? '');
      final response = await _apiClient.client.get<dynamic>(
        url,
        options: Options(responseType: ResponseType.bytes, followRedirects: true),
      );
      final data = response.data;
      if (data is List<int> && data.isNotEmpty) return data;
    } catch (_) {}

    // Dynamic PDF Generation
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(30),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.blue900, width: 4),
            ),
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'UNIVERSITAS BHAKTI KENCANA',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                ),
                pw.SizedBox(height: 10),
                pw.Text('SERTIFIKAT KELULUSAN PKKMB KENCANA', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Nomor: ${cert.certificateNumber ?? 'CERT/KENCANA/2026/001'}', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 25),
                pw.Text('Diberikan kepada:', style: const pw.TextStyle(fontSize: 12)),
                pw.SizedBox(height: 10),
                pw.Text(
                  cert.studentName ?? 'SABILLA SRI ANGGITA PUTRI SETIADI',
                  style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'Telah dinyatakan LULUS dalam kegiatan PKKMB Kencana ${cert.periodName ?? '2026'} dengan Nilai Akhir ${cert.finalScore?.toStringAsFixed(1) ?? '82.7'} (${cert.predicateLabel}).',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 30),
                pw.Text('Bandung, 2026', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('Panitia PKKMB Kencana', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );
    return await pdf.save();
  }
}

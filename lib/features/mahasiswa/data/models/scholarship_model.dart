import '../../domain/entities/scholarship.dart';

class ScholarshipModel extends Scholarship {
  ScholarshipModel({
    required super.id,
    required super.title,
    required super.provider,
    required super.category,
    required super.deadline,
    required super.coverAmount,
    required super.description,
    super.status,
    super.applicationStatus,
    super.kuota,
    super.minIpk,
    super.minSemester,
    super.motivasi,
    super.ktmKtpUrl,
    super.sertifikatUrl,
    super.transkripUrl,
    super.persyaratan,
    super.fileKtm,
    super.fileTranskrip,
    super.fileSertifikat,
    super.customFieldsRaw,
    super.customAnswersRaw,
    super.rubrikSchemaRaw,
    super.rubrikAnswersRaw,
    super.skema,
    super.nomorPendaftaran,
    super.tanggalPengajuan,
    super.catatanVerifikator,
    super.logs,
    super.tingkat,
    super.fakultasNama,
    super.prodiNama,
  });

  factory ScholarshipModel.fromJson(Map<String, dynamic> json) {
    String deadlineStr = '';
    if (json['deadline'] != null || json['Deadline'] != null) {
      try {
        final dt = DateTime.parse((json['deadline'] ?? json['Deadline']).toString());
        deadlineStr =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        deadlineStr = (json['deadline'] ?? json['Deadline']).toString();
      }
    }

    String tanggalPengajuanStr = '';
    if (json['created_at'] != null || json['CreatedAt'] != null) {
      try {
        final dt = DateTime.parse((json['created_at'] ?? json['CreatedAt']).toString());
        tanggalPengajuanStr =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        tanggalPengajuanStr = (json['created_at'] ?? json['CreatedAt']).toString();
      }
    }

    final fakultas = json['Fakultas'] ?? json['fakultas'];
    String? fNama;
    if (fakultas is Map) {
      fNama = (fakultas['nama'] ?? fakultas['Nama'])?.toString();
    }

    final prodi = json['ProgramStudi'] ?? json['program_studi'];
    String? pNama;
    if (prodi is Map) {
      pNama = (prodi['nama'] ?? prodi['Nama'])?.toString();
    }

    return ScholarshipModel(
      id: json['id']?.toString() ?? json['ID']?.toString() ?? '',
      title: json['nama'] ?? json['Nama'] ?? '',
      provider: json['penyelenggara'] ?? json['Penyelenggara'] ?? '',
      category: json['kategori'] ?? json['Kategori'] ?? '',
      deadline: deadlineStr,
      coverAmount: (json['nilai_bantuan'] ?? json['NilaiBantuan'] ?? 0).toString(),
      description: json['deskripsi'] ?? json['Deskripsi'] ?? '',
      status: json['status'] ?? json['Status'] ?? 'Open',
      applicationStatus: json['application_status']?.toString() ?? json['Status']?.toString(),
      kuota: json['kuota']?.toString() ?? json['Kuota']?.toString(),
      minIpk: json['ipk_min']?.toString() ?? json['IPKMin']?.toString() ?? json['syarat_ipk_min']?.toString(),
      minSemester: json['semester_min']?.toString() ?? json['SemesterMin']?.toString() ?? json['syarat_semester_min']?.toString(),
      motivasi: json['motivasi'] ?? json['Motivasi'],
      ktmKtpUrl: json['ktm_ktp_url'] ?? json['KtmKtpURL'] ?? json['ktm_ktp'],
      sertifikatUrl: json['sertifikat_url'] ?? json['SertifikatURL'] ?? json['sertifikat'],
      transkripUrl: json['transkrip_url'] ?? json['TranskripURL'] ?? json['transkrip'],
      persyaratan: json['persyaratan'] ?? json['Persyaratan'],
      fileKtm: json['file_ktm']?.toString() ?? json['FileKtm']?.toString() ?? 'wajib',
      fileTranskrip: json['file_transkrip']?.toString() ?? json['FileTranskrip']?.toString() ?? 'wajib',
      fileSertifikat: json['file_sertifikat']?.toString() ?? json['FileSertifikat']?.toString() ?? 'opsional',
      customFieldsRaw: json['custom_fields'] ?? json['CustomFields'],
      customAnswersRaw: json['custom_answers'] ?? json['CustomAnswers'],
      rubrikSchemaRaw: json['rubrik_schema'] ?? json['RubrikSchema'],
      rubrikAnswersRaw: json['rubrik_answers'] ?? json['RubrikAnswers'],
      skema: json['skema']?.toString() ?? json['Skema']?.toString(),
      nomorPendaftaran: json['nomor_pendaftaran'] ?? json['NomorPendaftaran'] ?? json['no_pendaftaran'],
      tanggalPengajuan: tanggalPengajuanStr,
      catatanVerifikator: json['catatan_verifikator'] ?? json['CatatanVerifikator'] ?? json['alasan_penolakan'] ?? json['catatan'],
      logs: json['logs'] != null && json['logs'] is List ? List<dynamic>.from(json['logs']) : null,
      tingkat: json['tingkat']?.toString() ?? json['Tingkat']?.toString() ?? 'universitas',
      fakultasNama: fNama,
      prodiNama: pNama,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': title,
      'penyelenggara': provider,
      'kategori': category,
      'deskripsi': description,
      'skema': skema,
      'tingkat': tingkat,
    };
  }
}

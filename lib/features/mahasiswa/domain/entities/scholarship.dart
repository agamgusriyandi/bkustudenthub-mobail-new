class Scholarship {
  final String id;
  final String title;
  final String provider;
  final String category;
  final String deadline;
  final String coverAmount;
  final String description;
  final String status;
  final String? applicationStatus;
  final String? kuota;
  final String? minIpk;
  final String? minSemester;
  final String? motivasi;
  final String? ktmKtpUrl;
  final String? sertifikatUrl;
  final String? transkripUrl;
  final String? persyaratan;
  final String fileKtm;
  final String fileTranskrip;
  final String fileSertifikat;
  final dynamic customFieldsRaw;
  final dynamic customAnswersRaw;
  final dynamic rubrikSchemaRaw;
  final dynamic rubrikAnswersRaw;
  final String? skema;
  final String? nomorPendaftaran;
  final String? tanggalPengajuan;
  final String? catatanVerifikator;
  final List<dynamic>? logs;
  final String? tingkat;
  final String? fakultasNama;
  final String? prodiNama;

  Scholarship({
    required this.id,
    required this.title,
    required this.provider,
    required this.category,
    required this.deadline,
    required this.coverAmount,
    required this.description,
    this.status = 'Open',
    this.applicationStatus,
    this.kuota,
    this.minIpk,
    this.minSemester,
    this.motivasi,
    this.ktmKtpUrl,
    this.sertifikatUrl,
    this.transkripUrl,
    this.persyaratan,
    this.fileKtm = 'wajib',
    this.fileTranskrip = 'wajib',
    this.fileSertifikat = 'opsional',
    this.customFieldsRaw,
    this.customAnswersRaw,
    this.rubrikSchemaRaw,
    this.rubrikAnswersRaw,
    this.skema,
    this.nomorPendaftaran,
    this.tanggalPengajuan,
    this.catatanVerifikator,
    this.logs,
    this.tingkat,
    this.fakultasNama,
    this.prodiNama,
  });
}

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

  Scholarship copyWith({
    String? id,
    String? title,
    String? provider,
    String? category,
    String? deadline,
    String? coverAmount,
    String? description,
    String? status,
    String? applicationStatus,
    String? kuota,
    String? minIpk,
    String? minSemester,
    String? motivasi,
    String? ktmKtpUrl,
    String? sertifikatUrl,
    String? transkripUrl,
    String? persyaratan,
    String? fileKtm,
    String? fileTranskrip,
    String? fileSertifikat,
    dynamic customFieldsRaw,
    dynamic customAnswersRaw,
    dynamic rubrikSchemaRaw,
    dynamic rubrikAnswersRaw,
    String? skema,
    String? nomorPendaftaran,
    String? tanggalPengajuan,
    String? catatanVerifikator,
    List<dynamic>? logs,
    String? tingkat,
    String? fakultasNama,
    String? prodiNama,
  }) {
    return Scholarship(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      category: category ?? this.category,
      deadline: deadline ?? this.deadline,
      coverAmount: coverAmount ?? this.coverAmount,
      description: description ?? this.description,
      status: status ?? this.status,
      applicationStatus: applicationStatus ?? this.applicationStatus,
      kuota: kuota ?? this.kuota,
      minIpk: minIpk ?? this.minIpk,
      minSemester: minSemester ?? this.minSemester,
      motivasi: motivasi ?? this.motivasi,
      ktmKtpUrl: ktmKtpUrl ?? this.ktmKtpUrl,
      sertifikatUrl: sertifikatUrl ?? this.sertifikatUrl,
      transkripUrl: transkripUrl ?? this.transkripUrl,
      persyaratan: persyaratan ?? this.persyaratan,
      fileKtm: fileKtm ?? this.fileKtm,
      fileTranskrip: fileTranskrip ?? this.fileTranskrip,
      fileSertifikat: fileSertifikat ?? this.fileSertifikat,
      customFieldsRaw: customFieldsRaw ?? this.customFieldsRaw,
      customAnswersRaw: customAnswersRaw ?? this.customAnswersRaw,
      rubrikSchemaRaw: rubrikSchemaRaw ?? this.rubrikSchemaRaw,
      rubrikAnswersRaw: rubrikAnswersRaw ?? this.rubrikAnswersRaw,
      skema: skema ?? this.skema,
      nomorPendaftaran: nomorPendaftaran ?? this.nomorPendaftaran,
      tanggalPengajuan: tanggalPengajuan ?? this.tanggalPengajuan,
      catatanVerifikator: catatanVerifikator ?? this.catatanVerifikator,
      logs: logs ?? this.logs,
      tingkat: tingkat ?? this.tingkat,
      fakultasNama: fakultasNama ?? this.fakultasNama,
      prodiNama: prodiNama ?? this.prodiNama,
    );
  }
}

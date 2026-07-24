class TkInsuranceClaimModel {
  final int id;
  final int mahasiswaId;
  final String mahasiswaName;
  final String mahasiswaNim;
  final String mahasiswaProdi;
  final String jenisProvider;
  final DateTime tanggalKejadian;
  final String lokasiFaskes;
  final String deskripsi;
  final double estimasiBiaya;
  final String? fileUrl;
  final String? fileUrl2;
  final String status;
  final String? catatanReview;
  final String? suratPengantarUrl;
  final DateTime createdAt;
  final String? namaFile;
  final String? namaFile2;
  final int? reviewedBy;
  final DateTime? reviewedAt;

  final String? mahasiswaFoto;

  TkInsuranceClaimModel({
    required this.id,
    required this.mahasiswaId,
    required this.mahasiswaName,
    required this.mahasiswaNim,
    required this.mahasiswaProdi,
    this.mahasiswaFoto,
    required this.jenisProvider,
    required this.tanggalKejadian,
    required this.lokasiFaskes,
    required this.deskripsi,
    required this.estimasiBiaya,
    this.fileUrl,
    this.fileUrl2,
    required this.status,
    this.catatanReview,
    this.suratPengantarUrl,
    required this.createdAt,
    this.namaFile,
    this.namaFile2,
    this.reviewedBy,
    this.reviewedAt,
  });

  factory TkInsuranceClaimModel.fromJson(Map<String, dynamic> json) {
    return TkInsuranceClaimModel(
      id: json['id'] ?? 0,
      mahasiswaId: json['mahasiswa_id'] ?? 0,
      mahasiswaName: json['mahasiswa']?['nama'] ?? json['nama_mahasiswa'] ?? '-',
      mahasiswaNim: json['mahasiswa']?['nim'] ?? json['nim'] ?? '-',
      mahasiswaProdi: json['mahasiswa']?['program_studi']?['nama'] ?? json['mahasiswa']?['prodi'] ?? json['prodi'] ?? '-',
      mahasiswaFoto: json['mahasiswa']?['foto'] ?? json['mahasiswa']?['foto_url'] ?? json['mahasiswa']?['pengguna']?['foto'] ?? json['foto'],
      jenisProvider: json['jenis_provider'] ?? '',
      tanggalKejadian:
          json['tanggal_kejadian'] != null
              ? DateTime.parse(json['tanggal_kejadian'])
              : DateTime.now(),
      lokasiFaskes: json['lokasi_faskes'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      estimasiBiaya: (json['estimasi_biaya'] ?? 0).toDouble(),
      fileUrl: json['file_url'],
      fileUrl2: json['file_url_2'],
      status: json['status'] ?? 'PENDING_VERIFICATION',
      catatanReview: json['catatan_review'],
      suratPengantarUrl: json['surat_pengantar_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      namaFile: json['nama_file'],
      namaFile2: json['nama_file_2'],
      reviewedBy: json['reviewed_by'],
      reviewedAt:
          json['reviewed_at'] != null
              ? DateTime.tryParse(json['reviewed_at'].toString())
              : null,
    );
  }
}

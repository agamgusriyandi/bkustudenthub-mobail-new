class InsuranceClaim {
  final int id;
  final int mahasiswaId;
  final String jenisProvider;
  final DateTime tanggalKejadian;
  final String lokasiFaskes;
  final String deskripsi;
  final double estimasiBiaya;
  final String? fileUrl;
  final String? fileUrl2;
  final String? namaFile;
  final String? namaFile2;
  final String status;
  final String? catatanReview;
  final String? suratPengantarUrl;
  final DateTime? createdAt;

  InsuranceClaim({
    required this.id,
    required this.mahasiswaId,
    required this.jenisProvider,
    required this.tanggalKejadian,
    required this.lokasiFaskes,
    required this.deskripsi,
    required this.estimasiBiaya,
    this.fileUrl,
    this.fileUrl2,
    this.namaFile,
    this.namaFile2,
    required this.status,
    this.catatanReview,
    this.suratPengantarUrl,
    this.createdAt,
  });
}

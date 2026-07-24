import '../../domain/entities/insurance_claim.dart';

class InsuranceClaimModel extends InsuranceClaim {
  InsuranceClaimModel({
    required super.id,
    required super.mahasiswaId,
    required super.jenisProvider,
    required super.tanggalKejadian,
    required super.lokasiFaskes,
    required super.deskripsi,
    required super.estimasiBiaya,
    super.fileUrl,
    super.fileUrl2,
    super.namaFile,
    super.namaFile2,
    required super.status,
    super.catatanReview,
    super.suratPengantarUrl,
    super.createdAt,
  });

  factory InsuranceClaimModel.fromJson(Map<String, dynamic> json) {
    return InsuranceClaimModel(
      id: json['id'] ?? json['ID'] ?? 0,
      mahasiswaId: json['mahasiswa_id'] ?? 0,
      jenisProvider: json['jenis_provider'] ?? '',
      tanggalKejadian:
          json['tanggal_kejadian'] != null
              ? DateTime.tryParse(json['tanggal_kejadian'].toString()) ??
                  DateTime.now()
              : DateTime.now(),
      lokasiFaskes: json['lokasi_faskes'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      estimasiBiaya: (json['estimasi_biaya'] ?? 0).toDouble(),
      fileUrl: json['file_url'],
      fileUrl2: json['file_url_2'],
      namaFile: json['nama_file'],
      namaFile2: json['nama_file_2'],
      status: json['status'] ?? '',
      catatanReview: json['catatan_review'],
      suratPengantarUrl: json['surat_pengantar_url'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis_provider': jenisProvider,
      'tanggal_kejadian': tanggalKejadian.toIso8601String().split('T').first,
      'lokasi_faskes': lokasiFaskes,
      'deskripsi': deskripsi,
      'estimasi_biaya': estimasiBiaya,
    };
  }
}

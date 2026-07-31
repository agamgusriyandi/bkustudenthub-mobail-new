class KencanaCertificate {
  final int id;
  final String? fileUrl;
  final String? certificateNumber;
  final String? predicate;
  final String? issuedAt;
  final String? studentName;
  final String? periodName;
  final double? finalScore;

  KencanaCertificate({
    required this.id,
    this.fileUrl,
    this.certificateNumber,
    this.predicate,
    this.issuedAt,
    this.studentName,
    this.periodName,
    this.finalScore,
  });

  factory KencanaCertificate.fromJson(Map<String, dynamic> json) {
    return KencanaCertificate(
      id: json['id'] ?? 0,
      fileUrl: json['file_url'] ?? json['fileURL'],
      certificateNumber: json['certificate_number'],
      predicate: json['predicate'],
      issuedAt: json['issued_at'] ?? json['tanggalTerbit'],
      studentName: json['student_name'],
      periodName: json['period_name'],
      finalScore: json['final_score'] != null
          ? double.tryParse(json['final_score'].toString())
          : null,
    );
  }

  bool get hasFile => fileUrl != null && fileUrl!.isNotEmpty;
  bool get hasCertificate => id > 0;

  String get predicateLabel {
    switch (predicate?.toLowerCase()) {
      case 'cum laude':
        return 'CUM LADE';
      case 'sangat memuaskan':
        return 'SANGAT MEMUASKAN';
      case 'memuaskan':
        return 'MEMUASKAN';
      case 'baik':
        return 'BAIK';
      default:
        return predicate?.toUpperCase() ?? '-';
    }
  }
}

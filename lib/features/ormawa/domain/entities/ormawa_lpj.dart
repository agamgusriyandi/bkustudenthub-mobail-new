class OrmawaLPJ {
  final String id;
  final String proposalId;
  final String judul;
  final String status;
  final String catatan;
  final double realisasiAnggaran;
  final double totalAnggaran;
  final String? fileUrl;
  final String? proposalTitle;
  final DateTime? tenggatLpj;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrmawaLPJ({
    required this.id,
    required this.proposalId,
    required this.judul,
    required this.status,
    required this.catatan,
    required this.realisasiAnggaran,
    required this.totalAnggaran,
    this.fileUrl,
    this.proposalTitle,
    this.tenggatLpj,
    this.createdAt,
    this.updatedAt,
  });

  String get title => judul;
  String get note => catatan;
  double get totalBudget => totalAnggaran;
  double get realizationBudget => realisasiAnggaran;
  double get amount => totalAnggaran;
  double get realization => realisasiAnggaran;
  String? get description => catatan;

  factory OrmawaLPJ.fromJson(Map<String, dynamic> json) {
    DateTime? parsedTenggat;
    if (json['Proposal'] != null) {
      final p = json['Proposal'];
      final rawTenggat = p['TenggatLPJ'] ?? p['tenggat_lpj'];
      if (rawTenggat != null) {
        parsedTenggat = DateTime.tryParse(rawTenggat.toString());
      }
    }

    return OrmawaLPJ(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      proposalId: (json['ProposalID'] ?? json['proposalId'] ?? '').toString(),
      judul: json['Judul'] ?? json['judul'] ?? '',
      status: json['Status'] ?? json['status'] ?? '',
      catatan: json['Catatan'] ?? json['catatan'] ?? '',
      realisasiAnggaran:
          ((json['RealisasiAnggaran'] ?? json['realisasiAnggaran'] ?? 0.0)
                  as num)
              .toDouble(),
      totalAnggaran:
          ((json['TotalAnggaran'] ?? json['totalAnggaran'] ?? 0.0) as num)
              .toDouble(),
      fileUrl: json['FileURL'] ?? json['fileUrl'] as String?,
      proposalTitle:
          json['Proposal'] != null
              ? (json['Proposal']['Judul'] ?? json['Proposal']['judul'] ?? '')
                  .toString()
              : null,
      tenggatLpj: parsedTenggat,
      createdAt: DateTime.tryParse(
        json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
      ),
      updatedAt: DateTime.tryParse(
        json['UpdatedAt'] ?? json['updatedAt'] ?? json['updated_at'] ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'ProposalID': int.tryParse(proposalId),
      'Judul': judul,
      'Status': status,
      'Catatan': catatan,
      'RealisasiAnggaran': realisasiAnggaran,
      'TotalAnggaran': totalAnggaran,
      'FileURL': fileUrl,
    };
  }
}

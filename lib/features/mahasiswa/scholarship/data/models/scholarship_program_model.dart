class ScholarshipProgramModel {
  final int id;
  final String nama;
  final String deskripsi;
  final String penyelenggara;
  final String kategori;
  final String deadline;
  final String nilaiBantuan;
  final String? kuota;
  final String? ipkMin;
  final String? persyaratan;
  final String status;
  final bool isApplied;

  const ScholarshipProgramModel({
    required this.id,
    required this.nama,
    required this.deskripsi,
    required this.penyelenggara,
    required this.kategori,
    required this.deadline,
    required this.nilaiBantuan,
    this.kuota,
    this.ipkMin,
    this.persyaratan,
    this.status = 'Open',
    this.isApplied = false,
  });

  factory ScholarshipProgramModel.fromJson(Map<String, dynamic> json) {
    return ScholarshipProgramModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      penyelenggara: json['penyelenggara'] ?? '',
      kategori: json['kategori'] ?? '',
      deadline: json['deadline'] ?? '',
      nilaiBantuan: (json['nilai_bantuan'] ?? '').toString(),
      kuota: json['kuota']?.toString(),
      ipkMin: json['ipk_min']?.toString(),
      persyaratan: json['persyaratan'],
      status: json['status'] ?? 'Open',
      isApplied: json['is_applied'] ?? false,
    );
  }

  String get formattedDeadline {
    try {
      final dt = DateTime.parse(deadline);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return deadline;
    }
  }
}

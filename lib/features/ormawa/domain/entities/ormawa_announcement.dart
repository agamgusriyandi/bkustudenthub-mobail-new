class OrmawaAnnouncement {
  final String id;
  final String judul;
  final String isi;
  final String target;
  final DateTime? createdAt;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;

  OrmawaAnnouncement({
    required this.id,
    required this.judul,
    required this.isi,
    required this.target,
    this.createdAt,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  factory OrmawaAnnouncement.fromJson(Map<String, dynamic> json) {
    return OrmawaAnnouncement(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      judul: json['Judul'] ?? json['judul'] ?? '',
      isi: json['Isi'] ?? json['isi'] ?? '',
      target: json['Target'] ?? json['target'] ?? 'Umum',
      createdAt: DateTime.tryParse(
        json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
      ),
      tanggalMulai: DateTime.tryParse(
        json['TanggalMulai'] ??
            json['tanggalMulai'] ??
            json['tanggal_mulai'] ??
            '',
      ),
      tanggalSelesai: DateTime.tryParse(
        json['TanggalSelesai'] ??
            json['tanggalSelesai'] ??
            json['tanggal_selesai'] ??
            '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'Judul': judul,
      'Isi': isi,
      'Target': target,
      'TanggalMulai': tanggalMulai?.toIso8601String(),
      'TanggalSelesai': tanggalSelesai?.toIso8601String(),
    };
  }
}

class OrmawaAnnouncement {
  final String id;
  final String judul;
  final String isi;
  final String target;
  final String targetAudiens;
  final String kategori;
  final String? lampiranUrl;
  final DateTime? createdAt;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;

  OrmawaAnnouncement({
    required this.id,
    required this.judul,
    required this.isi,
    required this.target,
    required this.targetAudiens,
    required this.kategori,
    this.lampiranUrl,
    this.createdAt,
    this.tanggalMulai,
    this.tanggalSelesai,
  });

  factory OrmawaAnnouncement.fromJson(Map<String, dynamic> json) {
    final cat = json['Kategori'] ?? json['kategori'] ?? json['Target'] ?? json['target'] ?? 'umum';
    final audiens = json['TargetAudiens'] ?? json['target_audiens'] ?? json['Target'] ?? json['target'] ?? 'Semua Mahasiswa';
    return OrmawaAnnouncement(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      judul: json['Judul'] ?? json['judul'] ?? '',
      isi: json['Isi'] ?? json['isi'] ?? json['Konten'] ?? json['konten'] ?? '',
      target: audiens.toString(),
      targetAudiens: audiens.toString(),
      kategori: cat.toString().toLowerCase(),
      lampiranUrl: json['LampiranUrl'] ?? json['lampiran_url'] ?? json['lampiranUrl'] ?? json['Link'] ?? json['link'],
      createdAt: DateTime.tryParse(
        json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
      ),
      tanggalMulai: DateTime.tryParse(
        json['TanggalMulai'] ??
            json['tanggalMulai'] ??
            json['tanggal_mulai'] ??
            json['Tanggal'] ??
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
      'Target': kategori,
      'Kategori': kategori,
      'TargetAudiens': targetAudiens,
      'LampiranUrl': lampiranUrl,
      'TanggalMulai': tanggalMulai?.toUtc().toIso8601String(),
      'TanggalSelesai': tanggalSelesai?.toUtc().toIso8601String(),
    };
  }
}
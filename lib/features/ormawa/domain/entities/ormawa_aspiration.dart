class OrmawaAspiration {
  final String id;
  final String judul;
  final String isi;
  final String status;
  final String? tanggapan;
  final String? lampiranUrl;
  final String mahasiswaName;
  final String mahasiswaNim;
  final String? mahasiswaFoto;
  final String ormawaNama;
  final String kategori;
  final DateTime? createdAt;

  OrmawaAspiration({
    required this.id,
    required this.judul,
    required this.isi,
    required this.status,
    this.tanggapan,
    this.lampiranUrl,
    required this.mahasiswaName,
    this.mahasiswaNim = '',
    this.mahasiswaFoto,
    this.ormawaNama = 'Organisasi Mahasiswa',
    this.kategori = 'Umum',
    this.createdAt,
  });

  factory OrmawaAspiration.fromJson(Map<String, dynamic> json) {
    final mName =
        json['MahasiswaName'] ??
        json['mahasiswaName'] ??
        json['Mahasiswa']?['Nama'] ??
        json['mahasiswa']?['nama'] ??
        'Mahasiswa';
    final mNim = json['Mahasiswa']?['NIM'] ?? json['mahasiswa']?['nim'] ?? '';
    final mFoto =
        json['Mahasiswa']?['Foto'] ??
        json['mahasiswa']?['foto'] ??
        json['Mahasiswa']?['FotoURL'] ??
        json['mahasiswa']?['foto_url'];
    final oName =
        json['OrmawaNama'] ??
        json['ormawaNama'] ??
        json['Ormawa']?['Nama'] ??
        json['ormawa']?['nama'] ??
        'Organisasi Mahasiswa';
    final rawStatus = (json['Status'] ?? json['status'] ?? 'pending').toString().toLowerCase();

    return OrmawaAspiration(
      id: (json['ID'] ?? json['id'] ?? '').toString(),
      judul: json['Judul'] ?? json['judul'] ?? '',
      isi: json['Isi'] ?? json['isi'] ?? json['Konten'] ?? json['konten'] ?? '',
      status: rawStatus,
      tanggapan: (json['Tanggapan'] ?? json['tanggapan']) as String?,
      lampiranUrl: json['lampiran_url'] ?? json['LampiranURL'] ?? json['lampiranUrl'] ?? json['LampiranUrl'],
      mahasiswaName: mName,
      mahasiswaNim: mNim,
      mahasiswaFoto: mFoto,
      ormawaNama: oName,
      kategori: json['Kategori'] ?? json['kategori'] ?? 'Umum',
      createdAt: DateTime.tryParse(
        json['CreatedAt'] ?? json['createdAt'] ?? json['created_at'] ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': int.tryParse(id),
      'Judul': judul,
      'Isi': isi,
      'Status': status,
      'Tanggapan': tanggapan,
      'lampiran_url': lampiranUrl,
      'Kategori': kategori,
    };
  }
}
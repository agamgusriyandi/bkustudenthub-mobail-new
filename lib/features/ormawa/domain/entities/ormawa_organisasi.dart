class OrmawaOrganisasi {
  final int id;
  final String nama;
  final String deskripsi;
  final String? logoUrl;
  final String? visi;
  final String? misi;
  final String? alamat;
  final String? email;
  final String? website;
  final String? instagram;
  final String? tahunBerdiri;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrmawaOrganisasi({
    required this.id,
    required this.nama,
    required this.deskripsi,
    this.logoUrl,
    this.visi,
    this.misi,
    this.alamat,
    this.email,
    this.website,
    this.instagram,
    this.tahunBerdiri,
    this.status = 'aktif',
    this.createdAt,
    this.updatedAt,
  });

  factory OrmawaOrganisasi.fromJson(Map<String, dynamic> json) {
    return OrmawaOrganisasi(
      id: json['ID'] ?? json['id'] ?? 0,
      nama: json['Nama'] ?? json['nama'] ?? '',
      deskripsi: json['Deskripsi'] ?? json['deskripsi'] ?? '',
      logoUrl: json['LogoURL'] ?? json['logo_url'] ?? json['logo'],
      visi: json['Visi'] ?? json['visi'],
      misi: json['Misi'] ?? json['misi'],
      alamat: json['Alamat'] ?? json['alamat'],
      email: json['Email'] ?? json['email'],
      website: json['Website'] ?? json['website'],
      instagram: json['Instagram'] ?? json['instagram'],
      tahunBerdiri: json['TahunBerdiri'] ?? json['tahun_berdiri'],
      status: json['Status'] ?? json['status'] ?? 'aktif',
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : json['created_at'] != null
              ? DateTime.tryParse(json['created_at'])
              : null,
      updatedAt: json['UpdatedAt'] != null
          ? DateTime.tryParse(json['UpdatedAt'])
          : json['updated_at'] != null
              ? DateTime.tryParse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'Nama': nama,
        'Deskripsi': deskripsi,
        'Visi': visi,
        'Misi': misi,
        'Alamat': alamat,
        'Email': email,
        'Website': website,
        'Instagram': instagram,
        'TahunBerdiri': tahunBerdiri,
        'Status': status,
      };
}
import '../../domain/entities/ormawa_proposal.dart';

class OrmawaProposalModel extends OrmawaProposal {
  OrmawaProposalModel({
    required super.id,
    super.ormawaId,
    super.mahasiswaId,
    super.fakultasId,
    required super.title,
    required super.code,
    required super.status,
    required super.date,
    super.tanggalSelesai,
    super.budget,
    super.description,
    super.landasanKegiatan,
    super.bentukKegiatan,
    super.mitra,
    super.pjKegiatan,
    super.jadwalPelaksanaan,
    super.sasaranKegiatan,
    super.indikatorKeberhasilan,
    super.sumberDana,
    super.latarBelakang,
    super.tujuanKegiatan,
    super.fileUrl,
    super.catatan,
  });

  factory OrmawaProposalModel.fromJson(Map<String, dynamic> json) {
    return OrmawaProposalModel(
      id: (json['id'] ?? json['ID'] ?? '').toString(),
      ormawaId: (json['ormawa_id'] ?? json['OrmawaID'])?.toString(),
      mahasiswaId: (json['mahasiswa_id'] ?? json['MahasiswaID'])?.toString(),
      fakultasId: (json['fakultas_id'] ?? json['FakultasID'])?.toString(),
      title: json['judul'] ?? json['Judul'] ?? json['nama'] ?? json['Nama'] ?? json['title'] ?? '',
      code: json['code'] ?? 'PROP-${json['id'] ?? json['ID'] ?? ''}',
      status: (json['status'] ?? json['Status'] ?? 'diajukan').toString().toLowerCase(),
      date: json['tanggal_kegiatan'] != null
          ? (DateTime.tryParse(json['tanggal_kegiatan'].toString()) ?? DateTime.now())
          : (json['TanggalKegiatan'] != null
              ? (DateTime.tryParse(json['TanggalKegiatan'].toString()) ?? DateTime.now())
              : (json['tanggal_mulai'] != null
                  ? (DateTime.tryParse(json['tanggal_mulai'].toString()) ?? DateTime.now())
                  : (json['TanggalMulai'] != null
                      ? (DateTime.tryParse(json['TanggalMulai'].toString()) ?? DateTime.now())
                      : (json['created_at'] != null
                          ? (DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now())
                          : (json['CreatedAt'] != null
                              ? (DateTime.tryParse(json['CreatedAt'].toString()) ?? DateTime.now())
                              : (json['date'] != null
                                  ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
                                  : DateTime.now())))))),
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'].toString())
          : (json['TanggalSelesai'] != null
              ? DateTime.tryParse(json['TanggalSelesai'].toString())
              : null),
      budget: (json['anggaran'] as num?)?.toDouble() ??
          (json['Anggaran'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0,
      description: json['deskripsi'] ?? json['Deskripsi'] ?? json['description'] ?? '',
      landasanKegiatan: json['landasan_kegiatan'] ?? json['LandasanKegiatan'],
      bentukKegiatan: json['bentuk_kegiatan'] ?? json['BentukKegiatan'],
      mitra: json['mitra'] ?? json['Mitra'],
      pjKegiatan: json['pj_kegiatan'] ?? json['PJKegiatan'],
      jadwalPelaksanaan: json['jadwal_pelaksanaan'] ?? json['JadwalPelaksanaan'],
      sasaranKegiatan: json['sasaran_kegiatan'] ?? json['SasaranKegiatan'],
      indikatorKeberhasilan: json['indikator_keberhasilan'] ?? json['IndikatorKeberhasilan'],
      sumberDana: json['sumber_dana'] ?? json['SumberDana'],
      latarBelakang: json['latar_belakang'] ?? json['LatarBelakang'],
      tujuanKegiatan: json['tujuan_kegiatan'] ?? json['TujuanKegiatan'],
      fileUrl: json['file_url'] ?? json['FileURL'],
      catatan: json['catatan'] ?? json['Catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    
    final cleanDate = '${date.toIso8601String().split('.').first}Z';

    final Map<String, dynamic> data = {
      'Judul': title,
      'Anggaran': budget,
      'Status': status.toLowerCase(),
      'TanggalKegiatan': cleanDate,
      'Deskripsi': description ?? '',
      'LandasanKegiatan': landasanKegiatan ?? '',
      'BentukKegiatan': bentukKegiatan ?? '',
      'Mitra': mitra ?? '',
      'PJKegiatan': pjKegiatan ?? '',
      'JadwalPelaksanaan': jadwalPelaksanaan ?? '',
      'SasaranKegiatan': sasaranKegiatan ?? '',
      'IndikatorKeberhasilan': indikatorKeberhasilan ?? '',
      'SumberDana': sumberDana ?? '',
      'LatarBelakang': latarBelakang ?? '',
      'TujuanKegiatan': tujuanKegiatan ?? '',
      'file_url': fileUrl ?? '',
      'FileURL': fileUrl ?? '',
      'Catatan': catatan ?? '',
    };

    if (ormawaId != null && ormawaId!.isNotEmpty) {
      data['OrmawaID'] = int.tryParse(ormawaId!);
    }
    if (mahasiswaId != null && mahasiswaId!.isNotEmpty) {
      data['MahasiswaID'] = int.tryParse(mahasiswaId!);
    }
    if (fakultasId != null && fakultasId!.isNotEmpty) {
      data['FakultasID'] = int.tryParse(fakultasId!);
    }

    return data;
  }
}
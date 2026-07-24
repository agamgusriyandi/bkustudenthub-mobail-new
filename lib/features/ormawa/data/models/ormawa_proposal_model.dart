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
      id: json['ID']?.toString() ?? json['id']?.toString() ?? '',
      ormawaId: json['OrmawaID']?.toString() ?? json['ormawa_id']?.toString(),
      mahasiswaId:
          json['MahasiswaID']?.toString() ?? json['mahasiswa_id']?.toString(),
      fakultasId:
          json['FakultasID']?.toString() ?? json['fakultas_id']?.toString(),
      title: json['Judul'] ?? json['title'] ?? '',
      code:
          json['code'] ??
          'PROP-${json['ID']?.toString() ?? json['id']?.toString() ?? ''}',
      status:
          (json['Status'] ?? json['status'] ?? 'diajukan')
              .toString()
              .toLowerCase(),
      date:
          json['TanggalKegiatan'] != null
              ? DateTime.parse(json['TanggalKegiatan'])
              : (json['date'] != null
                  ? DateTime.parse(json['date'])
                  : DateTime.now()),
      budget:
          (json['Anggaran'] as num?)?.toDouble() ??
          (json['budget'] as num?)?.toDouble() ??
          0,
      description: json['Deskripsi'] ?? json['deskripsi'] ?? '',
      landasanKegiatan: json['LandasanKegiatan'] ?? json['landasan_kegiatan'],
      bentukKegiatan: json['BentukKegiatan'] ?? json['bentuk_kegiatan'],
      mitra: json['Mitra'] ?? json['mitra'],
      pjKegiatan: json['PJKegiatan'] ?? json['pj_kegiatan'],
      jadwalPelaksanaan:
          json['JadwalPelaksanaan'] ?? json['jadwal_pelaksanaan'],
      sasaranKegiatan: json['SasaranKegiatan'] ?? json['sasaran_kegiatan'],
      indikatorKeberhasilan:
          json['IndikatorKeberhasilan'] ?? json['indikator_keberhasilan'],
      sumberDana: json['SumberDana'] ?? json['sumber_dana'],
      latarBelakang: json['LatarBelakang'] ?? json['latar_belakang'],
      tujuanKegiatan: json['TujuanKegiatan'] ?? json['tujuan_kegiatan'],
      fileUrl: json['file_url'] ?? json['FileURL'],
      catatan: json['Catatan'] ?? json['catatan'],
    );
  }

  Map<String, dynamic> toJson() {
    // Clean date format for Go's time.Time
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

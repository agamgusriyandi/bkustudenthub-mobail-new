import '../../domain/entities/ormawa_agenda.dart';

class OrmawaAgendaModel extends OrmawaAgenda {
  OrmawaAgendaModel({
    required super.id,
    required super.title,
    required super.date,
    required super.endDate,
    required super.status,
    required super.description,
    required super.location,
    super.landasanKegiatan,
    super.bentukKegiatan,
    super.mitra,
    super.latarBelakang,
    super.tujuanKegiatan,
    super.jadwalPelaksanaan,
    super.sasaranKegiatan,
    super.indikatorKeberhasilan,
    super.sumberDana,
    super.estimasiDana,
    super.pjKegiatan,
  });

  factory OrmawaAgendaModel.fromJson(Map<String, dynamic> json) {
    return OrmawaAgendaModel(
      id: (json['id'] ?? json['ID'] ?? '').toString(),
      title: json['judul'] ??
          json['Judul'] ??
          json['nama'] ??
          json['Nama'] ??
          json['nama_kegiatan'] ??
          json['NamaKegiatan'] ??
          json['title'] ??
          '',
      date: json['tanggal_mulai'] != null
          ? (DateTime.tryParse(json['tanggal_mulai'].toString()) ?? DateTime.now())
          : (json['TanggalMulai'] != null
              ? (DateTime.tryParse(json['TanggalMulai'].toString()) ?? DateTime.now())
              : (json['tanggal_kegiatan'] != null
                  ? (DateTime.tryParse(json['tanggal_kegiatan'].toString()) ?? DateTime.now())
                  : (json['TanggalKegiatan'] != null
                      ? (DateTime.tryParse(json['TanggalKegiatan'].toString()) ?? DateTime.now())
                      : (json['date'] != null
                          ? (DateTime.tryParse(json['date'].toString()) ?? DateTime.now())
                          : DateTime.now())))),
      endDate: json['tanggal_selesai'] != null
          ? (DateTime.tryParse(json['tanggal_selesai'].toString()) ?? DateTime.now())
          : (json['TanggalSelesai'] != null
              ? (DateTime.tryParse(json['TanggalSelesai'].toString()) ?? DateTime.now())
              : (json['tanggal_mulai'] != null
                  ? (DateTime.tryParse(json['tanggal_mulai'].toString()) ?? DateTime.now()).add(const Duration(hours: 2))
                  : DateTime.now().add(const Duration(hours: 2)))),
      status: (json['status'] ?? json['Status'] ?? 'Persiapan').toString(),
      description: (json['deskripsi'] ?? json['Deskripsi'] ?? json['description'] ?? '').toString(),
      location: (json['lokasi'] ?? json['Lokasi'] ?? json['location'] ?? '').toString(),
      landasanKegiatan: json['landasan_kegiatan'] ?? json['LandasanKegiatan'] ?? '',
      bentukKegiatan: json['bentuk_kegiatan'] ?? json['BentukKegiatan'] ?? '',
      mitra: json['mitra'] ?? json['Mitra'] ?? '',
      latarBelakang: json['latar_belakang'] ?? json['LatarBelakang'] ?? '',
      tujuanKegiatan: json['tujuan_kegiatan'] ?? json['TujuanKegiatan'] ?? '',
      jadwalPelaksanaan: json['jadwal_pelaksanaan'] ?? json['JadwalPelaksanaan'] ?? '',
      sasaranKegiatan: json['sasaran_kegiatan'] ?? json['SasaranKegiatan'] ?? '',
      indikatorKeberhasilan: json['indikator_keberhasilan'] ?? json['IndikatorKeberhasilan'] ?? '',
      sumberDana: json['sumber_dana'] ?? json['SumberDana'] ?? '',
      estimasiDana: (json['estimasi_dana'] ?? json['EstimasiDana']) != null
          ? ((json['estimasi_dana'] ?? json['EstimasiDana']) as num).toDouble()
          : 0.0,
      pjKegiatan: json['pj_kegiatan'] ?? json['PJKegiatan'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Judul': title,
      'Deskripsi': description,
      'TanggalMulai': date.toIso8601String(),
      'TanggalSelesai': endDate.toIso8601String(),
      'Lokasi': location,
      'Status': status,
      'LandasanKegiatan': landasanKegiatan ?? '',
      'BentukKegiatan': bentukKegiatan ?? '',
      'Mitra': mitra ?? '',
      'LatarBelakang': latarBelakang ?? '',
      'TujuanKegiatan': tujuanKegiatan ?? '',
      'JadwalPelaksanaan': jadwalPelaksanaan ?? '',
      'SasaranKegiatan': sasaranKegiatan ?? '',
      'IndikatorKeberhasilan': indikatorKeberhasilan ?? '',
      'SumberDana': sumberDana ?? '',
      'EstimasiDana': estimasiDana ?? 0.0,
      'PJKegiatan': pjKegiatan ?? '',
    };
  }
}
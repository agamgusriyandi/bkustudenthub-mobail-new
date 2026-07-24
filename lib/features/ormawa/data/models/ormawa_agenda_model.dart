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
      id: json['ID']?.toString() ?? json['id']?.toString() ?? '',
      title: json['Judul'] ?? json['title'] ?? '',
      date:
          json['TanggalMulai'] != null
              ? DateTime.parse(json['TanggalMulai'])
              : (json['date'] != null
                  ? DateTime.parse(json['date'])
                  : DateTime.now()),
      endDate:
          json['TanggalSelesai'] != null
              ? DateTime.parse(json['TanggalSelesai'])
              : (json['TanggalMulai'] != null
                  ? DateTime.parse(
                    json['TanggalMulai'],
                  ).add(const Duration(hours: 2))
                  : DateTime.now().add(const Duration(hours: 2))),
      status: json['Status'] ?? json['status'] ?? 'Persiapan',
      description: json['Deskripsi'] ?? json['description'] ?? '',
      location: json['Lokasi'] ?? json['location'] ?? '',

      landasanKegiatan:
          json['landasan_kegiatan'] ?? json['LandasanKegiatan'] ?? '',
      bentukKegiatan: json['bentuk_kegiatan'] ?? json['BentukKegiatan'] ?? '',
      mitra: json['mitra'] ?? json['Mitra'] ?? '',
      latarBelakang: json['latar_belakang'] ?? json['LatarBelakang'] ?? '',
      tujuanKegiatan: json['tujuan_kegiatan'] ?? json['TujuanKegiatan'] ?? '',
      jadwalPelaksanaan:
          json['jadwal_pelaksanaan'] ?? json['JadwalPelaksanaan'] ?? '',
      sasaranKegiatan:
          json['sasaran_kegiatan'] ?? json['SasaranKegiatan'] ?? '',
      indikatorKeberhasilan:
          json['indikator_keberhasilan'] ?? json['IndikatorKeberhasilan'] ?? '',
      sumberDana: json['sumber_dana'] ?? json['SumberDana'] ?? '',
      estimasiDana:
          (json['estimasi_dana'] ?? json['EstimasiDana']) != null
              ? (json['estimasi_dana'] ?? json['EstimasiDana'] as num)
                  .toDouble()
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

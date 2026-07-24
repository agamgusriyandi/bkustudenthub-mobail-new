import '../../domain/entities/achievement.dart';

class AchievementModel extends Achievement {
  AchievementModel({
    required super.id,
    required super.title,
    required super.organizer,
    required super.level,
    required super.rank,
    required super.date,
    super.status,
    super.isSynced,
    super.certificateUrl,
    super.filePath,
    super.kategori,
    super.tipe,
    super.danaDiajukan,
    super.cabang,
    super.jumlahUnitPeserta,
    super.kelompokPrestasi,
    super.bentuk,
    super.urlPeserta,
    super.urlFotoUpp,
    super.urlDokumenUndangan,
    super.jenisRekognisi,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    return AchievementModel(
      id: json['id']?.toString() ?? '',
      title: json['nama_kegiatan'] ?? '',
      organizer: json['penyelenggara'] ?? '',
      level: json['tingkat'] ?? '',
      rank: json['peringkat'] ?? '',
      date:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
              : DateTime.now(),
      status: json['status'] ?? 'Pending',
      isSynced: true,
      certificateUrl: json['bukti_url'],
      kategori: json['kategori'],
      tipe: json['tipe'],
      danaDiajukan: json['dana_diajukan']?.toString(),
      cabang: json['cabang'],
      jumlahUnitPeserta: json['jumlah_unit_peserta']?.toString(),
      kelompokPrestasi: json['kelompok_prestasi'],
      bentuk: json['bentuk'],
      urlPeserta: json['url_peserta'],
      urlFotoUpp: json['url_foto_upp'],
      urlDokumenUndangan: json['url_dokumen_undangan'],
      jenisRekognisi: json['jenis_rekognisi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_kegiatan': title,
      if (kategori != null) 'kategori': kategori,
      'tingkat': level,
      'peringkat': rank,
      'penyelenggara': organizer,
      'tanggal': date.toIso8601String().split('T')[0],
      if (tipe != null) 'tipe': tipe,
      if (danaDiajukan != null) 'dana_diajukan': danaDiajukan,
      if (cabang != null) 'cabang': cabang,
      if (jumlahUnitPeserta != null) 'jumlah_unit_peserta': jumlahUnitPeserta,
      if (kelompokPrestasi != null) 'kelompok_prestasi': kelompokPrestasi,
      if (bentuk != null) 'bentuk': bentuk,
      if (urlPeserta != null) 'url_peserta': urlPeserta,
      if (urlFotoUpp != null) 'url_foto_upp': urlFotoUpp,
      if (urlDokumenUndangan != null)
        'url_dokumen_undangan': urlDokumenUndangan,
      if (jenisRekognisi != null) 'jenis_rekognisi': jenisRekognisi,
    };
  }
}

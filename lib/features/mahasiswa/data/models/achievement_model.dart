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
    super.suratTugasPath,
    super.kategori,
    super.tipe,
    super.danaDiajukan,
    super.danaDisetujui,
    super.catatanVerifikator,
    super.cabang,
    super.jumlahUnitPeserta,
    super.kelompokPrestasi,
    super.bentuk,
    super.urlPeserta,
    super.urlFotoUpp,
    super.urlDokumenUndangan,
    super.jenisRekognisi,
    super.simkatmawaStatus,
    super.keterangan,
    super.pembimbingDosen,
    super.anggotaMahasiswa,
  });

  factory AchievementModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'] ?? json['Status'] ?? 'Menunggu';
    final isSynced = (json['simkatmawa_status'] == 'Sukses' || json['simkatmawa_status'] == 'Sinkron' || status == 'Diverifikasi' || status == 'Valid');

    return AchievementModel(
      id: json['id']?.toString() ?? json['ID']?.toString() ?? '',
      title: json['nama_kegiatan'] ?? json['NamaKegiatan'] ?? '',
      organizer: json['penyelenggara'] ?? json['Penyelenggara'] ?? '',
      level: json['tingkat'] ?? json['Tingkat'] ?? '',
      rank: json['peringkat'] ?? json['Peringkat'] ?? '',
      date: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'].toString()) ?? (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now())
          : (json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now() : DateTime.now()),
      status: status,
      isSynced: isSynced,
      certificateUrl: json['bukti_url'] ?? json['BuktiURL'] ?? json['url_sertifikat'],
      kategori: json['kategori'] ?? json['Kategori'],
      tipe: json['tipe'] ?? json['Tipe'] ?? 'Laporan Prestasi',
      danaDiajukan: json['dana_diajukan']?.toString() ?? json['DanaDiajukan']?.toString(),
      danaDisetujui: json['dana_disetujui']?.toString() ?? json['DanaDisetujui']?.toString(),
      catatanVerifikator: json['catatan_verifikator'] ?? json['CatatanVerifikator'],
      cabang: json['cabang'] ?? json['Cabang'],
      jumlahUnitPeserta: json['jumlah_unit_peserta']?.toString() ?? json['JumlahUnitPeserta']?.toString(),
      kelompokPrestasi: json['kelompok_prestasi'] ?? json['KelompokPrestasi'] ?? 'individu',
      bentuk: json['bentuk'] ?? json['Bentuk'],
      urlPeserta: json['url_peserta'] ?? json['UrlPeserta'],
      urlFotoUpp: json['url_foto_upp'] ?? json['UrlFotoUpp'],
      urlDokumenUndangan: json['url_dokumen_undangan'] ?? json['UrlDokumenUndangan'],
      jenisRekognisi: json['jenis_rekognisi'] ?? json['JenisRekognisi'],
      simkatmawaStatus: json['simkatmawa_status'] ?? json['SimkatmawaStatus'],
      keterangan: json['keterangan'] ?? json['Keterangan'],
      pembimbingDosen: json['pembimbing_dosen'] ?? json['PembimbingDosen'],
      anggotaMahasiswa: json['anggota_mahasiswa'] ?? json['AnggotaMahasiswa'],
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
      if (urlDokumenUndangan != null) 'url_dokumen_undangan': urlDokumenUndangan,
      if (jenisRekognisi != null) 'jenis_rekognisi': jenisRekognisi,
      if (keterangan != null) 'keterangan': keterangan,
    };
  }
}

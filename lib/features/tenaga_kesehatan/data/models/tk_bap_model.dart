class TkBapModel {
  final int id;
  final String namaKegiatan;
  final DateTime tanggalPelaksanaan;
  final String waktuMulai;
  final String waktuSelesai;
  final String tempat;
  final int jumlahPeserta;
  final int jumlahDiperiksa;
  final int totalLayak;
  final int totalPantauan;
  final int totalTidakLayak;
  final String status;
  final int? eventId;
  final int? tkId;
  final String? ttdKepalaDivisiNama;
  final String? ttdKepalaDivisiNik;
  final String? ttdTimMedisNama;
  final String? ttdTimMedisNik;
  final String? fotoKegiatan;

  TkBapModel({
    required this.id,
    required this.namaKegiatan,
    required this.tanggalPelaksanaan,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tempat,
    required this.jumlahPeserta,
    required this.jumlahDiperiksa,
    required this.totalLayak,
    required this.totalPantauan,
    required this.totalTidakLayak,
    required this.status,
    this.eventId,
    this.tkId,
    this.ttdKepalaDivisiNama,
    this.ttdKepalaDivisiNik,
    this.ttdTimMedisNama,
    this.ttdTimMedisNik,
    this.fotoKegiatan,
  });

  factory TkBapModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      return int.tryParse(val.toString()) ?? 0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      return DateTime.tryParse(val.toString()) ?? DateTime.now();
    }

    return TkBapModel(
      id: parseInt(json['id'] ?? json['ID']),
      namaKegiatan:
          (json['nama_kegiatan'] ?? json['nama'] ?? json['nama_event'] ?? '')
              .toString(),
      tanggalPelaksanaan: parseDate(
        json['tanggal_pelaksanaan'] ??
            json['tanggal'] ??
            json['created_at'],
      ),
      waktuMulai: (json['waktu_mulai'] ?? json['jam_mulai'] ?? '').toString(),
      waktuSelesai:
          (json['waktu_selesai'] ?? json['jam_selesai'] ?? '').toString(),
      tempat: (json['tempat'] ?? json['lokasi'] ?? '').toString(),
      jumlahPeserta: parseInt(json['jumlah_peserta'] ?? json['peserta']),
      jumlahDiperiksa: parseInt(json['jumlah_diperiksa'] ?? json['diperiksa']),
      totalLayak: parseInt(json['total_layak'] ?? json['layak']),
      totalPantauan: parseInt(json['total_pantauan'] ?? json['pantauan']),
      totalTidakLayak: parseInt(json['total_tidak_layak'] ?? json['tidak_layak']),
      status: (json['status'] ?? 'DRAFT').toString(),
      eventId: json['event_id'] != null ? parseInt(json['event_id']) : null,
      tkId: json['tk_id'] != null ? parseInt(json['tk_id']) : null,
      ttdKepalaDivisiNama: json['ttd_kepala_divisi_nama']?.toString(),
      ttdKepalaDivisiNik: json['ttd_kepala_divisi_nik']?.toString(),
      ttdTimMedisNama: json['ttd_tim_medis_nama']?.toString(),
      ttdTimMedisNik: json['ttd_tim_medis_nik']?.toString(),
      fotoKegiatan: json['foto_kegiatan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_kegiatan': namaKegiatan,
      'tanggal_pelaksanaan':
          "${tanggalPelaksanaan.year.toString().padLeft(4, '0')}-${tanggalPelaksanaan.month.toString().padLeft(2, '0')}-${tanggalPelaksanaan.day.toString().padLeft(2, '0')}",
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'tempat': tempat,
      'jumlah_peserta': jumlahPeserta,
      'jumlah_diperiksa': jumlahDiperiksa,
      'total_layak': totalLayak,
      'total_pantauan': totalPantauan,
      'total_tidak_layak': totalTidakLayak,
      'status': status,
      if (eventId != null) 'event_id': eventId,
      if (tkId != null) 'tk_id': tkId,
      if (ttdKepalaDivisiNama != null)
        'ttd_kepala_divisi_nama': ttdKepalaDivisiNama,
      if (ttdKepalaDivisiNik != null)
        'ttd_kepala_divisi_nik': ttdKepalaDivisiNik,
      if (ttdTimMedisNama != null) 'ttd_tim_medis_nama': ttdTimMedisNama,
      if (ttdTimMedisNik != null) 'ttd_tim_medis_nik': ttdTimMedisNik,
      if (fotoKegiatan != null) 'foto_kegiatan': fotoKegiatan,
    };
  }
}

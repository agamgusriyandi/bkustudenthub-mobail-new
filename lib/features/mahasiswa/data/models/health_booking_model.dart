import '../../domain/entities/health_booking.dart';

class HealthWorkerModel extends HealthWorker {
  HealthWorkerModel({
    required super.id,
    required super.nama,
    required super.email,
    required super.noHp,
    required super.spesialisasi,
    required super.fotoUrl,
    required super.lokasi,
    super.isAktif,
  });

  factory HealthWorkerModel.fromJson(Map<String, dynamic> json) {
    final userMap = json['user'] is Map ? json['user'] : null;

    String parsedNama =
        (userMap != null ? (userMap['name'] ?? userMap['nama']) : null) ??
        json['nama'] ??
        json['Nama'] ??
        json['name'] ??
        '';
    if (parsedNama.isEmpty || parsedNama.toLowerCase().contains('dummy')) {
      // If it's a dummy or empty, fallback harder to userMap if possible
      parsedNama =
          (userMap != null ? (userMap['name'] ?? userMap['nama']) : null) ??
          parsedNama;
    }
    if (parsedNama.isEmpty) parsedNama = 'Tenaga Kesehatan';

    // Fallback if nama is literally 'Dr. Medis Dummy' but userMap has 'sinta'
    if (parsedNama == 'Dr. Medis Dummy' &&
        userMap != null &&
        userMap['name'] != null) {
      parsedNama = userMap['name'];
    }

    String parsedFotoUrl =
        json['foto_url'] ??
        json['FotoURL'] ??
        json['avatar_url'] ??
        json['foto'] ??
        json['picture'] ??
        json['photo'] ??
        json['image'] ??
        json['gambar'] ??
        json['profile_picture'] ??
        (userMap != null
            ? (userMap['avatar_url'] ??
                userMap['foto'] ??
                userMap['picture'] ??
                userMap['photo'] ??
                userMap['image'])
            : null) ??
        '';
    if (parsedFotoUrl.trim().isEmpty) {
      parsedFotoUrl =
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(parsedNama)}&background=003399&color=fff&size=128';
    }

    return HealthWorkerModel(
      id: json['id'] ?? json['ID'] ?? 0,
      nama: parsedNama,
      email:
          (userMap != null ? userMap['email'] : null) ??
          json['email'] ??
          json['Email'] ??
          '',
      noHp:
          (userMap != null ? userMap['phone'] : null) ??
          json['no_hp'] ??
          json['NoHP'] ??
          '',
      spesialisasi:
          json['spesialisasi'] ?? json['Spesialisasi'] ?? 'Pemeriksaan Umum',
      fotoUrl: parsedFotoUrl,
      lokasi: json['lokasi'] ?? json['Lokasi'] ?? 'Klinik Kampus BKU',
      isAktif: json['is_aktif'] ?? json['IsAktif'] ?? true,
    );
  }
}

class HealthScheduleModel extends HealthSchedule {
  HealthScheduleModel({
    required super.id,
    required super.tenagaKesId,
    super.tenagaKes,
    required super.tanggal,
    required super.jamMulai,
    required super.jamSelesai,
    required super.kuota,
    required super.sisaKuota,
    required super.lokasi,
    required super.tipeLayanan,
    required super.catatan,
  });

  factory HealthScheduleModel.fromJson(Map<String, dynamic> json) {
    return HealthScheduleModel(
      id: json['id'] ?? json['ID'] ?? 0,
      tenagaKesId: json['tenaga_kes_id'] ?? json['TenagaKesID'] ?? 0,
      tenagaKes:
          json['tenaga_kes'] != null
              ? HealthWorkerModel.fromJson(json['tenaga_kes'])
              : null,
      tanggal:
          json['tanggal'] != null
              ? (DateTime.tryParse(json['tanggal'].toString()) ??
                      DateTime.now())
                  .toLocal()
              : DateTime.now(),
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      kuota: json['kuota'] ?? 0,
      sisaKuota: json['sisa_kuota'] ?? json['kuota'] ?? 0,
      lokasi: json['lokasi'] ?? '',
      tipeLayanan: json['tipe_layanan'] ?? '',
      catatan: json['catatan'] ?? '',
    );
  }
}

class HealthBookingModel extends HealthBooking {
  HealthBookingModel({
    required super.id,
    required super.jadwalId,
    super.jadwal,
    required super.mahasiswaId,
    required super.keluhan,
    required super.status,
    required super.alasanPenolakan,
  });

  factory HealthBookingModel.fromJson(Map<String, dynamic> json) {
    return HealthBookingModel(
      id: json['id'] ?? json['ID'] ?? 0,
      jadwalId: json['jadwal_id'] ?? json['JadwalID'] ?? 0,
      jadwal:
          json['jadwal'] != null
              ? HealthScheduleModel.fromJson(json['jadwal'])
              : null,
      mahasiswaId: json['mahasiswa_id'] ?? json['MahasiswaID'] ?? 0,
      keluhan: json['keluhan'] ?? '',
      status: json['status'] ?? '',
      alasanPenolakan: json['alasan_penolakan'] ?? '',
    );
  }
}

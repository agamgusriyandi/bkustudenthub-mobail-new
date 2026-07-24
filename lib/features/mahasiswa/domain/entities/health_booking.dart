class HealthWorker {
  final int id;
  final String nama;
  final String email;
  final String noHp;
  final String spesialisasi;
  final String fotoUrl;
  final String lokasi;
  final bool isAktif;

  HealthWorker({
    required this.id,
    required this.nama,
    required this.email,
    required this.noHp,
    required this.spesialisasi,
    required this.fotoUrl,
    required this.lokasi,
    this.isAktif = true,
  });
}

class HealthSchedule {
  final int id;
  final int tenagaKesId;
  final HealthWorker? tenagaKes;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final int kuota;
  final int sisaKuota;
  final String lokasi;
  final String tipeLayanan;
  final String catatan;

  HealthSchedule({
    required this.id,
    required this.tenagaKesId,
    this.tenagaKes,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
    required this.sisaKuota,
    required this.lokasi,
    required this.tipeLayanan,
    required this.catatan,
  });
}

class HealthBooking {
  final int id;
  final int jadwalId;
  final HealthSchedule? jadwal;
  final int mahasiswaId;
  final String keluhan;
  final String status;
  final String alasanPenolakan;

  HealthBooking({
    required this.id,
    required this.jadwalId,
    this.jadwal,
    required this.mahasiswaId,
    required this.keluhan,
    required this.status,
    required this.alasanPenolakan,
  });
}

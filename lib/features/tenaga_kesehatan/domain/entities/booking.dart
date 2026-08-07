import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final int id;
  final int mahasiswaId;
  final int jadwalId;
  final String nama;
  final String nim;
  final String email;
  final String phone;
  final String prodi;
  final String fakultas;
  final int semester;
  final String? fotoURL;
  final String? jadwalTanggal;
  final String? waktu;
  final String? rawDate;
  final String? tipeLayanan;
  final String? lokasi;
  final String? keluhan;
  final String status;
  final String? alasanPenolakan;
  final DateTime? createdAt;

  const Booking({
    required this.id,
    required this.mahasiswaId,
    required this.jadwalId,
    required this.nama,
    required this.nim,
    required this.email,
    required this.phone,
    required this.prodi,
    required this.fakultas,
    required this.semester,
    this.fotoURL,
    this.jadwalTanggal,
    this.waktu,
    this.rawDate,
    this.tipeLayanan,
    this.lokasi,
    this.keluhan,
    required this.status,
    this.alasanPenolakan,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      mahasiswaId: json['mahasiswa_id'] ?? 0,
      jadwalId: json['jadwal']?['id'] ?? 0,
      nama: json['name'] ?? json['nama'] ?? '',
      nim: json['nim'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      prodi: json['prodi'] ?? '',
      fakultas: json['faculty'] ?? json['fakultas'] ?? '',
      semester: json['semester'] ?? 1,
      fotoURL: () {
        final m = json['mahasiswa'] is Map ? json['mahasiswa'] : null;
        final u = json['user'] is Map ? json['user'] : null;
        final possibleUrls = [
          json['foto_url'],
          json['avatar_url'],
          json['foto'],
          json['FotoURL'],
          json['avatar'],
          if (m != null) ...[
            m['foto_url'],
            m['avatar_url'],
            m['foto'],
            m['FotoURL'],
            m['avatar'],
          ],
          if (u != null) ...[
            u['foto_url'],
            u['avatar_url'],
            u['foto'],
            u['FotoURL'],
            u['avatar'],
          ],
        ];
        for (final url in possibleUrls) {
          if (url != null && url.toString().trim().isNotEmpty) {
            return url.toString();
          }
        }
        return null;
      }(),
      jadwalTanggal: json['date'],
      waktu: json['time'],
      rawDate: json['raw_date'],
      tipeLayanan: json['tipe_layanan'],
      lokasi: json['jadwal']?['lokasi'],
      keluhan: json['note'] ?? json['keluhan'],
      status: json['status'] ?? 'Menunggu Konfirmasi',
      alasanPenolakan: json['alasan_penolakan'],
      createdAt:
          json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'jadwal_id': jadwalId,
      'name': nama,
      'nim': nim,
      'email': email,
      'phone': phone,
      'prodi': prodi,
      'faculty': fakultas,
      'semester': semester,
      'status': status,
      'note': keluhan,
    };
  }

  String get initials {
    if (nama.isEmpty) return 'M';
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0][0];
  }

  bool get isPending => status == 'Menunggu Konfirmasi';
  bool get isConfirmed => status == 'Dikonfirmasi';
  bool get isRejected => status == 'Ditolak';
  bool get isCompleted => status == 'Selesai';

  @override
  List<Object?> get props => [
    id,
    mahasiswaId,
    jadwalId,
    nama,
    nim,
    prodi,
    fakultas,
    status,
    createdAt,
  ];
}

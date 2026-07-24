import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final int id;
  final int tenagaKesId;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final int kuota;
  final int? eventId;
  final String lokasi;
  final String tipeLayanan;
  final String? catatan;
  final bool isRepeat;
  final String? repeatDays;
  final int? bookedCount;
  final int? sisaKuota;

  const Schedule({
    required this.id,
    required this.tenagaKesId,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.kuota,
    this.eventId,
    required this.lokasi,
    required this.tipeLayanan,
    this.catatan,
    this.isRepeat = false,
    this.repeatDays,
    this.bookedCount,
    this.sisaKuota,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'] ?? 0,
      tenagaKesId: json['tenaga_kes_id'] ?? 0,
      tanggal:
          json['tanggal'] != null
              ? DateTime.tryParse(json['tanggal'].toString()) ?? DateTime.now()
              : DateTime.now(),
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      kuota: json['kuota'] ?? 1,
      eventId: json['event_id'],
      lokasi: json['lokasi'] ?? '',
      tipeLayanan: json['tipe_layanan'] ?? 'Pemeriksaan Umum',
      catatan: json['catatan'],
      isRepeat: json['is_repeat'] ?? false,
      repeatDays: json['repeat_days'],
      bookedCount: json['booked_count'],
      sisaKuota: json['sisa_kuota'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenaga_kes_id': tenagaKesId,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'kuota': kuota,
      'event_id': eventId,
      'lokasi': lokasi,
      'tipe_layanan': tipeLayanan,
      'catatan': catatan,
      'is_repeat': isRepeat,
      'repeat_days': repeatDays,
    };
  }

  String get waktuFormat => '$jamMulai - $jamSelesai';

  bool get hasKuota => (sisaKuota ?? (kuota - (bookedCount ?? 0))) > 0;

  int get availableSlots => sisaKuota ?? (kuota - (bookedCount ?? 0));

  @override
  List<Object?> get props => [
    id,
    tenagaKesId,
    tanggal,
    jamMulai,
    jamSelesai,
    kuota,
    eventId,
    lokasi,
    tipeLayanan,
    catatan,
    isRepeat,
    repeatDays,
  ];
}

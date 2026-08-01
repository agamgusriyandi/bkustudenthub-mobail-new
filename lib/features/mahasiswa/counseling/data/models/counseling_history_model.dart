enum CounselingStatus { menunggu, selesai, dibatalkan }

enum CounselingType { individu, kelompok }

class CounselingHistoryModel {
  final int id;
  final String psychologistName;
  final String psychologistSpecialization;
  final String psychologistPhoto;
  final DateTime date;
  final String time;
  final CounselingStatus status;
  final CounselingType type;
  final String? notes;
  final String? cancelReason;
  final bool canReschedule;
  final bool canCancel;

  const CounselingHistoryModel({
    required this.id,
    required this.psychologistName,
    required this.psychologistSpecialization,
    required this.psychologistPhoto,
    required this.date,
    required this.time,
    required this.status,
    required this.type,
    this.notes,
    this.cancelReason,
    this.canReschedule = false,
    this.canCancel = false,
  });

  factory CounselingHistoryModel.fromJson(Map<String, dynamic> json) {
    return CounselingHistoryModel(
      id: json['id'] ?? 0,
      psychologistName: json['psychologist_name'] ?? '',
      psychologistSpecialization: json['psychologist_specialization'] ?? '',
      psychologistPhoto: json['psychologist_photo'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      time: json['time'] ?? '',
      status: _parseStatus(json['status']),
      type: _parseType(json['type']),
      notes: json['notes'],
      cancelReason: json['cancel_reason'],
      canReschedule: json['can_reschedule'] ?? false,
      canCancel: json['can_cancel'] ?? false,
    );
  }

  static CounselingStatus _parseStatus(dynamic value) {
    if (value == null) return CounselingStatus.menunggu;
    switch (value.toString().toLowerCase()) {
      case 'menunggu':
      case 'pending':
        return CounselingStatus.menunggu;
      case 'selesai':
      case 'completed':
      case 'done':
        return CounselingStatus.selesai;
      case 'dibatalkan':
      case 'cancelled':
      case 'canceled':
        return CounselingStatus.dibatalkan;
      default:
        return CounselingStatus.menunggu;
    }
  }

  static CounselingType _parseType(dynamic value) {
    if (value == null) return CounselingType.individu;
    switch (value.toString().toLowerCase()) {
      case 'kelompok':
      case 'group':
        return CounselingType.kelompok;
      default:
        return CounselingType.individu;
    }
  }

  String get statusLabel {
    switch (status) {
      case CounselingStatus.menunggu:
        return 'Menunggu';
      case CounselingStatus.selesai:
        return 'Selesai';
      case CounselingStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  String get typeLabel {
    switch (type) {
      case CounselingType.individu:
        return 'Individu';
      case CounselingType.kelompok:
        return 'Kelompok';
    }
  }

  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

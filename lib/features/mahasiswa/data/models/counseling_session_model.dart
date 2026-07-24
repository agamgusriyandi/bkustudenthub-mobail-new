import '../../domain/entities/counseling_session.dart';

class CounselingSessionModel extends CounselingSession {
  CounselingSessionModel({
    required super.id,
    required super.psychologistId,
    required super.psychologistName,
    required super.topic,
    required super.date,
    required super.time,
    super.location,
    required super.status,
    super.notes,
  });

  factory CounselingSessionModel.fromJson(Map<String, dynamic> json) {
    // Backend Konseling struct tidak punya json tags → GORM return PascalCase
    // Fields: ID, DosenID, MahasiswaID, Tanggal, Topik, Status, Catatan, Dosen

    // Parse waktu
    String timeStr = '';
    final dateRaw = json['Tanggal'] ?? json['tanggal'] ?? json['date'];
    DateTime parsedDate = DateTime.now();
    if (dateRaw != null) {
      try {
        parsedDate = DateTime.parse(dateRaw.toString());
        final hour = parsedDate.hour.toString().padLeft(2, '0');
        final minute = parsedDate.minute.toString().padLeft(2, '0');
        timeStr =
            '$hour:$minute - ${(parsedDate.hour + 1).toString().padLeft(2, '0')}:$minute';
      } catch (_) {
        timeStr = '08:00 - 10:00';
      }
    } else {
      timeStr = '08:00 - 10:00';
    }

    // Extract nama dosen/psikolog dari relasi Dosen
    String psyName = '';
    final dosenRaw = json['Dosen'] ?? json['dosen'] ?? json['psychologist'];
    if (dosenRaw is Map) {
      psyName =
          dosenRaw['Nama']?.toString() ??
          dosenRaw['nama']?.toString() ??
          dosenRaw['name']?.toString() ??
          'Konselor';
    }
    if (psyName.isEmpty) {
      psyName = json['psychologistName']?.toString() ?? 'Konselor';
    }

    // Extract psychologistId dari DosenID
    final dosenId =
        json['DosenID'] ??
        json['dosen_id'] ??
        json['psychologist_id'] ??
        json['psychologistId'] ??
        '';

    // Extract topik/catatan
    final topik = json['Topik'] ?? json['topik'] ?? json['topic'] ?? '';
    final catatan =
        json['Catatan'] ??
        json['catatan'] ??
        json['complaint'] ??
        json['notes'] ??
        '';
    final status = json['Status'] ?? json['status'] ?? '';

    // Fallback or override time if 'start' and 'end' are provided (new api format)
    if (json['start'] != null) {
      timeStr = '${json['start']} - ${json['end']}';
    }

    return CounselingSessionModel(
      id: (json['ID'] ?? json['id'])?.toString() ?? '',
      psychologistId: dosenId.toString(),
      psychologistName: psyName,
      topic: topik.toString(),
      date: parsedDate,
      time: timeStr,
      location:
          json['location']?.toString() ??
          json['Lokasi']?.toString() ??
          'Ruang Konseling',
      status: status.toString() == 'Selesai' ? 'Completed' : status.toString(),
      notes: catatan.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'psychologistId': psychologistId,
      'psychologistName': psychologistName,
      'topic': topic,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'status': status,
      'notes': notes,
    };
  }
}

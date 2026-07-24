class CounselingSession {
  final String id;
  final String studentName;
  final String studentId;
  final DateTime dateTime;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String reason;
  final String? meetLink;
  final List<SessionNote>? notes;
  final AssessmentResult? assessment;

  CounselingSession({
    required this.id,
    required this.studentName,
    required this.studentId,
    required this.dateTime,
    required this.status,
    required this.reason,
    this.meetLink,
    this.notes,
    this.assessment,
  });
}

class SessionNote {
  final String id;
  final DateTime createdAt;
  final String content;
  final String psychologistId;
  final String psychologistName;

  SessionNote({
    required this.id,
    required this.createdAt,
    required this.content,
    required this.psychologistId,
    required this.psychologistName,
  });
}

class AssessmentResult {
  final String id;
  final DateTime date;
  final int stressLevel; // 0-100
  final int anxietyLevel; // 0-100
  final String summary;
  final Map<String, dynamic> answers;

  AssessmentResult({
    required this.id,
    required this.date,
    required this.stressLevel,
    required this.anxietyLevel,
    required this.summary,
    required this.answers,
  });
}

class TimeSlot {
  final DateTime start;
  final DateTime end;
  final bool isBooked;

  TimeSlot({required this.start, required this.end, this.isBooked = false});
}

// ─── Tindak Lanjut (Referral) ─────────────────────────────────────────────────

class Referral {
  final int id;
  final int mahasiswaId;
  final String mahasiswaNama;
  final String? mahasiswaNim;
  final String? mahasiswaAvatar;
  final String tipe; // "Medis" atau "Akademik"
  final String alasan;
  final String status; // "Pending", "Sent", "Received"
  final String approvalStatus; // "pending", "disetujui", "ditolak"
  final String pihakTujuan;
  final String emailTujuan;
  final String? filePendukungUrl;
  final String? suratRujiukanUrl;
  final DateTime tanggalDibuat;
  final String? diagnosis;
  final String? keluhanUtama;
  final double? suhuTubuh;
  final int? sistole;
  final int? diastole;
  final int? denyutNadi;
  final int? respirationRate;
  final int? spo2;
  final DateTime? tanggalDikirim;
  final DateTime? tanggalDiterima;

  Referral({
    required this.id,
    required this.mahasiswaId,
    required this.mahasiswaNama,
    this.mahasiswaNim,
    this.mahasiswaAvatar,
    required this.tipe,
    required this.alasan,
    required this.status,
    required this.approvalStatus,
    required this.pihakTujuan,
    required this.emailTujuan,
    this.filePendukungUrl,
    this.suratRujiukanUrl,
    required this.tanggalDibuat,
    this.tanggalDikirim,
    this.tanggalDiterima,
    this.diagnosis,
    this.keluhanUtama,
    this.suhuTubuh,
    this.sistole,
    this.diastole,
    this.denyutNadi,
    this.respirationRate,
    this.spo2,
  });

  factory Referral.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic val, [bool required = true]) {
      if (val == null) return required ? DateTime.now() : null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return required ? DateTime.now() : null;
      }
    }

    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString()) ?? 0;
    }

    String extractMahasiswaName(Map<String, dynamic> j) {
      if (j['mahasiswa_nama'] != null) return j['mahasiswa_nama'].toString();
      if (j['mahasiswa_name'] != null) return j['mahasiswa_name'].toString();
      if (j['MahasiswaName'] != null) return j['MahasiswaName'].toString();
      if (j['NamaMahasiswa'] != null) return j['NamaMahasiswa'].toString();
      if (j['MahasiswaNama'] != null) return j['MahasiswaNama'].toString();
      if (j['nama_mahasiswa'] != null) return j['nama_mahasiswa'].toString();
      if (j['nama_pasien'] != null) return j['nama_pasien'].toString();
      if (j['nama'] != null) return j['nama'].toString();
      if (j['student_name'] != null) return j['student_name'].toString();
      if (j['studentName'] != null) return j['studentName'].toString();
      if (j['patient_name'] != null) return j['patient_name'].toString();
      if (j['patientName'] != null) return j['patientName'].toString();

      final mhsData =
          j['mahasiswa'] ??
          j['Mahasiswa'] ??
          j['pasien'] ??
          j['Pasien'] ??
          j['user'] ??
          j['User'] ??
          j['student'] ??
          j['Student'];
      if (mhsData is Map) {
        final m = mhsData;
        if (m['nama'] != null) return m['nama'].toString();
        if (m['Nama'] != null) return m['Nama'].toString();
        if (m['name'] != null) return m['name'].toString();
        if (m['Name'] != null) return m['Name'].toString();
      }

      return 'Tidak Diketahui';
    }

    String? extractMahasiswaNim(Map<String, dynamic> j) {
      final possibleRootKeys = [
        'mahasiswa_nim',
        'nim',
        'NIM',
        'Nim',
        'student_nim',
        'patient_nim',
      ];
      for (final key in possibleRootKeys) {
        if (j[key] != null && j[key].toString().isNotEmpty) {
          return j[key].toString();
        }
      }

      final mhsData =
          j['mahasiswa'] ??
          j['Mahasiswa'] ??
          j['pasien'] ??
          j['Pasien'] ??
          j['user'] ??
          j['User'] ??
          j['student'] ??
          j['Student'];
      if (mhsData is Map) {
        return mhsData['nim']?.toString() ?? mhsData['NIM']?.toString();
      }
      return null;
    }

    String? extractMahasiswaAvatar(Map<String, dynamic> j) {
      final possibleRootKeys = [
        'FotoURL',
        'foto_url',
        'Foto',
        'foto',
        'FotoProfil',
        'foto_profil',
        'mahasiswa_avatar',
        'avatar_url',
      ];
      for (final key in possibleRootKeys) {
        if (j[key] != null && j[key].toString().isNotEmpty) {
          return j[key].toString();
        }
      }
      final mhsData =
          j['mahasiswa'] ??
          j['Mahasiswa'] ??
          j['pasien'] ??
          j['Pasien'] ??
          j['user'] ??
          j['User'] ??
          j['student'] ??
          j['Student'];
      if (mhsData is Map) {
        final photo =
            mhsData['FotoURL'] ??
            mhsData['foto_url'] ??
            mhsData['Foto'] ??
            mhsData['foto'] ??
            mhsData['FotoProfil'] ??
            mhsData['foto_profil'];
        if (photo != null) {
          return photo.toString();
        }

        final user =
            mhsData['Pengguna'] ??
            mhsData['pengguna'] ??
            mhsData['User'] ??
            mhsData['user'];
        if (user is Map) {
          final userPhoto =
              user['Foto'] ??
              user['foto'] ??
              user['FotoURL'] ??
              user['foto_url'];
          if (userPhoto != null) {
            return userPhoto.toString();
          }
        }
      }
      return null;
    }

    String extractPihakTujuan(Map<String, dynamic> j) {
      if (j['pihak_tujuan'] != null) return j['pihak_tujuan'].toString();
      if (j['PihakTujuan'] != null) return j['PihakTujuan'].toString();
      if (j['faskes_tujuan'] != null) return j['faskes_tujuan'].toString();
      if (j['nama_faskes'] != null) return j['nama_faskes'].toString();
      if (j['psikolog'] is Map) {
        final p = j['psikolog'];
        if (p['nama'] != null) return p['nama'].toString();
        if (p['name'] != null) return p['name'].toString();
      }
      return '-';
    }

    String extractEmailTujuan(Map<String, dynamic> j) {
      if (j['email_tujuan'] != null) return j['email_tujuan'].toString();
      if (j['EmailTujuan'] != null) return j['EmailTujuan'].toString();
      if (j['email_faskes'] != null) return j['email_faskes'].toString();
      if (j['faskes_email'] != null) return j['faskes_email'].toString();
      if (j['psikolog'] is Map) {
        final p = j['psikolog'];
        if (p['email'] != null) return p['email'].toString();
      }
      return '-';
    }

    String parseStatus(dynamic val) {
      if (val == null) return 'Pending';
      final s = val.toString().toLowerCase().trim();
      if (s == 'pending' ||
          s == 'menunggu_approval' ||
          s == 'menunggu approval' ||
          s == 'menunggu persetujuan' ||
          s == 'menunggu_persetujuan') {
        return 'Pending';
      }
      if (s == 'sent' ||
          s == 'sudah dikirim' ||
          s == 'sudah_dikirim' ||
          s == 'dikirim') {
        return 'Sent';
      }
      if (s == 'received' ||
          s == 'selesai' ||
          s == 'diterima' ||
          s == 'sudah diterima' ||
          s == 'sudah_diterima') {
        return 'Received';
      }
      if (s == 'ditolak' || s == 'rejected') {
        return 'Ditolak';
      }
      return 'Pending';
    }

    return Referral(
      id: parseInt(json['id'] ?? json['ID'] ?? json['Id']),
      mahasiswaId: parseInt(
        json['mahasiswa_id'] ??
            json['MahasiswaID'] ??
            json['pasien_id'] ??
            json['student_id'],
      ),
      mahasiswaNama: extractMahasiswaName(json),
      mahasiswaNim: extractMahasiswaNim(json),
      mahasiswaAvatar: extractMahasiswaAvatar(json),
      tipe:
          json['tipe'] ??
          json['Tipe'] ??
          json['tipe_rujukan'] ??
          json['jenis_rujukan'] ??
          json['tipe_konseling'] ??
          json['type'] ??
          (json['faskes_tujuan'] != null ? 'Medis' : '-'),
      alasan:
          json['alasan'] ??
          json['Alasan'] ??
          json['alasan_rujukan'] ??
          json['keluhan_utama'] ??
          json['diagnosis'] ??
          '-',
      status: parseStatus(
        json['status'] ?? json['Status'] ?? json['approval_status'],
      ),
      approvalStatus:
          (json['approval_status'] ?? json['ApprovalStatus'] ?? '').toString(),
      pihakTujuan: extractPihakTujuan(json),
      emailTujuan: extractEmailTujuan(json),
      filePendukungUrl: json['file_pendukung_url'] ?? json['FilePendukungUrl'],
      suratRujiukanUrl: json['surat_rujukan_url'] ?? json['SuratRujukanUrl'],
      tanggalDibuat:
          parseDate(
            json['tanggal_dibuat'] ??
                json['TanggalDibuat'] ??
                json['created_at'],
          ) ??
          DateTime.now(),
      tanggalDikirim: parseDate(
        json['tanggal_dikirim'] ?? json['TanggalDikirim'],
        false,
      ),
      tanggalDiterima: parseDate(
        json['tanggal_diterima'] ?? json['TanggalDiterima'],
        false,
      ),
      diagnosis: json['diagnosis'],
      keluhanUtama: json['keluhan_utama'],
      suhuTubuh:
          json['suhu_tubuh'] != null
              ? double.tryParse(json['suhu_tubuh'].toString())
              : null,
      sistole:
          json['sistole'] != null
              ? int.tryParse(json['sistole'].toString())
              : null,
      diastole:
          json['diastole'] != null
              ? int.tryParse(json['diastole'].toString())
              : null,
      denyutNadi:
          json['denyut_nadi'] != null
              ? int.tryParse(json['denyut_nadi'].toString())
              : null,
      respirationRate:
          json['respiration_rate'] != null
              ? int.tryParse(json['respiration_rate'].toString())
              : null,
      spo2: json['spo2'] != null ? int.tryParse(json['spo2'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mahasiswa_id': mahasiswaId,
      'mahasiswa_name': mahasiswaNama,
      'tipe': tipe,
      'alasan': alasan,
      'status': status,
      'approval_status': approvalStatus,
      'pihak_tujuan': pihakTujuan,
      'email_tujuan': emailTujuan,
      'file_pendukung_url': filePendukungUrl,
      'surat_rujukan_url': suratRujiukanUrl,
      'tanggal_dibuat': tanggalDibuat.toIso8601String(),
      'tanggal_dikirim': tanggalDikirim?.toIso8601String(),
      'tanggal_diterima': tanggalDiterima?.toIso8601String(),
      'diagnosis': diagnosis,
      'keluhan_utama': keluhanUtama,
      'suhu_tubuh': suhuTubuh,
      'sistole': sistole,
      'diastole': diastole,
      'denyut_nadi': denyutNadi,
      'respiration_rate': respirationRate,
      'spo2': spo2,
    };
  }
}

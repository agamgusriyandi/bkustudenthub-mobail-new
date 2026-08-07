import 'dart:convert';

class MentorDashboardData {
  final int totalMentees;
  final int totalGroups;
  final int pendingScoring;
  final int unreadAnnouncements;
  final int passedStudents;
  final int remedialStudents;
  final int pendingHandbooks;
  final Map<String, dynamic> rawData;

  MentorDashboardData({
    required this.totalMentees,
    required this.totalGroups,
    required this.pendingScoring,
    required this.unreadAnnouncements,
    this.passedStudents = 0,
    this.remedialStudents = 0,
    this.pendingHandbooks = 0,
    this.rawData = const {},
  });

  factory MentorDashboardData.fromJson(Map<String, dynamic> json) {
    int parseIntStrict(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    return MentorDashboardData(
      totalMentees: parseIntStrict(
        json['total_mentees'] ??
            json['total_mentee'] ??
            json['totalMentees'] ??
            json['TotalMentee'],
      ),
      totalGroups: parseIntStrict(
        json['total_groups'] ??
            json['total_grup'] ??
            json['totalGroups'] ??
            json['TotalGrup'],
      ),
      pendingScoring: parseIntStrict(
        json['pending_scoring'] ??
            json['belum_dinilai'] ??
            json['pendingScoring'] ??
            json['BelumDinilai'],
      ),
      unreadAnnouncements: parseIntStrict(
        json['unread_announcements'] ??
            json['unreadAnnouncements'] ??
            json['jumlah_notifikasi'] ??
            json['notifikasi'] ??
            json['Notifikasi'],
      ),
      passedStudents: parseIntStrict(
        json['passed_students'] ??
            json['passedStudents'] ??
            json['lulus'] ??
            json['Lulus'],
      ),
      remedialStudents: parseIntStrict(
        json['remedial_students'] ??
            json['remedialStudents'] ??
            json['remedial'] ??
            json['Remedial'],
      ),
      pendingHandbooks: parseIntStrict(
        json['pending_handbooks'] ??
            json['pendingHandbooks'] ??
            json['menunggu_persetujuan'] ??
            json['Menunggu'],
      ),
      rawData: json,
    );
  }
}

class MentorAnnouncement {
  final int id;
  final String title;
  final String content;
  final String date;
  final bool isRead;

  MentorAnnouncement({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.isRead,
  });

  factory MentorAnnouncement.fromJson(Map<String, dynamic> json) {
    final parsedTitle =
        json['title'] ??
        json['judul'] ??
        json['judul_pengumuman'] ??
        json['name'] ??
        '';
    final parsedContent =
        json['content'] ??
        json['isi'] ??
        json['konten'] ??
        json['deskripsi'] ??
        json['description'] ??
        '';
    final parsedDate =
        json['date'] ??
        json['tanggal'] ??
        json['created_at'] ??
        json['CreatedAt'] ??
        '';
    return MentorAnnouncement(
      id: json['id'] ?? json['ID'] ?? 0,
      title: parsedTitle.toString(),
      content: parsedContent.toString(),
      date: parsedDate.toString(),
      isRead: json['is_read'] ?? json['isRead'] ?? json['dibaca'] ?? false,
    );
  }
}

class MenteeData {
  final int id;
  final String name;
  final String nim;
  final String programStudi;
  final String faculty;
  final String status;
  final double score;
  final String? avatarUrl;

  MenteeData({
    required this.id,
    required this.name,
    required this.nim,
    this.programStudi = '',
    required this.faculty,
    required this.status,
    required this.score,
    this.avatarUrl,
  });

  factory MenteeData.fromJson(Map<String, dynamic> json) {
    final studentMap = json['student'] is Map ? json['student'] : null;
    final idValue =
        studentMap != null
            ? (studentMap['id'] ?? json['student_id'] ?? json['id'] ?? 0)
            : (json['student_id'] ?? json['id'] ?? json['ID'] ?? 0);
    final nameValue =
        studentMap != null
            ? (studentMap['nama'] ?? studentMap['name'] ?? '')
            : (json['name'] ?? json['nama'] ?? json['Nama'] ?? '');
    final nimValue =
        studentMap != null
            ? (studentMap['nim'] ?? studentMap['NIM'] ?? '')
            : (json['nim'] ?? json['NIM'] ?? '');
    String facultyValue = '';
    if (json['Fakultas'] is Map) {
      facultyValue = json['Fakultas']['nama'] ?? json['Fakultas']['name'] ?? '';
    } else if (json['fakultas'] is Map) {
      facultyValue = json['fakultas']['nama'] ?? json['fakultas']['name'] ?? '';
    } else if (json['faculty'] is Map) {
      facultyValue = json['faculty']['nama'] ?? json['faculty']['name'] ?? '';
    } else if (studentMap != null) {
      if (studentMap['fakultas'] is Map) {
        facultyValue =
            studentMap['fakultas']['nama'] ??
            studentMap['fakultas']['name'] ??
            '';
      } else if (studentMap['Fakultas'] is Map) {
        facultyValue =
            studentMap['Fakultas']['nama'] ??
            studentMap['Fakultas']['name'] ??
            '';
      } else {
        facultyValue =
            studentMap['fakultas_name']?.toString() ??
            studentMap['fakultas']?.toString() ??
            studentMap['Fakultas']?.toString() ??
            '';
      }
    }
    if (facultyValue.isEmpty) {
      facultyValue =
          json['faculty']?.toString() ??
          json['fakultas']?.toString() ??
          json['Fakultas']?.toString() ??
          '';
    }

    final prodiValue =
        studentMap != null
            ? (studentMap['prodi'] ?? studentMap['program_studi'] ?? '')
            : (json['program_studi'] ?? json['prodi'] ?? '');

    final avatarUrlValue = () {
      final possibleKeys = [
        'foto_url',
        'FotoURL',
        'avatar_url',
        'avatar',
        'foto',
      ];
      for (final key in possibleKeys) {
        if (json[key] != null && json[key].toString().trim().isNotEmpty) {
          return json[key].toString().trim();
        }
      }
      if (studentMap != null) {
        for (final key in possibleKeys) {
          if (studentMap[key] != null &&
              studentMap[key].toString().trim().isNotEmpty) {
            return studentMap[key].toString().trim();
          }
        }
        final user =
            studentMap['user'] ??
            studentMap['User'] ??
            studentMap['Pengguna'] ??
            studentMap['pengguna'];
        if (user is Map) {
          for (final key in possibleKeys) {
            if (user[key] != null && user[key].toString().trim().isNotEmpty) {
              return user[key].toString().trim();
            }
          }
        }
      }
      return null;
    }();

    return MenteeData(
      id: idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0,
      name: nameValue.toString(),
      nim: nimValue.toString(),
      faculty: facultyValue.toString(),
      programStudi: prodiValue.toString(),
      status: json['status'] ?? json['Status'] ?? 'Belum Lulus',
      score:
          double.tryParse(
            (json['score'] ?? json['nilai'] ?? json['Nilai'] ?? 0).toString(),
          ) ??
          0.0,
      avatarUrl: avatarUrlValue,
    );
  }
}

class MenteeGroup {
  final int id;
  final String name;
  final List<MenteeData> mentees;

  MenteeGroup({required this.id, required this.name, required this.mentees});

  factory MenteeGroup.fromJson(Map<String, dynamic> json) {
    var menteeList =
        json['members'] ??
        json['mentees'] ??
        json['mentee'] ??
        json['mahasiswa'] ??
        [];
    return MenteeGroup(
      id: json['id'] ?? json['ID'] ?? 0,
      name:
          json['name'] ??
          json['nama'] ??
          json['Nama'] ??
          json['group_name'] ??
          '',
      mentees:
          menteeList is List
              ? menteeList.map((m) => MenteeData.fromJson(m)).toList()
              : [],
    );
  }
}

class MentorSession {
  final int id;
  final String title;
  final String stageName;
  final String date;
  final String qrToken;
  final int attendanceCount;
  final int totalMentees;

  MentorSession({
    required this.id,
    required this.title,
    required this.stageName,
    required this.date,
    required this.qrToken,
    required this.attendanceCount,
    required this.totalMentees,
  });

  factory MentorSession.fromJson(Map<String, dynamic> json) {
    return MentorSession(
      id: json['id'] ?? json['ID'] ?? 0,
      title: json['title'] ?? json['judul'] ?? json['nama'] ?? '',
      stageName: json['stage_name'] ?? json['stageName'] ?? json['tahap'] ?? '',
      date: json['date'] ?? json['tanggal'] ?? '',
      qrToken: json['qr_token'] ?? json['qrToken'] ?? '',
      attendanceCount:
          json['attendance_count'] ??
          json['attendanceCount'] ??
          json['jumlah_hadir'] ??
          0,
      totalMentees:
          json['total_mentees'] ??
          json['totalMentees'] ??
          json['total_mentee'] ??
          0,
    );
  }
}

class MenteeAssignment {
  final int id;
  final String title;
  final String type;
  final double score;
  final String status;
  final String submittedFile;
  final String submittedLink;
  final String answerText;

  MenteeAssignment({
    required this.id,
    required this.title,
    required this.type,
    required this.score,
    required this.status,
    required this.submittedFile,
    required this.submittedLink,
    required this.answerText,
  });

  factory MenteeAssignment.fromJson(Map<String, dynamic> json) {
    return MenteeAssignment(
      id: json['id'] ?? json['ID'] ?? 0,
      title: json['title'] ?? json['judul'] ?? '',
      type: json['type'] ?? json['tipe'] ?? '',
      score:
          double.tryParse((json['score'] ?? json['nilai'] ?? 0).toString()) ??
          0.0,
      status: json['status'] ?? 'not_submitted',
      submittedFile: json['submitted_file'] ?? '',
      submittedLink: json['submitted_link'] ?? '',
      answerText: json['answer_text'] ?? '',
    );
  }
}

class MenteeNote {
  final int id;
  final String notes;
  final String assessedAt;

  MenteeNote({required this.id, required this.notes, required this.assessedAt});

  factory MenteeNote.fromJson(Map<String, dynamic> json) {
    return MenteeNote(
      id: json['id'] ?? json['ID'] ?? 0,
      notes: json['notes'] ?? json['catatan'] ?? '',
      assessedAt: json['assessed_at'] ?? json['created_at'] ?? '',
    );
  }
}

class MenteeDetailData {
  final int id;
  final String name;
  final String nim;
  final String faculty;
  final String status;
  final int totalScore;
  final int attendanceCount;
  final List<MenteeAssignment> assignments;
  final List<MenteeNote> notes;
  final String? avatarUrl;

  MenteeDetailData({
    required this.id,
    required this.name,
    required this.nim,
    required this.faculty,
    required this.status,
    required this.totalScore,
    required this.attendanceCount,
    required this.assignments,
    required this.notes,
    this.avatarUrl,
  });

  factory MenteeDetailData.fromJson(Map<String, dynamic> json) {
    final studentMap = json['student'] is Map ? json['student'] : null;
    final idValue =
        studentMap != null
            ? (studentMap['id'] ?? json['id'] ?? 0)
            : (json['id'] ?? json['ID'] ?? 0);
    final nameValue =
        studentMap != null
            ? (studentMap['nama'] ?? studentMap['name'] ?? '')
            : (json['name'] ?? json['nama'] ?? json['Nama'] ?? '');
    final nimValue =
        studentMap != null
            ? (studentMap['nim'] ?? studentMap['NIM'] ?? '')
            : (json['nim'] ?? json['NIM'] ?? '');

    String facultyValue = '';
    if (json['Fakultas'] is Map) {
      facultyValue = json['Fakultas']['nama'] ?? json['Fakultas']['name'] ?? '';
    } else if (json['fakultas'] is Map) {
      facultyValue = json['fakultas']['nama'] ?? json['fakultas']['name'] ?? '';
    } else if (json['faculty'] is Map) {
      facultyValue = json['faculty']['nama'] ?? json['faculty']['name'] ?? '';
    } else if (studentMap != null) {
      if (studentMap['fakultas'] is Map) {
        facultyValue =
            studentMap['fakultas']['nama'] ??
            studentMap['fakultas']['name'] ??
            '';
      } else if (studentMap['Fakultas'] is Map) {
        facultyValue =
            studentMap['Fakultas']['nama'] ??
            studentMap['Fakultas']['name'] ??
            '';
      } else {
        facultyValue =
            studentMap['fakultas_name']?.toString() ??
            studentMap['fakultas']?.toString() ??
            studentMap['Fakultas']?.toString() ??
            '';
      }
    }
    if (facultyValue.isEmpty) {
      facultyValue =
          json['faculty']?.toString() ??
          json['fakultas']?.toString() ??
          json['Fakultas']?.toString() ??
          '';
    }

    final avatarUrlValue = () {
      final possibleKeys = [
        'foto_url',
        'FotoURL',
        'avatar_url',
        'avatar',
        'foto',
      ];
      for (final key in possibleKeys) {
        if (json[key] != null && json[key].toString().trim().isNotEmpty) {
          return json[key].toString().trim();
        }
      }
      if (studentMap != null) {
        for (final key in possibleKeys) {
          if (studentMap[key] != null &&
              studentMap[key].toString().trim().isNotEmpty) {
            return studentMap[key].toString().trim();
          }
        }
        final user =
            studentMap['user'] ??
            studentMap['User'] ??
            studentMap['Pengguna'] ??
            studentMap['pengguna'];
        if (user is Map) {
          for (final key in possibleKeys) {
            if (user[key] != null && user[key].toString().trim().isNotEmpty) {
              return user[key].toString().trim();
            }
          }
        }
      }
      return null;
    }();

    return MenteeDetailData(
      id: idValue is int ? idValue : int.tryParse(idValue.toString()) ?? 0,
      name: nameValue.toString(),
      nim: nimValue.toString(),
      faculty: facultyValue,
      status: json['status'] ?? json['Status'] ?? '-',
      totalScore:
          json['totalScore'] ?? json['total_score'] ?? json['total_nilai'] ?? 0,
      attendanceCount:
          json['attendanceCount'] ??
          json['attendance_count'] ??
          json['jumlah_hadir'] ??
          0,
      assignments:
          (json['assignments'] as List?)
              ?.map((e) => MenteeAssignment.fromJson(e))
              .toList() ??
          [],
      notes:
          (json['notes'] as List?)
              ?.map((e) => MenteeNote.fromJson(e))
              .toList() ??
          [],
      avatarUrl: avatarUrlValue,
    );
  }
}

class AvailableStudentData {
  final int id;
  final String name;
  final String nim;
  final String faculty;
  final String prodi;
  final bool alreadyHasMentor;
  final String? mentorName;

  AvailableStudentData({
    required this.id,
    required this.name,
    required this.nim,
    required this.faculty,
    this.prodi = '',
    this.alreadyHasMentor = false,
    this.mentorName,
  });

  factory AvailableStudentData.fromJson(Map<String, dynamic> json) {
    String facultyValue = '';
    if (json['fakultas'] is Map) {
      facultyValue = json['fakultas']['nama'] ?? json['fakultas']['name'] ?? '';
    } else {
      facultyValue = json['fakultas']?.toString() ?? json['faculty']?.toString() ?? json['Fakultas']?.toString() ?? '';
    }

    String prodiValue = '';
    if (json['program_studi'] is Map) {
      prodiValue = json['program_studi']['nama'] ?? json['program_studi']['name'] ?? '';
    } else {
      prodiValue = json['program_studi']?.toString() ?? json['prodi']?.toString() ?? json['ProgramStudi']?.toString() ?? '';
    }

    final hasMentorRaw = json['already_has_mentor'];
    final hasMentor = hasMentorRaw == true || hasMentorRaw == 'true' || (json['mentor_name'] != null && json['mentor_name'].toString().isNotEmpty);

    return AvailableStudentData(
      id: json['id'] ?? json['ID'] ?? 0,
      name: json['name'] ?? json['nama'] ?? json['Nama'] ?? '',
      nim: json['nim'] ?? json['NIM'] ?? '',
      faculty: facultyValue,
      prodi: prodiValue,
      alreadyHasMentor: hasMentor,
      mentorName: json['mentor_name']?.toString(),
    );
  }
}

class AbsenceRequestData {
  final int id;
  final String studentName;
  final String nim;
  final String sessionTitle;
  final String reason;
  final String date;
  final String status;
  final String attachmentUrl;

  AbsenceRequestData({
    required this.id,
    required this.studentName,
    required this.nim,
    required this.sessionTitle,
    required this.reason,
    required this.date,
    required this.status,
    this.attachmentUrl = '',
  });

  factory AbsenceRequestData.fromJson(Map<String, dynamic> json) {
    return AbsenceRequestData(
      id: json['id'] ?? json['ID'] ?? 0,
      studentName:
          json['studentName'] ??
          json['student_name'] ??
          json['nama_mahasiswa'] ??
          json['nama'] ??
          '',
      nim: json['nim'] ?? json['NIM'] ?? '',
      sessionTitle:
          json['sessionTitle'] ??
          json['session_title'] ??
          json['nama_sesi'] ??
          '',
      reason: json['reason'] ?? json['alasan'] ?? '',
      date: json['date'] ?? json['tanggal'] ?? '',
      status: json['status'] ?? json['Status'] ?? 'Pending',
      attachmentUrl:
          json['attachmentUrl'] ??
          json['attachment_url'] ??
          json['file_url'] ??
          json['bukti'] ??
          '',
    );
  }
}

class MenteeHandbookData {
  final String status;
  final String feedback;
  final String submittedAt;
  final Map<String, dynamic>? contentJson;

  MenteeHandbookData({
    required this.status,
    required this.feedback,
    required this.submittedAt,
    this.contentJson,
  });

  factory MenteeHandbookData.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedContent;
    if (json['content_json'] != null) {
      if (json['content_json'] is String) {
        try {
          final decoded = jsonDecode(json['content_json']);
          if (decoded is Map) {
            parsedContent = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      } else if (json['content_json'] is Map) {
        parsedContent = Map<String, dynamic>.from(json['content_json']);
      }
    }

    return MenteeHandbookData(
      status: json['status'] ?? 'not_started',
      feedback: json['feedback'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      contentJson: parsedContent,
    );
  }
}

class MentorGroup {
  final int id;
  final String name;
  final int memberCount;
  final String createdAt;
  final String groupNumber;
  final String code;
  final String status;
  final int capacity;

  MentorGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.createdAt,
    this.groupNumber = '',
    this.code = '',
    this.status = 'Aktif',
    this.capacity = 40,
  });

  factory MentorGroup.fromJson(Map<String, dynamic> json) {
    final memberList =
        json['members'] ??
        json['mentees'] ??
        json['mahasiswa'] ??
        json['member_count_list'];
    int count = json['member_count'] ?? json['jumlah_anggota'] ?? json['members_count'] ?? 0;
    if (count == 0 && memberList is List) {
      count = memberList.length;
    }

    return MentorGroup(
      id: json['id'] ?? json['ID'] ?? 0,
      name:
          json['name'] ??
          json['nama'] ??
          json['group_name'] ??
          json['Nama'] ??
          '',
      memberCount: count,
      createdAt: json['created_at'] ?? '',
      groupNumber: json['group_number']?.toString() ?? json['nomor_kelompok']?.toString() ?? '',
      code: json['code']?.toString() ?? json['kode']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Aktif',
      capacity: json['capacity'] ?? json['kapasitas'] ?? 40,
    );
  }
}

class MentorGroupDetail {
  final int id;
  final String name;
  final int maxCapacity;
  final List<MenteeData> members;
  final Map<String, dynamic>? scoreDefinitions;

  MentorGroupDetail({
    required this.id,
    required this.name,
    required this.maxCapacity,
    required this.members,
    this.scoreDefinitions,
  });

  factory MentorGroupDetail.fromJson(Map<String, dynamic> json) {
    final memberList =
        json['members'] ?? json['mentees'] ?? json['mahasiswa'] ?? [];

    final rawCapacity =
        json['max_capacity'] ??
        json['maxCapacity'] ??
        json['capacity'] ??
        json['max_members'] ??
        json['maxMembers'] ??
        json['quota'] ??
        json['kuota'] ??
        json['kapasitas'] ??
        json['max'] ??
        json['limit'];

    int capacity = 0;
    if (rawCapacity != null) {
      capacity = int.tryParse(rawCapacity.toString()) ?? 0;
    }
    if (capacity == 0 && memberList is List) {
      capacity = memberList.length;
    }

    return MentorGroupDetail(
      id: json['id'] ?? json['ID'] ?? 0,
      name:
          json['name'] ??
          json['nama'] ??
          json['group_name'] ??
          json['Nama'] ??
          '',
      maxCapacity: capacity,
      members:
          memberList is List
              ? memberList.map((m) => MenteeData.fromJson(m)).toList()
              : [],
      scoreDefinitions:
          json['score_definitions'] is Map
              ? Map<String, dynamic>.from(json['score_definitions'])
              : null,
    );
  }
}

class MentorNote {
  final int id;
  final String title;
  final String content;
  final String createdAt;
  final String studentName;

  MentorNote({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.studentName,
  });

  factory MentorNote.fromJson(Map<String, dynamic> json) {
    String studentName = '';
    if (json['student'] is Map) {
      studentName = json['student']['nama'] ?? json['student']['name'] ?? '';
    } else if (json['student_name'] != null) {
      studentName = json['student_name'].toString();
    } else if (json['nama_mahasiswa'] != null) {
      studentName = json['nama_mahasiswa'].toString();
    }

    return MentorNote(
      id: json['id'] ?? json['ID'] ?? 0,
      title: json['title'] ?? json['judul'] ?? json['judul_catatan'] ?? '',
      content:
          json['content'] ??
          json['notes'] ??
          json['catatan'] ??
          json['isi'] ??
          '',
      createdAt:
          json['created_at'] ??
          json['createdAt'] ??
          json['tanggal'] ??
          json['assessed_at'] ??
          '',
      studentName: studentName,
    );
  }
}

class MentorEssayItem {
  final int id;
  final String studentName;
  final String nim;
  final String question;
  final String answer;
  final String status;
  final double? score;
  final double maxScore;
  final String submittedAt;
  final String? feedback;

  MentorEssayItem({
    required this.id,
    required this.studentName,
    required this.nim,
    required this.question,
    required this.answer,
    required this.status,
    this.score,
    this.maxScore = 25.0,
    required this.submittedAt,
    this.feedback,
  });

  factory MentorEssayItem.fromJson(Map<String, dynamic> json) {
    String studentName = '';
    String nim = '';
    if (json['student'] is Map) {
      studentName = json['student']['nama'] ?? json['student']['name'] ?? '';
      nim = json['student']['nim'] ?? json['student']['NIM'] ?? '';
    } else {
      studentName =
          json['student_name'] ?? json['nama_mahasiswa'] ?? json['nama'] ?? '';
      nim = json['nim'] ?? json['NIM'] ?? '';
    }

    final qText = json['question_text'] ?? json['question'] ?? json['pertanyaan'] ?? json['soal'] ?? json['text'] ?? '';
    final aText = json['student_answer'] ?? json['answer_text'] ?? json['answer'] ?? json['jawaban'] ?? json['response'] ?? '';
    final scoreVal = json['score'] ?? json['nilai'] ?? json['point'];
    final feedbackText = json['grading_notes'] ?? json['feedback'] ?? json['catatan'] ?? json['notes'] ?? '';
    final maxScoreVal = json['max_score'] ?? json['maxScore'] ?? 25;

    return MentorEssayItem(
      id: json['answer_id'] ?? json['id'] ?? json['ID'] ?? json['essay_id'] ?? json['submission_id'] ?? 0,
      studentName: studentName.toString(),
      nim: nim.toString(),
      question: qText.toString(),
      answer: aText.toString(),
      status: json['grading_status']?.toString() ?? json['status']?.toString() ?? (scoreVal != null ? 'graded' : 'pending'),
      score: scoreVal != null ? double.tryParse(scoreVal.toString()) : null,
      maxScore: double.tryParse(maxScoreVal.toString()) ?? 25.0,
      submittedAt: json['submitted_at'] ?? json['created_at'] ?? json['tanggal'] ?? '',
      feedback: feedbackText.toString(),
    );
  }
}

class MentorMaterial {
  final int id;
  final String title;
  final String description;
  final String category;
  final String fileUrl;
  final String uploadedAt;

  MentorMaterial({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.fileUrl,
    required this.uploadedAt,
  });

  factory MentorMaterial.fromJson(Map<String, dynamic> json) {
    return MentorMaterial(
      id: json['id'] ?? json['ID'] ?? 0,
      title: json['title'] ?? json['judul'] ?? '',
      description: json['description'] ?? json['deskripsi'] ?? '',
      category: json['category'] ?? json['kategori'] ?? '',
      fileUrl: json['file_url'] ?? json['fileUrl'] ?? '',
      uploadedAt: json['uploaded_at'] ?? json['created_at'] ?? '',
    );
  }
}

class MentorHandbookDetail {
  final int id;
  final int studentId;
  final String studentName;
  final String status;
  final String feedback;
  final String submittedAt;
  final String reviewedAt;
  final Map<String, dynamic>? contentJson;

  MentorHandbookDetail({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.status,
    required this.feedback,
    required this.submittedAt,
    required this.reviewedAt,
    this.contentJson,
  });

  factory MentorHandbookDetail.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parsedContent;
    if (json['content_json'] != null) {
      if (json['content_json'] is String) {
        try {
          final decoded = jsonDecode(json['content_json']);
          if (decoded is Map) {
            parsedContent = Map<String, dynamic>.from(decoded);
          }
        } catch (_) {}
      } else if (json['content_json'] is Map) {
        parsedContent = Map<String, dynamic>.from(json['content_json']);
      }
    }

    String studentName = '';
    if (json['student'] is Map) {
      studentName = json['student']['nama'] ?? json['student']['name'] ?? '';
    } else {
      studentName = json['student_name'] ?? json['nama_mahasiswa'] ?? '';
    }

    return MentorHandbookDetail(
      id: json['id'] ?? json['ID'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentName: studentName.toString(),
      status: json['status'] ?? 'not_started',
      feedback: json['feedback'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      reviewedAt: json['reviewed_at'] ?? '',
      contentJson: parsedContent,
    );
  }
}

class MentorSessionScore {
  final int studentId;
  final String studentName;
  final String nim;
  final List<MentorScoreItem> items;
  final double totalScore;

  MentorSessionScore({
    required this.studentId,
    required this.studentName,
    required this.nim,
    required this.items,
    required this.totalScore,
  });

  factory MentorSessionScore.fromJson(Map<String, dynamic> json) {
    String studentName = '';
    String nim = '';
    if (json['student'] is Map) {
      studentName = json['student']['nama'] ?? json['student']['name'] ?? '';
      nim = json['student']['nim'] ?? json['student']['NIM'] ?? '';
    } else {
      studentName =
          json['student_name'] ?? json['nama_mahasiswa'] ?? json['nama'] ?? '';
      nim = json['nim'] ?? json['NIM'] ?? '';
    }

    final itemsList = json['items'] ?? json['scores'] ?? [];
    final parsedItems =
        itemsList is List
            ? itemsList.map((e) => MentorScoreItem.fromJson(e)).toList()
            : <MentorScoreItem>[];

    return MentorSessionScore(
      studentId: json['student_id'] ?? json['id'] ?? 0,
      studentName: studentName.toString(),
      nim: nim.toString(),
      items: parsedItems,
      totalScore:
          double.tryParse(
            (json['total_score'] ?? json['totalScore'] ?? json['score'] ?? 0)
                .toString(),
          ) ??
          0.0,
    );
  }
}

class MentorScoreItem {
  final String component;
  final String itemName;
  final double score;
  final String notes;

  MentorScoreItem({
    required this.component,
    required this.itemName,
    required this.score,
    required this.notes,
  });

  factory MentorScoreItem.fromJson(Map<String, dynamic> json) {
    return MentorScoreItem(
      component: json['component'] ?? json['kategori'] ?? '',
      itemName: json['item_name'] ?? json['nama_item'] ?? '',
      score:
          double.tryParse((json['score'] ?? json['nilai'] ?? 0).toString()) ??
          0.0,
      notes: json['notes'] ?? json['catatan'] ?? '',
    );
  }
}

class MentorAttendanceStudent {
  final int studentId;
  final String name;
  final String nim;
  final String status;
  final String? note;

  MentorAttendanceStudent({
    required this.studentId,
    required this.name,
    required this.nim,
    required this.status,
    this.note,
  });

  factory MentorAttendanceStudent.fromJson(Map<String, dynamic> json) {
    String name = '';
    String nim = '';
    int sid = 0;
    if (json['student'] is Map) {
      name = json['student']['nama'] ?? json['student']['name'] ?? '';
      nim = json['student']['nim'] ?? json['student']['NIM'] ?? '';
      sid = json['student']['id'] ?? 0;
    } else {
      name = json['student_name'] ?? json['name'] ?? json['nama'] ?? '';
      nim = json['nim'] ?? json['NIM'] ?? '';
      sid = json['student_id'] ?? json['id'] ?? 0;
    }

    return MentorAttendanceStudent(
      studentId: sid,
      name: name.toString(),
      nim: nim.toString(),
      status: json['status'] ?? json['Status'] ?? 'absent',
      note: json['note']?.toString(),
    );
  }
}

class BandingModel {
  final int id;
  final String studentName;
  final String studentNim;
  final String type;
  final String reason;
  final String status;
  final String? adminResponse;
  final String? createdAt;

  BandingModel({
    required this.id,
    required this.studentName,
    required this.studentNim,
    required this.type,
    required this.reason,
    required this.status,
    this.adminResponse,
    this.createdAt,
  });

  factory BandingModel.fromJson(Map<String, dynamic> json) {
    final student = json['student'] ?? {};
    return BandingModel(
      id: json['id'] ?? 0,
      studentName: student['Nama'] ?? student['nama'] ?? '-',
      studentNim: student['NIM'] ?? student['nim'] ?? '-',
      type: json['type'] ?? 'fakultas',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      adminResponse: json['admin_response'],
      createdAt: json['created_at'],
    );
  }
}

class BandingScoreItemModel {
  final int id;
  final String itemName;
  final double score;
  final double? maxScore;
  final double? weight;

  BandingScoreItemModel({
    required this.id,
    required this.itemName,
    required this.score,
    this.maxScore,
    this.weight,
  });

  factory BandingScoreItemModel.fromJson(Map<String, dynamic> json) {
    double parseDoubleStrict(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return BandingScoreItemModel(
      id: json['id'] ?? 0,
      itemName: json['item_name'] ?? json['ItemName'] ?? '',
      score: parseDoubleStrict(json['score'] ?? json['Score']),
      maxScore: parseDoubleStrict(json['max_score'] ?? json['MaxScore'] ?? 100),
      weight: parseDoubleStrict(json['weight'] ?? json['Weight']),
    );
  }
}

class SessionAttendanceData {
  final int id;
  final String nim;
  final String name;
  final String programStudi;
  final String faculty;
  final String status; // Hadir, Izin, Sakit, Alpha, Pending
  final String originalStatus;
  final String reason;
  final String attachmentUrl;

  SessionAttendanceData({
    required this.id,
    required this.nim,
    required this.name,
    required this.programStudi,
    required this.faculty,
    required this.status,
    this.originalStatus = '',
    this.reason = '',
    this.attachmentUrl = '',
  });

  factory SessionAttendanceData.fromJson(Map<String, dynamic> json) {
    String nameValue = '';
    String nimValue = '';
    String prodiValue = '';
    String facultyValue = '';

    if (json['student'] is Map) {
      final st = json['student'];
      nameValue = st['nama'] ?? st['name'] ?? '';
      nimValue = st['nim'] ?? st['NIM'] ?? '';
      
      if (st['program_studi'] is Map) {
        prodiValue = st['program_studi']['nama'] ?? st['program_studi']['name'] ?? '';
      } else {
        prodiValue = st['program_studi']?.toString() ?? st['prodi']?.toString() ?? '';
      }

      if (st['fakultas'] is Map) {
        facultyValue = st['fakultas']['nama'] ?? st['fakultas']['name'] ?? '';
      } else {
        facultyValue = st['fakultas']?.toString() ?? st['faculty']?.toString() ?? '';
      }
    } else {
      nameValue = json['name'] ?? json['nama'] ?? '';
      nimValue = json['nim'] ?? json['NIM'] ?? '';
      prodiValue = json['program_studi'] ?? json['prodi'] ?? '';
      facultyValue = json['faculty'] ?? json['fakultas'] ?? '';
    }

    String statusStr = 'Alpha';
    final rawStatus = (json['status'] ?? json['attendance_status'] ?? '').toString().toLowerCase();
    final isAttended = json['is_attended'] == true || 
                       json['is_attended'] == 1 || 
                       json['scanned_at'] != null || 
                       json['attended_at'] != null || 
                       json['qr_scanned'] == true || 
                       json['qr_scanned'] == 1;

    if (isAttended || rawStatus == 'hadir' || rawStatus == 'present' || rawStatus == 'attended' || rawStatus == '1' || rawStatus == 'true') {
      statusStr = 'Hadir';
    } else if (rawStatus == 'izin' || rawStatus == 'sakit' || rawStatus.contains('izin') || rawStatus.contains('sakit')) {
      statusStr = 'Izin';
    } else if (rawStatus == 'alpha' || rawStatus == 'absent' || rawStatus == '0' || rawStatus == 'false') {
      statusStr = 'Alpha';
    } else if (rawStatus.isNotEmpty) {
      statusStr = rawStatus[0] + rawStatus.substring(1);
    }

    return SessionAttendanceData(
      id: json['id'] ?? json['student_id'] ?? 0,
      name: nameValue,
      nim: nimValue,
      programStudi: prodiValue,
      faculty: facultyValue,
      status: statusStr,
      originalStatus: rawStatus,
      reason: json['reason']?.toString() ?? '',
      attachmentUrl: json['attachment_url']?.toString() ?? json['file_url']?.toString() ?? '',
    );
  }
}

class SessionMaterialItem {
  final int id;
  final String title;
  final String description;
  final String fileUrl;
  final String component;
  final String status;
  final String submissionType;
  final String dueDate;
  final String startDate;
  final bool isRequired;

  SessionMaterialItem({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrl,
    required this.component,
    required this.status,
    this.submissionType = 'LINK URL',
    this.dueDate = '',
    this.startDate = '',
    this.isRequired = true,
  });

  factory SessionMaterialItem.fromJson(Map<String, dynamic> json) {
    return SessionMaterialItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['judul'] ?? json['nama'] ?? '',
      description: json['description'] ?? json['instruction'] ?? json['instruksi'] ?? '',
      fileUrl: json['file_url'] ?? json['fileUrl'] ?? json['file_path'] ?? json['file'] ?? '',
      component: json['component'] ?? json['komponen'] ?? 'Psikomotor',
      status: json['status'] ?? json['status_label'] ?? 'DITERBITKAN',
      submissionType: json['submission_type'] ?? json['tipe_pengumpulan'] ?? json['type'] ?? 'LINK URL',
      dueDate: json['due_date'] ?? json['tenggat_waktu'] ?? json['deadline'] ?? '',
      startDate: json['start_date'] ?? json['startDate'] ?? json['mulai'] ?? '',
      isRequired: json['is_required'] == null ? true : (json['is_required'] == true || json['is_required'] == 1),
    );
  }
}

class SessionMaterialData {
  final int id;
  final String title;
  final String description;
  final String stageType;
  final String status;
  final bool isRequired;
  final String startDate;
  final String endDate;
  final List<SessionMaterialItem> materials;
  final List<SessionMaterialItem> quizzes;
  final List<SessionMaterialItem> assignments;

  SessionMaterialData({
    required this.id,
    required this.title,
    required this.description,
    required this.stageType,
    required this.status,
    required this.isRequired,
    required this.startDate,
    required this.endDate,
    required this.materials,
    required this.quizzes,
    required this.assignments,
  });

  factory SessionMaterialData.fromJson(Map<String, dynamic> json) {
    final stageObj = json['stage'] is Map ? json['stage'] : {};
    final stageTypeValue = stageObj['type'] ?? json['stage_type'] ?? 'pra_kencana';

    final mats = (json['materials'] as List?)?.map((e) => SessionMaterialItem.fromJson(e)).toList() ?? [];
    final qzs = (json['quizzes'] as List?)?.map((e) => SessionMaterialItem.fromJson(e)).toList() ?? [];
    final assns = (json['assignments'] as List?)?.map((e) => SessionMaterialItem.fromJson(e)).toList() ?? [];

    return SessionMaterialData(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      stageType: stageTypeValue.toString(),
      status: json['status'] ?? 'active',
      isRequired: json['is_required'] == true || json['is_required'] == 1,
      startDate: json['start_date'] ?? json['startDate'] ?? '',
      endDate: json['end_date'] ?? json['endDate'] ?? '',
      materials: mats,
      quizzes: qzs,
      assignments: assns,
    );
  }
}

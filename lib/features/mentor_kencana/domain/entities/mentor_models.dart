import 'dart:convert';

class MentorDashboardData {
  final int totalMentees;
  final int totalGroups;
  final int pendingScoring;
  final int unreadAnnouncements;

  MentorDashboardData({
    required this.totalMentees,
    required this.totalGroups,
    required this.pendingScoring,
    required this.unreadAnnouncements,
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
  final String faculty;
  final String status;
  final double score;
  final String? avatarUrl;

  MenteeData({
    required this.id,
    required this.name,
    required this.nim,
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

  AvailableStudentData({
    required this.id,
    required this.name,
    required this.nim,
    required this.faculty,
  });

  factory AvailableStudentData.fromJson(Map<String, dynamic> json) {
    return AvailableStudentData(
      id: json['id'] ?? json['ID'] ?? 0,
      name: json['name'] ?? json['nama'] ?? json['Nama'] ?? '',
      nim: json['nim'] ?? json['NIM'] ?? '',
      faculty: json['faculty'] ?? json['fakultas'] ?? json['Fakultas'] ?? '',
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

  AbsenceRequestData({
    required this.id,
    required this.studentName,
    required this.nim,
    required this.sessionTitle,
    required this.reason,
    required this.date,
    required this.status,
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

  MentorGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.createdAt,
  });

  factory MentorGroup.fromJson(Map<String, dynamic> json) {
    final memberList =
        json['members'] ??
        json['mentees'] ??
        json['mahasiswa'] ??
        json['member_count_list'];
    int count = json['member_count'] ?? json['jumlah_anggota'] ?? 0;
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
      createdAt:
          json['created_at'] ??
          json['createdAt'] ??
          json['tanggal_dibuat'] ??
          '',
    );
  }
}

class MentorGroupDetail {
  final int id;
  final String name;
  final List<MenteeData> members;
  final Map<String, dynamic>? scoreDefinitions;

  MentorGroupDetail({
    required this.id,
    required this.name,
    required this.members,
    this.scoreDefinitions,
  });

  factory MentorGroupDetail.fromJson(Map<String, dynamic> json) {
    final memberList =
        json['members'] ??
        json['mentees'] ??
        json['mahasiswa'] ??
        [];
    return MentorGroupDetail(
      id: json['id'] ?? json['ID'] ?? 0,
      name:
          json['name'] ??
          json['nama'] ??
          json['group_name'] ??
          json['Nama'] ??
          '',
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
      studentName =
          json['student']['nama'] ?? json['student']['name'] ?? '';
    } else if (json['student_name'] != null) {
      studentName = json['student_name'].toString();
    } else if (json['nama_mahasiswa'] != null) {
      studentName = json['nama_mahasiswa'].toString();
    }

    return MentorNote(
      id: json['id'] ?? json['ID'] ?? 0,
      title:
          json['title'] ??
          json['judul'] ??
          json['judul_catatan'] ??
          '',
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
  final String submittedAt;

  MentorEssayItem({
    required this.id,
    required this.studentName,
    required this.nim,
    required this.question,
    required this.answer,
    required this.status,
    this.score,
    required this.submittedAt,
  });

  factory MentorEssayItem.fromJson(Map<String, dynamic> json) {
    String studentName = '';
    String nim = '';
    if (json['student'] is Map) {
      studentName =
          json['student']['nama'] ?? json['student']['name'] ?? '';
      nim = json['student']['nim'] ?? json['student']['NIM'] ?? '';
    } else {
      studentName =
          json['student_name'] ??
          json['nama_mahasiswa'] ??
          json['nama'] ??
          '';
      nim = json['nim'] ?? json['NIM'] ?? '';
    }

    return MentorEssayItem(
      id: json['id'] ?? json['ID'] ?? 0,
      studentName: studentName.toString(),
      nim: nim.toString(),
      question:
          json['question'] ??
          json['pertanyaan'] ??
          json['soal'] ??
          '',
      answer:
          json['answer'] ??
          json['jawaban'] ??
          json['answer_text'] ??
          '',
      status: json['status'] ?? 'pending',
      score:
          json['score'] != null
              ? double.tryParse(json['score'].toString())
              : null,
      submittedAt:
          json['submitted_at'] ??
          json['created_at'] ??
          json['tanggal'] ??
          '',
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
      studentName = json['student_name'] ?? json['nama_mahasiswa'] ?? json['nama'] ?? '';
      nim = json['nim'] ?? json['NIM'] ?? '';
    }

    final itemsList = json['items'] ?? json['scores'] ?? [];
    final parsedItems = itemsList is List
        ? itemsList.map((e) => MentorScoreItem.fromJson(e)).toList()
        : <MentorScoreItem>[];

    return MentorSessionScore(
      studentId: json['student_id'] ?? json['id'] ?? 0,
      studentName: studentName.toString(),
      nim: nim.toString(),
      items: parsedItems,
      totalScore: double.tryParse(
        (json['total_score'] ?? json['totalScore'] ?? json['score'] ?? 0).toString(),
      ) ?? 0.0,
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
      score: double.tryParse((json['score'] ?? json['nilai'] ?? 0).toString()) ?? 0.0,
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
      name =
          json['student']['nama'] ?? json['student']['name'] ?? '';
      nim = json['student']['nim'] ?? json['student']['NIM'] ?? '';
      sid = json['student']['id'] ?? 0;
    } else {
      name =
          json['student_name'] ??
          json['name'] ??
          json['nama'] ??
          '';
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

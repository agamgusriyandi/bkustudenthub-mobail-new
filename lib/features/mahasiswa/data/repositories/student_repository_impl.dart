import '../../domain/entities/achievement.dart';
import '../../domain/entities/scholarship.dart';
import '../../domain/entities/mission.dart';
import '../../domain/entities/counseling_session.dart';
import '../../domain/entities/aspiration.dart';
import '../../domain/entities/health_record.dart';
import '../../domain/entities/organization_history.dart';
import '../../domain/entities/campus_news.dart';
import '../../domain/entities/faculty_progress.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/pkkmb_event.dart';
import '../../domain/entities/campus_event_schedule.dart';
import 'package:bkuhub_mobile/features/counseling/domain/entities/psychologist.dart';
import '../../domain/entities/health_booking.dart';
import '../../domain/entities/insurance_claim.dart';
import '../../data/models/achievement_model.dart';
import '../../data/models/scholarship_model.dart';
import '../../data/models/counseling_session_model.dart';
import '../../data/models/aspiration_model.dart';
import '../../data/models/health_record_model.dart';
import '../../data/models/organization_history_model.dart';
import '../models/health_booking_model.dart';
import '../models/insurance_claim_model.dart';
import 'package:bkuhub_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer';

class StudentRepositoryImpl implements StudentRepository {
  final ApiClient apiClient;

  StudentRepositoryImpl({required this.apiClient});

  @override
  Future<List<Achievement>> getAchievements() async {
    try {
      final response = await apiClient.client.get('/achievement/');
      final rawData = response.data['data'];
      final List list = (rawData is Map ? rawData['list'] : rawData) ?? [];
      return list
          .map<Achievement>((json) => AchievementModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error getting achievements: $e');
      throw Exception('Gagal memuat data prestasi');
    }
  }

  @override
  Future<List<Scholarship>> getScholarships() async {
    try {
      final response = await apiClient.client.get('/scholarship/');
      final List data = response.data['data'] ?? [];
      final List<Scholarship> list =
          data
              .map<Scholarship>((json) => ScholarshipModel.fromJson(json))
              .toList();

      try {
        final riwayatResponse = await apiClient.client.get(
          '/scholarship/riwayat',
        );
        final List riwayatData = riwayatResponse.data['data'] ?? [];
        for (final item in riwayatData) {
          if (item is Map<String, dynamic>) {
            final parsedApplied = _parseBeasiswaPendaftaran(item);
            if (parsedApplied.id.isNotEmpty) {
              final index = list.indexWhere((s) => s.id == parsedApplied.id);
              if (index != -1) {
                list[index] = parsedApplied;
              } else {
                list.add(parsedApplied);
              }
            }
          }
        }
      } catch (riwayatError) {
        log('Error fetching scholarship history: $riwayatError');
      }

      log('SCHOLARSHIP_MERGED_RESPONSE: $list');
      return list;
    } catch (e) {
      log('Error getting scholarships: $e');
      throw Exception('Gagal memuat katalog beasiswa');
    }
  }

  ScholarshipModel _parseBeasiswaPendaftaran(Map<String, dynamic> json) {
    final beasiswaJson = json['Beasiswa'] ?? json['beasiswa'] ?? {};
    final id =
        beasiswaJson['id']?.toString() ??
        json['BeasiswaID']?.toString() ??
        json['beasiswa_id']?.toString() ??
        '';

    String deadlineStr = '';
    if (beasiswaJson['deadline'] != null) {
      try {
        final dt = DateTime.parse(beasiswaJson['deadline'].toString());
        deadlineStr =
            '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      } catch (_) {
        deadlineStr = beasiswaJson['deadline'].toString();
      }
    }

    final applicationStatus = json['Status'] ?? json['status'] ?? 'Menunggu';

    return ScholarshipModel(
      id: id,
      title: beasiswaJson['nama'] ?? beasiswaJson['Nama'] ?? '',
      provider:
          beasiswaJson['penyelenggara'] ?? beasiswaJson['Penyelenggara'] ?? '',
      category: beasiswaJson['kategori'] ?? beasiswaJson['Kategori'] ?? '',
      deadline: deadlineStr,
      coverAmount:
          (beasiswaJson['nilai_bantuan'] ?? beasiswaJson['NilaiBantuan'] ?? 0)
              .toString(),
      description: beasiswaJson['deskripsi'] ?? beasiswaJson['Deskripsi'] ?? '',
      status: 'Applied',
      applicationStatus: applicationStatus,
      kuota:
          beasiswaJson['kuota']?.toString() ??
          beasiswaJson['Kuota']?.toString(),
      minIpk:
          beasiswaJson['ipk_min']?.toString() ??
          beasiswaJson['IPKMin']?.toString(),
      motivasi: json['motivasi'] ?? json['Motivasi'],
      ktmKtpUrl: json['ktm_ktp_url'] ?? json['KtmKtpURL'],
      sertifikatUrl: json['sertifikat_url'] ?? json['SertifikatURL'],
      transkripUrl: json['transkrip_url'] ?? json['TranskripURL'],
      persyaratan: beasiswaJson['persyaratan'] ?? beasiswaJson['Persyaratan'],
      fileKtm:
          beasiswaJson['file_ktm']?.toString() ??
          beasiswaJson['FileKtm']?.toString() ??
          'wajib',
      fileTranskrip:
          beasiswaJson['file_transkrip']?.toString() ??
          beasiswaJson['FileTranskrip']?.toString() ??
          'wajib',
      fileSertifikat:
          beasiswaJson['file_sertifikat']?.toString() ??
          beasiswaJson['FileSertifikat']?.toString() ??
          'opsional',
      customFieldsRaw:
          beasiswaJson['custom_fields'] ?? beasiswaJson['CustomFields'],
      customAnswersRaw: json['custom_answers'] ?? json['CustomAnswers'],
      skema:
          beasiswaJson['skema']?.toString() ??
          beasiswaJson['Skema']?.toString(),
    );
  }

  @override
  Future<List<Mission>> getMissions() async {
    try {
      final response = await apiClient.client.get('/kencana/progress');
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null && data['tahaps'] != null) {
          final List<Mission> missionsList = [];
          final tahaps = data['tahaps'] as List;
          for (var t in tahaps) {
            final label = t['label']?.toString() ?? '';
            final materis = t['materis'] as List?;
            if (materis != null) {
              for (var m in materis) {
                // Add material module
                missionsList.add(
                  Mission(
                    id: m['materi_id']?.toString() ?? '',
                    title: m['judul']?.toString() ?? '',
                    desc: m['deskripsi']?.toString() ?? 'Baca & Pelajari Modul',
                    stage: label,
                    type: 'Module',
                    isCompleted:
                        true, // Materials seeded are initially set as completed
                  ),
                );

                // Add quiz if present
                final kuis = m['kuis'];
                if (kuis != null) {
                  final kuisStatus =
                      kuis['status']?.toString() ?? 'belum_dikerjakan';
                  final double kuisScore =
                      double.tryParse(
                        (kuis['nilai_terbaik'] ?? '0').toString(),
                      ) ??
                      0.0;
                  missionsList.add(
                    Mission(
                      id: kuis['kuis_id']?.toString() ?? '',
                      title: kuis['judul_kuis']?.toString() ?? 'Kuis Evaluasi',
                      desc: 'Selesaikan kuis untuk menguji pemahaman.',
                      stage: label,
                      type: 'Quiz',
                      score: kuisScore.toInt(),
                      isCompleted: kuisStatus == 'lulus',
                    ),
                  );
                }
              }
            }
          }
          return missionsList;
        }
      }
      return [];
    } catch (e) {
      log('Error getting missions: $e');
      return [];
    }
  }

  @override
  Future<List<PkkmbEvent>> getPkkmbEvents() async {
    try {
      final response = await apiClient.client.get('/kencana/kegiatan');
      final List data = response.data['data'] ?? [];
      return data.map((json) => PkkmbEvent.fromJson(json)).toList();
    } catch (e) {
      log('Error getting pkkmb events: $e');
      return [];
    }
  }

  @override
  Future<List<CampusEventSchedule>> getCampusEvents() async {
    try {
      final response = await apiClient.client.get('/mahasiswa/kegiatan');
      final List data = response.data['data'] ?? [];
      return data.map((json) => CampusEventSchedule.fromJson(json)).toList();
    } catch (e) {
      log('Error getting campus events: $e');
      return [];
    }
  }

  @override
  Future<List<CampusNews>> getCampusNews() async {
    try {
      final response = await apiClient.client.get('/mahasiswa/dashboard');
      final List data = response.data['data']?['pengumuman'] ?? [];
      return data.map((json) => CampusNews.fromJson(json)).toList();
    } catch (e) {
      log('Error getting campus news: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await apiClient.client.get('/mahasiswa/dashboard');
      return response.data['data'] ?? {};
    } catch (e) {
      log('Error getting dashboard stats: $e');
      return {};
    }
  }

  @override
  Future<List<CounselingSession>> getCounselingSessions() async {
    try {
      final response = await apiClient.client.get(
        '/counseling/psychologist-bookings',
      );
      final List data = response.data['data'] ?? [];
      return data
          .map<CounselingSession>(
            (json) => CounselingSessionModel.fromJson(json),
          )
          .toList();
    } catch (e) {
      log('Error getting counseling sessions: $e');
      return [];
    }
  }

  @override
  Future<List<FacultyProgress>> getFacultyStatistics() async {
    try {
      final response = await apiClient.client.get(
        '/counseling/faculty-statistics',
      );
      final List data = response.data['data'] ?? [];
      return data.map((json) => FacultyProgress.fromJson(json)).toList();
    } catch (e) {
      log('Error getting faculty statistics from backend: $e');
      return [];
    }
  }

  @override
  Future<List<Psychologist>> getPsychologists() async {
    try {
      final response = await apiClient.client.get('/counseling/psychologists');
      final List data = response.data['data'] ?? [];
      return data.map((json) => Psychologist.fromJson(json)).toList();
    } catch (e) {
      log('Error getting psychologists from backend: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPsychologistSchedules(
    String psychologistId,
  ) async {
    try {
      final response = await apiClient.client.get(
        '/counseling/psychologists/$psychologistId/schedules',
      );
      final raw = response.data['data'];
      final List list = (raw is Map ? raw['slots'] : []) ?? [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      log('Error getting psychologist schedules from backend: $e');
      return [];
    }
  }

  @override
  Future<List<Aspiration>> getAspirations() async {
    try {
      final response = await apiClient.client.get('/student-voice/');
      final rawData = response.data['data'];
      final List list = (rawData is Map ? rawData['list'] : rawData) ?? [];
      return list
          .map<Aspiration>((json) => AspirationModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error getting aspirations: $e');
      throw Exception('Gagal memuat aspirasi');
    }
  }

  @override
  Future<Aspiration> getAspirationDetail(String id) async {
    try {
      final response = await apiClient.client.get('/student-voice/$id');
      final data = response.data['data'];
      return AspirationModel.fromJson(data);
    } catch (e) {
      log('Error getting aspiration detail: $e');
      throw Exception('Gagal memuat detail aspirasi');
    }
  }

  @override
  Future<List<HealthRecord>> getHealthRecords() async {
    try {
      final response = await apiClient.client.get('/student-health/riwayat');
      final List data = response.data['data'] ?? [];
      return data
          .map<HealthRecord>((json) => HealthRecordModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error getting health records: $e');
      throw Exception('Gagal memuat riwayat kesehatan');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRujukans() async {
    try {
      final response = await apiClient.client.get('/mahasiswa/rujukan');
      final rawData = response.data['data'];
      final List list = rawData is List ? rawData : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      log('Error getting rujukans: $e');
      return [];
    }
  }

  @override
  Future<void> addAchievement(Achievement achievement) async {
    try {
      final model = AchievementModel(
        id: achievement.id,
        title: achievement.title,
        organizer: achievement.organizer,
        level: achievement.level,
        rank: achievement.rank,
        date: achievement.date,
        status: achievement.status,
        certificateUrl: achievement.certificateUrl,
        filePath: achievement.filePath,
        kategori: achievement.kategori,
        tipe: achievement.tipe,
        danaDiajukan: achievement.danaDiajukan,
        cabang: achievement.cabang,
        jumlahUnitPeserta: achievement.jumlahUnitPeserta,
        kelompokPrestasi: achievement.kelompokPrestasi,
        bentuk: achievement.bentuk,
        urlPeserta: achievement.urlPeserta,
        urlFotoUpp: achievement.urlFotoUpp,
        urlDokumenUndangan: achievement.urlDokumenUndangan,
        jenisRekognisi: achievement.jenisRekognisi,
      );

      if (achievement.filePath != null && achievement.filePath!.isNotEmpty) {
        final formData = FormData.fromMap({
          ...model.toJson().map((k, v) => MapEntry(k, v?.toString() ?? '')),
          'bukti': await MultipartFile.fromFile(
            achievement.filePath!,
            filename:
                achievement.filePath!.replaceAll('\\', '/').split('/').last,
          ),
        });
        await apiClient.client.post('/achievement/', data: formData);
      } else {
        await apiClient.client.post('/achievement/', data: model.toJson());
      }
    } catch (e) {
      log('Error adding achievement: $e');
      throw Exception('Gagal menambah prestasi');
    }
  }

  @override
  Future<void> deleteAchievement(String id) async {
    try {
      await apiClient.client.delete('/achievement/$id');
    } catch (e) {
      log('Error deleting achievement: $e');
      if (e is DioException && e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          final msg = data['message'] ?? data['error'];
          if (msg != null) {
            throw Exception(msg.toString());
          }
        }
      }
      throw Exception('Gagal menghapus prestasi');
    }
  }

  @override
  Future<void> updateAchievement(String id, Achievement achievement) async {
    try {
      final model = AchievementModel(
        id: achievement.id,
        title: achievement.title,
        organizer: achievement.organizer,
        level: achievement.level,
        rank: achievement.rank,
        date: achievement.date,
        status: achievement.status,
        certificateUrl: achievement.certificateUrl,
        filePath: achievement.filePath,
        kategori: achievement.kategori,
        tipe: achievement.tipe,
        danaDiajukan: achievement.danaDiajukan,
        cabang: achievement.cabang,
        jumlahUnitPeserta: achievement.jumlahUnitPeserta,
        kelompokPrestasi: achievement.kelompokPrestasi,
        bentuk: achievement.bentuk,
        urlPeserta: achievement.urlPeserta,
        urlFotoUpp: achievement.urlFotoUpp,
        urlDokumenUndangan: achievement.urlDokumenUndangan,
        jenisRekognisi: achievement.jenisRekognisi,
      );

      if (achievement.filePath != null && achievement.filePath!.isNotEmpty) {
        final formData = FormData.fromMap({
          ...model.toJson().map((k, v) => MapEntry(k, v?.toString() ?? '')),
          'bukti': await MultipartFile.fromFile(
            achievement.filePath!,
            filename:
                achievement.filePath!.replaceAll('\\', '/').split('/').last,
          ),
        });
        await apiClient.client.put('/achievement/$id', data: formData);
      } else {
        await apiClient.client.put('/achievement/$id', data: model.toJson());
      }
    } catch (e) {
      log('Error updating achievement: $e');
      if (e is DioException && e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          final msg = data['message'] ?? data['error'];
          if (msg != null) {
            throw Exception(msg.toString());
          }
        }
      }
      throw Exception('Gagal memperbarui prestasi');
    }
  }

  @override
  Future<void> applyForScholarship(
    String scholarshipId,
    String motivasi, {
    String? ktmKtpPath,
    String? sertifikatPath,
    String? transkripPath,
    String? customAnswers,
    String? rubrikAnswers,
  }) async {
    try {
      final map = <String, dynamic>{
        'motivasi': motivasi,
        if (customAnswers != null) 'custom_answers': customAnswers,
        if (rubrikAnswers != null) 'rubrik_answers': rubrikAnswers,
      };
      if (ktmKtpPath == "") {
        map['delete_ktm_ktp'] = 'true';
      } else if (ktmKtpPath != null &&
          ktmKtpPath.isNotEmpty &&
          !ktmKtpPath.startsWith('/uploads') &&
          !ktmKtpPath.startsWith('/storage') &&
          !ktmKtpPath.startsWith('http')) {
        map['ktm_ktp'] = await MultipartFile.fromFile(
          ktmKtpPath,
          filename: ktmKtpPath.replaceAll('\\', '/').split('/').last,
        );
      }
      if (sertifikatPath == "") {
        map['delete_sertifikat'] = 'true';
      } else if (sertifikatPath != null &&
          sertifikatPath.isNotEmpty &&
          !sertifikatPath.startsWith('/uploads') &&
          !sertifikatPath.startsWith('/storage') &&
          !sertifikatPath.startsWith('http')) {
        map['sertifikat'] = await MultipartFile.fromFile(
          sertifikatPath,
          filename: sertifikatPath.replaceAll('\\', '/').split('/').last,
        );
      }
      if (transkripPath == "") {
        map['delete_transkrip'] = 'true';
      } else if (transkripPath != null &&
          transkripPath.isNotEmpty &&
          !transkripPath.startsWith('/uploads') &&
          !transkripPath.startsWith('/storage') &&
          !transkripPath.startsWith('http')) {
        map['transkrip'] = await MultipartFile.fromFile(
          transkripPath,
          filename: transkripPath.replaceAll('\\', '/').split('/').last,
        );
      }

      final formData = FormData.fromMap(map);
      await apiClient.client.post(
        '/scholarship/$scholarshipId/daftar',
        data: formData,
      );
    } catch (e) {
      log('Error applying for scholarship: $e');
      if (e is DioException && e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          String? errorMessage;
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            errorMessage = errors.values
                .map((v) {
                  if (v is List) return v.join('\n');
                  return v.toString();
                })
                .join('\n');
          } else {
            errorMessage = data['message'] ?? data['error'];
          }

          if (errorMessage != null && errorMessage.isNotEmpty) {
            throw Exception(errorMessage);
          }
        }
      }
      throw Exception('Gagal mendaftar beasiswa');
    }
  }

  @override
  Future<void> cancelScholarshipApplication(String scholarshipId) async {
    try {
      await apiClient.client.delete('/scholarship/$scholarshipId/cancel');
    } catch (e) {
      log('Error cancelling scholarship: $e');
      if (e is DioException && e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          final msg = data['message'] ?? data['error'];
          if (msg != null) {
            throw Exception(msg.toString());
          }
        }
      }
      throw Exception('Gagal membatalkan beasiswa');
    }
  }

  @override
  Future<String> uploadCustomFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      final response = await apiClient.client.post(
        '/scholarship/upload-custom',
        data: formData,
      );
      if (response.statusCode == 200) {
        return response.data['file_url'];
      }
      throw Exception('Gagal mengunggah file kustom');
    } catch (e) {
      log('Error uploading custom file: ');
      throw Exception('Gagal mengunggah file kustom');
    }
  }

  @override
  Future<void> submitAspiration(Aspiration aspiration) async {
    try {
      final formData = FormData.fromMap({
        'judul': aspiration.title,
        'isi': aspiration.description,
        'kategori': aspiration.category,
        'tujuan': aspiration.tujuan,
        'is_anonim': aspiration.isAnonim.toString(),
      });

      if (aspiration.attachmentPath != null &&
          aspiration.attachmentPath!.isNotEmpty) {
        formData.files.add(
          MapEntry(
            'lampiran',
            await MultipartFile.fromFile(aspiration.attachmentPath!),
          ),
        );
      }

      await apiClient.client.post('/student-voice/create', data: formData);
    } catch (e) {
      log('Error submitting aspiration: $e');
      throw _parseError(e, 'Gagal mengirim aspirasi');
    }
  }

  @override
  Future<void> addHealthRecord(HealthRecord record) async {
    try {
      final model = HealthRecordModel(
        id: record.id,
        height: record.height,
        weight: record.weight,
        bloodPressure: record.bloodPressure,
        heartRate: record.heartRate,
        temperature: record.temperature,
        date: record.date,
        bloodType: record.bloodType,
        notes: record.notes,
        gulaDarah: record.gulaDarah,
      );
      await apiClient.client.post(
        '/student-health/record',
        data: model.toJson(),
      );
    } catch (e) {
      log('Error adding health record: $e');
      throw _parseError(e, 'Gagal menambah data kesehatan');
    }
  }

  @override
  Future<void> bookCounseling(CounselingSession session) async {
    try {
      final isSpecificPsychologist = session.psychologistId != 'UNASSIGNED';
      if (isSpecificPsychologist) {
        final idParts = session.psychologistId.split(':');
        final psychologistId = int.tryParse(idParts.first);
        final slotId = idParts.length > 1 ? int.tryParse(idParts[1]) : null;

        final timeParts = session.time.split('-');
        final start = timeParts.isNotEmpty ? timeParts.first.trim() : '09:00';
        final end = timeParts.length > 1 ? timeParts[1].trim() : '10:00';

        final Map<String, dynamic> requestData = {
          'psikolog_id': psychologistId,
          'date': session.date.toIso8601String().split('T').first,
          'start': start,
          'end': end,
          'topic': session.topic,
          'complaint': session.notes ?? 'Konseling',
        };
        if (slotId != null) {
          requestData['slot_id'] = slotId;
        }

        await apiClient.client.post(
          '/counseling/psychologist-bookings',
          data: requestData,
        );
      } else {
        await apiClient.client.post(
          '/counseling/request',
          data: {
            'topik': session.topic,
            'tanggal': session.date.toIso8601String(),
          },
        );
      }
    } catch (e) {
      log('Error booking counseling: $e');
      throw _parseError(e, 'Gagal mengajukan konseling');
    }
  }

  @override
  Future<List<OrganizationHistory>> getOrganizationHistory() async {
    try {
      final response = await apiClient.client.get('/organisasi/');
      final List data = response.data['data'] ?? [];
      return data
          .map<OrganizationHistory>(
            (json) => OrganizationHistoryModel.fromJson(json),
          )
          .toList();
    } catch (e) {
      log('Error getting organization history: $e');
      return [];
    }
  }

  @override
  Future<void> addOrganizationHistory(OrganizationHistory org) async {
    try {
      final model = OrganizationHistoryModel(
        id: org.id,
        namaOrganisasi: org.namaOrganisasi,
        tipe: org.tipe,
        jabatan: org.jabatan,
        periodeMulai: org.periodeMulai,
        periodeSelesai: org.periodeSelesai,
        deskripsiKegiatan: org.deskripsiKegiatan,
        apresiasi: org.apresiasi,
        statusVerifikasi: org.statusVerifikasi,
        achievements: org.achievements,
      );
      await apiClient.client.post('/organisasi/', data: model.toJson());
    } catch (e) {
      if (e is DioException) {
        log('DioException response: ${e.response?.data}');
      }
      log('Error adding organization history: $e');
      throw Exception('Gagal menambah riwayat organisasi');
    }
  }

  @override
  Future<void> updateOrganizationHistory(
    String id,
    OrganizationHistory org,
  ) async {
    try {
      final model = OrganizationHistoryModel(
        id: org.id,
        namaOrganisasi: org.namaOrganisasi,
        tipe: org.tipe,
        jabatan: org.jabatan,
        periodeMulai: org.periodeMulai,
        periodeSelesai: org.periodeSelesai,
        deskripsiKegiatan: org.deskripsiKegiatan,
        apresiasi: org.apresiasi,
        statusVerifikasi: org.statusVerifikasi,
        achievements: org.achievements,
      );
      await apiClient.client.put('/organisasi/$id', data: model.toJson());
    } catch (e) {
      log('Error updating organization history: $e');
      throw _parseError(e, 'Gagal memperbarui riwayat organisasi');
    }
  }

  @override
  Future<void> deleteOrganizationHistory(String id) async {
    try {
      await apiClient.client.delete('/organisasi/$id');
    } catch (e) {
      log('Error deleting organization history: $e');
      throw _parseError(e, 'Gagal menghapus riwayat organisasi');
    }
  }

  @override
  Future<String> uploadDokumentasiOrganisasi(String id, String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'dokumentasi': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await apiClient.client.post(
        '/organisasi/riwayat/$id/dokumentasi',
        data: formData,
      );

      return response.data['data']['dokumentasi'] ?? '';
    } catch (e) {
      log('Error uploading organization documentation: $e');
      throw _parseError(e, 'Gagal mengunggah dokumentasi organisasi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrmawaList() async {
    try {
      final response = await apiClient.client.get('/organisasi/ormawa-list');
      final rawData = response.data['data'];
      final List list =
          (rawData is List
              ? rawData
              : (rawData is Map ? rawData['list'] : null)) ??
          [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      log('Error getting ormawa list: $e');
      throw _parseError(e, 'Gagal memuat daftar ormawa');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendaftaranList() async {
    try {
      final response = await apiClient.client.get('/organisasi/pendaftaran');
      final rawData = response.data['data'];
      final List list = rawData is List ? rawData : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      log('Error getting pendaftaran list: $e');
      throw _parseError(e, 'Gagal memuat riwayat pendaftaran');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getOrmawaDivisions(String ormawaId) async {
    try {
      final response = await apiClient.client.get(
        '/organisasi/divisions/$ormawaId',
      );
      final rawData = response.data['data'];
      final List list = rawData is List ? rawData : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      log('Error getting divisions list: $e');
      throw _parseError(e, 'Gagal memuat divisi ormawa');
    }
  }

  @override
  Future<Map<String, dynamic>> getRecruitmentFields(String ormawaId) async {
    try {
      final response = await apiClient.client.get(
        '/organisasi/recruitment-fields/$ormawaId',
      );
      return response.data ?? {};
    } catch (e) {
      log('Error getting recruitment fields: $e');
      throw _parseError(e, 'Gagal memuat detail pendaftaran ormawa');
    }
  }

  @override
  Future<String> uploadRecruitmentFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      final response = await apiClient.client.post(
        '/organisasi/upload-file',
        data: formData,
      );
      if (response.data != null && response.data['success'] == true) {
        return response.data['url'];
      }
      throw Exception(response.data?['message'] ?? 'Gagal mengunggah file');
    } catch (e) {
      log('Error uploading recruitment file: $e');
      throw _parseError(e, 'Gagal mengunggah file lampiran');
    }
  }

  @override
  Future<void> daftarOrmawa({
    required String ormawaId,
    required String alasan,
    String? cvUrl,
    String? divisi,
    String? divisiPilihanDua,
    Map<String, dynamic>? customAnswers,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'ormawa_id': ormawaId,
        'alasan': alasan,
      };
      if (cvUrl != null) body['cv_url'] = cvUrl;
      if (divisi != null) body['divisi'] = divisi;
      if (divisiPilihanDua != null) {
        body['divisi_pilihan_dua'] = divisiPilihanDua;
      }
      if (customAnswers != null) body['custom_answers'] = customAnswers;

      await apiClient.client.post('/organisasi/daftar', data: body);
    } catch (e) {
      log('Error registering ormawa: $e');
      throw _parseError(e, 'Gagal mendaftar ormawa');
    }
  }

  @override
  Future<void> submitAppeal(String alasan) async {
    try {
      await apiClient.client.post('/kencana/banding', data: {'alasan': alasan});
    } catch (e) {
      log('Error submitting appeal: $e');
      throw Exception('Gagal mengajukan banding');
    }
  }

  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiClient.client.get('/profil/');
      final data = response.data['data'] ?? {};

      try {
        final authResponse = await apiClient.client.get('/auth/me');
        log('AUTH ME RESPONSE: ${authResponse.data}');
        final userData =
            authResponse.data['data']?['user'] ??
            authResponse.data['user'] ??
            {};
        if (userData['avatar_url'] != null) {
          data['avatar_url'] = userData['avatar_url'];
        }
        if (userData['avatar'] != null) {
          data['avatar'] = userData['avatar'];
        }
        if (userData['foto'] != null) {
          data['foto'] = userData['foto'];
        }
        if (userData['email'] != null) {
          data['email'] = userData['email'];
        }
      } catch (_) {
        // Abaikan jika auth/me gagal
      }

      return data;
    } catch (e) {
      log('Error getting profile: $e');
      throw Exception('Gagal memuat profil');
    }
  }

  @override
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      await apiClient.client.put('/profil/data-diri', data: data);
    } catch (e) {
      log('Error updating profile: $e');
      throw _parseError(e, 'Gagal memperbarui profil');
    }
  }

  @override
  Future<void> changePassword(
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await apiClient.client.put(
        '/profil/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
    } catch (e) {
      log('Error changing password: $e');
      throw _parseError(e, 'Gagal mengubah password');
    }
  }

  @override
  Future<String> uploadAvatar(String filePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      final formData = FormData.fromMap({
        'foto': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      final response = await apiClient.client.post(
        '/auth/profile/upload-avatar',
        data: formData,
        options: Options(
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      log('Upload Avatar Response Data: ${response.data}');

      return response.data['url'] ??
          response.data['foto_url'] ??
          response.data['file_url'] ??
          '';
    } catch (e) {
      log('Error uploading avatar: $e');
      throw _parseError(e, 'Gagal mengunggah foto');
    }
  }

  @override
  Future<List<HealthWorker>> getHealthWorkers() async {
    try {
      final response = await apiClient.client.get(
        '/student-health/health-workers',
      );
      final List data = response.data['data'] ?? [];
      final List<HealthWorker> list =
          data
              .where((json) {
                final role = json['role']?.toString().toLowerCase() ?? '';
                final nama =
                    json['nama']?.toString().toLowerCase() ??
                    json['Nama']?.toString().toLowerCase() ??
                    '';
                final email =
                    json['email']?.toString().toLowerCase() ??
                    json['Email']?.toString().toLowerCase() ??
                    '';
                final spes =
                    json['spesialisasi']?.toString().toLowerCase() ??
                    json['Spesialisasi']?.toString().toLowerCase() ??
                    '';

                return !role.contains('superadmin') &&
                    !nama.contains('superadmin') &&
                    !email.contains('superadmin') &&
                    !spes.contains('superadmin');
              })
              .map<HealthWorker>((json) => HealthWorkerModel.fromJson(json))
              .toList();
      return list;
    } catch (e) {
      log('Error getting health workers: $e');
      throw _parseError(e, 'Gagal memuat daftar tenaga kesehatan');
    }
  }

  @override
  Future<List<HealthSchedule>> getHealthSchedules() async {
    try {
      final response = await apiClient.client.get(
        '/student-health/health-worker-schedules',
      );
      final List data = response.data['data'] ?? [];
      final List<HealthSchedule> list =
          data
              .map<HealthSchedule>((json) => HealthScheduleModel.fromJson(json))
              .toList();
      return list.where((s) {
        final workerName = s.tenagaKes?.nama.toLowerCase() ?? '';
        final workerEmail = s.tenagaKes?.email.toLowerCase() ?? '';
        return !workerName.contains('superadmin') &&
            !workerEmail.contains('superadmin');
      }).toList();
    } catch (e) {
      log('Error getting health schedules: $e');
      throw _parseError(e, 'Gagal memuat jadwal klinik');
    }
  }

  @override
  Future<List<HealthBooking>> getHealthBookings() async {
    try {
      final response = await apiClient.client.get('/student-health/bookings');
      final List data = response.data['data'] ?? [];
      return data
          .map<HealthBooking>((json) => HealthBookingModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error getting health bookings: $e');
      throw _parseError(e, 'Gagal memuat riwayat booking klinik');
    }
  }

  @override
  Future<void> createHealthBooking({
    required int scheduleId,
    required String keluhan,
  }) async {
    try {
      await apiClient.client.post(
        '/student-health/bookings',
        data: {'jadwal_id': scheduleId, 'keluhan': keluhan},
      );
    } catch (e) {
      log('Error creating health booking: $e');
      throw _parseError(e, 'Gagal membuat booking klinik');
    }
  }

  @override
  Future<void> cancelHealthBooking(String bookingId) async {
    try {
      await apiClient.client.delete('/student-health/bookings/$bookingId');
    } catch (e) {
      log('Error cancelling health booking: $e');
      throw _parseError(e, 'Gagal membatalkan booking klinik');
    }
  }

  @override
  Future<void> rescheduleHealthBooking(
    String bookingId,
    int newScheduleId,
  ) async {
    try {
      await apiClient.client.put(
        '/student-health/bookings/$bookingId/reschedule',
        data: {
          'jadwal_id': newScheduleId,
          'schedule_id': newScheduleId,
          'new_schedule_id': newScheduleId,
          'new_jadwal_id': newScheduleId,
        },
      );
    } catch (e) {
      log('Error rescheduling health booking: $e');
      throw _parseError(e, 'Gagal melakukan reschedule booking klinik');
    }
  }

  @override
  Future<List<InsuranceClaim>> getInsuranceClaims() async {
    try {
      final response = await apiClient.client.get('/mahasiswa/insurance');
      final List data = response.data['data'] ?? [];
      return data
          .map<InsuranceClaim>((json) => InsuranceClaimModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error getting insurance claims: $e');
      throw _parseError(e, 'Gagal memuat riwayat klaim asuransi');
    }
  }

  @override
  Future<InsuranceClaim> createInsuranceClaim({
    required String provider,
    required String tanggal,
    required String faskes,
    required String deskripsi,
    required double biaya,
  }) async {
    try {
      final response = await apiClient.client.post(
        '/mahasiswa/insurance',
        data: {
          'jenis_provider': provider,
          'tanggal_kejadian': tanggal,
          'lokasi_faskes': faskes,
          'deskripsi': deskripsi,
          'estimasi_biaya': biaya,
        },
      );
      final raw = response.data['data'];
      return InsuranceClaimModel.fromJson(raw);
    } catch (e) {
      log('Error creating insurance claim: $e');
      throw _parseError(e, 'Gagal mengajukan klaim asuransi');
    }
  }

  @override
  Future<void> uploadInsuranceDocument({
    required int claimId,
    required String filePath,
    required int docNumber,
  }) async {
    try {
      final formData = FormData.fromMap({
        'doc_number': docNumber.toString(),
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      await apiClient.client.post(
        '/mahasiswa/insurance/$claimId/upload',
        data: formData,
      );
    } catch (e) {
      log('Error uploading insurance document: $e');
      throw _parseError(e, 'Gagal mengunggah berkas asuransi');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getIuranList() async {
    try {
      final response = await apiClient.client.get('/organisasi/iuran');
      final rawData = response.data['data'];
      final List list = rawData is List ? rawData : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (e) {
      log('Error getting iuran list: $e');
      throw _parseError(e, 'Gagal memuat tagihan iuran');
    }
  }

  @override
  Future<void> bayarIuran({
    required String detailId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      await apiClient.client.post(
        '/organisasi/iuran/pembayaran/$detailId',
        data: formData,
      );
    } catch (e) {
      log('Error paying iuran: $e');
      throw _parseError(e, 'Gagal mengunggah bukti pembayaran');
    }
  }

  Exception _parseError(dynamic e, String defaultMsg) {
    if (e is DioException) {
      log('DioException type: ${e.type}');
      log('DioException status: ${e.response?.statusCode}');
      log('DioException data: ${e.response?.data}');

      final data = e.response?.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'];
        if (msg != null) {
          return Exception(msg.toString());
        }
      }
      if (data is String && data.isNotEmpty) {
        return Exception(data);
      }
      // No response body — likely a connection/timeout issue
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return Exception(
          'Koneksi ke server timeout. Pastikan jaringan kamu stabil.',
        );
      }
      if (e.type == DioExceptionType.connectionError) {
        return Exception(
          'Tidak dapat terhubung ke server. Pastikan jaringan kamu aktif.',
        );
      }
    }
    log('Non-Dio error: $e (${e.runtimeType})');
    return Exception(defaultMsg);
  }
}

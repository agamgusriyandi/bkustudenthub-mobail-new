import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_notification.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_division.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_role.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_announcement.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_aspiration.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_lpj.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_finance.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_attendance.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_proposal.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_organisasi.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_repository.dart';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/features/ormawa/data/datasources/ormawa_remote_data_source.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_proposal_model.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_agenda_model.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_division_model.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_notification_model.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_member.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_member_model.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_organisasi_model.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_financial_setting.dart';

class OrmawaRepositoryImpl implements OrmawaRepository {
  @override
  Future<List<OrmawaProposal>> getProposals(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getProposals(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaProposalModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getProposals: $e');
      return [];
    }
  }

  @override
  Future<List<OrmawaAgenda>> getAgendas(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getAgendas(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaAgendaModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getAgendas: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getStats(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaStats(ormawaId);
      return response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>? ??
          {};
    } catch (e) {
      log('Error in getStats: $e');
      return {};
    }
  }

  @override
  Future<Map<String, dynamic>> getGamifikasiSummary() async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaGamifikasi();
      return response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>? ??
          {};
    } catch (e) {
      log('Error in getGamifikasiSummary: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGamifikasiHistory() async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaGamifikasiHistory();
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } catch (e) {
      log('Error in getGamifikasiHistory: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGamifikasiLeaderboard() async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaGamifikasiLeaderboard();
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } catch (e) {
      log('Error in getGamifikasiLeaderboard: $e');
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getGamifikasiRules() async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaGamifikasiRules();
      final data = response.data['data'];
      if (data is List) return List<Map<String, dynamic>>.from(data);
      return [];
    } catch (e) {
      log('Error in getGamifikasiRules: $e');
      return [];
    }
  }

  @override
  Future<void> addProposal(OrmawaProposal proposal) async {
    try {
      final model = OrmawaProposalModel(
        id: proposal.id,
        ormawaId: proposal.ormawaId,
        mahasiswaId: proposal.mahasiswaId,
        fakultasId: proposal.fakultasId,
        title: proposal.title,
        code: proposal.code,
        status: proposal.status,
        date: proposal.date,
        budget: proposal.budget,
        description: proposal.description,
        landasanKegiatan: proposal.landasanKegiatan,
        bentukKegiatan: proposal.bentukKegiatan,
        mitra: proposal.mitra,
        pjKegiatan: proposal.pjKegiatan,
        jadwalPelaksanaan: proposal.jadwalPelaksanaan,
        sasaranKegiatan: proposal.sasaranKegiatan,
        indikatorKeberhasilan: proposal.indikatorKeberhasilan,
        sumberDana: proposal.sumberDana,
        latarBelakang: proposal.latarBelakang,
        tujuanKegiatan: proposal.tujuanKegiatan,
        fileUrl: proposal.fileUrl,
        catatan: proposal.catatan,
      );
      await ormawaRemoteDataSource.addProposal(model.toJson());
    } catch (e) {
      log('Error in addProposal: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateProposal(OrmawaProposal proposal) async {
    try {
      final model = OrmawaProposalModel(
        id: proposal.id,
        ormawaId: proposal.ormawaId,
        mahasiswaId: proposal.mahasiswaId,
        fakultasId: proposal.fakultasId,
        title: proposal.title,
        code: proposal.code,
        status: proposal.status,
        date: proposal.date,
        budget: proposal.budget,
        description: proposal.description,
        landasanKegiatan: proposal.landasanKegiatan,
        bentukKegiatan: proposal.bentukKegiatan,
        mitra: proposal.mitra,
        pjKegiatan: proposal.pjKegiatan,
        jadwalPelaksanaan: proposal.jadwalPelaksanaan,
        sasaranKegiatan: proposal.sasaranKegiatan,
        indikatorKeberhasilan: proposal.indikatorKeberhasilan,
        sumberDana: proposal.sumberDana,
        latarBelakang: proposal.latarBelakang,
        tujuanKegiatan: proposal.tujuanKegiatan,
        fileUrl: proposal.fileUrl,
        catatan: proposal.catatan,
      );
      await ormawaRemoteDataSource.updateProposal(proposal.id, model.toJson());
    } catch (e) {
      log('Error in updateProposal: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteProposal(String proposalId) async {
    try {
      await ormawaRemoteDataSource.deleteProposal(proposalId);
    } catch (e) {
      log('Error in deleteProposal: $e');
      rethrow;
    }
  }

  @override
  Future<void> addAgenda(String ormawaId, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.addAgenda(data);
    } catch (e) {
      log('Error in addAgenda: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAgenda(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateAgenda(id, data);
    } catch (e) {
      log('Error in updateAgenda: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAgenda(String id) async {
    try {
      await ormawaRemoteDataSource.deleteAgenda(id);
    } catch (e) {
      log('Error in deleteAgenda: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaFinance>> getFinance(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getFinance(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaFinance.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getFinance: $e');
      return [];
    }
  }

  @override
  Future<void> addFinance(String ormawaId, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.addFinance(ormawaId, data);
    } catch (e) {
      log('Error in addFinance: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaLPJ>> getLPJs(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getLPJs(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaLPJ.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getLPJs: $e');
      return [];
    }
  }

  @override
  Future<void> addLPJ(Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.addLPJ(data);
    } catch (e) {
      log('Error in addLPJ: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateLPJ(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateLPJ(id, data);
    } catch (e) {
      log('Error in updateLPJ: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteLPJ(String id) async {
    try {
      await ormawaRemoteDataSource.deleteLPJ(id);
    } catch (e) {
      log('Error in deleteLPJ: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaAspiration>> getAspirations(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getAspirations(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaAspiration.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getAspirations: $e');
      return [];
    }
  }

  @override
  Future<void> respondToAspiration(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.respondToAspiration(id, data);
    } catch (e) {
      log('Error in respondToAspiration: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaAnnouncement>> getAnnouncements(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getAnnouncements(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaAnnouncement.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getAnnouncements: $e');
      return [];
    }
  }

  @override
  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.createAnnouncement(data);
    } catch (e) {
      log('Error in createAnnouncement: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateAnnouncement(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateAnnouncement(id, data);
    } catch (e) {
      log('Error in updateAnnouncement: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteAnnouncement(String id) async {
    try {
      await ormawaRemoteDataSource.deleteAnnouncement(id);
    } catch (e) {
      log('Error in deleteAnnouncement: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaAttendance>> getAttendance(String eventId) async {
    try {
      final response = await ormawaRemoteDataSource.getAttendance(eventId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) {
          final mahasiswa = e['Mahasiswa'] as Map<String, dynamic>?;
          return OrmawaAttendance(
            mahasiswaId: (e['MahasiswaID'] ?? '').toString(),
            mahasiswaName: mahasiswa?['Nama'] ?? mahasiswa?['nama'] ?? '',
            nim: mahasiswa?['NIM'] ?? mahasiswa?['nim'] ?? '',
            waktuHadir:
                DateTime.tryParse(e['WaktuHadir'] ?? '') ?? DateTime.now(),
            status: e['Status'] ?? 'belum_absen',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      log('Error in getAttendance: $e');
      return [];
    }
  }

  @override
  Future<List<OrmawaRole>> getRoles() async {
    return [];
  }

  @override
  Future<void> createRole(Map<String, dynamic> data) async {
    return;
  }

  @override
  Future<void> updateRole(String id, Map<String, dynamic> data) async {
    return;
  }

  @override
  Future<void> deleteRole(String id) async {
    return;
  }

  @override
  Future<List<OrmawaDivision>> getDivisions({String? ormawaId}) async {
    try {
      final response = await ormawaRemoteDataSource.getDivisions(
        ormawaId ?? '',
      );
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaDivisionModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getDivisions: $e');
      return [];
    }
  }

  @override
  Future<void> createDivision(Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.createDivision(data);
    } catch (e) {
      log('Error in createDivision: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDivision(String id) async {
    try {
      await ormawaRemoteDataSource.deleteDivision(id);
    } catch (e) {
      log('Error in deleteDivision: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaNotification>> getNotifications(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getNotifications(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaNotificationModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getNotifications: $e');
      return [];
    }
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    try {
      await ormawaRemoteDataSource.markNotificationAsRead(id);
    } catch (e) {
      log('Error in markNotificationAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String ormawaId) async {
    try {
      await ormawaRemoteDataSource.markAllNotificationsAsRead(ormawaId);
    } catch (e) {
      log('Error in markAllNotificationsAsRead: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    try {
      await ormawaRemoteDataSource.deleteNotification(id);
    } catch (e) {
      log('Error in deleteNotification: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getActiveAcademicYear() async {
    return '2025/2026';
  }

  @override
  Future<Map<String, dynamic>> getRecruitmentSettings(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getRecruitmentFormFields(
        ormawaId,
      );
      return response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>? ??
          {};
    } catch (e) {
      log('Error in getRecruitmentSettings: $e');
      return {};
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRecruitmentApplicants(
    String ormawaId,
  ) async {
    return [];
  }

  @override
  Future<void> reviewRecruitmentApplicant(
    String applicantId,
    String status,
  ) async {
    return;
  }

  @override
  Future<List<Map<String, dynamic>>> getRecruitmentFormFields(
    String ormawaId,
  ) async {
    try {
      final response = await ormawaRemoteDataSource.getRecruitmentFormFields(
        ormawaId,
      );
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      log('Error in getRecruitmentFormFields: $e');
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> getOrmawaSettings(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaSettings(ormawaId);
      return response.data['data'] as Map<String, dynamic>? ??
          response.data as Map<String, dynamic>? ??
          {};
    } catch (e) {
      log('Error in getOrmawaSettings: $e');
      return {};
    }
  }

  @override
  Future<void> updateOrmawaSettings(
    String ormawaId,
    Map<String, dynamic> data,
  ) async {
    try {
      await ormawaRemoteDataSource.updateOrmawaSettings(ormawaId, data);
    } catch (e) {
      log('Error in updateOrmawaSettings: $e');
      rethrow;
    }
  }

  @override
  Future<String?> uploadFile(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.replaceAll('\\', '/').split('/').last,
        ),
      });
      final response = await ormawaRemoteDataSource.uploadFile(formData);
      return response.data['url'] as String?;
    } catch (e) {
      log('Error in uploadFile repository: $e');
      rethrow;
    }
  }

  final OrmawaRemoteDataSource ormawaRemoteDataSource;

  OrmawaRepositoryImpl({required this.ormawaRemoteDataSource});

  @override
  Future<Map<String, dynamic>> getMembersData(
    String ormawaId, {
    String? periode,
  }) async {
    try {
      final response = await ormawaRemoteDataSource.getMembers(ormawaId);
      final dataMap = response.data as Map<String, dynamic>? ?? {};

      final dynamic list = dataMap['data'] ?? [];
      final List<OrmawaMember> members = [];
      if (list is List) {
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            members.add(OrmawaMemberModel.fromJson(item));
          }
        }
      }

      final dynamic periodsList = dataMap['periods'] ?? [];
      final List<String> periods = [];
      if (periodsList is List) {
        for (var item in periodsList) {
          periods.add(item.toString());
        }
      }

      return {'members': members, 'periods': periods};
    } catch (e) {
      log('Error in getMembersData: $e');
      return {'members': <OrmawaMember>[], 'periods': <String>[]};
    }
  }

  @override
  Future<void> saveRecruitmentFormFields(
    String ormawaId,
    List<Map<String, dynamic>> fields,
  ) async {
    try {
      await ormawaRemoteDataSource.saveRecruitmentFormFields(ormawaId, fields);
    } catch (e) {
      log('Error in saveRecruitmentFormFields: $e');
      rethrow;
    }
  }

  @override
  Future<void> submitAttendance(
    String eventId,
    String mahasiswaId,
    String status,
  ) async {
    try {
      final data = {
        'KegiatanID': int.tryParse(eventId) ?? 0,
        'MahasiswaID': int.tryParse(mahasiswaId) ?? 0,
        'Status': status,
      };
      await ormawaRemoteDataSource.submitAttendance(data);
    } catch (e) {
      log('Error in submitAttendance: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateRecruitmentSettings(
    String ormawaId,
    Map<String, dynamic> data,
  ) async {
    return;
  }

  @override
  Future<void> regenerateMembers(String ormawaId) async {
    try {
      await ormawaRemoteDataSource.regenerateMembers(ormawaId);
    } catch (e) {
      log('Error in regenerateMembers: $e');
      rethrow;
    }
  }

  @override
  Future<void> createDivisionInline(String ormawaId, String name) async {
    try {
      await ormawaRemoteDataSource.createDivision({
        'OrmawaID': int.tryParse(ormawaId),
        'Nama': name,
      });
    } catch (e) {
      log('Error in createDivisionInline: $e');
      rethrow;
    }
  }

  @override
  Future<void> addMember(String ormawaId, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.createMember(data);
    } catch (e) {
      log('Error in addMember: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateMember(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateMember(id, data);
    } catch (e) {
      log('Error in updateMember: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    try {
      await ormawaRemoteDataSource.deleteMember(id);
    } catch (e) {
      log('Error in deleteMember: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final response = await ormawaRemoteDataSource.getStudents();
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      log('Error in getStudents: $e');
      return [];
    }
  }

  Future<dynamic> markAllAsRead(Map<String, dynamic> data) async {
    try {
      final response = await ormawaRemoteDataSource.markAllAsRead(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in markAllAsRead: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteBulk() async {
    try {
      final response = await ormawaRemoteDataSource.deleteBulk();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteBulk: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteRead() async {
    try {
      final response = await ormawaRemoteDataSource.deleteRead();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteRead: $e');
      rethrow;
    }
  }

  Future<dynamic> getUnreadCount() async {
    try {
      final response = await ormawaRemoteDataSource.getUnreadCount();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getUnreadCount: $e');
      rethrow;
    }
  }

  Future<dynamic> markAsRead(String id, Map<String, dynamic> data) async {
    try {
      final response = await ormawaRemoteDataSource.markAsRead(id, data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in markAsRead: $e');
      rethrow;
    }
  }

  Future<dynamic> getList() async {
    try {
      final response = await ormawaRemoteDataSource.getList();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getList: $e');
      rethrow;
    }
  }

  Future<dynamic> create(Map<String, dynamic> data) async {
    try {
      final response = await ormawaRemoteDataSource.create(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in create: $e');
      rethrow;
    }
  }

  Future<dynamic> daftarOrmawa(Map<String, dynamic> data) async {
    try {
      final response = await ormawaRemoteDataSource.daftarOrmawa(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in daftarOrmawa: $e');
      rethrow;
    }
  }

  Future<dynamic> getOrmawaDivisions(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaDivisions(
        ormawaId,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getOrmawaDivisions: $e');
      rethrow;
    }
  }

  Future<dynamic> getOrmawaList() async {
    try {
      final response = await ormawaRemoteDataSource.getOrmawaList();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getOrmawaList: $e');
      rethrow;
    }
  }

  Future<dynamic> getPendaftaranList() async {
    try {
      final response = await ormawaRemoteDataSource.getPendaftaranList();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getPendaftaranList: $e');
      rethrow;
    }
  }

  Future<dynamic> getRecruitmentFields(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getRecruitmentFields(
        ormawaId,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getRecruitmentFields: $e');
      rethrow;
    }
  }

  Future<dynamic> uploadRecruitmentFile(FormData data) async {
    try {
      final response = await ormawaRemoteDataSource.uploadRecruitmentFile(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in uploadRecruitmentFile: $e');
      rethrow;
    }
  }

  Future<dynamic> update(String id, Map<String, dynamic> data) async {
    try {
      final response = await ormawaRemoteDataSource.update(id, data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in update: $e');
      rethrow;
    }
  }

  Future<dynamic> delete(String id) async {
    try {
      final response = await ormawaRemoteDataSource.delete(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in delete: $e');
      rethrow;
    }
  }

  // Attendance Management
  @override
  Future<List<Map<String, dynamic>>> getAbsensiManagement(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getAbsensiManagement(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return List<Map<String, dynamic>>.from(list);
      }
      return [];
    } catch (e) {
      log('Error in getAbsensiManagement: $e');
      return [];
    }
  }

  @override
  Future<void> createAbsensiManagement(Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.createAbsensiManagement(data);
    } catch (e) {
      log('Error in createAbsensiManagement: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> getAbsensiManagementDetail(String id) async {
    try {
      final response = await ormawaRemoteDataSource.getAbsensiManagementDetail(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getAbsensiManagementDetail: $e');
      return null;
    }
  }

  @override
  Future<void> updateAbsensiManagement(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateAbsensiManagement(id, data);
    } catch (e) {
      log('Error in updateAbsensiManagement: $e');
      rethrow;
    }
  }

  // RBAC Roles
  @override
  Future<Map<String, dynamic>> getRoleDetails(String roleId) async {
    try {
      final response = await ormawaRemoteDataSource.getRoleDetails(roleId);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getRoleDetails: $e');
      return {};
    }
  }

  // LPJ
  @override
  Future<List<dynamic>> getLpjDocuments(String lpjId) async {
    try {
      final response = await ormawaRemoteDataSource.getLpjDocuments(lpjId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list;
      }
      return [];
    } catch (e) {
      log('Error in getLpjDocuments: $e');
      return [];
    }
  }

  // Organisasi
  @override
  Future<List<OrmawaOrganisasi>> getOrganisasiList() async {
    try {
      final response = await ormawaRemoteDataSource.getOrganisasiList();
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaOrganisasiModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getOrganisasiList: $e');
      return [];
    }
  }

  @override
  Future<void> createOrganisasi(Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.createOrganisasi(data);
    } catch (e) {
      log('Error in createOrganisasi: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateOrganisasi(String id, Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateOrganisasi(id, data);
    } catch (e) {
      log('Error in updateOrganisasi: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteOrganisasi(String id) async {
    try {
      await ormawaRemoteDataSource.deleteOrganisasi(id);
    } catch (e) {
      log('Error in deleteOrganisasi: $e');
      rethrow;
    }
  }

  @override
  Future<List<OrmawaFinancialSetting>> getFinancialSettings({String? ormawaId, String? periode}) async {
    try {
      final response = await ormawaRemoteDataSource.getFinancialSettings(
        ormawaId: ormawaId,
        periode: periode,
      );
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaFinancialSetting.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getFinancialSettings: $e');
      return [];
    }
  }

  @override
  Future<List<OrmawaFinancialAuditLog>> getFinancialAuditLogs(String ormawaId) async {
    try {
      final response = await ormawaRemoteDataSource.getFinancialAuditLogs(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        return list.map((e) => OrmawaFinancialAuditLog.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      log('Error in getFinancialAuditLogs: $e');
      return [];
    }
  }

  @override
  Future<void> updateFinancialSetting(Map<String, dynamic> data) async {
    try {
      await ormawaRemoteDataSource.updateFinancialSetting(data);
    } catch (e) {
      log('Error in updateFinancialSetting: $e');
      rethrow;
    }
  }
}

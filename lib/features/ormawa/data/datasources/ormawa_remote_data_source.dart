import 'package:dio/dio.dart';

abstract class OrmawaRemoteDataSource {
  Future<Response> markAllAsRead(Map<String, dynamic> data);
  Future<Response> deleteBulk();
  Future<Response> deleteRead();
  Future<Response> getUnreadCount();
  Future<Response> markAsRead(String id, Map<String, dynamic> data);
  Future<Response> getList();
  Future<Response> create(Map<String, dynamic> data);
  Future<Response> daftarOrmawa(Map<String, dynamic> data);
  Future<Response> getOrmawaDivisions(String ormawaId);
  Future<Response> getOrmawaList();
  Future<Response> getPendaftaranList();
  Future<Response> getRecruitmentFields(String ormawaId);
  Future<Response> uploadRecruitmentFile(FormData data);
  Future<Response> update(String id, Map<String, dynamic> data);
  Future<Response> delete(String id);

  // Ormawa Role Dashboards
  Future<Response> getOrmawaStats(String ormawaId);
  Future<Response> getOrmawaGamifikasi();
  Future<Response> getProposals(String ormawaId);
  Future<Response> addProposal(Map<String, dynamic> data);
  Future<Response> updateProposal(String id, Map<String, dynamic> data);
  Future<Response> deleteProposal(String id);
  Future<Response> getAgendas(String ormawaId);
  Future<Response> addAgenda(Map<String, dynamic> data);
  Future<Response> updateAgenda(String id, Map<String, dynamic> data);
  Future<Response> deleteAgenda(String id);
  Future<Response> getAttendance(String eventId);
  Future<Response> submitAttendance(Map<String, dynamic> data);
  Future<Response> getFinance(String ormawaId);
  Future<Response> addFinance(String ormawaId, Map<String, dynamic> data);
  Future<Response> getLPJs(String ormawaId);
  Future<Response> addLPJ(Map<String, dynamic> data);
  Future<Response> updateLPJ(String id, Map<String, dynamic> data);
  Future<Response> deleteLPJ(String id);
  Future<Response> getAspirations(String ormawaId);
  Future<Response> respondToAspiration(String id, Map<String, dynamic> data);
  Future<Response> getAnnouncements(String ormawaId);
  Future<Response> createAnnouncement(Map<String, dynamic> data);
  Future<Response> updateAnnouncement(String id, Map<String, dynamic> data);
  Future<Response> deleteAnnouncement(String id);

  // Notifications
  Future<Response> getNotifications(String ormawaId);
  Future<Response> markNotificationAsRead(String id);
  Future<Response> markAllNotificationsAsRead(String ormawaId);
  Future<Response> deleteNotification(String id);

  // Divisions
  Future<Response> getDivisions(String ormawaId);
  Future<Response> createDivision(Map<String, dynamic> data);
  Future<Response> deleteDivision(String id);

  // Members
  Future<Response> getMembers(String ormawaId);
  Future<Response> createMember(Map<String, dynamic> data);
  Future<Response> regenerateMembers(String ormawaId);
  Future<Response> updateMember(String id, Map<String, dynamic> data);
  Future<Response> deleteMember(String id);

  // Recruitment Form Builder
  Future<Response> getRecruitmentFormFields(String ormawaId);
  Future<Response> saveRecruitmentFormFields(
    String ormawaId,
    List<Map<String, dynamic>> fields,
  );

  // Settings
  Future<Response> getOrmawaSettings(String ormawaId);
  Future<Response> updateOrmawaSettings(
    String ormawaId,
    Map<String, dynamic> data,
  );

  // Student Lookup
  Future<Response> getStudents();
  Future<Response> uploadFile(FormData data);
}

class OrmawaRemoteDataSourceImpl implements OrmawaRemoteDataSource {
  final Dio dio;

  OrmawaRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> markAllAsRead(Map<String, dynamic> data) async {
    return await dio.put('/notifikasi/baca-semua', data: data);
  }

  @override
  Future<Response> deleteBulk() async {
    return await dio.delete('/notifikasi/hapus-bulk');
  }

  @override
  Future<Response> deleteRead() async {
    return await dio.delete('/notifikasi/hapus-dibaca');
  }

  @override
  Future<Response> getUnreadCount() async {
    return await dio.get('/notifikasi/unread-count');
  }

  @override
  Future<Response> markAsRead(String id, Map<String, dynamic> data) async {
    return await dio.put('/notifikasi/$id/baca', data: data);
  }

  @override
  Future<Response> getList() async {
    return await dio.get('/organisasi/');
  }

  @override
  Future<Response> create(Map<String, dynamic> data) async {
    return await dio.post('/organisasi/', data: data);
  }

  @override
  Future<Response> daftarOrmawa(Map<String, dynamic> data) async {
    return await dio.post('/organisasi/daftar', data: data);
  }

  @override
  Future<Response> getOrmawaDivisions(String ormawaId) async {
    return await dio.get('/organisasi/divisions/$ormawaId');
  }

  @override
  Future<Response> getOrmawaList() async {
    return await dio.get('/organisasi/ormawa-list');
  }

  @override
  Future<Response> getPendaftaranList() async {
    return await dio.get('/organisasi/pendaftaran');
  }

  @override
  Future<Response> getRecruitmentFields(String ormawaId) async {
    return await dio.get('/organisasi/recruitment-fields/$ormawaId');
  }

  @override
  Future<Response> uploadRecruitmentFile(FormData data) async {
    return await dio.post('/organisasi/upload-file', data: data);
  }

  @override
  Future<Response> update(String id, Map<String, dynamic> data) async {
    return await dio.put('/organisasi/$id', data: data);
  }

  @override
  Future<Response> delete(String id) async {
    return await dio.delete('/organisasi/$id');
  }

  // Ormawa Role Dashboards HTTP Implementation
  @override
  Future<Response> getOrmawaStats(String ormawaId) async {
    return await dio.get('/ormawa/stats');
  }

  @override
  Future<Response> getOrmawaGamifikasi() async {
    return await dio.get('/ormawa/gamifikasi');
  }

  @override
  Future<Response> getProposals(String ormawaId) async {
    return await dio.get('/ormawa/proposals');
  }

  @override
  Future<Response> addProposal(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/proposals', data: data);
  }

  @override
  Future<Response> updateProposal(String id, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/proposals/$id', data: data);
  }

  @override
  Future<Response> deleteProposal(String id) async {
    return await dio.delete('/ormawa/proposals/$id');
  }

  @override
  Future<Response> getAgendas(String ormawaId) async {
    return await dio.get('/ormawa/events');
  }

  @override
  Future<Response> addAgenda(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/events', data: data);
  }

  @override
  Future<Response> updateAgenda(String id, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/events/$id', data: data);
  }

  @override
  Future<Response> deleteAgenda(String id) async {
    return await dio.delete('/ormawa/events/$id');
  }

  @override
  Future<Response> getFinance(String ormawaId) async {
    return await dio.get('/ormawa/kas');
  }

  @override
  Future<Response> addFinance(
    String ormawaId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post('/ormawa/kas', data: data);
  }

  @override
  Future<Response> getLPJs(String ormawaId) async {
    return await dio.get('/ormawa/lpjs');
  }

  @override
  Future<Response> addLPJ(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/lpjs', data: data);
  }

  @override
  Future<Response> updateLPJ(String id, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/lpjs/$id', data: data);
  }

  @override
  Future<Response> deleteLPJ(String id) async {
    return await dio.delete('/ormawa/lpjs/$id');
  }

  @override
  Future<Response> getAspirations(String ormawaId) async {
    return await dio.get(
      '/ormawa/aspirations',
      queryParameters: {'ormawaId': ormawaId},
    );
  }

  @override
  Future<Response> respondToAspiration(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/ormawa/aspirations/$id', data: data);
  }

  @override
  Future<Response> getAnnouncements(String ormawaId) async {
    return await dio.get(
      '/ormawa/announcements',
      queryParameters: {'ormawaId': ormawaId},
    );
  }

  @override
  Future<Response> createAnnouncement(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/announcements', data: data);
  }

  @override
  Future<Response> updateAnnouncement(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/ormawa/announcements/$id', data: data);
  }

  @override
  Future<Response> deleteAnnouncement(String id) async {
    return await dio.delete('/ormawa/announcements/$id');
  }

  // Notifications
  @override
  Future<Response> getNotifications(String ormawaId) async {
    return await dio.get(
      '/ormawa/notifications',
      queryParameters: {'ormawaId': ormawaId},
    );
  }

  @override
  Future<Response> markNotificationAsRead(String id) async {
    return await dio.put('/ormawa/notifications/$id/read');
  }

  @override
  Future<Response> markAllNotificationsAsRead(String ormawaId) async {
    return await dio.put(
      '/ormawa/notifications/read-all',
      queryParameters: {'ormawaId': ormawaId},
    );
  }

  @override
  Future<Response> deleteNotification(String id) async {
    return await dio.delete('/ormawa/notifications/$id');
  }

  // Divisions
  @override
  Future<Response> getDivisions(String ormawaId) async {
    return await dio.get('/ormawa/divisions');
  }

  @override
  Future<Response> createDivision(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/divisions', data: data);
  }

  @override
  Future<Response> deleteDivision(String id) async {
    return await dio.delete('/ormawa/divisions/$id');
  }

  // Members
  @override
  Future<Response> getMembers(String ormawaId) async {
    return await dio.get('/ormawa/members');
  }

  @override
  Future<Response> createMember(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/members', data: data);
  }

  @override
  Future<Response> regenerateMembers(String ormawaId) async {
    return await dio.post('/ormawa/members/regenerate');
  }

  @override
  Future<Response> updateMember(String id, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/members/$id', data: data);
  }

  @override
  Future<Response> deleteMember(String id) async {
    return await dio.delete('/ormawa/members/$id');
  }

  // Recruitment Form Fields
  @override
  Future<Response> getRecruitmentFormFields(String ormawaId) async {
    return await dio.get('/ormawa/recruitment-fields');
  }

  @override
  Future<Response> saveRecruitmentFormFields(
    String ormawaId,
    List<Map<String, dynamic>> fields,
  ) async {
    return await dio.post('/ormawa/recruitment-fields', data: fields);
  }

  // Settings
  @override
  Future<Response> getOrmawaSettings(String ormawaId) async {
    return await dio.get('/ormawa/settings/$ormawaId');
  }

  @override
  Future<Response> updateOrmawaSettings(
    String ormawaId,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/ormawa/settings/$ormawaId', data: data);
  }

  @override
  Future<Response> getStudents() async {
    return await dio.get('/ormawa/students');
  }

  @override
  Future<Response> getAttendance(String eventId) async {
    return await dio.get('/ormawa/attendance/$eventId');
  }

  @override
  Future<Response> submitAttendance(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/attendance', data: data);
  }

  @override
  Future<Response> uploadFile(FormData data) async {
    return await dio.post('/ormawa/upload', data: data);
  }
}

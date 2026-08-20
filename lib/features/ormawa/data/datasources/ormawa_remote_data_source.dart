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

  Future<Response> getOrmawaStats(String ormawaId);
  Future<Response> getOrmawaGamifikasi();
  Future<Response> getOrmawaGamifikasiHistory();
  Future<Response> getOrmawaGamifikasiLeaderboard();
  Future<Response> getOrmawaGamifikasiRules();
  Future<Response> getProposals(String ormawaId);
  Future<Response> addProposal(Map<String, dynamic> data);
  Future<Response> updateProposal(String id, Map<String, dynamic> data);
  Future<Response> resubmitProposal(String id);
  Future<Response> deleteProposal(String id);
  Future<Response> getAgendas(String ormawaId);
  Future<Response> addAgenda(Map<String, dynamic> data);
  Future<Response> updateAgenda(String id, Map<String, dynamic> data);
  Future<Response> deleteAgenda(String id);
  Future<Response> getAttendance(String eventId);
  Future<Response> submitAttendance(Map<String, dynamic> data);
  Future<Response> getFinance(String ormawaId);
  Future<Response> addFinance(String ormawaId, Map<String, dynamic> data);
  Future<Response> deleteFinance(String id);
  Future<Response> getBudgetStatus(String ormawaId);
  Future<Response> generateReportNumber(String ormawaId);
  Future<Response> getBankAccount(String ormawaId);
  Future<Response> updateBankAccount(String ormawaId, Map<String, dynamic> data);
  Future<Response> getIurans(String ormawaId);
  Future<Response> createIuran(String ormawaId, Map<String, dynamic> data);
  Future<Response> getIuranMembers(String iuranId, String ormawaId);
  Future<Response> verifyIuranPayment(String detailId, String ormawaId, Map<String, dynamic> data);
  Future<Response> getMyIurans(String ormawaId);
  Future<Response> payMyIuran(String detailId, String ormawaId, Map<String, dynamic> data);
  Future<Response> getLPJs(String ormawaId);
  Future<Response> getLpjDocuments(String lpjId);
  Future<Response> addLPJ(Map<String, dynamic> data);
  Future<Response> updateLPJ(String id, Map<String, dynamic> data);
  Future<Response> deleteLPJ(String id);
  Future<Response> getAspirations(String ormawaId);
  Future<Response> respondToAspiration(String id, Map<String, dynamic> data);
  Future<Response> getAnnouncements(String ormawaId);
  Future<Response> createAnnouncement(Map<String, dynamic> data);
  Future<Response> updateAnnouncement(String id, Map<String, dynamic> data);
  Future<Response> deleteAnnouncement(String id);

  Future<Response> getNotifications(String ormawaId);
  Future<Response> markNotificationAsRead(String id);
  Future<Response> markAllNotificationsAsRead(String ormawaId);
  Future<Response> deleteNotification(String id);

  Future<Response> getDivisions(String ormawaId);
  Future<Response> createDivision(Map<String, dynamic> data);
  Future<Response> deleteDivision(String id);

  Future<Response> getMembers(String ormawaId);
  Future<Response> createMember(Map<String, dynamic> data);
  Future<Response> regenerateMembers(String ormawaId);
  Future<Response> updateMember(String id, Map<String, dynamic> data);
  Future<Response> deleteMember(String id);

  Future<Response> getRecruitmentFormFields(String ormawaId);
  Future<Response> saveRecruitmentFormFields(
    String ormawaId,
    List<Map<String, dynamic>> fields,
  );

  Future<Response> getOrmawaSettings(String ormawaId);
  Future<Response> updateOrmawaSettings(
    String ormawaId,
    Map<String, dynamic> data,
  );

  Future<Response> getStudents();
  Future<Response> uploadFile(FormData data);

  Future<Response> getOrganisasiList();
  Future<Response> createOrganisasi(Map<String, dynamic> data);
  Future<Response> updateOrganisasi(String id, Map<String, dynamic> data);
  Future<Response> deleteOrganisasi(String id);

  Future<Response> getAbsensiManagement(String ormawaId);
  Future<Response> createAbsensiManagement(Map<String, dynamic> data);
  Future<Response> getAbsensiManagementDetail(String id);
  Future<Response> updateAbsensiManagement(String id, Map<String, dynamic> data);

  Future<Response> getRoleDetails(String roleId);

  Future<Response> getFinancialSettings({String? ormawaId, String? periode});
  Future<Response> getFinancialAuditLogs(String ormawaId);
  Future<Response> updateFinancialSetting(Map<String, dynamic> data);
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

  @override
  Future<Response> getOrmawaStats(String ormawaId) async {
    return await dio.get('/ormawa/stats');
  }

  @override
  Future<Response> getOrmawaGamifikasi() async {
    return await dio.get('/ormawa/gamifikasi');
  }

  @override
  Future<Response> getOrmawaGamifikasiHistory() async {
    return await dio.get('/ormawa/gamifikasi/history');
  }

  @override
  Future<Response> getOrmawaGamifikasiLeaderboard() async {
    return await dio.get('/ormawa/gamifikasi/leaderboard');
  }

  @override
  Future<Response> getOrmawaGamifikasiRules() async {
    return await dio.get('/ormawa/gamifikasi/rules');
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
  Future<Response> resubmitProposal(String id) async {
    return await dio.post('/ormawa/proposals/$id/resubmit');
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
    return await dio.get('/ormawa/kas', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> addFinance(
    String ormawaId,
    Map<String, dynamic> data,
  ) async {
    return await dio.post('/ormawa/kas', data: data);
  }

  @override
  Future<Response> deleteFinance(String id) async {
    return await dio.delete('/ormawa/kas/$id');
  }

  @override
  Future<Response> getBudgetStatus(String ormawaId) async {
    return await dio.get('/ormawa/budget-status', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> generateReportNumber(String ormawaId) async {
    return await dio.post('/ormawa/kas/generate-report-number', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> getBankAccount(String ormawaId) async {
    return await dio.get('/ormawa/bank-account', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> updateBankAccount(String ormawaId, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/bank-account', queryParameters: {'ormawaId': ormawaId}, data: data);
  }

  @override
  Future<Response> getIurans(String ormawaId) async {
    return await dio.get('/ormawa/iuran', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> createIuran(String ormawaId, Map<String, dynamic> data) async {
    return await dio.post('/ormawa/iuran', queryParameters: {'ormawaId': ormawaId}, data: data);
  }

  @override
  Future<Response> getIuranMembers(String iuranId, String ormawaId) async {
    return await dio.get('/ormawa/iuran/$iuranId/anggota', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> verifyIuranPayment(String detailId, String ormawaId, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/iuran/pembayaran/$detailId/verifikasi', queryParameters: {'ormawaId': ormawaId}, data: data);
  }

  @override
  Future<Response> getMyIurans(String ormawaId) async {
    return await dio.get('/ormawa/iuran-saya', queryParameters: {'ormawaId': ormawaId});
  }

  @override
  Future<Response> payMyIuran(String detailId, String ormawaId, Map<String, dynamic> data) async {
    return await dio.post('/ormawa/iuran-pembayaran/$detailId', queryParameters: {'ormawaId': ormawaId}, data: data);
  }

  @override
  Future<Response> getLPJs(String ormawaId) async {
    return await dio.get('/ormawa/lpjs');
  }

  @override
  Future<Response> getLpjDocuments(String lpjId) async {
    return await dio.get('/ormawa/lpjs/documents/$lpjId');
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

  @override
  Future<Response> getMembers(String ormawaId) async {
    return await dio.get(
      '/ormawa/members',
      queryParameters: {
        if (ormawaId.isNotEmpty && ormawaId != 'null') 'ormawaId': ormawaId,
        'limit': 200,
      },
    );
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

  @override
  Future<Response> getAbsensiManagement(String ormawaId) async {
    return await dio.get('/ormawa/attendance', queryParameters: {'ormawa_id': ormawaId});
  }

  @override
  Future<Response> createAbsensiManagement(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/attendance', data: data);
  }

  @override
  Future<Response> getAbsensiManagementDetail(String id) async {
    return await dio.get('/ormawa/attendance/$id');
  }

  @override
  Future<Response> updateAbsensiManagement(String id, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/events/$id', data: data);
  }

  @override
  Future<Response> getRoleDetails(String roleId) async {
    return await dio.get('/ormawa/roles/$roleId');
  }

  @override
  Future<Response> getOrganisasiList() async {
    return await dio.get('/ormawa/organisasi');
  }

  @override
  Future<Response> createOrganisasi(Map<String, dynamic> data) async {
    return await dio.post('/ormawa/organisasi', data: data);
  }

  @override
  Future<Response> updateOrganisasi(String id, Map<String, dynamic> data) async {
    return await dio.put('/ormawa/organisasi/$id', data: data);
  }

  @override
  Future<Response> deleteOrganisasi(String id) async {
    return await dio.delete('/ormawa/organisasi/$id');
  }

  @override
  Future<Response> getFinancialSettings({String? ormawaId, String? periode}) async {
    final queryParams = <String, dynamic>{};
    if (ormawaId != null && ormawaId.isNotEmpty) queryParams['ormawaId'] = ormawaId;
    if (periode != null && periode.isNotEmpty) queryParams['periode'] = periode;
    return await dio.get('/ormawa/financial-settings', queryParameters: queryParams);
  }

  @override
  Future<Response> getFinancialAuditLogs(String ormawaId) async {
    return await dio.get('/ormawa/financial-settings/$ormawaId/audit-logs');
  }

  @override
  Future<Response> updateFinancialSetting(Map<String, dynamic> data) async {
    return await dio.put('/ormawa/financial-settings', data: data);
  }
}
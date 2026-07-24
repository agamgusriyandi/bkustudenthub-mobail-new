import 'package:dio/dio.dart';

abstract class TenagaKesehatanRemoteDataSource {
  Future<Response> getActivities();
  Future<Response> getBookings();
  Future<Response> createManualBooking(Map<String, dynamic> data);
  Future<Response> getBookingDetail(String id);
  Future<Response> updateBookingStatus(String id, Map<String, dynamic> data);
  Future<Response> getAllMedicalRecords();
  Future<Response> exportMedicalRecordPDF(String id);
  Future<Response> updateMedicalRecord(
    String recordId,
    Map<String, dynamic> data,
  );
  Future<Response> getPatients();
  Future<Response> getMedicalRecord(String id);
  Future<Response> createScreening(String id, Map<String, dynamic> data);
  Future<Response> exportExcel();
  Future<Response> exportRegistrationFormPDF();
  Future<Response> exportPDF();
  Future<Response> getSchedules();
  Future<Response> createSchedule(Map<String, dynamic> data);
  Future<Response> updateSchedule(String id, Map<String, dynamic> data);
  Future<Response> deleteSchedule(String id);
  Future<Response> exportPatientsRecapPDF();
  Future<Response> createSessionNote(String id, Map<String, dynamic> data);
  Future<Response> updatePatientStatus(
    String studentId,
    Map<String, dynamic> data,
  );
  Future<Response> saveSchedules(Map<String, dynamic> data);
}

class TenagaKesehatanRemoteDataSourceImpl
    implements TenagaKesehatanRemoteDataSource {
  final Dio dio;

  TenagaKesehatanRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> getActivities() async {
    return await dio.get('/api/activities');
  }

  @override
  Future<Response> getBookings() async {
    return await dio.get('/api/bookings');
  }

  @override
  Future<Response> createManualBooking(Map<String, dynamic> data) async {
    return await dio.post('/api/bookings/manual', data: data);
  }

  @override
  Future<Response> getBookingDetail(String id) async {
    return await dio.get('/api/bookings/$id');
  }

  @override
  Future<Response> updateBookingStatus(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/api/bookings/$id/status', data: data);
  }

  @override
  Future<Response> getAllMedicalRecords() async {
    return await dio.get('/api/medical-records');
  }

  @override
  Future<Response> exportMedicalRecordPDF(String id) async {
    return await dio.get(
      '/api/medical-records/$id/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> updateMedicalRecord(
    String recordId,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/api/medical-records/$recordId', data: data);
  }

  @override
  Future<Response> getPatients() async {
    return await dio.get('/api/patients');
  }

  @override
  Future<Response> getMedicalRecord(String id) async {
    return await dio.get('/api/patients/$id/medical-record');
  }

  @override
  Future<Response> createScreening(String id, Map<String, dynamic> data) async {
    return await dio.post('/api/patients/$id/screening', data: data);
  }

  @override
  Future<Response> exportExcel() async {
    return await dio.get(
      '/api/reports/export-excel',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> exportRegistrationFormPDF() async {
    return await dio.get(
      '/api/reports/export-offline-form',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> exportPDF() async {
    return await dio.get(
      '/api/reports/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> getSchedules() async {
    return await dio.get('/api/schedules');
  }

  @override
  Future<Response> createSchedule(Map<String, dynamic> data) async {
    return await dio.post('/api/schedules', data: data);
  }

  @override
  Future<Response> updateSchedule(String id, Map<String, dynamic> data) async {
    return await dio.put('/api/schedules/$id', data: data);
  }

  @override
  Future<Response> deleteSchedule(String id) async {
    return await dio.delete('/api/schedules/$id');
  }

  @override
  Future<Response> exportPatientsRecapPDF() async {
    return await dio.get(
      '/api/patients/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> createSessionNote(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.post('/api/patients/$id/session-notes', data: data);
  }

  @override
  Future<Response> updatePatientStatus(
    String studentId,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/api/patients/$studentId/status', data: data);
  }

  @override
  Future<Response> saveSchedules(Map<String, dynamic> data) async {
    return await dio.put('/api/schedules', data: data);
  }
}

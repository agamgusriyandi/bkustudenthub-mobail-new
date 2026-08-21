import 'package:dio/dio.dart';

abstract class StudentHealthRemoteDataSource {
  Future<Response> getStudentHealthBookings();
  Future<Response> createStudentHealthBooking(Map<String, dynamic> data);
  Future<Response> cancelStudentHealthBooking(String id);
  Future<Response> rescheduleStudentHealthBooking(
    String id,
    Map<String, dynamic> data,
  );
  Future<Response> getAvailableHealthSchedules();
  Future<Response> listHealthWorkers();
  Future<Response> getHealthWorkerSchedules(String id);
  Future<Response> createHealthMandiri(Map<String, dynamic> data);
  Future<Response> createHealthRecord(Map<String, dynamic> data);
  Future<Response> getHealthRingkasan();
  Future<Response> getHealthRiwayat();
  Future<Response> getHealthDetail(String id);
  Future<Response> getHealthTips();
}

class StudentHealthRemoteDataSourceImpl
    implements StudentHealthRemoteDataSource {
  final Dio dio;

  StudentHealthRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> getStudentHealthBookings() async {
    return await dio.get('/student-health/bookings');
  }

  @override
  Future<Response> createStudentHealthBooking(Map<String, dynamic> data) async {
    return await dio.post('/student-health/bookings', data: data);
  }

  @override
  Future<Response> cancelStudentHealthBooking(String id) async {
    return await dio.delete('/student-health/bookings/$id');
  }

  @override
  Future<Response> rescheduleStudentHealthBooking(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put('/student-health/bookings/$id/reschedule', data: data);
  }

  @override
  Future<Response> getAvailableHealthSchedules() async {
    return await dio.get('/student-health/health-worker-schedules');
  }

  @override
  Future<Response> listHealthWorkers() async {
    return await dio.get('/student-health/health-workers');
  }

  @override
  Future<Response> getHealthWorkerSchedules(String id) async {
    return await dio.get('/student-health/health-workers/$id/schedules');
  }

  @override
  Future<Response> createHealthMandiri(Map<String, dynamic> data) async {
    return await dio.post('/student-health/mandiri', data: data);
  }

  @override
  Future<Response> createHealthRecord(Map<String, dynamic> data) async {
    return await dio.post('/student-health/record', data: data);
  }

  @override
  Future<Response> getHealthRingkasan() async {
    return await dio.get('/student-health/ringkasan');
  }

  @override
  Future<Response> getHealthRiwayat() async {
    return await dio.get('/student-health/riwayat');
  }

  @override
  Future<Response> getHealthDetail(String id) async {
    return await dio.get('/student-health/riwayat/$id');
  }

  @override
  Future<Response> getHealthTips() async {
    return await dio.get('/student-health/tips');
  }
}

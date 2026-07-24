import 'package:dio/dio.dart';

abstract class CounselingRemoteDataSource {
  Future<Response> createBooking(Map<String, dynamic> data);
  Future<Response> getFacultyStatistics();
  Future<Response> getCounselingJadwal();
  Future<Response> getStudentPsychologistMedicalRecord();
  Future<Response> getStudentPsychologistBookings();
  Future<Response> createStudentPsychologistBooking(Map<String, dynamic> data);
  Future<Response> cancelStudentPsychologistBooking(String id);
  Future<Response> exportBookingSessionNotePDF(String id);
  Future<Response> rescheduleStudentPsychologistBooking(
    String id,
    Map<String, dynamic> data,
  );
  Future<Response> getAvailablePsychologistSchedules();
  Future<Response> getStudentReferrals();
  Future<Response> requestCounseling(Map<String, dynamic> data);
  Future<Response> getCounselingRiwayat();
  Future<Response> cancelBooking(String id);
  Future<Response> exportStudentSessionNotePDF(String id);
  Future<Response> getCounselingStatus();
}

class CounselingRemoteDataSourceImpl implements CounselingRemoteDataSource {
  final Dio dio;

  CounselingRemoteDataSourceImpl({required this.dio});

  @override
  Future<Response> createBooking(Map<String, dynamic> data) async {
    return await dio.post('/counseling/booking', data: data);
  }

  @override
  Future<Response> getFacultyStatistics() async {
    return await dio.get('/counseling/faculty-statistics');
  }

  @override
  Future<Response> getCounselingJadwal() async {
    return await dio.get('/counseling/jadwal');
  }

  @override
  Future<Response> getStudentPsychologistMedicalRecord() async {
    return await dio.get('/counseling/medical-record');
  }

  @override
  Future<Response> getStudentPsychologistBookings() async {
    return await dio.get('/counseling/psychologist-bookings');
  }

  @override
  Future<Response> createStudentPsychologistBooking(
    Map<String, dynamic> data,
  ) async {
    return await dio.post('/counseling/psychologist-bookings', data: data);
  }

  @override
  Future<Response> cancelStudentPsychologistBooking(String id) async {
    return await dio.delete('/counseling/psychologist-bookings/$id');
  }

  @override
  Future<Response> exportBookingSessionNotePDF(String id) async {
    return await dio.get(
      '/counseling/psychologist-bookings/$id/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> rescheduleStudentPsychologistBooking(
    String id,
    Map<String, dynamic> data,
  ) async {
    return await dio.put(
      '/counseling/psychologist-bookings/$id/reschedule',
      data: data,
    );
  }

  @override
  Future<Response> getAvailablePsychologistSchedules() async {
    return await dio.get('/counseling/psychologist-schedules');
  }

  @override
  Future<Response> getStudentReferrals() async {
    return await dio.get('/counseling/referrals');
  }

  @override
  Future<Response> requestCounseling(Map<String, dynamic> data) async {
    return await dio.post('/counseling/request', data: data);
  }

  @override
  Future<Response> getCounselingRiwayat() async {
    return await dio.get('/counseling/riwayat');
  }

  @override
  Future<Response> cancelBooking(String id) async {
    return await dio.delete('/counseling/riwayat/$id');
  }

  @override
  Future<Response> exportStudentSessionNotePDF(String id) async {
    return await dio.get(
      '/counseling/session-notes/$id/export-pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  @override
  Future<Response> getCounselingStatus() async {
    return await dio.get('/counseling/status');
  }
}

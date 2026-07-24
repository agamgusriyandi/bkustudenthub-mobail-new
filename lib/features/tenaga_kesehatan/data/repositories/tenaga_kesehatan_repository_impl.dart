import 'dart:developer';
import 'package:bkuhub_mobile/features/tenaga_kesehatan/data/datasources/tenaga_kesehatan_remote_data_source.dart';

abstract class TenagaKesehatanRepository {
  Future<dynamic> getActivities();
  Future<dynamic> getBookings();
  Future<dynamic> createManualBooking(Map<String, dynamic> data);
  Future<dynamic> getBookingDetail(String id);
  Future<dynamic> updateBookingStatus(String id, Map<String, dynamic> data);
  Future<dynamic> getAllMedicalRecords();
  Future<dynamic> exportMedicalRecordPDF(String id);
  Future<dynamic> getPatients();
  Future<dynamic> getMedicalRecord(String id);
  Future<dynamic> createScreening(String id, Map<String, dynamic> data);
  Future<dynamic> exportExcel();
  Future<dynamic> exportRegistrationFormPDF();
  Future<dynamic> exportPDF();
  Future<dynamic> getSchedules();
  Future<dynamic> createSchedule(Map<String, dynamic> data);
  Future<dynamic> updateSchedule(String id, Map<String, dynamic> data);
  Future<dynamic> deleteSchedule(String id);
  Future<dynamic> exportPatientsRecapPDF();
  Future<dynamic> createSessionNote(String id, Map<String, dynamic> data);
  Future<dynamic> saveSchedules(Map<String, dynamic> data);
}

class TenagaKesehatanRepositoryImpl implements TenagaKesehatanRepository {
  final TenagaKesehatanRemoteDataSource tenagaKesehatanRemoteDataSource;

  TenagaKesehatanRepositoryImpl({
    required this.tenagaKesehatanRemoteDataSource,
  });

  @override
  Future<dynamic> getActivities() async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.getActivities();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getActivities: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getBookings() async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.getBookings();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getBookings: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createManualBooking(Map<String, dynamic> data) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource
          .createManualBooking(data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createManualBooking: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getBookingDetail(String id) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.getBookingDetail(
        id,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getBookingDetail: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateBookingStatus(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource
          .updateBookingStatus(id, data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateBookingStatus: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getAllMedicalRecords() async {
    try {
      final response =
          await tenagaKesehatanRemoteDataSource.getAllMedicalRecords();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getAllMedicalRecords: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> exportMedicalRecordPDF(String id) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource
          .exportMedicalRecordPDF(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in exportMedicalRecordPDF: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getPatients() async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.getPatients();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getPatients: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getMedicalRecord(String id) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.getMedicalRecord(
        id,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getMedicalRecord: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createScreening(String id, Map<String, dynamic> data) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.createScreening(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createScreening: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> exportExcel() async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.exportExcel();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in exportExcel: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> exportRegistrationFormPDF() async {
    try {
      final response =
          await tenagaKesehatanRemoteDataSource.exportRegistrationFormPDF();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in exportRegistrationFormPDF: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> exportPDF() async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.exportPDF();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in exportPDF: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> getSchedules() async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.getSchedules();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in getSchedules: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createSchedule(Map<String, dynamic> data) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.createSchedule(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createSchedule: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> updateSchedule(String id, Map<String, dynamic> data) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.updateSchedule(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in updateSchedule: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> deleteSchedule(String id) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.deleteSchedule(id);
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in deleteSchedule: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> exportPatientsRecapPDF() async {
    try {
      final response =
          await tenagaKesehatanRemoteDataSource.exportPatientsRecapPDF();
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in exportPatientsRecapPDF: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> createSessionNote(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.createSessionNote(
        id,
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in createSessionNote: $e');
      rethrow;
    }
  }

  @override
  Future<dynamic> saveSchedules(Map<String, dynamic> data) async {
    try {
      final response = await tenagaKesehatanRemoteDataSource.saveSchedules(
        data,
      );
      return response.data['data'] ?? response.data;
    } catch (e) {
      log('Error in saveSchedules: $e');
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:bkuhub_mobile/core/error/failures.dart';
import 'package:bkuhub_mobile/core/utils/either.dart';
import 'package:bkuhub_mobile/features/ormawa/data/datasources/ormawa_remote_data_source.dart';
import 'package:bkuhub_mobile/features/ormawa/data/models/ormawa_agenda_model.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_calendar_repository.dart';
import 'dart:developer';

class OrmawaCalendarRepositoryImpl implements OrmawaCalendarRepository {
  final OrmawaRemoteDataSource remoteDataSource;

  OrmawaCalendarRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<OrmawaAgenda>>> getAgendas(String ormawaId) async {
    try {
      final response = await remoteDataSource.getAgendas(ormawaId);
      final dynamic list = response.data['data'] ?? response.data;
      if (list is List) {
        final agendas = list.map((e) => OrmawaAgendaModel.fromJson(e)).toList();
        return Right(agendas);
      }
      return const Right([]);
    } on DioException catch (e) {
      log('DioException in getAgendas: \${e.message}', error: e, stackTrace: e.stackTrace);
      if (e.response?.statusCode == 401) {
        return const Left(UnauthorizedFailure());
      }
      return Left(ServerFailure(e.response?.data?['message'] ?? 'Gagal mengambil data kalender.'));
    } catch (e, stackTrace) {
      log('Error in getAgendas: \$e', error: e, stackTrace: stackTrace);
      return const Left(ServerFailure('Terjadi kesalahan yang tidak terduga.'));
    }
  }

  @override
  Future<Either<Failure, void>> addAgenda(String ormawaId, Map<String, dynamic> data) async {
    try {
      final payload = Map<String, dynamic>.from(data);
      payload['ormawa_id'] = ormawaId;
      await remoteDataSource.addAgenda(payload);
      return const Right(null);
    } on DioException catch (e) {
      log('DioException in addAgenda: \${e.message}', error: e, stackTrace: e.stackTrace);
      if (e.response?.statusCode == 422) {
        return const Left(ValidationFailure('Pastikan semua field diisi dengan benar.'));
      }
      return Left(ServerFailure(e.response?.data?['message'] ?? 'Gagal menambahkan agenda.'));
    } catch (e, stackTrace) {
      log('Error in addAgenda: \$e', error: e, stackTrace: stackTrace);
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateAgenda(String id, Map<String, dynamic> data) async {
    try {
      await remoteDataSource.updateAgenda(id, data);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? 'Gagal memperbarui agenda.'));
    } catch (e, stackTrace) {
      log('Error in updateAgenda: \$e', error: e, stackTrace: stackTrace);
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAgenda(String id) async {
    try {
      await remoteDataSource.deleteAgenda(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data?['message'] ?? 'Gagal menghapus agenda.'));
    } catch (e, stackTrace) {
      log('Error in deleteAgenda: \$e', error: e, stackTrace: stackTrace);
      return const Left(ServerFailure());
    }
  }
}

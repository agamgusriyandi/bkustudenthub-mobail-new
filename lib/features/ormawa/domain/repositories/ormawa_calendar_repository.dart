import 'package:bkuhub_mobile/core/error/failures.dart';
import 'package:bkuhub_mobile/core/utils/either.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';

abstract class OrmawaCalendarRepository {
  Future<Either<Failure, List<OrmawaAgenda>>> getAgendas(String ormawaId);
  Future<Either<Failure, void>> addAgenda(String ormawaId, Map<String, dynamic> data);
  Future<Either<Failure, void>> updateAgenda(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> deleteAgenda(String id);
}

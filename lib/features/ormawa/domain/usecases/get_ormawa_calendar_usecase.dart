import 'package:bkuhub_mobile/core/error/failures.dart';
import 'package:bkuhub_mobile/core/utils/either.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/repositories/ormawa_calendar_repository.dart';

class GetOrmawaCalendarUseCase {
  final OrmawaCalendarRepository repository;

  GetOrmawaCalendarUseCase(this.repository);

  Future<Either<Failure, List<OrmawaAgenda>>> execute(String ormawaId) async {
    return await repository.getAgendas(ormawaId);
  }
}

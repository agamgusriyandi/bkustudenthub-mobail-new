import 'package:flutter/foundation.dart';
import 'package:bkuhub_mobile/core/state/ui_state.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/entities/ormawa_agenda.dart';
import 'package:bkuhub_mobile/features/ormawa/domain/usecases/get_ormawa_calendar_usecase.dart';

class OrmawaCalendarProvider extends ChangeNotifier {
  final GetOrmawaCalendarUseCase getOrmawaCalendarUseCase;

  OrmawaCalendarProvider(this.getOrmawaCalendarUseCase);

  UiState<List<OrmawaAgenda>> _calendarState = const InitialState();
  UiState<List<OrmawaAgenda>> get calendarState => _calendarState;

  Future<void> fetchAgendas(String ormawaId) async {
    _calendarState = const LoadingState();
    notifyListeners();

    final result = await getOrmawaCalendarUseCase.execute(ormawaId);
    
    result.fold(
      (failure) {
        _calendarState = ErrorState(failure.message);
        notifyListeners();
      },
      (agendas) {
        if (agendas.isEmpty) {
          _calendarState = const EmptyState('Belum ada agenda untuk bulan ini.');
        } else {
          _calendarState = SuccessState(agendas);
        }
        notifyListeners();
      }
    );
  }
}
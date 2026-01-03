import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_statistics.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetStatistics getStatistics;

  StatisticsBloc({required this.getStatistics}) : super(const StatisticsInitial()) {
    on<LoadStatistics>(_onLoadStatistics);
  }

  Future<void> _onLoadStatistics(
    LoadStatistics event,
    Emitter<StatisticsState> emit,
  ) async {
    emit(const StatisticsLoading());
    try {
      final result = await getStatistics(event.habitId);
      emit(StatisticsLoaded(result));
    } catch (e) {
      emit(StatisticsError(e.toString()));
    }
  }
}



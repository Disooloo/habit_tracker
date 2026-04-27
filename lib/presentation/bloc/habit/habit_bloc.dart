import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_habit.dart';
import '../../../domain/usecases/update_habit.dart';
import '../../../domain/usecases/delete_habit.dart';
import '../../../domain/usecases/get_habits.dart';
import '../../../domain/usecases/get_habit_by_id.dart';
import '../../../domain/usecases/track_habit.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../../domain/entities/habit.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/constants/app_constants.dart';
import 'habit_event.dart';
import 'habit_state.dart';

class HabitBloc extends Bloc<HabitEvent, HabitState> {
  final CreateHabit createHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final GetHabits getHabits;
  final GetHabitById getHabitById;
  final TrackHabit trackHabit;
  final HabitRepository repository;

  HabitBloc({
    required this.createHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.getHabits,
    required this.getHabitById,
    required this.trackHabit,
    required this.repository,
  }) : super(const HabitInitial()) {
    on<LoadHabits>(_onLoadHabits);
    on<CreateHabitEvent>(_onCreateHabit);
    on<UpdateHabitEvent>(_onUpdateHabit);
    on<DeleteHabitEvent>(_onDeleteHabit);
    on<TrackHabitEvent>(_onTrackHabit);
    on<LoadHabitDetail>(_onLoadHabitDetail);
    on<DeleteTrackingEvent>(_onDeleteTracking);
  }

  Future<void> _onLoadHabits(LoadHabits event, Emitter<HabitState> emit) async {
    // Сохраняем текущие привычки при загрузке
    List<Habit> currentHabits = [];
    if (state is HabitLoaded) {
      currentHabits = (state as HabitLoaded).habits;
    } else if (state is HabitLoading) {
      currentHabits = (state as HabitLoading).habits;
    }
    emit(HabitLoading(habits: currentHabits));
    try {
      final habits = await getHabits();
      emit(HabitLoaded(habits));
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onCreateHabit(CreateHabitEvent event, Emitter<HabitState> emit) async {
    try {
      final result = await createHabit(event.habit);
      if (result is Success) {
        emit(HabitCreated(event.habit.copyWith(id: result.id)));
        // Reload habits
        add(const LoadHabits());
      } else if (result is Error) {
        emit(HabitError(result.message));
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onUpdateHabit(UpdateHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await updateHabit(event.habit);
      emit(HabitUpdated(event.habit));
      // Reload habits
      add(const LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onDeleteHabit(DeleteHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await deleteHabit(event.id);
      emit(HabitDeleted(event.id));
      // Reload habits
      add(const LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onTrackHabit(TrackHabitEvent event, Emitter<HabitState> emit) async {
    try {
      await trackHabit(
        habitId: event.habitId,
        status: event.status,
        currentValue: event.currentValue,
      );
      emit(HabitTracked(habitId: event.habitId, status: event.status));
      // Reload habits to update status on home screen
      add(const LoadHabits());
      // Reload habit detail if we're viewing it
      if (state is HabitDetailLoaded) {
        final currentState = state as HabitDetailLoaded;
        if (currentState.habit.id == event.habitId) {
          add(LoadHabitDetail(event.habitId));
        }
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onLoadHabitDetail(LoadHabitDetail event, Emitter<HabitState> emit) async {
    emit(const HabitLoading());
    try {
      final habit = await getHabitById(event.habitId);
      if (habit != null) {
        final tracking = await repository.getTrackingByHabitId(event.habitId);
        emit(HabitDetailLoaded(habit: habit, tracking: tracking));
      } else {
        emit(const HabitError('Habit not found'));
      }
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }

  Future<void> _onDeleteTracking(
    DeleteTrackingEvent event,
    Emitter<HabitState> emit,
  ) async {
    try {
      await repository.deleteTrackingById(event.trackingId);
      add(LoadHabitDetail(event.habitId));
      add(const LoadHabits());
    } catch (e) {
      emit(HabitError(e.toString()));
    }
  }
}



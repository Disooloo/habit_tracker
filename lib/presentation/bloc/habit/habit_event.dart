import 'package:equatable/equatable.dart';
import '../../../domain/entities/habit.dart';

abstract class HabitEvent extends Equatable {
  const HabitEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabits extends HabitEvent {
  const LoadHabits();
}

class CreateHabitEvent extends HabitEvent {
  final Habit habit;

  const CreateHabitEvent(this.habit);

  @override
  List<Object?> get props => [habit];
}

class UpdateHabitEvent extends HabitEvent {
  final Habit habit;

  const UpdateHabitEvent(this.habit);

  @override
  List<Object?> get props => [habit];
}

class DeleteHabitEvent extends HabitEvent {
  final int id;

  const DeleteHabitEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class TrackHabitEvent extends HabitEvent {
  final int habitId;
  final String status; // 'done', 'partial', or 'not_done'
  final int? currentValue; // Текущее значение для количественных/временных целей

  const TrackHabitEvent({
    required this.habitId,
    required this.status,
    this.currentValue,
  });

  @override
  List<Object?> get props => [habitId, status, currentValue];
}

class LoadHabitDetail extends HabitEvent {
  final int habitId;

  const LoadHabitDetail(this.habitId);

  @override
  List<Object?> get props => [habitId];
}



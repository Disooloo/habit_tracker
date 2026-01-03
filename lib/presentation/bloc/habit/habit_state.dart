import 'package:equatable/equatable.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_tracking.dart';

abstract class HabitState extends Equatable {
  const HabitState();

  @override
  List<Object?> get props => [];
}

class HabitInitial extends HabitState {
  const HabitInitial();
}

class HabitLoading extends HabitState {
  final List<Habit> habits; // Сохраняем предыдущие привычки при загрузке
  
  const HabitLoading({this.habits = const []});

  @override
  List<Object?> get props => [habits];
}

class HabitLoaded extends HabitState {
  final List<Habit> habits;

  const HabitLoaded(this.habits);

  @override
  List<Object?> get props => [habits];
}

class HabitError extends HabitState {
  final String message;

  const HabitError(this.message);

  @override
  List<Object?> get props => [message];
}

class HabitCreated extends HabitState {
  final Habit habit;

  const HabitCreated(this.habit);

  @override
  List<Object?> get props => [habit];
}

class HabitUpdated extends HabitState {
  final Habit habit;

  const HabitUpdated(this.habit);

  @override
  List<Object?> get props => [habit];
}

class HabitDeleted extends HabitState {
  final int id;

  const HabitDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class HabitTracked extends HabitState {
  final int habitId;
  final String status;

  const HabitTracked({
    required this.habitId,
    required this.status,
  });

  @override
  List<Object?> get props => [habitId, status];
}

class HabitDetailLoaded extends HabitState {
  final Habit habit;
  final List<HabitTracking> tracking;

  const HabitDetailLoaded({
    required this.habit,
    required this.tracking,
  });

  @override
  List<Object?> get props => [habit, tracking];
}



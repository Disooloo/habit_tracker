import 'package:equatable/equatable.dart';

abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

class TimerInitial extends TimerState {
  const TimerInitial();
}

class TimerRunning extends TimerState {
  final int habitId;
  final int remainingSeconds;
  final int totalSeconds;

  const TimerRunning({
    required this.habitId,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  List<Object?> get props => [habitId, remainingSeconds, totalSeconds];

  double get progress => 1.0 - (remainingSeconds / totalSeconds);
}

class TimerPaused extends TimerState {
  final int habitId;
  final int remainingSeconds;
  final int totalSeconds;

  const TimerPaused({
    required this.habitId,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  List<Object?> get props => [habitId, remainingSeconds, totalSeconds];
}

class TimerCompleted extends TimerState {
  final int habitId;
  final int totalSeconds;

  const TimerCompleted({
    required this.habitId,
    required this.totalSeconds,
  });

  @override
  List<Object?> get props => [habitId, totalSeconds];
}

class TimerFinished extends TimerState {
  const TimerFinished();
}



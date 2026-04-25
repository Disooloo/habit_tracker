import 'package:equatable/equatable.dart';

abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

class TimerStarted extends TimerEvent {
  final int habitId;
  final int durationSeconds;

  const TimerStarted({
    required this.habitId,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props => [habitId, durationSeconds];
}

class TimerTicked extends TimerEvent {
  final int remainingSeconds;

  const TimerTicked(this.remainingSeconds);

  @override
  List<Object?> get props => [remainingSeconds];
}

class TimerCompletedEvent extends TimerEvent {
  const TimerCompletedEvent();
}

class TimerPausedEvent extends TimerEvent {
  const TimerPausedEvent();
}

class TimerResumed extends TimerEvent {
  const TimerResumed();
}

class TimerStopped extends TimerEvent {
  const TimerStopped();
}

class TimerContinue extends TimerEvent {
  const TimerContinue();
}

class TimerFinish extends TimerEvent {
  const TimerFinish();
}


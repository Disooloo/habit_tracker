import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'timer_event.dart';
import 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _timer;

  TimerBloc() : super(const TimerInitial()) {
    on<TimerStarted>(_onTimerStarted);
    on<TimerTicked>(_onTimerTicked);
    on<TimerCompletedEvent>(_onTimerCompleted);
    on<TimerPausedEvent>(_onTimerPaused);
    on<TimerResumed>(_onTimerResumed);
    on<TimerStopped>(_onTimerStopped);
    on<TimerContinue>(_onTimerContinue);
    on<TimerFinish>(_onTimerFinish);
  }

  void _onTimerStarted(TimerStarted event, Emitter<TimerState> emit) {
    _timer?.cancel();
    emit(TimerRunning(
      habitId: event.habitId,
      remainingSeconds: event.durationSeconds,
      totalSeconds: event.durationSeconds,
    ));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState is TimerRunning) {
        if (currentState.remainingSeconds > 0) {
          add(TimerTicked(currentState.remainingSeconds - 1));
        } else {
          add(const TimerCompletedEvent());
        }
      }
    });
  }

  void _onTimerTicked(TimerTicked event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is TimerRunning) {
      emit(TimerRunning(
        habitId: currentState.habitId,
        remainingSeconds: event.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
      ));
    }
  }

  void _onTimerCompleted(TimerCompletedEvent event, Emitter<TimerState> emit) {
    final currentState = state;
    _timer?.cancel();
    _timer = null;
    if (currentState is TimerRunning) {
      emit(TimerCompleted(
        habitId: currentState.habitId,
        totalSeconds: currentState.totalSeconds,
      ));
      return;
    }
    emit(const TimerInitial());
  }

  void _onTimerPaused(TimerPausedEvent event, Emitter<TimerState> emit) {
    _timer?.cancel();
    final currentState = state;
    if (currentState is TimerRunning) {
      emit(TimerPaused(
        habitId: currentState.habitId,
        remainingSeconds: currentState.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
      ));
    }
  }

  void _onTimerResumed(TimerResumed event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is TimerPaused) {
      emit(TimerRunning(
        habitId: currentState.habitId,
        remainingSeconds: currentState.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
      ));
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final currentState = state;
        if (currentState is TimerRunning) {
          if (currentState.remainingSeconds > 0) {
            add(TimerTicked(currentState.remainingSeconds - 1));
          } else {
            add(const TimerCompletedEvent());
          }
        }
      });
    }
  }

  void _onTimerStopped(TimerStopped event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(const TimerInitial());
  }

  void _onTimerContinue(TimerContinue event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is TimerCompleted) {
      emit(TimerRunning(
        habitId: currentState.habitId,
        remainingSeconds: currentState.totalSeconds,
        totalSeconds: currentState.totalSeconds,
      ));
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final runningState = state;
        if (runningState is TimerRunning) {
          if (runningState.remainingSeconds > 0) {
            add(TimerTicked(runningState.remainingSeconds - 1));
          } else {
            add(const TimerCompletedEvent());
          }
        }
      });
    }
  }

  void _onTimerFinish(TimerFinish event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(const TimerFinished());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}


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
        remainingSeconds: event.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
      ));
    }
  }

  void _onTimerCompleted(TimerCompletedEvent event, Emitter<TimerState> emit) {
    _timer?.cancel();
    _timer = null;
    emit(const TimerCompleted());
  }

  void _onTimerPaused(TimerPausedEvent event, Emitter<TimerState> emit) {
    _timer?.cancel();
    final currentState = state;
    if (currentState is TimerRunning) {
      emit(TimerPaused(
        remainingSeconds: currentState.remainingSeconds,
        totalSeconds: currentState.totalSeconds,
      ));
    }
  }

  void _onTimerResumed(TimerResumed event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is TimerPaused) {
      emit(TimerRunning(
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
    // Restart timer for another 30 seconds
    add(const TimerStarted(30));
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


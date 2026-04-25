import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_event.dart';
import '../../bloc/timer/timer_state.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../../domain/entities/habit.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/timer_widget.dart';
import '../../../services/in_app_notification_service.dart';

class TimerScreen extends StatefulWidget {
  final int habitId;

  const TimerScreen({super.key, required this.habitId});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  bool _timerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Загружаем привычку
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(LoadHabitDetail(widget.habitId));
    });
  }

  Habit? _currentHabit;
  int _lastUpdatedSeconds = -1;
  static const List<String> _finishMessages = [
    'Прекрасная работа! Сегодня вы закрыли цель.',
    'Супер! Еще один выполненный день.',
    'Отличный результат, вы в ритме!',
    'Класс! Вы завершили привычку на сегодня.',
  ];

  void _initializeTimer(Habit habit) {
    if (_timerInitialized) return;
    _currentHabit = habit;

    final timerState = context.read<TimerBloc>().state;
    if ((timerState is TimerRunning || timerState is TimerPaused || timerState is TimerCompleted) &&
        ((timerState is TimerRunning && timerState.habitId == habit.id) ||
            (timerState is TimerPaused && timerState.habitId == habit.id) ||
            (timerState is TimerCompleted && timerState.habitId == habit.id))) {
      _timerInitialized = true;
      return;
    }
    _timerInitialized = true;

    int timerSeconds = AppConstants.quickStartTimerSeconds; // По умолчанию 30 секунд
    
    // Если у привычки установлено время, используем его
    if (habit.goalType == 'time' && habit.targetValue != null) {
      final targetValue = habit.targetValue!;
      final unit = habit.unit ?? 'минут';
      
      // Конвертируем в секунды
      if (unit.contains('секунд')) {
        timerSeconds = targetValue;
      } else if (unit.contains('минут')) {
        timerSeconds = targetValue * 60;
      } else if (unit.contains('час')) {
        timerSeconds = targetValue * 3600;
      }
    }
    
    // Записываем начало выполнения
    context.read<HabitBloc>().add(
      TrackHabitEvent(
        habitId: widget.habitId,
        status: AppConstants.statusPartial, // Начали - значит частично
        currentValue: 0, // Начали с 0
      ),
    );
    
    context.read<TimerBloc>().add(TimerStarted(
          habitId: widget.habitId,
          durationSeconds: timerSeconds,
        ));
  }

  void _saveProgressOnPause(BuildContext context, TimerPaused state) {
    if (_currentHabit?.goalType != 'time' || _currentHabit?.targetValue == null) return;
    
    final totalSeconds = state.totalSeconds;
    final elapsedSeconds = totalSeconds - state.remainingSeconds;
    final progress = elapsedSeconds / totalSeconds;
    
    // Определяем статус: 50% = partial, 100% = done
    final status = progress >= 1.0
        ? AppConstants.statusDone
        : progress >= 0.5
            ? AppConstants.statusPartial
            : AppConstants.statusPartial;
    
    // Конвертируем прошедшее время в единицы привычки
    int currentValue = elapsedSeconds;
    if (_currentHabit!.unit != null) {
      if (_currentHabit!.unit!.contains('минут')) {
        currentValue = elapsedSeconds ~/ 60;
      } else if (_currentHabit!.unit!.contains('час')) {
        currentValue = elapsedSeconds ~/ 3600;
      }
    }
    
    context.read<HabitBloc>().add(
      TrackHabitEvent(
        habitId: widget.habitId,
        status: status,
        currentValue: currentValue,
      ),
    );
  }

  void _updateProgress(BuildContext context, TimerRunning state) {
    if (_currentHabit?.goalType != 'time' || _currentHabit?.targetValue == null) return;
    
    final totalSeconds = state.totalSeconds;
    final elapsedSeconds = totalSeconds - state.remainingSeconds;
    final progress = elapsedSeconds / totalSeconds;
    
    // Обновляем при достижении важных отметок (50%, 100%) или каждые 10 секунд
    final progressPercent = (progress * 100).round();
    final shouldUpdate = progressPercent >= 50 && elapsedSeconds != _lastUpdatedSeconds
        || elapsedSeconds % 10 == 0 && elapsedSeconds != _lastUpdatedSeconds;
    
    if (!shouldUpdate) return;
    
    _lastUpdatedSeconds = elapsedSeconds;
    
    // Определяем статус: 50% = partial, 100% = done
    final status = progress >= 1.0
        ? AppConstants.statusDone
        : progress >= 0.5
            ? AppConstants.statusPartial
            : AppConstants.statusPartial; // Начали - уже partial
    
    // Конвертируем прошедшее время в единицы привычки
    int currentValue = elapsedSeconds;
    if (_currentHabit!.unit != null) {
      if (_currentHabit!.unit!.contains('минут')) {
        currentValue = elapsedSeconds ~/ 60;
      } else if (_currentHabit!.unit!.contains('час')) {
        currentValue = elapsedSeconds ~/ 3600;
      }
    }
    
    context.read<HabitBloc>().add(
      TrackHabitEvent(
        habitId: widget.habitId,
        status: status,
        currentValue: currentValue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.start30Seconds),
        actions: [
          IconButton(
            tooltip: 'Сбросить',
            onPressed: () {
              context.read<TimerBloc>().add(const TimerStopped());
              Navigator.of(context).maybePop();
            },
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: BlocListener<TimerBloc, TimerState>(
        listener: (context, state) {
          if (state is TimerFinished) {
            // Возвращаемся только на предыдущий экран,
            // чтобы кнопка "назад" вела по реальному стеку.
            Navigator.of(context).maybePop();
          }
          // Обновляем прогресс при тике таймера
          if (state is TimerRunning) {
            _updateProgress(context, state);
          }
          // Сохраняем прогресс при паузе
          if (state is TimerPaused) {
            _saveProgressOnPause(context, state);
          }
        },
        child: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, habitState) {
            // Инициализируем таймер когда привычка загружена
            if (habitState is HabitDetailLoaded) {
              _initializeTimer(habitState.habit);
            }
            
            return BlocBuilder<TimerBloc, TimerState>(
              builder: (context, state) {
                if (state is TimerRunning) {
                  return _buildRunningState(context, state);
                }

                if (state is TimerCompleted) {
                  return _buildCompletedState(context);
                }

                if (state is TimerPaused) {
                  return _buildPausedState(context, state);
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRunningState(BuildContext context, TimerRunning state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (value * 0.2),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: TimerWidget(
              remainingSeconds: state.remainingSeconds,
              totalSeconds: state.totalSeconds,
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      context.read<TimerBloc>().add(const TimerPausedEvent());
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.pause, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 32),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      // Сохраняем прогресс перед остановкой
                      final currentState = context.read<TimerBloc>().state;
                      if (currentState is TimerRunning) {
                        _saveProgressOnPause(context, TimerPaused(
                          habitId: currentState.habitId,
                          remainingSeconds: currentState.remainingSeconds,
                          totalSeconds: currentState.totalSeconds,
                        ));
                      }
                      context.read<TimerBloc>().add(const TimerStopped());
                      // Возвращаемся только на предыдущий экран.
                      Navigator.of(context).maybePop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.stop, size: 48),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPausedState(BuildContext context, TimerPaused state) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimerWidget(
            remainingSeconds: state.remainingSeconds,
            totalSeconds: state.totalSeconds,
          ),
          const SizedBox(height: 48),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<TimerBloc>().add(const TimerResumed());
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Продолжить'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(
                Icons.check_circle,
                size: 120,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              l10n.thisIsEnough,
              style: theme.textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Mark as done
                  context.read<HabitBloc>().add(
                        TrackHabitEvent(
                          habitId: widget.habitId,
                          status: AppConstants.statusDone,
                        ),
                      );
                  final message = _finishMessages[
                      DateTime.now().millisecond % _finishMessages.length];
                  InAppNotificationService().addMessage(message);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                  // Continue timer
                  context.read<TimerBloc>().add(const TimerContinue());
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(l10n.continueAction),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Mark as done
                  context.read<HabitBloc>().add(
                        TrackHabitEvent(
                          habitId: widget.habitId,
                          status: AppConstants.statusDone,
                        ),
                      );
                  final message = _finishMessages[
                      DateTime.now().millisecond % _finishMessages.length];
                  InAppNotificationService().addMessage(message);
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(message)));
                  // Finish
                  context.read<TimerBloc>().add(const TimerFinish());
                },
                icon: const Icon(Icons.check),
                label: Text(l10n.finish),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


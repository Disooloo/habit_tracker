import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_state.dart';
import '../timer/timer_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as habit_date_utils;
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/habit_tracking.dart';
import '../../../domain/entities/habit.dart';

class HabitDetailScreen extends StatelessWidget {
  final int habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: context.read<HabitBloc>(),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/habit-form',
                  arguments: habitId,
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HabitError) {
              return Center(child: Text(state.message));
            }

            if (state is HabitDetailLoaded) {
              return _buildContent(context, state.habit, state.tracking);
            }

            // Load habit detail if not loaded
            if (state is! HabitDetailLoaded) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<HabitBloc>().add(LoadHabitDetail(habitId));
              });
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    Habit habit,
    List<HabitTracking> tracking,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            habit.name,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            habit.minimalAction,
            style: theme.textTheme.bodyLarge,
          ),
          // Показываем цель если есть
          if (habit.goalType != null && habit.targetValue != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Цель: ${habit.targetValue} ${habit.unit ?? ""}',
                    style: theme.textTheme.titleMedium,
                  ),
                  IconButton(
                    icon: const Icon(Icons.trending_up),
                    tooltip: 'Повысить планку',
                    onPressed: () => _showIncreaseGoalDialog(context, habit),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 32),
          // Показываем информацию о паузе если есть активный таймер
          BlocBuilder<TimerBloc, TimerState>(
            builder: (context, timerState) {
              if (timerState is TimerPaused && habit.goalType == 'time') {
                final remaining = timerState.remainingSeconds;
                String remainingText = '';
                if (habit.unit != null) {
                  if (habit.unit!.contains('минут')) {
                    remainingText = '${remaining ~/ 60} ${habit.unit}';
                  } else if (habit.unit!.contains('час')) {
                    remainingText = '${remaining ~/ 3600} ${habit.unit}';
                  } else {
                    remainingText = '$remaining ${habit.unit}';
                  }
                } else {
                  remainingText = '${remaining ~/ 60} минут';
                }
                
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.partialColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pause_circle_outline),
                          const SizedBox(width: 8),
                          Text('Осталось: $remainingText'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/timer',
                  arguments: habitId,
                );
              },
              icon: const Icon(Icons.play_circle_outline),
              label: Text(
                habit.goalType == 'time' && habit.targetValue != null
                    ? 'Начать на ${habit.targetValue} ${habit.unit ?? ""}'
                    : l10n.start30Seconds,
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.history,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (tracking.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noTrackingYet,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.startTracking,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            )
          else
            ...tracking.map((t) => _buildTrackingItem(context, t)),
        ],
      ),
    );
  }

  Widget _buildTrackingItem(BuildContext context, HabitTracking tracking) {
    final theme = Theme.of(context);
    final date = habit_date_utils.DateUtils.parseDate(tracking.date);
    final isToday = habit_date_utils.DateUtils.isToday(date);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (tracking.status == AppConstants.statusDone) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
      statusText = 'Выполнено';
    } else if (tracking.status == AppConstants.statusPartial) {
      statusColor = AppTheme.partialColor;
      statusIcon = Icons.radio_button_checked;
      statusText = 'Сделано немного';
    } else {
      statusColor = AppTheme.neutralColor;
      statusIcon = Icons.circle_outlined;
      statusText = 'Не сделал';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(statusIcon, color: statusColor),
        title: Text(
          isToday ? 'Сегодня' : habit_date_utils.DateUtils.getDayOfWeekName(date),
        ),
        subtitle: Text(
          '${date.day}.${date.month}.${date.year}',
        ),
        trailing: Text(
          statusText,
          style: TextStyle(color: statusColor),
        ),
      ),
    );
  }

  void _showIncreaseGoalDialog(BuildContext context, Habit habit) {
    final controller = TextEditingController(
      text: (habit.targetValue ?? 1).toString(),
    );
    final unit = habit.unit ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Повысить планку'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Текущая цель: ${habit.targetValue} $unit'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Новая цель ($unit)',
                hintText: '${(habit.targetValue ?? 1) + 1}',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = int.tryParse(controller.text);
              if (newValue != null && newValue > (habit.targetValue ?? 0)) {
                final updatedHabit = habit.copyWith(targetValue: newValue);
                context.read<HabitBloc>().add(UpdateHabitEvent(updatedHabit));
                Navigator.of(context).pop();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}


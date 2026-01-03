import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_tracking.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as habit_date_utils;
import '../bloc/habit/habit_bloc.dart';
import '../bloc/habit/habit_event.dart';
import '../screens/timer/timer_screen.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final HabitTracking? todayTracking; // Статус на сегодня
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged; // status: 'done', 'partial', 'not_done'

  const HabitCard({
    super.key,
    required this.habit,
    this.todayTracking,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (value * 0.1),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text(
                habit.name,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                habit.minimalAction,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              // Показываем прогресс для количественных/временных целей
              if (habit.goalType != null && habit.targetValue != null) ...[
                _buildProgressIndicator(context, habit, todayTracking),
                const SizedBox(height: 8),
              ],
              // Динамическая кнопка для привычек со временем
              if (habit.goalType == 'time' && habit.targetValue != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: Hero(
                    tag: 'timer_button_${habit.id}',
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                TimerScreen(habitId: habit.id),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: const Duration(milliseconds: 300),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_outline),
                      label: Text(_getTimerButtonText(habit)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // Показываем текущий статус если есть
              if (todayTracking != null) ...[
                _buildCurrentStatus(context, todayTracking!),
                const SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusButton(
                    context,
                    l10n.done,
                    AppTheme.successColor,
                    Icons.check_circle,
                    AppConstants.statusDone,
                    todayTracking?.status == AppConstants.statusDone,
                  ),
                  _buildStatusButton(
                    context,
                    l10n.partial,
                    AppTheme.partialColor,
                    Icons.radio_button_checked,
                    AppConstants.statusPartial,
                    todayTracking?.status == AppConstants.statusPartial,
                  ),
                  _buildStatusButton(
                    context,
                    l10n.notDone,
                    AppTheme.neutralColor,
                    Icons.circle_outlined,
                    AppConstants.statusNotDone,
                    todayTracking?.status == AppConstants.statusNotDone,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    Habit habit,
    HabitTracking? tracking,
  ) {
    final theme = Theme.of(context);
    final current = tracking?.currentValue ?? 0;
    final target = habit.targetValue ?? 1;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    
    // Формируем текст единицы измерения
    String unitText = '';
    if (habit.goalType == 'time' && habit.unit != null) {
      unitText = ' ${habit.unit}';
    } else if (habit.goalType == 'quantity') {
      // Для количества единица не показывается, только число
      unitText = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '$current / $target$unitText',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (habit.goalType == 'quantity')
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                tween: Tween(begin: 1.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // Анимация нажатия
                      _incrementQuantity(context, habit, tracking);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            if (habit.goalType == 'time')
              IconButton(
                icon: const Icon(Icons.edit),
                color: theme.colorScheme.primary,
                onPressed: () => _showProgressDialog(context, habit, tracking),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          tween: Tween(begin: 0.0, end: progress),
          builder: (context, value, child) {
            return LinearProgressIndicator(
              value: value,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0
                    ? AppTheme.successColor
                    : progress > 0.0
                        ? AppTheme.partialColor
                        : AppTheme.neutralColor,
              ),
            );
          },
        ),
        if (habit.goalType == 'time' && current < target)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Осталось: ${target - current} ${habit.unit ?? ""}',
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }

  void _showProgressDialog(
    BuildContext context,
    Habit habit,
    HabitTracking? tracking,
  ) {
    final controller = TextEditingController(
      text: (tracking?.currentValue ?? 0).toString(),
    );
    final target = habit.targetValue ?? 1;
    final unitText = habit.goalType == 'time' && habit.unit != null 
        ? ' ${habit.unit}' 
        : '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(habit.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Цель: $target$unitText'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: habit.goalType == 'time' 
                    ? 'Текущее значение$unitText'
                    : 'Текущее количество',
                hintText: '0',
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
              final value = int.tryParse(controller.text) ?? 0;
              final status = value >= target
                  ? AppConstants.statusDone
                  : value > 0
                      ? AppConstants.statusPartial
                      : AppConstants.statusNotDone;
              if (onStatusChanged != null) {
                // Нужно передать currentValue через callback
                Navigator.of(context).pop();
                // Вызываем через специальный callback для количественных целей
                _onProgressChanged(context, habit.id, value, status);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _incrementQuantity(BuildContext context, Habit habit, HabitTracking? tracking) {
    final current = tracking?.currentValue ?? 0;
    final newValue = current + 1;
    final target = habit.targetValue ?? 1;
    
    // Определяем статус
    final status = newValue >= target
        ? AppConstants.statusDone
        : newValue > 0
            ? AppConstants.statusPartial
            : AppConstants.statusNotDone;
    
    // Анимация нажатия
    context.read<HabitBloc>().add(
      TrackHabitEvent(
        habitId: habit.id,
        status: status,
        currentValue: newValue,
      ),
    );
  }

  void _onProgressChanged(
    BuildContext context,
    int habitId,
    int currentValue,
    String status,
  ) {
    // Используем Bloc напрямую для передачи currentValue
    context.read<HabitBloc>().add(
          TrackHabitEvent(
            habitId: habitId,
            status: status,
            currentValue: currentValue,
          ),
        );
  }

  String _getTimerButtonText(Habit habit) {
    if (habit.goalType == 'time' && habit.targetValue != null) {
      final value = habit.targetValue!;
      final unit = habit.unit ?? 'минут';
      return 'Начать на $value $unit';
    }
    return 'Начать';
  }

  Widget _buildCurrentStatus(BuildContext context, HabitTracking tracking) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (tracking.status == AppConstants.statusDone) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.check_circle;
      statusText = 'Выполнено сегодня';
    } else if (tracking.status == AppConstants.statusPartial) {
      statusColor = AppTheme.partialColor;
      statusIcon = Icons.radio_button_checked;
      statusText = 'Сделано немного сегодня';
    } else {
      statusColor = AppTheme.neutralColor;
      statusIcon = Icons.circle_outlined;
      statusText = 'Пропущено сегодня';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 16, color: statusColor),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    Color color,
    IconData icon,
    String status,
    bool isSelected,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: OutlinedButton.icon(
          onPressed: onStatusChanged != null
              ? () => onStatusChanged!(status)
              : null,
          icon: Icon(icon, size: 20, color: color),
          label: Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: color,
              width: isSelected ? 2 : 1,
            ),
            backgroundColor: isSelected ? color.withOpacity(0.1) : null,
            padding: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}


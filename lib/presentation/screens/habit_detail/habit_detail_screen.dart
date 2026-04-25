import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as habit_date_utils;
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/habit_tracking.dart';
import '../../../domain/entities/habit.dart';
import '../../../services/habit_advice_service.dart';
import '../../../services/habit_goal_service.dart';

enum HistoryRange { day1, day3, week, month, custom }

class HabitDetailScreen extends StatefulWidget {
  final int habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  HistoryRange _selectedRange = HistoryRange.week;
  DateTimeRange? _customRange;
  final HabitAdviceService _adviceService = HabitAdviceService();
  final HabitGoalService _goalService = HabitGoalService();
  String? _currentGoal;

  @override
  void initState() {
    super.initState();
    _loadGoal();
  }

  Future<void> _loadGoal() async {
    final goal = await _goalService.getGoal(widget.habitId);
    if (!mounted) return;
    setState(() {
      _currentGoal = goal;
    });
  }

  List<HabitTracking> _filterTracking(List<HabitTracking> items) {
    if (items.isEmpty) return items;
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedRange) {
      case HistoryRange.day1:
        start = DateTime(now.year, now.month, now.day);
        break;
      case HistoryRange.day3:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 2));
        break;
      case HistoryRange.week:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
        break;
      case HistoryRange.month:
        start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 29));
        break;
      case HistoryRange.custom:
        if (_customRange == null) return items;
        start = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day);
        end = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
        break;
    }

    return items.where((t) {
      final ts = t.timestamp;
      return !ts.isBefore(start) && !ts.isAfter(end);
    }).toList();
  }

  String _formatRemaining(TimerState timerState, Habit habit) {
    final remaining = timerState is TimerPaused ? timerState.remainingSeconds : 0;
    final mm = (remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (remaining % 60).toString().padLeft(2, '0');
    if (habit.unit != null && habit.unit!.contains('час')) {
      final hours = (remaining ~/ 3600).toString().padLeft(2, '0');
      final min = ((remaining % 3600) ~/ 60).toString().padLeft(2, '0');
      return '$hours:$min:${ss}';
    }
    return '$mm:$ss';
  }

  @override
  Widget build(BuildContext context) {

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
                  arguments: widget.habitId,
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
                context.read<HabitBloc>().add(LoadHabitDetail(widget.habitId));
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
    final filteredTracking = _filterTracking(tracking);

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
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () async {
              final advice =
                  await _adviceService.getAdviceForHabit(habit.id, habit.name);
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Совет по привычке'),
                  content: Text(advice),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Понятно'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.lightbulb_outline),
            label: const Text('Совет'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showGoalDialog(context),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Цель'),
          ),
          if (_currentGoal != null && _currentGoal!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Текущая цель: $_currentGoal',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ..._goalService
                        .buildPlanForGoal(_currentGoal!)
                        .map((step) => Text('• $step')),
                  ],
                ),
              ),
            ),
          ],
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
              if (timerState is TimerPaused &&
                  timerState.habitId == habit.id &&
                  habit.goalType == 'time') {
                final remainingText = _formatRemaining(timerState, habit);
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
                          Text('Пауза. Осталось: $remainingText'),
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
          if (habit.goalType == 'time') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    '/timer',
                    arguments: widget.habitId,
                  );
                },
                icon: const Icon(Icons.play_circle_outline),
                label: BlocBuilder<TimerBloc, TimerState>(
                  builder: (context, timerState) {
                    if (timerState is TimerPaused &&
                        timerState.habitId == habit.id &&
                        habit.goalType == 'time') {
                      return Text('Продолжить (${_formatRemaining(timerState, habit)})');
                    }
                    return Text(
                      habit.goalType == 'time' && habit.targetValue != null
                          ? 'Начать на ${habit.targetValue} ${habit.unit ?? ""}'
                          : l10n.start30Seconds,
                    );
                  },
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
          Text(
            l10n.history,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildRangeChip('1 день', HistoryRange.day1),
              _buildRangeChip('3 дня', HistoryRange.day3),
              _buildRangeChip('Неделя', HistoryRange.week),
              _buildRangeChip('Месяц', HistoryRange.month),
              ActionChip(
                label: Text(
                  _selectedRange == HistoryRange.custom && _customRange != null
                      ? '${_customRange!.start.day}.${_customRange!.start.month} - ${_customRange!.end.day}.${_customRange!.end.month}'
                      : 'Свой период',
                ),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
                    lastDate: DateTime.now(),
                    currentDate: DateTime.now(),
                  );
                  if (range != null && mounted) {
                    setState(() {
                      _customRange = range;
                      _selectedRange = HistoryRange.custom;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredTracking.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  tracking.isEmpty ? l10n.noTrackingYet : 'За выбранный период записей нет',
                ),
              ),
            )
          else
            ...filteredTracking.map((t) => _buildTrackingItem(context, t)),
        ],
      ),
    );
  }

  Widget _buildRangeChip(String label, HistoryRange range) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedRange == range,
      onSelected: (_) {
        setState(() {
          _selectedRange = range;
        });
      },
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
          '${date.day}.${date.month}.${date.year}  ${tracking.timestamp.hour.toString().padLeft(2, '0')}:${tracking.timestamp.minute.toString().padLeft(2, '0')}',
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

  Future<void> _showGoalDialog(BuildContext context) async {
    final controller = TextEditingController(text: _currentGoal ?? '');
    String selectedTemplate = HabitGoalService.readingGoalTemplates.first;

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Цель привычки'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Шаблоны целей:'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedTemplate,
                  items: HabitGoalService.readingGoalTemplates
                      .map(
                        (t) => DropdownMenuItem<String>(
                          value: t,
                          child: Text(t),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() {
                      selectedTemplate = value;
                    });
                    controller.text = value;
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Моя цель',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () async {
                final goal = controller.text.trim();
                if (goal.isEmpty) return;
                await _goalService.saveGoal(widget.habitId, goal);
                if (mounted) {
                  setState(() {
                    _currentGoal = goal;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}


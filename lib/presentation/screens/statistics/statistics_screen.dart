import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../bloc/statistics/statistics_bloc.dart';
import '../../bloc/statistics/statistics_event.dart';
import '../../bloc/statistics/statistics_state.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_state.dart';
import '../../widgets/statistics_card.dart';
import '../../../core/utils/date_utils.dart' as habit_date_utils;
import '../../../domain/entities/habit.dart';

class StatisticsScreen extends StatefulWidget {
  final int? habitId; // If null, show overall stats

  const StatisticsScreen({super.key, this.habitId});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  int? _selectedHabitId;

  @override
  void initState() {
    super.initState();
    _selectedHabitId = widget.habitId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
      ),
      body: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, habitState) {
          // Get habits list for selection
          List<Habit> habits = [];
          if (habitState is HabitLoaded) {
            habits = habitState.habits;
          }

          // If no habit selected and we have habits, select first one
          if (_selectedHabitId == null && habits.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _selectedHabitId = habits.first.id;
              });
            });
          }

          // If we have a selected habit, load its statistics
          if (_selectedHabitId != null) {
            return BlocBuilder<StatisticsBloc, StatisticsState>(
              builder: (context, state) {
                if (state is StatisticsLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is StatisticsError) {
                  return Center(child: Text(state.message));
                }

                if (state is StatisticsLoaded) {
                  return _buildStatisticsContent(
                    context,
                    state.result,
                    habits,
                  );
                }

                // Load statistics
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<StatisticsBloc>().add(
                        LoadStatistics(_selectedHabitId!),
                      );
                });

                return const Center(child: CircularProgressIndicator());
              },
            );
          }

          // No habits
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noHabitsYet,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsContent(
    BuildContext context,
    result,
    List<Habit> habits,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit selector
          if (habits.length > 1)
            DropdownButtonFormField<int>(
              value: _selectedHabitId,
              decoration: const InputDecoration(
                labelText: 'Выберите привычку',
              ),
              items: habits.map((habit) {
                return DropdownMenuItem<int>(
                  value: habit.id,
                  child: Text(habit.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHabitId = value;
                });
                context.read<StatisticsBloc>().add(LoadStatistics(value!));
              },
            ),
          const SizedBox(height: 24),
          // Days with attempt
          StatisticsCard(
            title: l10n.daysWithAttempt,
            value: '${result.daysWithAttempt} из ${result.totalDays} (${result.attemptPercentage.toStringAsFixed(1)}%)',
            icon: Icons.calendar_today,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          // Best day of week
          StatisticsCard(
            title: l10n.bestDayOfWeek,
            value: result.bestDayName ?? 'Нет данных',
            icon: Icons.star,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 16),
          // Comeback count
          StatisticsCard(
            title: l10n.youCameBack,
            value: '${result.comebackCount} раз',
            icon: Icons.refresh,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 32),
          // Weekday chart
          if (result.weekdayStats.isNotEmpty) ...[
            Text(
              'Активность по дням недели',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildWeekdayChart(context, result.weekdayStats),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekdayChart(BuildContext context, Map<int, int> weekdayStats) {
    final theme = Theme.of(context);
    final maxCount = weekdayStats.values.isEmpty
        ? 1
        : weekdayStats.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(7, (index) {
            final weekday = index + 1; // 1-7 (Monday-Sunday)
            final count = weekdayStats[weekday] ?? 0;
            final percentage = maxCount > 0 ? count / maxCount : 0.0;

            final date = DateTime.now();
            final testDate = date.add(Duration(days: weekday - date.weekday));
            final dayName = habit_date_utils.DateUtils.getDayOfWeekName(testDate);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      dayName,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    count.toString(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}


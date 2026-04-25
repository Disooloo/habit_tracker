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
import '../../../services/habit_localization_service.dart';

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
      body: BlocListener<HabitBloc, HabitState>(
        listener: (context, state) {
          if (state is HabitTracked || state is HabitUpdated || state is HabitDeleted) {
            if (_selectedHabitId == null) {
              setState(() {});
              return;
            }
            context.read<StatisticsBloc>().add(LoadStatistics(_selectedHabitId!));
          }
        },
        child: BlocBuilder<HabitBloc, HabitState>(
        builder: (context, habitState) {
          // Get habits list for selection
          List<Habit> habits = [];
          if (habitState is HabitLoaded) {
            habits = habitState.habits;
          }

          if (habits.isEmpty) {
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
          }

          // Habit selected -> per habit statistics
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

          // Overall statistics for all habits
          return FutureBuilder<Map<String, num>>(
            future: _loadOverallStats(habits),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildOverallContent(context, habits, snapshot.data!);
            },
          );
        },
      ),
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
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Habit selector
          DropdownButtonFormField<int?>(
            initialValue: _selectedHabitId,
            decoration: InputDecoration(
              labelText: isRu ? 'Режим статистики' : 'Mode',
            ),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(isRu ? 'Все привычки' : 'All habits'),
              ),
              ...habits.map((habit) {
                final localizedName = HabitLocalizationService.localizeHabitName(
                  habit.name,
                  Localizations.localeOf(context).languageCode,
                );
                return DropdownMenuItem<int?>(
                  value: habit.id,
                  child: Text(
                    localizedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedHabitId = value;
              });
              if (value != null) {
                context.read<StatisticsBloc>().add(LoadStatistics(value));
              }
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
            value: result.bestDayName ?? (isRu ? 'Нет данных' : 'No data'),
            icon: Icons.star,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 16),
          // Comeback count
          StatisticsCard(
            title: l10n.youCameBack,
            value: isRu ? '${result.comebackCount} раз' : '${result.comebackCount} times',
            icon: Icons.refresh,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          StatisticsCard(
            title: isRu ? 'Выше нормы' : 'Above target',
            value: isRu ? '${result.aboveNormCount} раз' : '${result.aboveNormCount} times',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          if (result.aboveNormCount > 0) ...[
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  isRu
                      ? 'Вы часто делаете выше нормы. Можно немного повысить порог цели.'
                      : 'You often exceed your target. Consider raising it gradually.',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          // Weekday chart
          if (result.weekdayStats.isNotEmpty) ...[
            Text(
              isRu ? 'Активность по дням недели' : 'Activity by weekday',
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

  Future<Map<String, num>> _loadOverallStats(List<Habit> habits) async {
    final repository = context.read<HabitBloc>().repository;
    int done = 0;
    int partial = 0;
    int notDone = 0;
    int attempts = 0;
    int totalDays = 0;
    int aboveNorm = 0;
    for (final habit in habits) {
      final stats = await repository.getTrackingStatsByHabitId(habit.id);
      done += stats['done'] ?? 0;
      partial += stats['partial'] ?? 0;
      notDone += stats['not_done'] ?? 0;
      attempts += await repository.getDaysWithAttempt(habit.id);
      totalDays += await repository.getTotalDays(habit.id);
      if (habit.targetValue != null) {
        final records = await repository.getTrackingByHabitId(habit.id);
        aboveNorm += records.where((r) => (r.currentValue ?? 0) > habit.targetValue!).length;
      }
    }
    return {
      'done': done,
      'partial': partial,
      'not_done': notDone,
      'attempts': attempts,
      'totalDays': totalDays,
      'rate': totalDays == 0 ? 0 : (attempts / totalDays) * 100,
      'aboveNorm': aboveNorm,
    };
  }

  Widget _buildOverallContent(
    BuildContext context,
    List<Habit> habits,
    Map<String, num> data,
  ) {
    final theme = Theme.of(context);
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<int?>(
            initialValue: _selectedHabitId,
            decoration: InputDecoration(labelText: isRu ? 'Режим статистики' : 'Statistics mode'),
            items: [
              DropdownMenuItem<int?>(
                value: null,
                child: Text(isRu ? 'Все привычки' : 'All habits'),
              ),
              ...habits.map(
                (h) {
                  final name = HabitLocalizationService.localizeHabitName(
                    h.name,
                    Localizations.localeOf(context).languageCode,
                  );
                  return DropdownMenuItem<int?>(
                    value: h.id,
                    child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  );
                },
              ),
            ],
            onChanged: (value) {
              setState(() => _selectedHabitId = value);
              if (value != null) {
                context.read<StatisticsBloc>().add(LoadStatistics(value));
              }
            },
          ),
          const SizedBox(height: 16),
          StatisticsCard(
            title: isRu ? 'Всего выполнено' : 'Total done',
            value: '${data['done']?.toInt() ?? 0}',
            icon: Icons.check_circle_outline,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(height: 16),
          StatisticsCard(
            title: isRu ? 'Частично выполнено' : 'Partial done',
            value: '${data['partial']?.toInt() ?? 0}',
            icon: Icons.timelapse,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(height: 16),
          StatisticsCard(
            title: isRu ? 'Процент попыток' : 'Attempt rate',
            value: '${(data['rate'] ?? 0).toStringAsFixed(1)}%',
            icon: Icons.insights,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          StatisticsCard(
            title: isRu ? 'Выше нормы' : 'Above target',
            value: '${data['aboveNorm']?.toInt() ?? 0}',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          if ((data['aboveNorm']?.toInt() ?? 0) > 0) ...[
            const SizedBox(height: 10),
            Text(
              isRu
                  ? 'Вы часто перевыполняете план. Подумайте о плавном повышении порога.'
                  : 'You often exceed your plan. Consider increasing the target gradually.',
            ),
          ],
        ],
      ),
    );
  }
}


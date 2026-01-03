import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as habit_date_utils;
import '../../widgets/habit_card.dart';
import '../habit_detail/habit_detail_screen.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_tracking.dart';
import '../../../domain/repositories/habit_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(const LoadHabits());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.hello),
            Text(
              l10n.canStartSmall,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).pushNamed('/statistics');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed('/settings');
            },
          ),
        ],
      ),
      body: BlocListener<HabitBloc, HabitState>(
        listener: (context, state) {
          // Перезагружаем привычки при изменении состояния
          if (state is HabitCreated || state is HabitUpdated || state is HabitDeleted || state is HabitTracked) {
            context.read<HabitBloc>().add(const LoadHabits());
          }
        },
        child: BlocBuilder<HabitBloc, HabitState>(
          builder: (context, state) {
            if (state is HabitLoading && state.habits.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HabitError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HabitBloc>().add(const LoadHabits());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            // Используем последнее загруженное состояние или текущее
            List<Habit> habits = [];
            if (state is HabitLoaded) {
              habits = state.habits;
            } else if (state is HabitLoading && state.habits.isNotEmpty) {
              habits = state.habits; // Используем предыдущие привычки при загрузке
            }

            if (habits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.self_improvement,
                      size: 80,
                      color: theme.colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noHabitsYet,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.createFirstHabit,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _HabitsListWidget(
                key: ValueKey('habits_${habits.length}'),
                habits: habits,
                repository: context.read<HabitBloc>().repository,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/habit-form');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _HabitsListWidget extends StatefulWidget {
  final List<Habit> habits;
  final HabitRepository repository;

  const _HabitsListWidget({
    super.key,
    required this.habits,
    required this.repository,
  });

  @override
  State<_HabitsListWidget> createState() => _HabitsListWidgetState();
}

class _HabitsListWidgetState extends State<_HabitsListWidget> {
  Map<int, HabitTracking?> _todayTracking = {};

  @override
  void initState() {
    super.initState();
    _loadTodayTracking();
  }

  @override
  void didUpdateWidget(_HabitsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habits != widget.habits) {
      _loadTodayTracking();
    }
  }

  Future<void> _loadTodayTracking() async {
    final today = habit_date_utils.DateUtils.today();
    final trackingMap = <int, HabitTracking?>{};

    for (final habit in widget.habits) {
      try {
        final tracking = await widget.repository.getTrackingByHabitIdAndDate(
          habit.id,
          today,
        );
        trackingMap[habit.id] = tracking;
        
        // Если нет записи на сегодня, создаем "пропустил" в фоне
        // (не блокируем UI, запись создастся при следующей загрузке)
      } catch (e) {
        trackingMap[habit.id] = null;
      }
    }

    if (mounted) {
      setState(() {
        _todayTracking = trackingMap;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.habits.length,
      itemBuilder: (context, index) {
        final habit = widget.habits[index];
        final todayTracking = _todayTracking[habit.id];

        return HabitCard(
          key: ValueKey('habit_${habit.id}_${todayTracking?.currentValue ?? 0}'),
          habit: habit,
          todayTracking: todayTracking,
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    HabitDetailScreen(habitId: habit.id),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
          },
          onStatusChanged: (status) async {
            context.read<HabitBloc>().add(
                  TrackHabitEvent(
                    habitId: habit.id,
                    status: status,
                  ),
                );
            // Обновляем локальное состояние после небольшой задержки
            await Future.delayed(const Duration(milliseconds: 200));
            _loadTodayTracking();
          },
        );
      },
    );
  }
}


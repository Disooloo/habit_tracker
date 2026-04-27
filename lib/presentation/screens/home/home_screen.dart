import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../bloc/timer/timer_bloc.dart';
import '../../bloc/timer/timer_state.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as habit_date_utils;
import '../../widgets/habit_card.dart';
import '../habit_detail/habit_detail_screen.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/entities/habit_tracking.dart';
import '../../../domain/repositories/habit_repository.dart';
import '../../../services/in_app_notification_service.dart';
import '../../../services/notification_service.dart';
import '../../../services/subscription_service.dart';
import '../../../services/habit_streak_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Habit> _cachedHabits = const [];
  String? _subscriptionHeaderText;
  bool _expirationHandledThisSession = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(const LoadHabits());
      _setupOpenSessionNotifications();
      _refreshSubscriptionHeader();
    });
  }

  Future<void> _setupOpenSessionNotifications() async {
    final inAppService = InAppNotificationService();
    await inAppService.markAppOpenedAndHandleInactivity();
    await _addDailyCheckinQuestion();

    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled =
        prefs.getBool(AppConstants.keyNotificationsEnabled) ?? false;

    if (notificationsEnabled) {
      await NotificationService().scheduleInactivityReminder48h();
      await NotificationService().scheduleDailyDayStartReminder();
    }
  }

  Future<void> _addDailyCheckinQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final key =
        'daily_checkin_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}';
    if (prefs.getBool(key) == true) return;
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final messages = isRu
        ? const [
            'Как сегодня с полезными привычками? Получилось удержать темп?',
            'Как прогресс по отказу от вредных привычек сегодня?',
            'Напомнить: маленький шаг сегодня лучше, чем идеальный завтра.',
          ]
        : const [
            'How are your positive habits going today?',
            'How is your progress on quitting bad habits today?',
            'Reminder: a small step today is better than perfect tomorrow.',
          ];
    await InAppNotificationService()
        .addMessage(messages[now.millisecond % messages.length]);
    await prefs.setBool(key, true);
  }

  Future<void> _refreshSubscriptionHeader() async {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final service = SubscriptionService();
    final plan = await service.getActivePlan();
    final until = await service.getActiveUntil();
    if (!mounted) return;
    setState(() {
      if (plan != null && until != null && until.isAfter(DateTime.now())) {
        _subscriptionHeaderText =
            isRu
                ? '$plan до ${until.day.toString().padLeft(2, '0')}.${until.month.toString().padLeft(2, '0')}.${until.year}'
                : '$plan until ${until.day.toString().padLeft(2, '0')}.${until.month.toString().padLeft(2, '0')}.${until.year}';
      } else {
        _subscriptionHeaderText = isRu ? 'Бесплатная подписка' : 'Free plan';
      }
    });
  }

  Future<void> _handleExpiredSubscriptionIfNeeded(List<Habit> habits) async {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    if (_expirationHandledThisSession) return;
    final prefs = await SharedPreferences.getInstance();
    final untilRaw = prefs.getString(AppConstants.keySubscriptionUntil);
    if (untilRaw == null || untilRaw.isEmpty) return;
    final until = DateTime.tryParse(untilRaw);
    if (until == null || until.isAfter(DateTime.now())) return;

    final token = until.toIso8601String();
    final handledToken = prefs.getString(AppConstants.keySubscriptionExpiredHandled);
    if (handledToken == token) return;

    _expirationHandledThisSession = true;
    await prefs.setBool(AppConstants.keySubscriptionActive, false);
    await prefs.remove(AppConstants.keySubscriptionPlan);
    await prefs.setString(AppConstants.keySubscriptionExpiredHandled, token);
    await _refreshSubscriptionHeader();

    if (!mounted) return;
    final overLimit = habits.length - AppConstants.freeHabitLimit;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isRu ? 'Подписка завершилась' : 'Subscription expired'),
        content: Text(
          overLimit > 0
              ? (isRu
                  ? 'Подписка истекла. Можно оставить до ${AppConstants.freeHabitLimit} привычек. Сейчас лишних: $overLimit.'
                  : 'Subscription expired. You can keep up to ${AppConstants.freeHabitLimit} habits. Extra habits: $overLimit.')
              : (isRu
                  ? 'Подписка истекла. Вы на бесплатном тарифе.'
                  : 'Subscription expired. You are now on the free plan.'),
        ),
        actions: [
          if (overLimit > 0)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final sorted = [...habits]
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
                final toDelete = sorted.skip(AppConstants.freeHabitLimit);
                for (final h in toDelete) {
                  await context.read<HabitBloc>().repository.deleteHabit(h.id);
                }
                if (mounted) {
                  context.read<HabitBloc>().add(const LoadHabits());
                }
              },
              child: Text(isRu ? 'Оставить базовые' : 'Keep basic set'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/subscription');
            },
            child: Text(isRu ? 'Продлить' : 'Renew'),
          ),
        ],
      ),
    );
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
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                final rawName = snapshot.data?.displayName?.trim();
                final firstName = rawName == null || rawName.isEmpty
                    ? null
                    : rawName.split(RegExp(r'\s+')).first;
                if (firstName == null || firstName.isEmpty) {
                  return Text(l10n.hello);
                }
                return Text('${l10n.hello}, $firstName');
              },
            ),
            Text(
              l10n.canStartSmall,
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (_subscriptionHeaderText != null)
              Text(
                _subscriptionHeaderText!,
                style: theme.textTheme.labelSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed('/statistics')
                  .then((_) => context.read<HabitBloc>().add(const LoadHabits()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/diary');
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context)
                  .pushNamed('/settings')
                  .then((_) {
                context.read<HabitBloc>().add(const LoadHabits());
                _refreshSubscriptionHeader();
              });
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
                      child: Text(Localizations.localeOf(context).languageCode.startsWith('ru')
                          ? 'Повторить'
                          : 'Retry'),
                    ),
                  ],
                ),
              );
            }

            // Используем последнее загруженное состояние или текущее
            List<Habit> habits = [];
            if (state is HabitLoaded) {
              habits = state.habits;
              _cachedHabits = habits;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _refreshSubscriptionHeader();
                _handleExpiredSubscriptionIfNeeded(habits);
              });
            } else if (state is HabitLoading && state.habits.isNotEmpty) {
              habits = state.habits; // Используем предыдущие привычки при загрузке
            } else if (state is HabitDetailLoaded && _cachedHabits.isNotEmpty) {
              habits = _cachedHabits;
            } else if (_cachedHabits.isNotEmpty) {
              habits = _cachedHabits;
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
          Navigator.of(context)
              .pushNamed('/habit-form')
              .then((_) => context.read<HabitBloc>().add(const LoadHabits()));
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
  final HabitStreakService _streakService = HabitStreakService();
  String? _maxQuitCounterText;

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

    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    Duration? best;
    for (final habit in widget.habits) {
      if (!_streakService.isLikelyQuitHabit(habit.name)) continue;
      final start = await _streakService.getStartDate(habit.id);
      if (start == null) continue;
      final d = DateTime.now().difference(start);
      if (best == null || d > best) best = d;
    }
    final bestText = best == null
        ? null
        : _streakService.elapsedText(
            DateTime.now().subtract(best),
            DateTime.now(),
            isRu,
          );

    if (mounted) {
      setState(() {
        _todayTracking = trackingMap;
        _maxQuitCounterText = bestText;
      });
    }
  }

  int _calculateSuggestedTarget(int currentTarget) {
    // Мягкое постепенное увеличение: минимум +1, либо +10% (округляя вниз).
    final increase = (currentTarget * 0.1).floor().clamp(1, 999999);
    return currentTarget + increase;
  }

  int? _resolveCurrentValueForStatus({
    required Habit habit,
    required HabitTracking? tracking,
    required String status,
  }) {
    if (habit.targetValue == null) {
      return null;
    }

    final target = habit.targetValue!;
    final existing = tracking?.currentValue ?? 0;

    if (status == AppConstants.statusDone) {
      return target;
    }
    if (status == AppConstants.statusPartial) {
      final partialByTarget = (target * 0.5).ceil();
      return partialByTarget > existing ? partialByTarget : existing;
    }
    return 0;
  }

  void _showGradualIncreaseSuggestion(Habit habit) {
    final currentTarget = habit.targetValue;
    if (currentTarget == null) return;

    final suggestedTarget = _calculateSuggestedTarget(currentTarget);
    final unit = habit.unit == null ? '' : ' ${habit.unit}';
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Отлично! Завтра можно попробовать $suggestedTarget$unit'),
        action: SnackBarAction(
          label: 'Применить',
          onPressed: () {
            context.read<HabitBloc>().add(
                  UpdateHabitEvent(
                    habit.copyWith(targetValue: suggestedTarget),
                  ),
                );
          },
        ),
      ),
    );
  }

  static const List<String> _completionPraise = [
    'Отличный темп! Сегодня закрыто как надо.',
    'Супер! Вы завершили привычку на сегодня.',
    'Классный результат: цель на сегодня выполнена.',
    'Вы молодец! Еще один стабильный день в копилку.',
    'Отличная дисциплина, так держать!',
  ];

  void _showCompletionPraise(Habit habit) {
    final message = _completionPraise[DateTime.now().millisecond % _completionPraise.length];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    InAppNotificationService().addMessage('${habit.name}: $message');
  }

  @override
  Widget build(BuildContext context) {
    final doneCount = _todayTracking.values
        .where((t) => t?.status == AppConstants.statusDone)
        .length;
    final partialCount = _todayTracking.values
        .where((t) => t?.status == AppConstants.statusPartial)
        .length;
    final total = widget.habits.length;

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, timerState) {
        return ListView.builder(
          itemCount: widget.habits.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Localizations.localeOf(context).languageCode.startsWith('ru')
                              ? 'Статистика за сегодня: $doneCount/$total выполнено, $partialCount в процессе'
                              : 'Today: $doneCount/$total done, $partialCount in progress',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (_maxQuitCounterText != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            isRu
                                ? 'Без вредных привычек (максимум): $_maxQuitCounterText'
                                : 'Without bad habits (max): $_maxQuitCounterText',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }

            final habit = widget.habits[index - 1];
            final todayTracking = _todayTracking[habit.id];
            final pausedRemainingSeconds = timerState is TimerPaused && timerState.habitId == habit.id
                ? timerState.remainingSeconds
                : null;

            return Dismissible(
              key: ValueKey('habit_dismiss_${habit.id}'),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) async {
                final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
                return await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(isRu ? 'Удалить привычку?' : 'Delete habit?'),
                        content: Text(
                          isRu
                              ? 'Привычка будет удалена вместе с историей.'
                              : 'The habit and its history will be deleted.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: Text(isRu ? 'Отмена' : 'Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: Text(isRu ? 'Удалить' : 'Delete'),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              },
              onDismissed: (_) {
                context.read<HabitBloc>().add(DeleteHabitEvent(habit.id));
                _loadTodayTracking();
              },
              background: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: HabitCard(
                key: ValueKey('habit_${habit.id}_${todayTracking?.currentValue ?? 0}'),
                habit: habit,
                todayTracking: todayTracking,
                pausedRemainingSeconds: pausedRemainingSeconds,
                onTap: () {
                  Navigator.of(context)
                      .push(
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
                      )
                      .then((_) => context.read<HabitBloc>().add(const LoadHabits()));
                },
                onStatusChanged: (status) async {
                  final currentValue = _resolveCurrentValueForStatus(
                    habit: habit,
                    tracking: todayTracking,
                    status: status,
                  );
                  context.read<HabitBloc>().add(
                        TrackHabitEvent(
                          habitId: habit.id,
                          status: status,
                          currentValue: currentValue,
                        ),
                      );
                  if (status == AppConstants.statusDone) {
                    _showGradualIncreaseSuggestion(habit);
                    _showCompletionPraise(habit);
                  }
                  await Future.delayed(const Duration(milliseconds: 200));
                  _loadTodayTracking();
                },
              ),
            );
          },
        );
      },
    );
  }
}


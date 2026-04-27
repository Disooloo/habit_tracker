import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:habit_tracker/l10n/app_localizations.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../../domain/entities/habit.dart';
import '../../../domain/usecases/get_habit_by_id.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/habit_suggestions.dart';
import '../../../services/subscription_service.dart';
import '../../../data/repositories/habit_repository_impl.dart';
import '../../../services/notification_service.dart';
import '../../../services/in_app_notification_service.dart';
import '../../../services/habit_streak_service.dart';

class HabitFormScreen extends StatefulWidget {
  final int? habitId; // null for create, non-null for edit

  const HabitFormScreen({super.key, this.habitId});

  @override
  State<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends State<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minimalActionController = TextEditingController();
  String _frequency = AppConstants.frequencyDailyOnce;
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;
  Set<int> _selectedReminderDays = {1, 2, 3, 4, 5, 6, 7};
  
  // Количественные/временные цели
  String? _goalType; // 'quantity', 'time', or null
  final _targetValueController = TextEditingController();
  String? _timeUnit; // 'seconds', 'minutes', 'hours' для времени
  String _habitKind = 'build'; // build or quit

  bool _isLoading = false;
  Habit? _existingHabit;
  final HabitStreakService _streakService = HabitStreakService();
  DateTime? _startDate;

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabit();
    }
  }

  Future<void> _syncHabitReminder(Habit habit) async {
    final service = NotificationService();
    if (habit.reminderTime == null || habit.reminderTime!.isEmpty) {
      await service.cancelHabitReminder(habit.id);
      return;
    }
    final granted = await service.requestPermissions();
    if (!granted) return;
    await service.scheduleHabitReminder(
      habitId: habit.id,
      habitName: habit.name,
      timeString: habit.reminderTime,
      weekdays: habit.reminderDays,
    );
  }

  Future<void> _loadHabit() async {
    setState(() => _isLoading = true);
    try {
      final repository = HabitRepositoryImpl();
      final useCase = GetHabitById(repository);
      final habit = await useCase(widget.habitId!);
      if (habit != null) {
        final streakStart = await _streakService.getStartDate(widget.habitId!);
        setState(() {
          _existingHabit = habit;
          _nameController.text = habit.name;
          _minimalActionController.text = habit.minimalAction;
          _frequency = habit.frequency;
          _hasReminder = habit.reminderTime != null;
          _selectedReminderDays = habit.reminderDays?.toSet() ??
              {1, 2, 3, 4, 5, 6, 7};
          if (habit.reminderTime != null) {
            final parts = habit.reminderTime!.split(':');
            _reminderTime = TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }
          _goalType = habit.goalType;
          if (habit.targetValue != null) {
            _targetValueController.text = habit.targetValue.toString();
          }
          if (habit.goalType == 'time' && habit.unit != null) {
            // Определяем единицу времени из сохраненного значения
            if (habit.unit!.contains('секунд') || habit.unit!.contains('second')) {
              _timeUnit = 'seconds';
            } else if (habit.unit!.contains('минут') || habit.unit!.contains('minute')) {
              _timeUnit = 'minutes';
            } else if (habit.unit!.contains('час') || habit.unit!.contains('hour')) {
              _timeUnit = 'hours';
            } else {
              _timeUnit = 'minutes'; // По умолчанию
            }
          }
          _startDate = streakStart;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка загрузки: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minimalActionController.dispose();
    _targetValueController.dispose();
    super.dispose();
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check free limit for new habits
    if (widget.habitId == null) {
      final subscriptionService = SubscriptionService();
      final repository = HabitRepositoryImpl();
      final canCreate = await subscriptionService.canCreateHabit(repository);
      if (!canCreate) {
        if (mounted) {
          _showLimitDialog(context);
        }
        return;
      }
    }

    final habit = Habit(
      id: widget.habitId ?? 0,
      name: _nameController.text.trim(),
      minimalAction: _minimalActionController.text.trim(),
      frequency: _frequency,
      reminderTime: _hasReminder && _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      reminderDays: _hasReminder
          ? (_selectedReminderDays.length == 7
              ? null
              : (_selectedReminderDays.toList()..sort()))
          : null,
      createdAt: _existingHabit?.createdAt ?? DateTime.now(),
      goalType: _goalType,
      targetValue: _targetValueController.text.isNotEmpty
          ? int.tryParse(_targetValueController.text)
          : null,
      unit: _goalType == 'time' && _timeUnit != null
          ? _getTimeUnitText(_timeUnit!)
          : null, // Для количества единица не нужна
    );

    if (widget.habitId == null) {
      context.read<HabitBloc>().add(CreateHabitEvent(habit));
    } else {
      context.read<HabitBloc>().add(UpdateHabitEvent(habit));
    }
  }

  void _showLimitDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.freeLimitReached),
        content: Text(l10n.upgradeToUnlimited),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/settings');
            },
            child: Text(l10n.upgrade),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.edit)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitCreated || state is HabitUpdated) {
          final savedHabit = state is HabitCreated ? state.habit : (state as HabitUpdated).habit;
          if (state is HabitCreated) {
            InAppNotificationService().addMessage(
              'Привычка "${savedHabit.name}" создана. Отличный старт!',
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Привычка "${savedHabit.name}" создана')),
              );
            }
          }
          _syncHabitReminder(savedHabit).then((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
          if (_startDate != null) {
            _streakService.setStartDate(savedHabit.id, _startDate!);
          }
        } else if (state is HabitError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.habitId == null ? l10n.createHabit : l10n.edit),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Предложения привычек (только при создании)
              if (widget.habitId == null) ...[
                Text(isRu ? 'Тип привычки' : 'Habit type', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'build',
                      label: Text(isRu ? 'Развивать' : 'Build'),
                    ),
                    ButtonSegment(
                      value: 'quit',
                      label: Text(isRu ? 'Отказаться' : 'Quit'),
                    ),
                  ],
                  selected: {_habitKind},
                  onSelectionChanged: (Set<String> value) {
                    setState(() {
                      _habitKind = value.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildSuggestionsSection(context),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
              ],
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.habitName,
                  hintText: l10n.habitName,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isRu ? 'Введите название привычки' : 'Enter habit name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minimalActionController,
                decoration: InputDecoration(
                  labelText: l10n.minimalAction,
                  hintText: l10n.minimalActionHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return isRu ? 'Введите минимальное действие' : 'Enter minimal action';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Выбор типа цели
              Text(isRu ? 'Тип цели' : 'Goal type', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String?>(
                segments: [
                  ButtonSegment(
                    value: null,
                    label: Text(isRu ? 'Простая' : 'Simple'),
                  ),
                  ButtonSegment(
                    value: 'quantity',
                    label: Text(isRu ? 'Количество' : 'Quantity'),
                  ),
                  ButtonSegment(
                    value: 'time',
                    label: Text(isRu ? 'Время' : 'Time'),
                  ),
                ],
                selected: {_goalType},
                onSelectionChanged: (Set<String?> newSelection) {
                  setState(() {
                    _goalType = newSelection.first;
                    if (_goalType == null) {
                      _targetValueController.clear();
                      _timeUnit = null;
                    } else if (_goalType == 'time') {
                      _timeUnit = _timeUnit ?? 'minutes'; // По умолчанию минуты
                    }
                  });
                },
              ),
              if (_goalType != null) ...[
                const SizedBox(height: 16),
                if (_goalType == 'time') ...[
                  // Для времени: выбор единицы измерения
                  TextFormField(
                    controller: _targetValueController,
                    decoration: InputDecoration(
                      labelText: isRu ? 'Целевое значение' : 'Target value',
                      hintText: '30',
                      helperText: isRu ? 'Максимум 99 минут' : 'Max 99 minutes',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isRu ? 'Введите значение' : 'Enter value';
                      }
                      final intValue = int.tryParse(value);
                      if (intValue == null) {
                        return isRu ? 'Введите число' : 'Enter a number';
                      }
                      if (_timeUnit == 'minutes' && intValue > 99) {
                        return isRu ? 'Максимум 99 минут' : 'Maximum is 99 minutes';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _timeUnit,
                    decoration: InputDecoration(
                      labelText: isRu ? 'Единица времени' : 'Time unit',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'seconds', child: Text('Seconds')),
                      DropdownMenuItem(value: 'minutes', child: Text('Minutes (max. 99)')),
                      DropdownMenuItem(value: 'hours', child: Text('Hours')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _timeUnit = value;
                      });
                    },
                    validator: (value) {
                      if (_goalType == 'time' && value == null) {
                        return isRu ? 'Выберите единицу времени' : 'Select time unit';
                      }
                      return null;
                    },
                  ),
                ] else if (_goalType == 'quantity') ...[
                  // Для количества: просто подсказка
                  TextFormField(
                    controller: _targetValueController,
                    decoration: InputDecoration(
                      labelText: isRu ? 'Целевое количество' : 'Target quantity',
                      hintText: isRu
                          ? 'Например: 3 стакана, 5 страниц, 10 шагов...'
                          : 'e.g. 3 glasses, 5 pages, 10 steps...',
                      helperText: isRu
                          ? 'Введите число'
                          : 'Enter a number',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return isRu ? 'Введите количество' : 'Enter quantity';
                      }
                      if (int.tryParse(value) == null) {
                        return isRu ? 'Введите число' : 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(isRu ? 'Дата начала привычки' : 'Habit start date'),
                subtitle: Text(
                  _startDate == null
                      ? (isRu ? 'Не выбрана' : 'Not selected')
                      : '${_startDate!.day.toString().padLeft(2, '0')}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.year}',
                ),
                trailing: TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: Text(isRu ? 'Выбрать' : 'Select'),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.frequency, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: AppConstants.frequencyDailyOnce,
                    label: Text(isRu ? '1 раз в день' : 'Once a day'),
                  ),
                  ButtonSegment(
                    value: AppConstants.frequencyDailyMulti,
                    label: Text(isRu ? 'Несколько раз в день' : 'Multiple times a day'),
                  ),
                  ButtonSegment(
                    value: AppConstants.frequencyWeekly,
                    label: Text(isRu ? 'По дням недели' : 'Weekly'),
                  ),
                ],
                selected: {_frequency},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _frequency = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(l10n.reminder),
                value: _hasReminder,
                onChanged: (value) {
                  setState(() {
                    _hasReminder = value;
                    if (value && _reminderTime == null) {
                      _reminderTime = TimeOfDay.now();
                    }
                  });
                },
              ),
              if (_hasReminder) ...[
                const SizedBox(height: 8),
                ListTile(
                  title: Text(l10n.reminderTime),
                  trailing: _reminderTime != null
                      ? Text(
                          '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}',
                        )
                      : null,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime ?? TimeOfDay.now(),
                    );
                    if (time != null) {
                      setState(() {
                        _reminderTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                _buildReminderDaysSelector(context),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveHabit,
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final isRu = languageCode.startsWith('ru');
    final categories = HabitSuggestions.categoriesByKind(_habitKind, languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _habitKind == 'build'
              ? (isRu ? 'Готовые полезные привычки' : 'Ready healthy habits')
              : (isRu ? 'Готовые привычки для отказа' : 'Ready quit habits'),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) {
          final suggestions = HabitSuggestions.getByCategory(
            category,
            _habitKind,
            languageCode,
          );
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ExpansionTile(
              leading: Text(
                suggestions.first.emoji,
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                category,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: suggestions.map((suggestion) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _nameController.text = suggestion.name;
                      _minimalActionController.text = suggestion.minimalAction;
                      _frequency = suggestion.frequency == AppConstants.frequencyDaily
                          ? AppConstants.frequencyDailyOnce
                          : suggestion.frequency;
                      _goalType = suggestion.goalType;
                      if (suggestion.targetValue != null) {
                        _targetValueController.text = suggestion.targetValue.toString();
                      } else {
                        _targetValueController.clear();
                      }

                      if (suggestion.goalType == 'time') {
                        if ((suggestion.unit ?? '').contains('час')) {
                          _timeUnit = 'hours';
                        } else if ((suggestion.unit ?? '').contains('сек')) {
                          _timeUnit = 'seconds';
                        } else {
                          _timeUnit = 'minutes';
                        }
                      } else {
                        _timeUnit = null;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${isRu ? 'Совет' : 'Tip'}: ${suggestion.tip}')),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                suggestion.name,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                suggestion.minimalAction,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isRu ? 'Совет' : 'Tip'}: ${suggestion.tip}',
                                style: theme.textTheme.bodySmall,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getTimeUnitText(String unit) {
    switch (unit) {
      case 'seconds':
        return 'seconds';
      case 'minutes':
        return 'minutes';
      case 'hours':
        return 'hours';
      default:
        return 'minutes';
    }
  }

  Widget _buildReminderDaysSelector(BuildContext context) {
    final isRu = Localizations.localeOf(context).languageCode.startsWith('ru');
    final labels = isRu
        ? const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
        : const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRu ? 'Дни напоминаний' : 'Reminder days',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            final day = index + 1;
            final selected = _selectedReminderDays.contains(day);
            return FilterChip(
              label: Text(labels[index]),
              selected: selected,
              onSelected: (value) {
                setState(() {
                  if (value) {
                    _selectedReminderDays.add(day);
                  } else {
                    if (_selectedReminderDays.length > 1) {
                      _selectedReminderDays.remove(day);
                    }
                  }
                });
              },
            );
          }),
        ),
      ],
    );
  }
}


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
import '../../../domain/repositories/habit_repository.dart';
import '../../../data/repositories/habit_repository_impl.dart';

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
  String _frequency = AppConstants.frequencyDaily;
  bool _hasReminder = false;
  TimeOfDay? _reminderTime;
  
  // Количественные/временные цели
  String? _goalType; // 'quantity', 'time', or null
  final _targetValueController = TextEditingController();
  String? _timeUnit; // 'seconds', 'minutes', 'hours' для времени

  bool _isLoading = false;
  Habit? _existingHabit;

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabit();
    }
  }

  Future<void> _loadHabit() async {
    setState(() => _isLoading = true);
    try {
      final repository = HabitRepositoryImpl();
      final useCase = GetHabitById(repository);
      final habit = await useCase(widget.habitId!);
      if (habit != null) {
        setState(() {
          _existingHabit = habit;
          _nameController.text = habit.name;
          _minimalActionController.text = habit.minimalAction;
          _frequency = habit.frequency;
          _hasReminder = habit.reminderTime != null;
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
            if (habit.unit!.contains('секунд')) {
              _timeUnit = 'seconds';
            } else if (habit.unit!.contains('минут')) {
              _timeUnit = 'minutes';
            } else if (habit.unit!.contains('час')) {
              _timeUnit = 'hours';
            } else {
              _timeUnit = 'minutes'; // По умолчанию
            }
          }
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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.edit)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return BlocListener<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitCreated || state is HabitUpdated) {
          Navigator.of(context).pop();
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
                    return 'Введите название привычки';
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
                    return 'Введите минимальное действие';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Выбор типа цели
              Text('Тип цели', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String?>(
                segments: [
                  ButtonSegment(
                    value: null,
                    label: const Text('Простая'),
                  ),
                  ButtonSegment(
                    value: 'quantity',
                    label: const Text('Количество'),
                  ),
                  ButtonSegment(
                    value: 'time',
                    label: const Text('Время'),
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
                    decoration: const InputDecoration(
                      labelText: 'Целевое значение',
                      hintText: '30',
                      helperText: 'Максимум 99 минут',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите значение';
                      }
                      final intValue = int.tryParse(value);
                      if (intValue == null) {
                        return 'Введите число';
                      }
                      if (_timeUnit == 'minutes' && intValue > 99) {
                        return 'Максимум 99 минут';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _timeUnit,
                    decoration: const InputDecoration(
                      labelText: 'Единица времени',
                    ),
                    items: const [
                      DropdownMenuItem(value: 'seconds', child: Text('Секунды')),
                      DropdownMenuItem(value: 'minutes', child: Text('Минуты (макс. 99)')),
                      DropdownMenuItem(value: 'hours', child: Text('Часы')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _timeUnit = value;
                      });
                    },
                    validator: (value) {
                      if (_goalType == 'time' && value == null) {
                        return 'Выберите единицу времени';
                      }
                      return null;
                    },
                  ),
                ] else if (_goalType == 'quantity') ...[
                  // Для количества: просто подсказка
                  TextFormField(
                    controller: _targetValueController,
                    decoration: const InputDecoration(
                      labelText: 'Целевое количество',
                      hintText: 'Например: 3 стакана, 5 страниц, 10 шагов...',
                      helperText: 'Введите число (единица измерения будет понятна из названия привычки)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите количество';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Введите число';
                      }
                      return null;
                    },
                  ),
                ],
              ],
              const SizedBox(height: 24),
              Text(l10n.frequency, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: AppConstants.frequencyDaily,
                    label: Text(l10n.daily),
                  ),
                  ButtonSegment(
                    value: AppConstants.frequencyWeekly,
                    label: Text(l10n.weekly),
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
    final categories = HabitSuggestions.categories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Готовые привычки',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) {
          final suggestions = HabitSuggestions.getByCategory(category);
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
                    });
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
                              ),
                              const SizedBox(height: 4),
                              Text(
                                suggestion.minimalAction,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
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
        return 'секунд';
      case 'minutes':
        return 'минут';
      case 'hours':
        return 'часов';
      default:
        return 'минут';
    }
  }
}


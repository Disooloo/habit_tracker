import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/habit.dart';
import '../../bloc/habit/habit_bloc.dart';
import '../../bloc/habit/habit_event.dart';
import '../../bloc/habit/habit_state.dart';
import '../../../services/habit_diary_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final _noteController = TextEditingController();
  final HabitDiaryService _diaryService = HabitDiaryService();
  DateTime _selectedDate = DateTime.now();
  List<String> _planned = const [];
  bool _loading = true;

  static const List<String> _templates = [
    'Сегодня было легко начать, потому что...',
    'Самое сложное в привычке сегодня...',
    'Что помогло выполнить план сегодня...',
    'Завтра улучшу это так...',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitBloc>().add(const LoadHabits());
      _loadEntry();
    });
  }

  Future<void> _loadEntry() async {
    final habits = _extractHabits(context.read<HabitBloc>().state);
    final entry = await _diaryService.getOrCreateEntry(
      date: _selectedDate,
      habits: habits,
    );
    if (!mounted) return;
    setState(() {
      _planned = entry.plannedItems;
      _noteController.text = entry.userNote;
      _loading = false;
    });
  }

  List<Habit> _extractHabits(HabitState state) {
    if (state is HabitLoaded) return state.habits;
    if (state is HabitLoading) return state.habits;
    return const [];
  }

  Future<void> _save() async {
    final habits = _extractHabits(context.read<HabitBloc>().state);
    await _diaryService.saveNote(
      date: _selectedDate,
      note: _noteController.text.trim(),
      habits: habits,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Дневник сохранен')),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Дневник привычек'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : BlocListener<HabitBloc, HabitState>(
              listener: (_, __) => _loadEntry(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Дата: $dateText'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365 * 3)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _selectedDate = picked;
                          _loading = true;
                        });
                        await _loadEntry();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Запланировано ${_planned.length} привычек:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._planned.map((e) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(e),
                      )),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Мои заметки за день',
                      hintText: 'Что получилось, что было сложно, мысли на завтра...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _templates
                        .map(
                          (t) => ActionChip(
                            label: Text(
                              t.length > 18 ? '${t.substring(0, 18)}...' : t,
                            ),
                            onPressed: () {
                              final text = _noteController.text;
                              _noteController.text =
                                  text.isEmpty ? t : '$text\n$t';
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить запись'),
                  ),
                ],
              ),
            ),
    );
  }
}


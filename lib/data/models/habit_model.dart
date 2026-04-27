import '../../domain/entities/habit.dart';

class HabitModel extends Habit {
  const HabitModel({
    required super.id,
    required super.name,
    required super.minimalAction,
    required super.frequency,
    super.reminderTime,
    super.reminderDays,
    required super.createdAt,
    super.goalType,
    super.targetValue,
    super.unit,
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as int,
      name: json['name'] as String,
      minimalAction: json['minimal_action'] as String,
      frequency: json['frequency'] as String,
      reminderTime: json['reminder_time'] as String?,
      reminderDays: _parseReminderDays(json['reminder_days'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      goalType: json['goal_type'] as String?,
      targetValue: json['target_value'] as int?,
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'minimal_action': minimalAction,
      'frequency': frequency,
      'reminder_time': reminderTime,
      'reminder_days': _encodeReminderDays(reminderDays),
      'created_at': createdAt.millisecondsSinceEpoch,
      'goal_type': goalType,
      'target_value': targetValue,
      'unit': unit,
    };
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      name: habit.name,
      minimalAction: habit.minimalAction,
      frequency: habit.frequency,
      reminderTime: habit.reminderTime,
      reminderDays: habit.reminderDays,
      createdAt: habit.createdAt,
      goalType: habit.goalType,
      targetValue: habit.targetValue,
      unit: habit.unit,
    );
  }

  static List<int>? _parseReminderDays(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parsed = raw
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .where((d) => d >= 1 && d <= 7)
        .toList()
      ..sort();
    if (parsed.isEmpty) return null;
    return parsed;
  }

  static String? _encodeReminderDays(List<int>? days) {
    if (days == null || days.isEmpty) return null;
    final normalized = [...days]..sort();
    return normalized.join(',');
  }
}



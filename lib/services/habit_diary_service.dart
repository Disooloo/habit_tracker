import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/habit.dart';

class HabitDiaryEntry {
  final String dateKey;
  final String userNote;
  final List<String> plannedItems;

  const HabitDiaryEntry({
    required this.dateKey,
    required this.userNote,
    required this.plannedItems,
  });

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'userNote': userNote,
        'plannedItems': plannedItems,
      };

  factory HabitDiaryEntry.fromJson(Map<String, dynamic> json) {
    return HabitDiaryEntry(
      dateKey: json['dateKey'] as String,
      userNote: json['userNote'] as String? ?? '',
      plannedItems:
          List<String>.from((json['plannedItems'] as List<dynamic>? ?? const [])),
    );
  }
}

class HabitDiaryService {
  static const String _keyPrefix = 'habit_diary_entry_';

  static String dateKeyFromDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  List<String> buildPlannedItems(List<Habit> habits) {
    return habits.map((h) {
      final time = h.reminderTime;
      if (time != null && time.isNotEmpty) {
        return '$time - ${h.name}';
      }
      return h.name;
    }).toList();
  }

  Future<HabitDiaryEntry> getOrCreateEntry({
    required DateTime date,
    required List<Habit> habits,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = dateKeyFromDate(date);
    final raw = prefs.getString('$_keyPrefix$dateKey');
    if (raw == null || raw.isEmpty) {
      final created = HabitDiaryEntry(
        dateKey: dateKey,
        userNote: '',
        plannedItems: buildPlannedItems(habits),
      );
      await prefs.setString(
        '$_keyPrefix$dateKey',
        jsonEncode(created.toJson()),
      );
      return created;
    }
    return HabitDiaryEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveNote({
    required DateTime date,
    required String note,
    required List<Habit> habits,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKey = dateKeyFromDate(date);
    final entry = HabitDiaryEntry(
      dateKey: dateKey,
      userNote: note,
      plannedItems: buildPlannedItems(habits),
    );
    await prefs.setString('$_keyPrefix$dateKey', jsonEncode(entry.toJson()));
  }

  Future<void> clearAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((k) => k.startsWith(_keyPrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}


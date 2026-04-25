import 'package:shared_preferences/shared_preferences.dart';

class HabitStreakService {
  static const String _startPrefix = 'habit_streak_start_';
  static const String _praisePrefix = 'habit_streak_last_praise_day_';

  Future<DateTime?> getStartDate(int habitId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_startPrefix$habitId');
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> setStartDate(int habitId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_startPrefix$habitId', date.toIso8601String());
  }

  bool isLikelyQuitHabit(String habitName) {
    final lower = habitName.toLowerCase();
    return lower.contains('кур') ||
        lower.contains('алког') ||
        lower.contains('сладк') ||
        lower.contains('переед') ||
        lower.contains('соцсет') ||
        lower.contains('smok') ||
        lower.contains('alco') ||
        lower.contains('sweet') ||
        lower.contains('overeat') ||
        lower.contains('social media');
  }

  String elapsedText(DateTime from, DateTime now, bool isRu) {
    final diff = now.difference(from);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;
    if (isRu) {
      return '$days дн $hours ч $minutes мин $seconds сек';
    }
    return '$days d $hours h $minutes m $seconds s';
  }

  Future<String?> maybeBuild24hPraise({
    required int habitId,
    required DateTime from,
    required String habitName,
    required bool isQuitHabit,
    required bool isRu,
  }) async {
    final elapsedDays = DateTime.now().difference(from).inHours ~/ 24;
    if (elapsedDays < 1) return null;
    final prefs = await SharedPreferences.getInstance();
    final key = '$_praisePrefix$habitId';
    final lastPraisedDay = prefs.getInt(key) ?? 0;
    if (elapsedDays <= lastPraisedDay) return null;
    await prefs.setInt(key, elapsedDays);
    if (isRu) {
      return isQuitHabit
          ? 'Отлично! Уже $elapsedDays суток без привычки "$habitName". Так держать!'
          : 'Супер! Уже $elapsedDays суток держите привычку "$habitName".';
    }
    return isQuitHabit
        ? 'Great job! $elapsedDays full days without "$habitName". Keep going!'
        : 'Great consistency! $elapsedDays full days with "$habitName".';
  }
}

